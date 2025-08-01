"""
Test script to demonstrate the predictive services with fallback functionality.
"""

import asyncio
import logging
from datetime import datetime

# Import required services
from src.integrations.supabase.resilient_client import get_resilient_client
from src.services.predictive_model_service import PredictiveModelService
from src.services.nlp_integration_service import NLPIntegrationService
from src.services.objection_prediction_service import ObjectionPredictionService
from src.services.needs_prediction_service import NeedsPredictionService
from src.services.conversion_prediction_service import ConversionPredictionService
from src.services.entity_recognition_service import EntityRecognitionService
from src.services.enhanced_predictive_wrapper import EnhancedPredictiveWrapper
from src.services.training.initialize_models import ModelInitializer

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

async def test_predictive_services():
    """Test the predictive services with sample conversations."""
    
    try:
        # Initialize services
        logger.info("Initializing services...")
        supabase = get_resilient_client()
        predictive_model_service = PredictiveModelService(supabase)
        nlp_service = NLPIntegrationService(supabase)
        entity_service = EntityRecognitionService(supabase)
        
        # Initialize predictive services
        objection_service = ObjectionPredictionService(
            supabase, predictive_model_service, nlp_service
        )
        needs_service = NeedsPredictionService(
            supabase, predictive_model_service, nlp_service, entity_service
        )
        conversion_service = ConversionPredictionService(
            supabase, predictive_model_service, nlp_service
        )
        
        # Create enhanced wrapper
        enhanced_predictor = EnhancedPredictiveWrapper(
            objection_service, needs_service, conversion_service
        )
        
        # Test conversation 1: Price objection
        logger.info("\n=== Test 1: Price Objection ===")
        conversation1 = [
            {"role": "assistant", "content": "¡Hola! Soy tu asistente de NGX. ¿En qué puedo ayudarte hoy?"},
            {"role": "customer", "content": "Hola, estoy buscando un sistema de AI para mi gimnasio"},
            {"role": "assistant", "content": "¡Excelente! NGX ofrece soluciones de AI que automatizan ventas y mejoran la retención de clientes."},
            {"role": "customer", "content": "Suena bien, pero me preocupa el precio. ¿Cuánto cuesta?"}
        ]
        
        result1 = await enhanced_predictor.get_unified_predictions(
            "test_conv_1", conversation1
        )
        print_results("Test 1 - Price Objection", result1)
        
        # Test conversation 2: Information need
        logger.info("\n=== Test 2: Information Need ===")
        conversation2 = [
            {"role": "customer", "content": "Hola, quisiera saber más información sobre sus servicios de AI"},
            {"role": "assistant", "content": "¡Por supuesto! Estaré encantado de ayudarte. ¿Qué aspectos te interesan más?"},
            {"role": "customer", "content": "Me gustaría entender qué funcionalidades incluye exactamente y cómo se integra con mi sistema actual"}
        ]
        
        result2 = await enhanced_predictor.get_unified_predictions(
            "test_conv_2", conversation2
        )
        print_results("Test 2 - Information Need", result2)
        
        # Test conversation 3: High conversion probability
        logger.info("\n=== Test 3: High Conversion ===")
        conversation3 = [
            {"role": "customer", "content": "He estado viendo sus servicios y me parecen muy interesantes"},
            {"role": "assistant", "content": "¡Me alegra mucho! ¿Qué es lo que más te ha llamado la atención?"},
            {"role": "customer", "content": "Definitivamente el ahorro de tiempo en ventas. Quiero empezar cuanto antes"},
            {"role": "assistant", "content": "Perfecto, te puedo guiar con los siguientes pasos"},
            {"role": "customer", "content": "Sí, vamos a hacerlo. ¿Cuál es el siguiente paso?"}
        ]
        
        result3 = await enhanced_predictor.get_unified_predictions(
            "test_conv_3", conversation3
        )
        print_results("Test 3 - High Conversion", result3)
        
        # Test conversation 4: Mixed signals
        logger.info("\n=== Test 4: Mixed Signals ===")
        conversation4 = [
            {"role": "customer", "content": "Estoy evaluando diferentes opciones para automatizar mi gimnasio"},
            {"role": "assistant", "content": "Entiendo, es una decisión importante. ¿Qué aspectos son prioritarios para ti?"},
            {"role": "customer", "content": "Necesito algo confiable pero el precio es importante. ¿Tienen referencias de otros gimnasios?"},
            {"role": "assistant", "content": "Por supuesto, trabajamos con más de 500 gimnasios. Te comparto algunos casos de éxito."},
            {"role": "customer", "content": "Me gustaría ver eso, pero también necesito consultarlo con mi socio"}
        ]
        
        result4 = await enhanced_predictor.get_unified_predictions(
            "test_conv_4", conversation4
        )
        print_results("Test 4 - Mixed Signals", result4)
        
    except Exception as e:
        logger.error(f"Error in test: {e}")
        raise

def print_results(test_name: str, result: Dict):
    """Pretty print test results."""
    print(f"\n{'='*50}")
    print(f"{test_name}")
    print(f"{'='*50}")
    
    # Objections
    print("\nObjections Predicted:")
    if result.get("objections_predicted"):
        for obj in result["objections_predicted"]:
            print(f"  - {obj.get('type', 'Unknown')}: {obj.get('confidence', 0):.2f} confidence")
            if obj.get('suggested_responses'):
                print(f"    Suggested: {obj['suggested_responses'][0][:60]}...")
    else:
        print("  None detected")
    
    # Needs
    print("\nNeeds Detected:")
    if result.get("needs_detected"):
        for need in result["needs_detected"]:
            print(f"  - {need.get('category', 'Unknown')}: {need.get('confidence', 0):.2f} confidence")
            actions = need.get('suggested_actions', [])
            if actions:
                print(f"    Action: {actions[0].get('action', 'N/A')}")
    else:
        print("  None detected")
    
    # Conversion
    print(f"\nConversion Probability: {result.get('conversion_probability', 0):.2%}")
    print(f"Conversion Category: {result.get('conversion_category', 'unknown')}")
    
    # Recommendations
    print("\nRecommended Actions:")
    if result.get("recommended_actions"):
        for i, action in enumerate(result["recommended_actions"][:3], 1):
            print(f"  {i}. {action.get('description', 'N/A')} [{action.get('priority', 'medium')}]")
    else:
        print("  No specific recommendations")
    
    # Sources
    sources = result.get("prediction_sources", {})
    if sources:
        print(f"\nPrediction Sources: {sources}")

async def initialize_and_test():
    """Initialize models and run tests."""
    print("\n" + "="*60)
    print("NGX Predictive Services Test")
    print("="*60)
    
    # Option 1: Initialize models with training data
    print("\nOption 1: Initialize models with training data (recommended for production)")
    print("Run: python -m src.services.training.initialize_models")
    
    # Option 2: Run tests with fallback predictor
    print("\nOption 2: Testing with fallback predictor (immediate results)")
    await test_predictive_services()

if __name__ == "__main__":
    asyncio.run(initialize_and_test())