#!/usr/bin/env python3
"""
Test script for active A/B Testing functionality.

This script tests the complete A/B testing integration with the NGX Voice Sales Agent,
including experiment creation, variant assignment, and outcome tracking.
"""

import asyncio
import logging
from datetime import datetime
import json
import sys
from typing import Dict, Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add src to path
sys.path.insert(0, '.')

from src.services.ab_testing_manager import ABTestingManager, ExperimentCategory, ExperimentConfig
from src.services.conversation.orchestrator import ConversationOrchestrator
from src.models.conversation import CustomerData
from src.models.platform_context import PlatformInfo


class ABTestingValidator:
    """Validates A/B testing functionality."""
    
    def __init__(self):
        self.ab_manager = ABTestingManager()
        self.orchestrator = ConversationOrchestrator()
        self.test_results = []
    
    async def initialize(self):
        """Initialize services."""
        logger.info("Initializing A/B Testing components...")
        await self.ab_manager.initialize()
        await self.orchestrator.initialize()
        logger.info("Initialization complete")
    
    async def test_experiment_creation(self) -> bool:
        """Test creating custom experiments."""
        logger.info("\n=== Testing Experiment Creation ===")
        
        try:
            # Create a test experiment
            test_config = ExperimentConfig(
                name="test_closing_urgency_experiment",
                category=ExperimentCategory.CLOSING_TECHNIQUE,
                description="Test urgency levels in closing",
                hypothesis="High urgency will increase conversions by 15%",
                variants=[
                    {
                        "name": "low_urgency",
                        "type": "closing",
                        "content": "low_urgency",
                        "parameters": {
                            "urgency": "low",
                            "style": "relaxed"
                        }
                    },
                    {
                        "name": "high_urgency",
                        "type": "closing",
                        "content": "high_urgency",
                        "parameters": {
                            "urgency": "high",
                            "style": "assertive",
                            "scarcity": "limited_time"
                        }
                    }
                ],
                minimum_sample_size=50
            )
            
            experiment_id = await self.ab_manager.create_custom_experiment(test_config)
            
            if experiment_id:
                logger.info(f"✅ Successfully created experiment: {experiment_id}")
                self.test_results.append(("Experiment Creation", True, experiment_id))
                return True
            else:
                logger.error("❌ Failed to create experiment")
                self.test_results.append(("Experiment Creation", False, "No ID returned"))
                return False
                
        except Exception as e:
            logger.error(f"❌ Error in experiment creation: {e}")
            self.test_results.append(("Experiment Creation", False, str(e)))
            return False
    
    async def test_variant_assignment(self) -> bool:
        """Test variant assignment for different categories."""
        logger.info("\n=== Testing Variant Assignment ===")
        
        success_count = 0
        test_conversation_id = "test_conv_123"
        
        # Test greeting variant
        try:
            greeting_variant = await self.ab_manager.get_variant_for_conversation(
                conversation_id=test_conversation_id,
                category=ExperimentCategory.GREETING,
                context={
                    "customer_age": 35,
                    "platform": "web"
                }
            )
            
            if greeting_variant:
                logger.info(f"✅ Greeting variant assigned: {greeting_variant.variant_id}")
                logger.info(f"   Parameters: {greeting_variant.parameters}")
                self.test_results.append(("Greeting Variant", True, greeting_variant.variant_id))
                success_count += 1
            else:
                logger.warning("⚠️  No greeting variant assigned (might be no active experiments)")
                self.test_results.append(("Greeting Variant", False, "No variant assigned"))
                
        except Exception as e:
            logger.error(f"❌ Error assigning greeting variant: {e}")
            self.test_results.append(("Greeting Variant", False, str(e)))
        
        # Test price objection variant
        try:
            price_variant = await self.ab_manager.get_variant_for_conversation(
                conversation_id=test_conversation_id,
                category=ExperimentCategory.PRICE_OBJECTION,
                context={
                    "objection_text": "Es muy caro para mí",
                    "tier_detected": "pro",
                    "emotional_state": "concerned"
                }
            )
            
            if price_variant:
                logger.info(f"✅ Price objection variant assigned: {price_variant.variant_id}")
                logger.info(f"   Parameters: {price_variant.parameters}")
                self.test_results.append(("Price Variant", True, price_variant.variant_id))
                success_count += 1
            else:
                logger.warning("⚠️  No price objection variant assigned")
                self.test_results.append(("Price Variant", False, "No variant assigned"))
                
        except Exception as e:
            logger.error(f"❌ Error assigning price variant: {e}")
            self.test_results.append(("Price Variant", False, str(e)))
        
        return success_count >= 1  # At least one variant should be assigned
    
    async def test_conversation_flow_with_ab(self) -> bool:
        """Test full conversation flow with A/B testing."""
        logger.info("\n=== Testing Conversation Flow with A/B ===")
        
        try:
            # Create test customer
            customer = CustomerData(
                id="test_customer_ab_123",
                name="María García",
                email="maria@test.com",
                phone="+1234567890",
                age=42
            )
            
            # Start conversation
            logger.info("Starting conversation...")
            conversation_state = await self.orchestrator.start_conversation(
                customer_data=customer,
                program_type="LONGEVITY"
            )
            
            conversation_id = conversation_state.conversation_id
            logger.info(f"Conversation started: {conversation_id}")
            
            # Process messages to trigger different A/B tests
            test_messages = [
                "Hola, me interesa saber más sobre sus programas",
                "¿Cuáles son los precios de sus servicios?",
                "Me parece un poco caro, ¿hay algún descuento?",
                "Necesito pensarlo un poco más"
            ]
            
            for i, message in enumerate(test_messages):
                logger.info(f"\nProcessing message {i+1}: '{message}'")
                
                response = await self.orchestrator.process_message(
                    conversation_id=conversation_id,
                    message_text=message
                )
                
                logger.info(f"Response phase: {response.get('sales_phase')}")
                logger.info(f"Has price concern: {response.get('metadata', {}).get('has_price_concern')}")
                
                # Log A/B variant info if available
                ml_insights = response.get('ml_insights', {})
                if ml_insights.get('ab_variants'):
                    logger.info(f"A/B variants active: {ml_insights['ab_variants']}")
            
            # End conversation
            logger.info("\nEnding conversation...")
            final_state = await self.orchestrator.end_conversation(
                conversation_id=conversation_id,
                end_reason="completed"
            )
            
            logger.info("✅ Conversation flow with A/B testing completed successfully")
            self.test_results.append(("Conversation Flow", True, conversation_id))
            return True
            
        except Exception as e:
            logger.error(f"❌ Error in conversation flow: {e}")
            self.test_results.append(("Conversation Flow", False, str(e)))
            return False
    
    async def test_outcome_recording(self) -> bool:
        """Test recording outcomes for A/B tests."""
        logger.info("\n=== Testing Outcome Recording ===")
        
        try:
            test_conversation_id = "test_outcome_conv_456"
            
            # Simulate getting variants
            greeting_variant = await self.ab_manager.get_variant_for_conversation(
                conversation_id=test_conversation_id,
                category=ExperimentCategory.GREETING,
                context={"platform": "web"}
            )
            
            # Record outcome
            await self.ab_manager.record_outcome(
                conversation_id=test_conversation_id,
                outcome="converted",
                metrics={
                    "conversion_value": 299,
                    "engagement_score": 8,
                    "satisfaction_score": 9,
                    "duration_seconds": 420
                }
            )
            
            logger.info("✅ Outcome recorded successfully")
            self.test_results.append(("Outcome Recording", True, "Success"))
            return True
            
        except Exception as e:
            logger.error(f"❌ Error recording outcome: {e}")
            self.test_results.append(("Outcome Recording", False, str(e)))
            return False
    
    async def test_experiment_results(self) -> bool:
        """Test retrieving experiment results."""
        logger.info("\n=== Testing Experiment Results Retrieval ===")
        
        try:
            # Get overall results
            results = await self.ab_manager.get_experiment_results()
            
            if "error" not in results:
                summary = results.get("summary", {})
                logger.info(f"\nExperiment Summary:")
                logger.info(f"  Active experiments: {summary.get('total_active', 0)}")
                logger.info(f"  Total conversions: {summary.get('total_conversions', 0)}")
                logger.info(f"  Winners found: {summary.get('winners_found', 0)}")
                
                # Show individual experiment results
                for exp in results.get("experiments", []):
                    logger.info(f"\n  Experiment: {exp['name']}")
                    logger.info(f"    Category: {exp['category']}")
                    logger.info(f"    Status: {exp['status']}")
                    
                    exp_results = exp.get("results", {})
                    logger.info(f"    Total assignments: {exp_results.get('total_assignments', 0)}")
                    logger.info(f"    Conversion rate: {exp_results.get('overall_conversion_rate', 0):.1f}%")
                
                logger.info("\n✅ Experiment results retrieved successfully")
                self.test_results.append(("Results Retrieval", True, "Success"))
                return True
            else:
                logger.error(f"❌ Error in results: {results['error']}")
                self.test_results.append(("Results Retrieval", False, results['error']))
                return False
                
        except Exception as e:
            logger.error(f"❌ Error retrieving results: {e}")
            self.test_results.append(("Results Retrieval", False, str(e)))
            return False
    
    async def run_all_tests(self):
        """Run all A/B testing validation tests."""
        logger.info("\n" + "="*60)
        logger.info("NGX Voice Sales Agent - A/B Testing Validation")
        logger.info("="*60)
        
        await self.initialize()
        
        # Run tests
        tests = [
            self.test_experiment_creation(),
            self.test_variant_assignment(),
            self.test_conversation_flow_with_ab(),
            self.test_outcome_recording(),
            self.test_experiment_results()
        ]
        
        results = await asyncio.gather(*tests)
        
        # Summary
        logger.info("\n" + "="*60)
        logger.info("TEST SUMMARY")
        logger.info("="*60)
        
        total_tests = len(self.test_results)
        passed_tests = sum(1 for _, success, _ in self.test_results if success)
        
        for test_name, success, details in self.test_results:
            status = "✅ PASS" if success else "❌ FAIL"
            logger.info(f"{status} - {test_name}: {details}")
        
        logger.info(f"\nTotal: {passed_tests}/{total_tests} tests passed")
        logger.info(f"Success rate: {(passed_tests/total_tests)*100:.1f}%")
        
        # Show active experiments summary
        summary = self.ab_manager.get_active_experiment_summary()
        logger.info("\nActive Experiments by Category:")
        for category, experiments in summary.items():
            if experiments:
                logger.info(f"  {category}: {len(experiments)} active")
                for exp_name in experiments[:2]:  # Show first 2
                    logger.info(f"    - {exp_name}")


async def main():
    """Main entry point."""
    validator = ABTestingValidator()
    await validator.run_all_tests()


if __name__ == "__main__":
    asyncio.run(main())