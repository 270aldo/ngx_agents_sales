#!/usr/bin/env python3
"""
Test cache performance improvement.
"""
import asyncio
import time
from unittest.mock import AsyncMock, patch

from src.services.conversation.orchestrator import ConversationOrchestrator
from src.services.conversation.response_cache import response_cache
from src.models.conversation import CustomerData, ConversationState

async def test_cache_performance():
    """Test that caching improves response times."""
    print("🚀 Testing Cache Performance")
    print("=" * 60)
    
    # Clear cache before test
    response_cache.clear()
    
    # Mock database methods
    with patch.object(ConversationOrchestrator, '_save_conversation_state', new_callable=AsyncMock), \
         patch.object(ConversationOrchestrator, '_get_conversation_state', new_callable=AsyncMock), \
         patch.object(ConversationOrchestrator, '_register_session', new_callable=AsyncMock), \
         patch.object(ConversationOrchestrator, '_start_ml_conversation_tracking', new_callable=AsyncMock), \
         patch.object(ConversationOrchestrator, '_update_ml_conversation_metrics', new_callable=AsyncMock):
        
        orchestrator = ConversationOrchestrator()
        await orchestrator.initialize()
        
        # Create mock state
        state = ConversationState(
            conversation_id="test-cache",
            customer_data={
                "id": "test_123",
                "name": "Carlos",
                "email": "carlos@test.com",
                "age": 35
            },
            messages=[],
            context={},
            program_type="PRIME",
            phase="exploration"
        )
        
        orchestrator._get_conversation_state.return_value = state
        orchestrator._start_ml_conversation_tracking.return_value = {"experiments_assigned": []}
        
        # Test same message multiple times
        test_message = "¿Cuánto cuesta el programa?"
        
        print(f"\n💬 Testing message: {test_message}")
        print("-" * 40)
        
        # First call - should hit API
        print("\n1️⃣ First call (no cache):")
        start_time = time.time()
        result1 = await orchestrator.process_message("test-cache", test_message)
        first_time = time.time() - start_time
        print(f"⏱️  Response time: {first_time:.2f}s")
        print(f"📊 Cache stats: {response_cache.stats()}")
        
        # Second call - should hit cache
        print("\n2️⃣ Second call (with cache):")
        start_time = time.time()
        result2 = await orchestrator.process_message("test-cache", test_message)
        second_time = time.time() - start_time
        print(f"⏱️  Response time: {second_time:.2f}s")
        print(f"📊 Cache stats: {response_cache.stats()}")
        
        # Third call - verify consistency
        print("\n3️⃣ Third call (verify cache):")
        start_time = time.time()
        result3 = await orchestrator.process_message("test-cache", test_message)
        third_time = time.time() - start_time
        print(f"⏱️  Response time: {third_time:.2f}s")
        
        # Results
        print("\n\n📊 PERFORMANCE COMPARISON")
        print("=" * 60)
        print(f"First call (no cache):  {first_time:.2f}s")
        print(f"Second call (cached):   {second_time:.2f}s")
        print(f"Third call (cached):    {third_time:.2f}s")
        
        improvement = ((first_time - second_time) / first_time) * 100 if first_time > 0 else 0
        print(f"\n🚀 Performance improvement: {improvement:.0f}%")
        print(f"⚡ Speed-up factor: {first_time/second_time:.1f}x faster" if second_time > 0 else "N/A")
        
        # Verify responses are identical
        responses_match = result1['response'] == result2['response'] == result3['response']
        print(f"\n✅ Response consistency: {'PASS' if responses_match else 'FAIL'}")
        
        # Test different contexts
        print("\n\n🔄 Testing Different Contexts")
        print("-" * 40)
        
        # Change emotional state
        state.phase = "objection_handling"
        
        print("\n4️⃣ Same message, different context:")
        start_time = time.time()
        result4 = await orchestrator.process_message("test-cache", test_message)
        fourth_time = time.time() - start_time
        print(f"⏱️  Response time: {fourth_time:.2f}s (should be slow again)")
        
        different_response = result4['response'] != result1['response']
        print(f"✅ Different response: {'YES' if different_response else 'NO'}")
        
        # Final cache stats
        print(f"\n📊 Final cache stats: {response_cache.stats()}")

if __name__ == "__main__":
    asyncio.run(test_cache_performance())