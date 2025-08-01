-- Script CORREGIDO para crear las 11 tablas faltantes
-- Quitando la referencia foreign key problemática

-- 1. adaptive_learning_config
CREATE TABLE IF NOT EXISTS adaptive_learning_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    config_name VARCHAR(255) NOT NULL,
    learning_rate FLOAT DEFAULT 0.01,
    exploration_rate FLOAT DEFAULT 0.1,
    model_update_frequency INTEGER DEFAULT 100,
    min_samples_for_update INTEGER DEFAULT 50,
    confidence_threshold FLOAT DEFAULT 0.7,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. learned_models
CREATE TABLE IF NOT EXISTS learned_models (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_type VARCHAR(50) NOT NULL,
    model_version VARCHAR(50) NOT NULL,
    model_data JSONB NOT NULL,
    performance_metrics JSONB,
    training_samples INTEGER DEFAULT 0,
    champion_model BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. ml_experiments
CREATE TABLE IF NOT EXISTS ml_experiments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experiment_name VARCHAR(255) NOT NULL,
    experiment_type VARCHAR(50) NOT NULL,
    variants JSONB NOT NULL,
    traffic_allocation JSONB NOT NULL,
    success_metrics JSONB NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. experiment_results  
CREATE TABLE IF NOT EXISTS experiment_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experiment_id UUID NOT NULL REFERENCES ml_experiments(id),
    variant_name VARCHAR(255) NOT NULL,
    conversation_id UUID NOT NULL,
    metrics JSONB NOT NULL,
    outcome VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. customer_profiles
CREATE TABLE IF NOT EXISTS customer_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id VARCHAR(255) UNIQUE NOT NULL,
    profile_data JSONB NOT NULL,
    behavioral_patterns JSONB,
    preferences JSONB,
    engagement_score FLOAT DEFAULT 0,
    lifetime_value FLOAT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. conversation_outcomes
CREATE TABLE IF NOT EXISTS conversation_outcomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    outcome_type VARCHAR(50) NOT NULL,
    outcome_value JSONB,
    ml_predictions JSONB,
    ml_confidence FLOAT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. ab_test_variants
CREATE TABLE IF NOT EXISTS ab_test_variants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255) NOT NULL,
    variant_config JSONB NOT NULL,
    is_control BOOLEAN DEFAULT false,
    traffic_percentage FLOAT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(test_name, variant_name)
);

-- 8. ab_test_results
CREATE TABLE IF NOT EXISTS ab_test_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    test_name VARCHAR(255) NOT NULL,
    variant_name VARCHAR(255) NOT NULL,
    conversation_id UUID NOT NULL,
    conversion BOOLEAN DEFAULT false,
    revenue FLOAT DEFAULT 0,
    engagement_score FLOAT DEFAULT 0,
    custom_metrics JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. pattern_recognitions
CREATE TABLE IF NOT EXISTS pattern_recognitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pattern_type VARCHAR(50) NOT NULL,
    pattern_data JSONB NOT NULL,
    confidence_score FLOAT NOT NULL,
    occurrences INTEGER DEFAULT 1,
    first_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. prompt_performance (SIN FOREIGN KEY)
CREATE TABLE IF NOT EXISTS prompt_performance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL,  -- Sin REFERENCES
    conversation_id UUID NOT NULL,
    performance_metrics JSONB NOT NULL,
    user_feedback JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. tier_detections
CREATE TABLE IF NOT EXISTS tier_detections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    detected_tier VARCHAR(50) NOT NULL,
    confidence_score FLOAT NOT NULL,
    detection_signals JSONB NOT NULL,
    ml_model_version VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_adaptive_learning_active ON adaptive_learning_config(is_active);
CREATE INDEX IF NOT EXISTS idx_learned_models_type ON learned_models(model_type);
CREATE INDEX IF NOT EXISTS idx_learned_models_champion ON learned_models(champion_model);
CREATE INDEX IF NOT EXISTS idx_ml_experiments_status ON ml_experiments(status);
CREATE INDEX IF NOT EXISTS idx_experiment_results_experiment ON experiment_results(experiment_id);
CREATE INDEX IF NOT EXISTS idx_customer_profiles_customer ON customer_profiles(customer_id);
CREATE INDEX IF NOT EXISTS idx_conversation_outcomes_conversation ON conversation_outcomes(conversation_id);
CREATE INDEX IF NOT EXISTS idx_ab_test_variants_test ON ab_test_variants(test_name);
CREATE INDEX IF NOT EXISTS idx_ab_test_results_test ON ab_test_results(test_name, variant_name);
CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_type ON pattern_recognitions(pattern_type);
CREATE INDEX IF NOT EXISTS idx_prompt_performance_variant ON prompt_performance(variant_id);
CREATE INDEX IF NOT EXISTS idx_tier_detections_conversation ON tier_detections(conversation_id);

-- Insertar configuración inicial
INSERT INTO adaptive_learning_config (config_name, is_active) 
VALUES ('default_config', true)
ON CONFLICT DO NOTHING;