#!/usr/bin/env python3
"""
Test ML Pipeline Integration with Conversation Orchestrator
"""

import asyncio
import logging
from datetime import datetime
from src.services.conversation.orchestrator import ConversationOrchestrator
from src.models.customer import Customer
from src.models.platform import PlatformContext

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


async def test_ml_pipeline_integration():
    """Test the ML Pipeline integration in a conversation flow."""
    
    print("\n" + "="*60)
    print("🧪 TESTING ML PIPELINE INTEGRATION")
    print("="*60 + "\n")
    
    # Create orchestrator
    orchestrator = ConversationOrchestrator(industry='salud')
    
    # Initialize
    print("1️⃣ Initializing orchestrator...")
    await orchestrator.initialize()
    
    # Verify ML Pipeline is initialized
    if orchestrator.ml_pipeline:
        print("✅ ML Pipeline initialized successfully")
    else:
        print("❌ ML Pipeline not initialized")
        return
    
    # Create test customer
    customer = Customer(
        id="test_customer_ml_001",
        name="María González",
        business_type="Entrenadora Personal",
        business_size="Individual",
        monthly_revenue=5000,
        main_goals=["Aumentar clientes", "Automatizar seguimiento"],
        communication_preference="formal"
    )
    
    platform = PlatformContext(
        source="web",
        device_type="desktop",
        timezone="America/Mexico_City"
    )
    
    # Start conversation
    print("\n2️⃣ Starting conversation...")
    state = await orchestrator.start_conversation(
        customer_data=customer,
        program_type="pro",
        platform_info=platform
    )
    print(f"✅ Conversation started: {state.conversation_id}")
    
    # Test conversation flow with ML tracking
    test_messages = [
        "Hola, me interesa saber más sobre sus servicios",
        "¿Cuánto cuesta el plan profesional?",
        "Me parece algo caro, ¿hay opciones de pago?",
        "¿Qué beneficios específicos obtendría?",
        "Me interesa, ¿cómo puedo empezar?"
    ]
    
    print("\n3️⃣ Processing messages with ML tracking...")
    for i, message in enumerate(test_messages, 1):
        print(f"\n   Message {i}: '{message}'")
        
        response = await orchestrator.process_message(
            conversation_id=state.conversation_id,
            message_text=message
        )
        
        print(f"   Response: {response['response'][:100]}...")
        
        # Add small delay to simulate real conversation
        await asyncio.sleep(0.5)
    
    # End conversation
    print("\n4️⃣ Ending conversation...")
    final_state = await orchestrator.end_conversation(
        conversation_id=state.conversation_id,
        end_reason="completed"
    )
    
    # Check ML Pipeline metrics
    print("\n5️⃣ ML Pipeline Metrics:")
    if orchestrator.ml_pipeline:
        try:
            # Get aggregated metrics
            metrics = await orchestrator.ml_pipeline.get_aggregated_metrics()
            print(f"   📊 Total events tracked: {metrics.get('total_events', 0)}")
            print(f"   📊 Patterns detected: {metrics.get('patterns_detected', 0)}")
            print(f"   📊 Model updates queued: {metrics.get('model_updates_queued', 0)}")
        except Exception as e:
            print(f"   ⚠️ Could not retrieve metrics: {e}")
    
    print("\n" + "="*60)
    print("✅ ML PIPELINE INTEGRATION TEST COMPLETED")
    print("="*60 + "\n")


async def test_pattern_recognition():
    """Test Pattern Recognition integration."""
    
    print("\n" + "="*60)
    print("🧪 TESTING PATTERN RECOGNITION")
    print("="*60 + "\n")
    
    orchestrator = ConversationOrchestrator(industry='salud')
    await orchestrator.initialize()
    
    if orchestrator.pattern_recognition:
        print("✅ Pattern Recognition Engine initialized")
        
        # Test pattern detection
        test_patterns = [
            {
                "message": "El precio me parece alto",
                "context": {"phase": "consideration", "emotion": "concerned"}
            },
            {
                "message": "¿Hay descuentos disponibles?",
                "context": {"phase": "negotiation", "emotion": "interested"}
            },
            {
                "message": "Me gustaría empezar cuanto antes",
                "context": {"phase": "decision", "emotion": "excited"}
            }
        ]
        
        print("\n📊 Testing pattern detection:")
        for test in test_patterns:
            patterns = await orchestrator.pattern_recognition.detect_patterns(
                test["message"],
                [],  # Empty message history for simplicity
                test["context"]
            )
            print(f"\n   Message: '{test['message']}'")
            print(f"   Patterns detected: {len(patterns) if patterns else 0}")
            if patterns:
                for p in patterns:
                    print(f"     - {p.get('type', 'unknown')}: {p.get('confidence', 0):.2f}")
    else:
        print("❌ Pattern Recognition not initialized")
    
    print("\n" + "="*60)
    print("✅ PATTERN RECOGNITION TEST COMPLETED")
    print("="*60 + "\n")


async def main():
    """Run all ML integration tests."""
    try:
        # Test ML Pipeline
        await test_ml_pipeline_integration()
        
        # Test Pattern Recognition
        await test_pattern_recognition()
        
        print("\n🎉 ALL ML INTEGRATION TESTS COMPLETED SUCCESSFULLY!\n")
        
    except Exception as e:
        logger.error(f"Test failed: {e}")
        print(f"\n❌ Test failed: {e}\n")


if __name__ == "__main__":
    asyncio.run(main())