"""
Test script for ML Pipeline - NGX Voice Sales Agent.

This script tests the complete ML training and prediction pipeline
with realistic fitness industry scenarios.
"""

import asyncio
import logging
from typing import Dict, List, Any

from src.services.training.training_data_generator import TrainingDataGenerator
from src.services.training.ml_model_trainer import MLModelTrainer
from src.services.training.ml_prediction_service import MLPredictionService

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

async def test_training_pipeline():
    """Test the training pipeline with synthetic data."""
    print("\n" + "="*50)
    print("TESTING ML TRAINING PIPELINE")
    print("="*50)
    
    # Step 1: Generate training data
    print("\n1. Generating synthetic training data...")
    generator = TrainingDataGenerator()
    dataset = generator.generate_complete_training_dataset()
    
    print(f"   - Generated {len(dataset['objection'])} objection samples")
    print(f"   - Generated {len(dataset['needs'])} needs samples")
    print(f"   - Generated {len(dataset['conversion'])} conversion samples")
    
    # Step 2: Train models
    print("\n2. Training ML models...")
    trainer = MLModelTrainer()
    
    # Train objection model
    print("\n   Training objection prediction model...")
    objection_result = trainer.train_objection_model(dataset["objection"])
    print(f"   ✓ Objection model: {objection_result['model_type']}")
    print(f"     - Accuracy: {objection_result['accuracy']:.2%}")
    print(f"     - F1 Score: {objection_result['f1_score']:.2f}")
    
    # Train needs model
    print("\n   Training needs prediction model...")
    needs_result = trainer.train_needs_model(dataset["needs"])
    print(f"   ✓ Needs model: {needs_result['model_type']}")
    print(f"     - Accuracy: {needs_result['accuracy']:.2%}")
    print(f"     - F1 Score: {needs_result['f1_score']:.2f}")
    
    # Train conversion model
    print("\n   Training conversion prediction model...")
    conversion_result = trainer.train_conversion_model(dataset["conversion"])
    print(f"   ✓ Conversion model: {conversion_result['model_type']}")
    print(f"     - Accuracy: {conversion_result['accuracy']:.2%}")
    print(f"     - F1 Score: {conversion_result['f1_score']:.2f}")
    
    return True

async def test_prediction_scenarios():
    """Test predictions with realistic scenarios."""
    print("\n" + "="*50)
    print("TESTING ML PREDICTIONS")
    print("="*50)
    
    # Initialize prediction service
    ml_service = MLPredictionService()
    
    # Test scenarios
    scenarios = [
        {
            "name": "Price Objection Scenario",
            "messages": [
                {"role": "assistant", "content": "¡Hola! Soy tu asistente de NGX. ¿En qué puedo ayudarte hoy?"},
                {"role": "user", "content": "Hola, tengo un gimnasio pequeño y estoy buscando formas de automatizar la atención a clientes."},
                {"role": "assistant", "content": "¡Perfecto! NGX AGENTS ACCESS es ideal para gimnasios. Incluye 11 agentes que automatizan ventas, seguimiento y más."},
                {"role": "user", "content": "Suena interesante, ¿cuánto cuesta?"},
                {"role": "assistant", "content": "La inversión es de $2,700 MXN al mes, que incluye todos los agentes trabajando 24/7."},
                {"role": "user", "content": "Uff, es muy caro para mi gimnasio. No creo poder pagar tanto al mes."}
            ]
        },
        {
            "name": "High Interest Scenario",
            "messages": [
                {"role": "assistant", "content": "¡Hola! ¿Cómo puedo ayudarte con tu negocio fitness?"},
                {"role": "user", "content": "Hola, vi su publicidad y creo que NGX es justo lo que necesito. Pierdo muchos clientes por no responder rápido."},
                {"role": "assistant", "content": "Me alegra que nos hayas encontrado. NGX responde instantáneamente 24/7 y nunca pierde un lead."},
                {"role": "user", "content": "Perfecto, eso es exactamente lo que necesito. ¿Cómo puedo empezar?"},
                {"role": "assistant", "content": "¡Excelente decisión! Podemos activar tu cuenta hoy mismo. ¿Prefieres pago mensual o anual?"},
                {"role": "user", "content": "Quiero empezar ya. Dame el link de pago para el plan mensual."}
            ]
        },
        {
            "name": "Information Seeking Scenario",
            "messages": [
                {"role": "assistant", "content": "¡Hola! Soy tu asistente NGX. ¿En qué puedo ayudarte?"},
                {"role": "user", "content": "Hola, tengo un box de CrossFit y quiero saber más sobre los agentes de NGX."},
                {"role": "assistant", "content": "¡Genial! NGX incluye 11 agentes especializados en fitness que pueden transformar tu box."},
                {"role": "user", "content": "¿Qué hace cada agente específicamente? ¿Se integran con Mindbody?"},
                {"role": "assistant", "content": "Cada agente tiene una función específica: ventas, nutrición, seguimiento, etc. Y sí, nos integramos con Mindbody."},
                {"role": "user", "content": "¿Pueden agendar clases y manejar pagos? ¿Cómo funciona el soporte?"}
            ]
        }
    ]
    
    for scenario in scenarios:
        print(f"\n\nScenario: {scenario['name']}")
        print("-" * 40)
        
        # Test objection prediction
        objection_result = await ml_service.predict_objections(scenario['messages'])
        print("\nObjection Prediction:")
        if objection_result.get('objections'):
            primary = objection_result.get('primary_objection', 'Unknown')
            confidence = objection_result.get('confidence', 0)
            print(f"  Primary: {primary} (confidence: {confidence:.2%})")
            for obj in objection_result['objections'][:2]:
                print(f"  - {obj['type']}: {obj['confidence']:.2%}")
                if obj['suggested_responses']:
                    print(f"    Response: {obj['suggested_responses'][0][:100]}...")
        else:
            print("  No objections detected")
        
        # Test needs prediction
        needs_result = await ml_service.predict_needs(scenario['messages'])
        print("\nNeeds Prediction:")
        if needs_result.get('needs'):
            primary = needs_result.get('primary_need', 'Unknown')
            confidence = needs_result.get('confidence', 0)
            print(f"  Primary: {primary} (confidence: {confidence:.2%})")
            for need in needs_result['needs'][:2]:
                print(f"  - {need['type']}: {need['confidence']:.2%}")
        else:
            print("  No specific needs detected")
        
        # Test conversion prediction
        conversion_result = await ml_service.predict_conversion(scenario['messages'])
        print("\nConversion Prediction:")
        print(f"  Will Convert: {conversion_result.get('will_convert', False)}")
        print(f"  Probability: {conversion_result.get('probability', 0):.2%}")
        print(f"  Level: {conversion_result.get('conversion_level', 'unknown')}")
        print(f"  Next Action: {conversion_result.get('next_action', 'N/A')}")

async def test_realtime_prediction():
    """Test real-time prediction with a flowing conversation."""
    print("\n" + "="*50)
    print("TESTING REAL-TIME PREDICTIONS")
    print("="*50)
    
    ml_service = MLPredictionService()
    
    # Simulate a real conversation flow
    conversation = []
    
    messages_flow = [
        {"role": "assistant", "content": "¡Hola! Soy tu asistente de NGX. ¿En qué puedo ayudarte hoy?"},
        {"role": "user", "content": "Hola, tengo un estudio de yoga y me cuesta mucho hacer seguimiento a los leads"},
        {"role": "assistant", "content": "Entiendo perfectamente. NGX AGENTS ACCESS puede automatizar completamente tu seguimiento. ¿Cuántos leads manejas al mes?"},
        {"role": "user", "content": "Unos 50-60 leads, pero convierto muy pocos porque no alcanzo a responder a todos"},
        {"role": "assistant", "content": "Con NGX podrías responder al 100% instantáneamente. Nuestros clientes aumentan su conversión 3x. La inversión es de $2,700 MXN mensuales."},
        {"role": "user", "content": "Me interesa pero $2,700 es bastante para mi estudio pequeño. ¿No hay algo más económico?"}
    ]
    
    print("\nConversation Flow Analysis:")
    print("-" * 40)
    
    for i, message in enumerate(messages_flow):
        conversation.append(message)
        
        if message["role"] == "user":
            print(f"\n[Message {i+1}] User: {message['content']}")
            
            # Get predictions after each user message
            conversion = await ml_service.predict_conversion(conversation)
            print(f"  → Conversion Probability: {conversion['probability']:.1%} ({conversion['conversion_level']})")
            
            # Check for objections in last message
            if len(conversation) > 4:
                objections = await ml_service.predict_objections(conversation)
                if objections.get('primary_objection'):
                    print(f"  → Objection Detected: {objections['primary_objection']} ({objections['confidence']:.1%})")

async def main():
    """Run all tests."""
    print("\n🚀 NGX ML PIPELINE TEST SUITE")
    print("=" * 60)
    
    try:
        # Test 1: Training Pipeline
        training_success = await test_training_pipeline()
        
        if training_success:
            # Test 2: Prediction Scenarios
            await test_prediction_scenarios()
            
            # Test 3: Real-time Prediction
            await test_realtime_prediction()
            
        print("\n\n✅ ML PIPELINE TEST COMPLETED SUCCESSFULLY!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n\n❌ ERROR: {e}")
        logger.error(f"Test failed: {e}", exc_info=True)

if __name__ == "__main__":
    asyncio.run(main())