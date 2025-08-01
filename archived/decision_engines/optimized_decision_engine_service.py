"""
Versión optimizada del DecisionEngineService con caché multi-capa
y mejoras de rendimiento para lograr <500ms P95.
"""

import asyncio
import time
import logging
from typing import Dict, List, Any, Optional, Tuple
from datetime import datetime
from contextlib import asynccontextmanager
import json

from src.services.decision_engine_service import DecisionEngineService
from src.services.cache.decision_cache import DecisionCacheLayer
from src.integrations.supabase.resilient_client import ResilientSupabaseClient
from src.services.predictive_model_service import PredictiveModelService
from src.services.nlp_integration_service import NLPIntegrationService
from src.services.objection_prediction_service import ObjectionPredictionService
from src.services.needs_prediction_service import NeedsPredictionService
from src.services.conversion_prediction_service import ConversionPredictionService

logger = logging.getLogger(__name__)


class PerformanceMonitor:
    """Monitor de rendimiento para tracking de métricas."""
    
    def __init__(self):
        self.metrics = {
            "latencies": [],
            "cache_hits": 0,
            "cache_misses": 0,
            "errors": 0
        }
    
    @asynccontextmanager
    async def track_latency(self, operation: str):
        """Context manager para tracking de latencia."""
        start_time = time.perf_counter()
        
        try:
            yield
        finally:
            duration = (time.perf_counter() - start_time) * 1000  # ms
            self.metrics["latencies"].append({
                "operation": operation,
                "duration_ms": duration,
                "timestamp": datetime.now().isoformat()
            })
            
            if duration > 500:
                logger.warning(f"Operación {operation} tomó {duration:.2f}ms (>500ms objetivo)")


class OptimizedDecisionEngineService(DecisionEngineService):
    """
    Versión optimizada del DecisionEngineService con:
    - Cache multi-capa (L1 memoria, L2 Redis)
    - Paralelización mejorada
    - Pruning de árboles de decisión
    - Monitoreo de rendimiento
    - Timeouts y circuit breakers
    """
    
    def __init__(self,
                 supabase: ResilientSupabaseClient,
                 predictive_model_service: PredictiveModelService,
                 nlp_integration_service: NLPIntegrationService,
                 objection_prediction_service: ObjectionPredictionService,
                 needs_prediction_service: NeedsPredictionService,
                 conversion_prediction_service: ConversionPredictionService,
                 redis_client=None,
                 enable_cache: bool = True):
        """
        Inicializa el servicio optimizado.
        
        Args:
            Mismos parámetros que DecisionEngineService más:
            redis_client: Cliente Redis para cache L2
            enable_cache: Si habilitar el sistema de cache
        """
        super().__init__(
            supabase=supabase,
            predictive_model_service=predictive_model_service,
            nlp_integration_service=nlp_integration_service,
            objection_prediction_service=objection_prediction_service,
            needs_prediction_service=needs_prediction_service,
            conversion_prediction_service=conversion_prediction_service
        )
        
        # Sistema de cache
        self.cache_enabled = enable_cache
        self.cache = DecisionCacheLayer(
            redis_client=redis_client,
            enable_l2=redis_client is not None
        ) if enable_cache else None
        
        # Monitor de rendimiento
        self.monitor = PerformanceMonitor()
        
        # Configuración de timeouts
        self.prediction_timeout = 1.0  # 1 segundo para predicciones
        self.total_timeout = 2.0  # 2 segundos total
        
        # Cache de parámetros del modelo (actualizado cada hora)
        self._cached_model_params = None
        self._model_params_timestamp = 0
        self._model_params_ttl = 3600  # 1 hora
    
    async def get_model_parameters(self) -> Dict[str, Any]:
        """Obtiene parámetros del modelo con cache."""
        current_time = time.time()
        
        # Verificar cache local
        if (self._cached_model_params and 
            current_time - self._model_params_timestamp < self._model_params_ttl):
            return self._cached_model_params
        
        # Obtener parámetros del modelo de la base de datos
        try:
            model = await self.predictive_model_service.get_model(self.model_name)
            if model and "parameters" in model:
                params = json.loads(model["parameters"])
            else:
                # Usar parámetros por defecto si no existe el modelo
                params = {
                    "objective_weights": {
                        "need_satisfaction": 0.35,
                        "objection_handling": 0.25,
                        "conversion_progress": 0.4
                    },
                    "exploration_rate": 0.2,
                    "adaptation_threshold": 0.3,
                    "max_tree_depth": 5,
                    "min_confidence": 0.6,
                    "context_window": 15
                }
        except Exception as e:
            logger.error(f"Error al obtener parámetros del modelo: {e}")
            # Usar parámetros por defecto en caso de error
            params = {
                "objective_weights": {
                    "need_satisfaction": 0.35,
                    "objection_handling": 0.25,
                    "conversion_progress": 0.4
                },
                "exploration_rate": 0.2,
                "adaptation_threshold": 0.3,
                "max_tree_depth": 5,
                "min_confidence": 0.6,
                "context_window": 15
            }
        
        # Actualizar cache local
        self._cached_model_params = params
        self._model_params_timestamp = current_time
        
        return params
    
    async def optimize_conversation_flow(self,
                                       conversation_id: str,
                                       messages: List[Dict[str, Any]],
                                       customer_profile: Optional[Dict[str, Any]] = None,
                                       current_objectives: Optional[Dict[str, float]] = None) -> Dict[str, Any]:
        """
        Versión optimizada con cache y timeouts.
        """
        async with self.monitor.track_latency("optimize_flow_total"):
            try:
                # Generar clave de cache
                cache_key = None
                if self.cache_enabled and self.cache:
                    profile_hash = self.cache._compute_hash(customer_profile)
                    objectives_hash = self.cache._compute_hash(current_objectives)
                    
                    cache_key = self.cache.generate_cache_key(
                        cache_type="flow_optimization",
                        conversation_id=conversation_id,
                        message_count=len(messages),
                        customer_profile_hash=profile_hash,
                        objectives_hash=objectives_hash
                    )
                    
                    # Intentar obtener de cache
                    cached_result = await self.cache.get("flow_optimization", cache_key)
                    if cached_result:
                        self.monitor.metrics["cache_hits"] += 1
                        logger.debug(f"Cache hit para {cache_key}")
                        return cached_result
                    else:
                        self.monitor.metrics["cache_misses"] += 1
                
                # Si no hay cache o miss, computar
                result = await self._compute_optimization_with_timeout(
                    conversation_id=conversation_id,
                    messages=messages,
                    customer_profile=customer_profile,
                    current_objectives=current_objectives
                )
                
                # Guardar en cache
                if cache_key and self.cache_enabled and self.cache:
                    await self.cache.set("flow_optimization", cache_key, result)
                
                return result
                
            except asyncio.TimeoutError:
                logger.error(f"Timeout en optimize_conversation_flow para {conversation_id}")
                return self._get_fallback_response()
            except Exception as e:
                logger.error(f"Error en optimize_conversation_flow: {e}")
                self.monitor.metrics["errors"] += 1
                return self._get_fallback_response()
    
    async def _compute_optimization_with_timeout(self,
                                               conversation_id: str,
                                               messages: List[Dict[str, Any]],
                                               customer_profile: Optional[Dict[str, Any]],
                                               current_objectives: Optional[Dict[str, float]]) -> Dict[str, Any]:
        """Computa optimización con timeout."""
        async with asyncio.timeout(self.total_timeout):
            await self.initialize()
            
            if not messages:
                return {
                    "next_actions": [],
                    "confidence": 0,
                    "decision_tree": {}
                }
            
            # Obtener parámetros (cacheados)
            model_params = await self.get_model_parameters()
            min_confidence = model_params.get("min_confidence", 0.6)
            
            objective_weights = current_objectives or model_params.get("objective_weights", {
                "need_satisfaction": 0.35,
                "objection_handling": 0.25,
                "conversion_progress": 0.4
            })
            
            # Obtener predicciones en paralelo con timeout individual
            predictions = await self._get_predictions_parallel_optimized(
                conversation_id=conversation_id,
                messages=messages,
                customer_profile=customer_profile
            )
            
            # Generar árbol de decisión optimizado
            decision_tree = await self._generate_decision_tree_optimized(
                objection_prediction=predictions.get("objection", {}),
                needs_prediction=predictions.get("needs", {}),
                conversion_prediction=predictions.get("conversion", {}),
                objective_weights=objective_weights,
                customer_profile=customer_profile
            )
            
            # Determinar acciones con pruning
            next_actions = await self._determine_next_actions_optimized(
                decision_tree=decision_tree,
                objective_weights=objective_weights,
                min_confidence=min_confidence
            )
            
            # Calcular confianza
            confidence = sum([action.get("confidence", 0) for action in next_actions]) / max(1, len(next_actions))
            
            # Preparar resultado (versión ligera del árbol)
            result = {
                "next_actions": next_actions,
                "confidence": confidence,
                "decision_tree": self._prune_tree_for_response(decision_tree),
                "timestamp": datetime.now().isoformat()
            }
            
            # Almacenar predicción de forma asíncrona (no bloquear)
            asyncio.create_task(self._store_prediction_async(
                conversation_id=conversation_id,
                result=result,
                confidence=confidence
            ))
            
            return result
    
    async def _get_predictions_parallel_optimized(self,
                                                conversation_id: str,
                                                messages: List[Dict[str, Any]],
                                                customer_profile: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """Obtiene predicciones en paralelo con timeout y manejo de errores."""
        async with self.monitor.track_latency("get_predictions_parallel"):
            # Crear tareas con timeout individual
            tasks = {
                "objection": asyncio.create_task(
                    self._get_prediction_with_timeout(
                        self.objection_service.predict_objections,
                        conversation_id, messages, customer_profile,
                        "objection"
                    )
                ),
                "needs": asyncio.create_task(
                    self._get_prediction_with_timeout(
                        self.needs_service.predict_needs,
                        conversation_id, messages, customer_profile,
                        "needs"
                    )
                ),
                "conversion": asyncio.create_task(
                    self._get_prediction_with_timeout(
                        self.conversion_service.predict_conversion,
                        conversation_id, messages, customer_profile,
                        "conversion"
                    )
                )
            }
            
            # Esperar todas las tareas
            results = {}
            for name, task in tasks.items():
                try:
                    results[name] = await task
                except Exception as e:
                    logger.warning(f"Error en predicción {name}: {e}")
                    results[name] = self._get_default_prediction(name)
            
            return results
    
    async def _get_prediction_with_timeout(self,
                                         prediction_func,
                                         conversation_id: str,
                                         messages: List[Dict[str, Any]],
                                         customer_profile: Optional[Dict[str, Any]],
                                         prediction_type: str) -> Dict[str, Any]:
        """Obtiene una predicción con timeout."""
        try:
            async with asyncio.timeout(self.prediction_timeout):
                # Intentar cache primero
                if self.cache_enabled and self.cache:
                    cache_key = self.cache.generate_cache_key(
                        cache_type="predictions",
                        conversation_id=conversation_id,
                        message_count=len(messages),
                        prediction_type=prediction_type
                    )
                    
                    cached = await self.cache.get("predictions", cache_key)
                    if cached:
                        return cached
                
                # Computar predicción
                result = await prediction_func(
                    conversation_id=conversation_id,
                    messages=messages,
                    customer_profile=customer_profile
                )
                
                # Cachear resultado
                if self.cache_enabled and self.cache and cache_key:
                    await self.cache.set("predictions", cache_key, result)
                
                return result
                
        except asyncio.TimeoutError:
            logger.warning(f"Timeout en predicción {prediction_type}")
            return self._get_default_prediction(prediction_type)
    
    async def _generate_decision_tree_optimized(self,
                                              objection_prediction: Dict[str, Any],
                                              needs_prediction: Dict[str, Any],
                                              conversion_prediction: Dict[str, Any],
                                              objective_weights: Dict[str, float],
                                              customer_profile: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Genera árbol de decisión optimizado con pruning."""
        # Usar implementación base pero con límites
        tree = await super()._generate_decision_tree(
            objection_prediction=objection_prediction,
            needs_prediction=needs_prediction,
            conversion_prediction=conversion_prediction,
            objective_weights=objective_weights,
            customer_profile=customer_profile
        )
        
        # Aplicar pruning para reducir tamaño
        self._prune_decision_tree(tree, max_depth=3, min_score=0.3)
        
        return tree
    
    def _prune_decision_tree(self, node: Dict[str, Any], max_depth: int = 3, 
                            min_score: float = 0.3, current_depth: int = 0) -> None:
        """Poda el árbol de decisión para mejorar rendimiento."""
        if current_depth >= max_depth:
            node["children"] = []
            return
        
        # Filtrar hijos con score bajo
        if "children" in node:
            node["children"] = [
                child for child in node["children"]
                if child.get("score", 0) >= min_score
            ]
            
            # Recursivamente podar hijos
            for child in node["children"]:
                self._prune_decision_tree(child, max_depth, min_score, current_depth + 1)
    
    def _prune_tree_for_response(self, tree: Dict[str, Any]) -> Dict[str, Any]:
        """Crea versión ligera del árbol para la respuesta."""
        def prune_node(node: Dict[str, Any], depth: int = 0) -> Dict[str, Any]:
            # Limitar profundidad para respuesta
            if depth > 2:
                return {
                    "id": node.get("id"),
                    "type": node.get("type"),
                    "score": node.get("score", 0)
                }
            
            pruned = {
                "id": node.get("id"),
                "type": node.get("type"),
                "description": node.get("description"),
                "score": node.get("score", 0),
                "confidence": node.get("confidence", 0)
            }
            
            # Solo incluir mejores hijos
            if "children" in node and node["children"]:
                sorted_children = sorted(
                    node["children"],
                    key=lambda x: x.get("score", 0),
                    reverse=True
                )[:3]  # Top 3 hijos
                
                pruned["children"] = [
                    prune_node(child, depth + 1)
                    for child in sorted_children
                ]
            
            return pruned
        
        return prune_node(tree)
    
    async def _determine_next_actions_optimized(self,
                                              decision_tree: Dict[str, Any],
                                              objective_weights: Dict[str, float],
                                              min_confidence: float) -> List[Dict[str, Any]]:
        """Determina acciones de forma optimizada."""
        # Usar implementación base pero limitar resultados
        actions = await super()._determine_next_actions(
            decision_tree=decision_tree,
            objective_weights=objective_weights,
            min_confidence=min_confidence
        )
        
        # Limitar a top 3 acciones para reducir payload
        return actions[:3]
    
    def _get_default_prediction(self, prediction_type: str) -> Dict[str, Any]:
        """Retorna predicción por defecto para casos de error/timeout."""
        defaults = {
            "objection": {
                "objections": [],
                "probability": 0.1,
                "confidence": 0.5
            },
            "needs": {
                "needs": [],
                "confidence": 0.5
            },
            "conversion": {
                "probability": 0.3,
                "category": "medium",
                "confidence": 0.5,
                "recommendations": []
            }
        }
        return defaults.get(prediction_type, {})
    
    def _get_fallback_response(self) -> Dict[str, Any]:
        """Respuesta de fallback para casos de error."""
        return {
            "next_actions": [
                {
                    "type": "exploration",
                    "action": "explore_needs",
                    "description": "Continuar explorando las necesidades del cliente",
                    "priority": "high",
                    "confidence": 0.6,
                    "score": 0.6
                }
            ],
            "confidence": 0.6,
            "decision_tree": {
                "id": "fallback",
                "type": "root",
                "description": "Respuesta de contingencia",
                "children": []
            },
            "timestamp": datetime.now().isoformat(),
            "fallback": True
        }
    
    async def _store_prediction_async(self,
                                    conversation_id: str,
                                    result: Dict[str, Any],
                                    confidence: float) -> None:
        """Almacena predicción de forma asíncrona sin bloquear."""
        try:
            await self.store_prediction(
                conversation_id=conversation_id,
                prediction_type="flow_optimization",
                prediction_data=result,
                confidence=confidence
            )
        except Exception as e:
            logger.error(f"Error al almacenar predicción: {e}")
    
    async def get_performance_metrics(self) -> Dict[str, Any]:
        """Obtiene métricas de rendimiento del servicio."""
        metrics = {
            "monitor": {
                "total_requests": len(self.monitor.metrics["latencies"]),
                "cache_hits": self.monitor.metrics["cache_hits"],
                "cache_misses": self.monitor.metrics["cache_misses"],
                "errors": self.monitor.metrics["errors"]
            }
        }
        
        # Calcular percentiles de latencia
        if self.monitor.metrics["latencies"]:
            latencies = [m["duration_ms"] for m in self.monitor.metrics["latencies"]]
            latencies.sort()
            n = len(latencies)
            
            metrics["latency"] = {
                "p50": latencies[int(n * 0.5)],
                "p90": latencies[int(n * 0.9)],
                "p95": latencies[int(n * 0.95)],
                "p99": latencies[int(n * 0.99)] if n > 99 else latencies[-1],
                "avg": sum(latencies) / n,
                "min": min(latencies),
                "max": max(latencies)
            }
        
        # Métricas de cache
        if self.cache_enabled and self.cache:
            metrics["cache"] = self.cache.get_stats()
        
        return metrics
    
    async def warmup_cache(self) -> None:
        """Pre-calienta el cache con datos comunes."""
        if not self.cache_enabled or not self.cache:
            return
        
        logger.info("Iniciando precalentamiento de cache...")
        
        # Cachear parámetros del modelo
        model_params = await self.get_model_parameters()
        
        # Aquí se pueden añadir más queries comunes para pre-cachear
        common_queries = [
            {
                "cache_type": "model_params",
                "key": "ngx:decision:model_params:global",
                "value": model_params
            }
        ]
        
        await self.cache.warmup(common_queries)
        
        logger.info("Precalentamiento de cache completado")