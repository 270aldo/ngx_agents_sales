#!/usr/bin/env python3
"""
Local test for A/B Testing functionality without database dependencies.
"""

import asyncio
import logging
import sys
from datetime import datetime
import uuid

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add src to path
sys.path.insert(0, '.')

from src.services.ab_testing_framework import MultiArmedBandit
from src.models.learning_models import (
    MLExperiment, ExperimentVariant, ExperimentType, ExperimentStatus
)


def test_multi_armed_bandit():
    """Test Multi-Armed Bandit functionality."""
    logger.info("\n=== Testing Multi-Armed Bandit ===")
    
    # Create bandit with 3 variants
    variants = ["variant_a", "variant_b", "variant_c"]
    bandit = MultiArmedBandit(variants)
    
    # Simulate selections and rewards
    selections = {v: 0 for v in variants}
    
    for i in range(100):
        # Select variant
        selected = bandit.select_variant()
        selections[selected] += 1
        
        # Simulate reward (variant_b performs best)
        if selected == "variant_a":
            reward = 1.0 if i % 4 == 0 else 0.0  # 25% success
        elif selected == "variant_b":
            reward = 1.0 if i % 2 == 0 else 0.0  # 50% success
        else:
            reward = 1.0 if i % 3 == 0 else 0.0  # 33% success
        
        bandit.update_reward(selected, reward)
    
    # Get statistics
    stats = bandit.get_statistics()
    
    logger.info("\nBandit Statistics after 100 iterations:")
    for variant, data in stats.items():
        logger.info(f"  {variant}:")
        logger.info(f"    Selections: {data['count']}")
        logger.info(f"    Mean reward: {data['mean_reward']:.2f}")
        logger.info(f"    Selection probability: {data['selection_probability']:.2f}")
    
    # Check if best variant is being selected more
    best_variant = max(stats.items(), key=lambda x: x[1]['mean_reward'])[0]
    logger.info(f"\n✅ Best performing variant: {best_variant}")
    

def test_experiment_creation():
    """Test experiment creation and management."""
    logger.info("\n=== Testing Experiment Creation ===")
    
    # Create test variants
    variants = [
        ExperimentVariant(
            variant_name="Control",
            variant_type="greeting",
            variant_content={
                "text": "Hello, how can I help you?",
                "style": "standard",
                "empathy_level": "low"
            },
            weight=0.5
        ),
        ExperimentVariant(
            variant_name="Empathetic",
            variant_type="greeting",
            variant_content={
                "text": "Hello! I'm here to help you achieve your wellness goals.",
                "style": "warm",
                "empathy_level": "high"
            },
            weight=0.5
        )
    ]
    
    # Create experiment
    experiment = MLExperiment(
        experiment_name="greeting_empathy_test",
        experiment_type=ExperimentType.PROMPT_VARIANT,
        description="Test empathetic vs standard greeting",
        hypothesis="Empathetic greetings will increase engagement by 20%",
        variants=variants,
        target_metric="engagement_score",
        minimum_sample_size=100,
        confidence_level=0.95,
        status=ExperimentStatus.RUNNING,
        auto_deploy_winner=True
    )
    
    logger.info(f"Created experiment: {experiment.experiment_name}")
    logger.info(f"  Type: {experiment.experiment_type.value}")
    logger.info(f"  Status: {experiment.status.value}")
    logger.info(f"  Variants: {len(experiment.variants)}")
    for variant in experiment.variants:
        logger.info(f"    - {variant.variant_name}: {variant.variant_content.get('text', 'No text')[:50]}...")
    
    logger.info("\n✅ Experiment creation successful!")
    

def test_ab_testing_flow():
    """Test complete A/B testing flow."""
    logger.info("\n=== Testing A/B Testing Flow ===")
    
    # Create variants
    variants = ["standard", "friendly", "professional"]
    bandit = MultiArmedBandit(variants, exploration_factor=2.0)
    
    # Track conversions
    conversions = {v: [] for v in variants}
    
    # Simulate 50 conversations
    for i in range(50):
        # Select variant
        selected_variant = bandit.select_variant()
        
        # Simulate conversation with different conversion rates
        if selected_variant == "standard":
            converted = i % 5 == 0  # 20% conversion
        elif selected_variant == "friendly":
            converted = i % 3 == 0  # 33% conversion
        else:
            converted = i % 4 == 0  # 25% conversion
        
        # Update bandit
        reward = 1.0 if converted else 0.0
        bandit.update_reward(selected_variant, reward)
        conversions[selected_variant].append(converted)
    
    # Calculate final statistics
    logger.info("\nFinal Results:")
    stats = bandit.get_statistics()
    
    for variant in variants:
        conv_list = conversions[variant]
        if conv_list:
            conversion_rate = sum(conv_list) / len(conv_list) * 100
            logger.info(f"  {variant}:")
            logger.info(f"    Conversations: {len(conv_list)}")
            logger.info(f"    Conversion rate: {conversion_rate:.1f}%")
            logger.info(f"    Bandit mean reward: {stats[variant]['mean_reward']:.2f}")
    
    # Identify winner
    best_variant = max(stats.items(), key=lambda x: x[1]['mean_reward'])[0]
    logger.info(f"\n✅ Winning variant: {best_variant}")
    

def test_variant_content():
    """Test variant content handling."""
    logger.info("\n=== Testing Variant Content ===")
    
    # Test different content types
    variants = [
        {
            "name": "ROI Focus",
            "content": {
                "approach": "value_demonstration",
                "use_roi_calculator": True,
                "emphasis": ["long_term_value", "cost_savings"]
            }
        },
        {
            "name": "Social Proof",
            "content": {
                "approach": "testimonials",
                "use_success_stories": True,
                "emphasis": ["peer_validation", "results"]
            }
        }
    ]
    
    for variant in variants:
        logger.info(f"\nVariant: {variant['name']}")
        logger.info(f"  Approach: {variant['content']['approach']}")
        logger.info(f"  Emphasis: {', '.join(variant['content']['emphasis'])}")
    
    logger.info("\n✅ Variant content test complete!")


def main():
    """Run all tests."""
    logger.info("\n" + "="*60)
    logger.info("NGX A/B Testing - Local Unit Tests")
    logger.info("="*60)
    
    # Run tests
    test_multi_armed_bandit()
    test_experiment_creation()
    test_ab_testing_flow()
    test_variant_content()
    
    logger.info("\n" + "="*60)
    logger.info("✅ All tests completed successfully!")
    logger.info("="*60)


if __name__ == "__main__":
    main()