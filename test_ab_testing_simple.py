#!/usr/bin/env python3
"""
Simple test for A/B Testing functionality.
"""

import asyncio
import logging
import sys
from datetime import datetime

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add src to path
sys.path.insert(0, '.')

from src.services.ab_testing_manager import ABTestingManager, ExperimentCategory, ExperimentConfig


async def test_ab_manager():
    """Test A/B Testing Manager basic functionality."""
    logger.info("\n=== Testing A/B Manager ===")
    
    ab_manager = ABTestingManager()
    
    # Initialize
    logger.info("Initializing A/B Manager...")
    await ab_manager.initialize()
    
    # Create test experiment
    logger.info("\nCreating test experiment...")
    test_config = ExperimentConfig(
        name="test_greeting_experiment_" + datetime.now().strftime("%Y%m%d_%H%M%S"),
        category=ExperimentCategory.GREETING,
        description="Test greeting variations",
        hypothesis="Warm greetings increase engagement",
        variants=[
            {
                "name": "control",
                "type": "greeting",
                "content": "standard",
                "parameters": {"style": "professional"}
            },
            {
                "name": "warm",
                "type": "greeting",
                "content": "warm",
                "parameters": {"style": "friendly"}
            }
        ],
        minimum_sample_size=10
    )
    
    experiment_id = await ab_manager.create_custom_experiment(test_config)
    if experiment_id:
        logger.info(f"✅ Experiment created: {experiment_id}")
    else:
        logger.error("❌ Failed to create experiment")
        return
    
    # Get variant
    logger.info("\nGetting variant for conversation...")
    variant = await ab_manager.get_variant_for_conversation(
        conversation_id="test_conv_001",
        category=ExperimentCategory.GREETING,
        context={"platform": "web"}
    )
    
    if variant:
        logger.info(f"✅ Variant assigned: {variant.variant_id}")
        logger.info(f"   Content: {variant.content}")
        logger.info(f"   Parameters: {variant.parameters}")
    else:
        logger.warning("⚠️  No variant assigned")
    
    # Record outcome
    logger.info("\nRecording outcome...")
    await ab_manager.record_outcome(
        conversation_id="test_conv_001",
        outcome="converted",
        metrics={
            "engagement_score": 8,
            "satisfaction_score": 9
        }
    )
    logger.info("✅ Outcome recorded")
    
    # Get results
    logger.info("\nGetting experiment results...")
    results = await ab_manager.get_experiment_results()
    
    if "error" not in results:
        summary = results.get("summary", {})
        logger.info(f"Active experiments: {summary.get('total_active', 0)}")
        logger.info(f"Total conversions: {summary.get('total_conversions', 0)}")
    
    # Get active experiments summary
    logger.info("\nActive experiments summary:")
    summary = ab_manager.get_active_experiment_summary()
    for category, experiments in summary.items():
        if experiments:
            logger.info(f"  {category}: {len(experiments)} active")
    
    logger.info("\n✅ A/B Testing Manager test completed!")


async def main():
    """Main entry point."""
    await test_ab_manager()


if __name__ == "__main__":
    asyncio.run(main())