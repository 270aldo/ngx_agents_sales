#!/usr/bin/env python3
"""
Script para verificar la integridad del esquema ML en Supabase.
"""

import asyncio
import os
from dotenv import load_dotenv
from supabase import create_client, Client
from datetime import datetime
import json

# Cargar variables de entorno
load_dotenv()

# Definir esquema esperado para tablas críticas
EXPECTED_SCHEMA = {
    "ml_experiments": [
        "experiment_id", "experiment_name", "experiment_type", "variants",
        "status", "is_active", "conversation_id", "user_id"
    ],
    "experiment_results": [
        "id", "experiment_id", "variant_id", "conversation_id",
        "metric_name", "metric_value", "success"
    ],
    "conversation_outcomes": [
        "outcome_id", "conversation_id", "outcome", "strategies_used",
        "experiment_assignments", "ml_predictions", "ab_test_assignments"
    ],
    "ab_test_variants": [
        "id", "experiment_id", "variant_id", "variant_name",
        "is_control", "is_active", "ucb_score"
    ],
    "pattern_recognitions": [
        "id", "pattern_type", "pattern_name", "confidence_score",
        "effectiveness_score", "is_active"
    ]
}

async def check_table_columns(supabase: Client, table_name: str, expected_columns: list):
    """Verificar que una tabla tenga las columnas esperadas."""
    print(f"\n📋 Verificando tabla: {table_name}")
    print("-" * 50)
    
    issues = []
    
    try:
        # Hacer query para obtener una fila
        result = supabase.table(table_name).select("*").limit(1).execute()
        
        if result.data and len(result.data) > 0:
            actual_columns = set(result.data[0].keys())
            expected_set = set(expected_columns)
            
            # Columnas faltantes
            missing = expected_set - actual_columns
            if missing:
                issues.append(f"Columnas faltantes: {', '.join(missing)}")
                print(f"❌ Faltan columnas: {', '.join(missing)}")
            
            # Columnas extras (informativo)
            extra = actual_columns - expected_set
            if extra:
                print(f"ℹ️  Columnas adicionales: {', '.join(extra)}")
            
            if not missing:
                print(f"✅ Todas las columnas críticas están presentes")
        else:
            # Tabla vacía, intentar con estructura mínima
            print("⚠️  Tabla vacía - no se puede verificar estructura completa")
            
    except Exception as e:
        issues.append(f"Error al verificar tabla: {str(e)[:100]}")
        print(f"❌ Error: {str(e)[:100]}...")
    
    return issues

async def check_relationships(supabase: Client):
    """Verificar relaciones entre tablas."""
    print("\n🔗 Verificando relaciones entre tablas")
    print("-" * 50)
    
    issues = []
    
    # Verificar si hay conversaciones con outcomes
    try:
        conv_result = supabase.table("conversations").select("conversation_id").limit(5).execute()
        
        if conv_result.data:
            conv_ids = [c['conversation_id'] for c in conv_result.data]
            
            # Buscar outcomes relacionados
            outcome_result = supabase.table("conversation_outcomes")\
                .select("conversation_id")\
                .in_("conversation_id", conv_ids)\
                .execute()
            
            print(f"✅ Conversaciones con outcomes: {len(outcome_result.data) if outcome_result.data else 0}/{len(conv_ids)}")
            
            # Buscar experimentos relacionados
            exp_result = supabase.table("ml_experiments")\
                .select("experiment_id")\
                .limit(5)\
                .execute()
            
            if exp_result.data:
                print(f"✅ Experimentos ML encontrados: {len(exp_result.data)}")
            else:
                issues.append("No hay experimentos ML creados")
                print("⚠️  No hay experimentos ML creados")
                
    except Exception as e:
        issues.append(f"Error verificando relaciones: {str(e)}")
        print(f"❌ Error: {str(e)[:100]}...")
    
    return issues

async def check_data_integrity(supabase: Client):
    """Verificar integridad de datos."""
    print("\n🔍 Verificando integridad de datos")
    print("-" * 50)
    
    issues = []
    
    # Verificar predictive_models
    try:
        models_result = supabase.table("predictive_models")\
            .select("name, model_type, is_active")\
            .execute()
        
        if models_result.data:
            active_models = [m for m in models_result.data if m.get('is_active')]
            print(f"✅ Modelos predictivos: {len(models_result.data)} total, {len(active_models)} activos")
            
            # Verificar tipos de modelos esperados
            model_types = set(m['model_type'] for m in models_result.data)
            expected_types = {'objection_prediction', 'needs_prediction', 'conversion_prediction', 'decision_engine'}
            missing_types = expected_types - model_types
            
            if missing_types:
                issues.append(f"Tipos de modelo faltantes: {', '.join(missing_types)}")
                print(f"⚠️  Tipos de modelo faltantes: {', '.join(missing_types)}")
        else:
            issues.append("No hay modelos predictivos configurados")
            print("❌ No hay modelos predictivos configurados")
            
    except Exception as e:
        print(f"❌ Error verificando modelos: {str(e)[:100]}...")
    
    return issues

async def generate_fix_script(all_issues):
    """Generar script SQL para corregir problemas encontrados."""
    if not all_issues:
        return
    
    print("\n📝 Generando script de corrección...")
    
    with open("fix_ml_schema_issues.sql", 'w') as f:
        f.write("-- =====================================================================\n")
        f.write("-- SCRIPT DE CORRECCIÓN DE ESQUEMA ML\n")
        f.write(f"-- Generado: {datetime.now().isoformat()}\n")
        f.write("-- =====================================================================\n\n")
        
        for issue in all_issues:
            f.write(f"-- TODO: {issue}\n")
        
        f.write("\n-- Aplicar migración 012 para corregir estructura:\n")
        f.write("-- 1. Ejecutar scripts/migrations/012_ml_tracking_schema_fix.sql\n")
        f.write("-- 2. Verificar nuevamente con este script\n")
    
    print("✅ Script de corrección generado: fix_ml_schema_issues.sql")

async def main():
    """Función principal."""
    # Crear cliente Supabase
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_ANON_KEY")
    
    if not url or not key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configuradas")
        return
        
    supabase: Client = create_client(url, key)
    
    print("🔍 Verificación de Integridad del Esquema ML")
    print("=" * 60)
    print(f"URL: {url}")
    print(f"Fecha: {datetime.now().isoformat()}")
    
    all_issues = []
    
    # Verificar esquema de cada tabla crítica
    for table, columns in EXPECTED_SCHEMA.items():
        issues = await check_table_columns(supabase, table, columns)
        all_issues.extend(issues)
    
    # Verificar relaciones
    rel_issues = await check_relationships(supabase)
    all_issues.extend(rel_issues)
    
    # Verificar integridad de datos
    data_issues = await check_data_integrity(supabase)
    all_issues.extend(data_issues)
    
    # Resumen final
    print("\n" + "=" * 60)
    print("📊 RESUMEN DE VERIFICACIÓN")
    print("=" * 60)
    
    if all_issues:
        print(f"\n⚠️  Se encontraron {len(all_issues)} problemas:")
        for i, issue in enumerate(all_issues, 1):
            print(f"{i}. {issue}")
        
        await generate_fix_script(all_issues)
        
        print("\n📌 ACCIONES RECOMENDADAS:")
        print("1. Ejecutar la migración 012_ml_tracking_schema_fix.sql")
        print("2. Revisar el archivo fix_ml_schema_issues.sql")
        print("3. Ejecutar este script nuevamente para confirmar")
    else:
        print("\n✅ No se encontraron problemas críticos")
        print("El esquema ML está correctamente configurado")

if __name__ == "__main__":
    asyncio.run(main())