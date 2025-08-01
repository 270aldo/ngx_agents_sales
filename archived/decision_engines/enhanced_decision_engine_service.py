"""
Enhanced Decision Engine Service with Advanced Strategies

Integrates advanced decision strategies with the optimized decision engine
for superior conversation flow optimization.
"""

import asyncio
from typing import Dict, List, Optional, Any, Tuple
from datetime import datetime
import logging

from src.services.optimized_decision_engine_service import OptimizedDecisionEngineService
from src.services.advanced_decision_strategies import (
    AdvancedDecisionStrategies,
    ConversationContext,
    DecisionStrategy,
    StrategyDecision
)


class EnhancedDecisionEngineService(OptimizedDecisionEngineService):
    """Enhanced decision engine with advanced strategic capabilities."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.advanced_strategies = AdvancedDecisionStrategies()
        self.strategy_performance = {}  # Track strategy performance
        self.conversation_strategies = {}  # Track strategy per conversation
        
        # Enhanced configuration
        self.config.update({
            "enable_multi_strategy": True,
            "strategy_adaptation": True,
            "performance_window": 100,  # conversations to track
            "min_confidence_threshold": 0.6
        })
    
    async def get_optimal_action(
        self,
        user_message: str,
        conversation_history: List[Dict[str, Any]],
        user_profile: Dict[str, Any],
        current_objectives: Dict[str, float]
    ) -> Dict[str, Any]:
        """Get optimal action using advanced strategies."""
        
        # Build enhanced context
        context = await self._build_conversation_context(
            user_message,
            conversation_history,
            user_profile,
            current_objectives
        )
        
        # Get base decision from parent class
        base_decision = await super().get_optimal_action(
            user_message,
            conversation_history,
            user_profile,
            current_objectives
        )
        
        # Enhance with advanced strategies
        enhanced_decision = await self._enhance_with_strategies(
            base_decision,
            context
        )
        
        # Track strategy usage
        self._track_strategy_usage(context.conversation_id, enhanced_decision)
        
        return enhanced_decision
    
    async def _build_conversation_context(
        self,
        user_message: str,
        conversation_history: List[Dict[str, Any]],
        user_profile: Dict[str, Any],
        current_objectives: Dict[str, float]
    ) -> ConversationContext:
        """Build comprehensive conversation context."""
        
        # Extract conversation metrics
        message_count = len(conversation_history)
        
        # Calculate sentiment (would use EmotionalAnalysisService in production)
        sentiment = await self._calculate_sentiment(user_message, conversation_history)
        
        # Calculate engagement score
        engagement = self._calculate_engagement(conversation_history)
        
        # Count objections
        objection_count = self._count_objections(conversation_history)
        
        # Check for price and competitor mentions
        price_mentioned = any(
            "price" in msg.get("content", "").lower() or 
            "cost" in msg.get("content", "").lower() or
            "$" in msg.get("content", "")
            for msg in conversation_history
        )
        
        competitor_mentioned = any(
            "competitor" in msg.get("content", "").lower() or
            "alternative" in msg.get("content", "").lower()
            for msg in conversation_history
        )
        
        # Extract timeline
        timeline = self._extract_decision_timeline(user_message, conversation_history)
        
        # Get detected needs from objectives
        detected_needs = [
            need for need, score in current_objectives.items() 
            if score > 0.5
        ]
        
        # Calculate conversion probability
        conversion_prob = await self._get_conversion_probability(
            conversation_history,
            user_profile
        )
        
        # Calculate time in conversation
        if conversation_history:
            first_msg_time = conversation_history[0].get("timestamp", datetime.now())
            if isinstance(first_msg_time, str):
                first_msg_time = datetime.fromisoformat(first_msg_time)
            time_in_conversation = (datetime.now() - first_msg_time).seconds
        else:
            time_in_conversation = 0
        
        return ConversationContext(
            conversation_id=self._get_conversation_id(conversation_history),
            message_count=message_count,
            customer_sentiment=sentiment,
            engagement_score=engagement,
            objection_count=objection_count,
            price_mentioned=price_mentioned,
            competitor_mentioned=competitor_mentioned,
            decision_timeline=timeline,
            customer_profile=user_profile,
            detected_needs=detected_needs,
            conversion_probability=conversion_prob,
            time_in_conversation=time_in_conversation
        )
    
    async def _enhance_with_strategies(
        self,
        base_decision: Dict[str, Any],
        context: ConversationContext
    ) -> Dict[str, Any]:
        """Enhance decision with advanced strategies."""
        
        if self.config["enable_multi_strategy"]:
            # Get recommendations from multiple strategies
            recommendations = self.advanced_strategies.get_multi_strategy_recommendation(
                context,
                top_n=3
            )
            
            # Select best recommendation
            best_strategy, best_decision = self._select_best_recommendation(
                recommendations,
                base_decision,
                context
            )
            
            # Merge with base decision
            enhanced_decision = self._merge_decisions(
                base_decision,
                best_decision,
                best_strategy
            )
        else:
            # Single strategy selection
            optimal_strategy = self.advanced_strategies.select_optimal_strategy(context)
            strategy_decision = self.advanced_strategies.execute_strategy(
                optimal_strategy,
                context
            )
            
            enhanced_decision = self._merge_decisions(
                base_decision,
                strategy_decision,
                optimal_strategy
            )
        
        return enhanced_decision
    
    def _select_best_recommendation(
        self,
        recommendations: List[Tuple[DecisionStrategy, StrategyDecision]],
        base_decision: Dict[str, Any],
        context: ConversationContext
    ) -> Tuple[DecisionStrategy, StrategyDecision]:
        """Select best recommendation from multiple strategies."""
        
        best_score = -1
        best_recommendation = recommendations[0]
        
        for strategy, decision in recommendations:
            # Score based on confidence and alignment with base decision
            score = decision.confidence
            
            # Bonus for alignment with base decision
            if decision.recommended_action in base_decision.get("next_actions", []):
                score += 0.2
            
            # Consider strategy performance history
            if self.config["strategy_adaptation"]:
                historical_performance = self.strategy_performance.get(
                    strategy.value, 
                    0.5
                )
                score *= (0.7 + 0.3 * historical_performance)
            
            # Consider urgency for time-sensitive contexts
            if context.decision_timeline == "immediate":
                score += decision.urgency_level * 0.05
            
            if score > best_score:
                best_score = score
                best_recommendation = (strategy, decision)
        
        return best_recommendation
    
    def _merge_decisions(
        self,
        base_decision: Dict[str, Any],
        strategy_decision: StrategyDecision,
        strategy: DecisionStrategy
    ) -> Dict[str, Any]:
        """Merge base decision with strategy decision."""
        
        enhanced_decision = base_decision.copy()
        
        # Add strategy information
        enhanced_decision["strategy"] = {
            "name": strategy.value,
            "confidence": strategy_decision.confidence,
            "reasoning": strategy_decision.reasoning,
            "urgency_level": strategy_decision.urgency_level
        }
        
        # Update next actions based on strategy
        if strategy_decision.confidence >= self.config["min_confidence_threshold"]:
            # High confidence - replace actions
            enhanced_decision["next_actions"] = [
                {
                    "action": strategy_decision.recommended_action,
                    "priority": "high",
                    "confidence": strategy_decision.confidence
                }
            ]
            
            if strategy_decision.fallback_action:
                enhanced_decision["next_actions"].append({
                    "action": strategy_decision.fallback_action,
                    "priority": "medium",
                    "confidence": strategy_decision.confidence * 0.7
                })
        else:
            # Low confidence - add as alternative
            if "next_actions" not in enhanced_decision:
                enhanced_decision["next_actions"] = []
            
            enhanced_decision["next_actions"].insert(0, {
                "action": strategy_decision.recommended_action,
                "priority": "medium",
                "confidence": strategy_decision.confidence,
                "strategy_suggested": True
            })
        
        # Add decision metadata
        enhanced_decision["metadata"] = enhanced_decision.get("metadata", {})
        enhanced_decision["metadata"]["strategy_used"] = strategy.value
        enhanced_decision["metadata"]["strategy_confidence"] = strategy_decision.confidence
        enhanced_decision["metadata"]["urgency_level"] = strategy_decision.urgency_level
        
        # Adjust confidence based on strategy alignment
        if "confidence" in enhanced_decision:
            enhanced_decision["confidence"] = (
                enhanced_decision["confidence"] * 0.7 + 
                strategy_decision.confidence * 0.3
            )
        
        return enhanced_decision
    
    def _track_strategy_usage(self, conversation_id: str, decision: Dict[str, Any]):
        """Track which strategies are being used."""
        strategy_name = decision.get("strategy", {}).get("name")
        if strategy_name:
            self.conversation_strategies[conversation_id] = strategy_name
    
    async def record_conversation_outcome(
        self,
        conversation_id: str,
        outcome: str,
        metrics: Dict[str, Any]
    ):
        """Record outcome and update strategy performance."""
        
        # Record base outcome
        await super().record_conversation_outcome(conversation_id, outcome, metrics)
        
        # Update strategy performance if enabled
        if self.config["strategy_adaptation"]:
            strategy_used = self.conversation_strategies.get(conversation_id)
            if strategy_used:
                self._update_strategy_performance(strategy_used, outcome, metrics)
    
    def _update_strategy_performance(
        self,
        strategy_name: str,
        outcome: str,
        metrics: Dict[str, Any]
    ):
        """Update strategy performance metrics."""
        
        # Calculate success score
        success_score = 0.0
        if outcome == "converted":
            success_score = 1.0
        elif outcome == "follow_up_scheduled":
            success_score = 0.7
        elif outcome == "interested":
            success_score = 0.5
        elif outcome == "not_interested":
            success_score = 0.2
        
        # Initialize if needed
        if strategy_name not in self.strategy_performance:
            self.strategy_performance[strategy_name] = []
        
        # Add to performance history
        self.strategy_performance[strategy_name].append(success_score)
        
        # Keep only recent history
        if len(self.strategy_performance[strategy_name]) > self.config["performance_window"]:
            self.strategy_performance[strategy_name].pop(0)
        
        # Calculate average performance
        avg_performance = sum(self.strategy_performance[strategy_name]) / len(
            self.strategy_performance[strategy_name]
        )
        
        # Adapt strategy weights based on performance
        if len(self.strategy_performance[strategy_name]) >= 10:
            performance_data = {
                strategy_name: avg_performance
                for strategy_name in self.strategy_performance
                if len(self.strategy_performance[strategy_name]) >= 10
            }
            self.advanced_strategies.adapt_strategy_weights(performance_data)
    
    # Helper methods
    
    async def _calculate_sentiment(
        self, 
        user_message: str, 
        conversation_history: List[Dict[str, Any]]
    ) -> float:
        """Calculate customer sentiment (-1 to 1)."""
        # Simplified sentiment calculation
        positive_words = ["great", "excellent", "love", "perfect", "awesome", "yes"]
        negative_words = ["bad", "hate", "terrible", "no", "expensive", "difficult"]
        
        text = user_message.lower()
        positive_count = sum(1 for word in positive_words if word in text)
        negative_count = sum(1 for word in negative_words if word in text)
        
        if positive_count + negative_count == 0:
            return 0.0
        
        sentiment = (positive_count - negative_count) / (positive_count + negative_count)
        return max(-1.0, min(1.0, sentiment))
    
    def _calculate_engagement(self, conversation_history: List[Dict[str, Any]]) -> float:
        """Calculate engagement score (0 to 1)."""
        if not conversation_history:
            return 0.5
        
        # Factors: message length, question asking, response time
        total_score = 0.0
        count = 0
        
        for i, msg in enumerate(conversation_history):
            if msg.get("role") == "user":
                # Message length factor
                length = len(msg.get("content", ""))
                length_score = min(1.0, length / 100)
                
                # Question factor
                question_score = 1.0 if "?" in msg.get("content", "") else 0.5
                
                # Combine
                msg_score = (length_score + question_score) / 2
                total_score += msg_score
                count += 1
        
        return total_score / count if count > 0 else 0.5
    
    def _count_objections(self, conversation_history: List[Dict[str, Any]]) -> int:
        """Count number of objections in conversation."""
        objection_keywords = [
            "expensive", "cost", "price", "budget", "afford",
            "not sure", "think about", "maybe", "don't know",
            "competitor", "alternative", "already have"
        ]
        
        count = 0
        for msg in conversation_history:
            if msg.get("role") == "user":
                text = msg.get("content", "").lower()
                if any(keyword in text for keyword in objection_keywords):
                    count += 1
        
        return count
    
    def _extract_decision_timeline(
        self, 
        user_message: str, 
        conversation_history: List[Dict[str, Any]]
    ) -> Optional[str]:
        """Extract decision timeline from conversation."""
        immediate_keywords = ["now", "today", "asap", "immediately", "urgent"]
        short_keywords = ["soon", "this week", "quickly", "few days"]
        long_keywords = ["later", "eventually", "future", "someday", "months"]
        
        all_text = user_message.lower()
        for msg in conversation_history[-5:]:  # Check last 5 messages
            if msg.get("role") == "user":
                all_text += " " + msg.get("content", "").lower()
        
        if any(keyword in all_text for keyword in immediate_keywords):
            return "immediate"
        elif any(keyword in all_text for keyword in short_keywords):
            return "short_term"
        elif any(keyword in all_text for keyword in long_keywords):
            return "long_term"
        
        return None
    
    async def _get_conversion_probability(
        self,
        conversation_history: List[Dict[str, Any]],
        user_profile: Dict[str, Any]
    ) -> float:
        """Get conversion probability from predictive service."""
        # In production, would call ConversionPredictionService
        # For now, simplified calculation
        
        engagement = self._calculate_engagement(conversation_history)
        objections = self._count_objections(conversation_history)
        message_count = len(conversation_history)
        
        # Base probability
        base_prob = 0.3
        
        # Adjust based on factors
        if engagement > 0.7:
            base_prob += 0.2
        elif engagement > 0.5:
            base_prob += 0.1
        
        if objections == 0:
            base_prob += 0.2
        elif objections > 2:
            base_prob -= 0.1
        
        if message_count > 10:
            base_prob += 0.1
        
        return max(0.0, min(1.0, base_prob))
    
    def _get_conversation_id(self, conversation_history: List[Dict[str, Any]]) -> str:
        """Extract or generate conversation ID."""
        if conversation_history:
            return conversation_history[0].get("conversation_id", "unknown")
        return "new_conversation"