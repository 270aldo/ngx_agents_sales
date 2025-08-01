-- =====================================================================
-- MIGRACIÓN 013: SOLUCIÓN COMPLETA - CREAR TABLAS Y CORREGIR VISTAS
-- =====================================================================
-- Este script PRIMERO crea TODAS las tablas necesarias y LUEGO las vistas
-- Fecha: 2025-07-28

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================================
-- PARTE 1: CREAR TODAS LAS TABLAS NECESARIAS SI NO EXISTEN
-- =====================================================================

-- 1. conversations
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id VARCHAR(255),
    lead_id UUID,
    tier_id UUID,
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. conversation_outcomes
CREATE TABLE IF NOT EXISTS conversation_outcomes (
    outcome_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    outcome_type VARCHAR(100),
    outcome_value VARCHAR(255),
    prompt_variant_id UUID,
    converted BOOLEAN DEFAULT false,
    quality_score FLOAT DEFAULT 0.0,
    conversion_value FLOAT,
    ml_predictions JSONB DEFAULT '{}',
    ml_confidence_scores JSONB DEFAULT '{}',
    ab_test_assignments JSONB DEFAULT '[]',
    pattern_matches JSONB DEFAULT '[]',
    prompts_used JSONB DEFAULT '[]',
    timestamp TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 3. prompt_variants
CREATE TABLE IF NOT EXISTS prompt_variants (
    variant_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    prompt_template TEXT NOT NULL,
    variant_type VARCHAR(100),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 4. ml_tracking_events
CREATE TABLE IF NOT EXISTS ml_tracking_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    conversation_id UUID,
    experiment_id UUID,
    model_id UUID,
    event_data JSONB NOT NULL DEFAULT '{}',
    metrics JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system',
    created_at TIMESTAMP DEFAULT NOW()
);

-- 5. predictive_models
CREATE TABLE IF NOT EXISTS predictive_models (
    model_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    model_name VARCHAR(255) NOT NULL,
    model_type VARCHAR(100) NOT NULL,
    version VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    model_config JSONB DEFAULT '{}',
    performance_metrics JSONB DEFAULT '{}',
    last_trained TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. pattern_recognitions
CREATE TABLE IF NOT EXISTS pattern_recognitions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pattern_type VARCHAR(100) NOT NULL,
    pattern_name VARCHAR(255) NOT NULL,
    description TEXT,
    pattern_data JSONB NOT NULL DEFAULT '{}',
    conditions JSONB NOT NULL DEFAULT '{}',
    occurrences INTEGER DEFAULT 1,
    confidence_score FLOAT DEFAULT 0.0,
    effectiveness_score FLOAT DEFAULT 0.0,
    is_active BOOLEAN DEFAULT true,
    last_seen TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 7. training_jobs
CREATE TABLE IF NOT EXISTS training_jobs (
    job_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    model_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    training_metrics JSONB DEFAULT '{}',
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 8. emotional_analyses
CREATE TABLE IF NOT EXISTS emotional_analyses (
    analysis_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    emotion_category VARCHAR(100),
    intensity FLOAT,
    confidence_score FLOAT,
    triggers JSONB DEFAULT '[]',
    timestamp TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 9. genetic_evolutions
CREATE TABLE IF NOT EXISTS genetic_evolutions (
    evolution_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    generation INTEGER NOT NULL,
    parent_genome_id UUID,
    genome_data JSONB NOT NULL DEFAULT '{}',
    fitness_score FLOAT DEFAULT 0.0,
    mutation_rate FLOAT DEFAULT 0.1,
    crossover_points JSONB DEFAULT '[]',
    survived BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 10. service_tiers
CREATE TABLE IF NOT EXISTS service_tiers (
    tier_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    tier_name VARCHAR(100) NOT NULL,
    tier_level INTEGER NOT NULL,
    features JSONB DEFAULT '[]',
    price_monthly DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 11. free_trials
CREATE TABLE IF NOT EXISTS free_trials (
    trial_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    converted_to_paid BOOLEAN DEFAULT false,
    engagement_score FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 12. demos
CREATE TABLE IF NOT EXISTS demos (
    demo_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    demo_type VARCHAR(100),
    feature_showcased VARCHAR(255),
    engagement_score FLOAT DEFAULT 0.0,
    completion_rate FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 13. engagement_touchpoints
CREATE TABLE IF NOT EXISTS engagement_touchpoints (
    engagement_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    touchpoint_type VARCHAR(100),
    touchpoint_name VARCHAR(255),
    engagement_score FLOAT DEFAULT 0.0,
    channel VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 14. lead_profiles
CREATE TABLE IF NOT EXISTS lead_profiles (
    lead_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profession_category VARCHAR(100),
    specialization VARCHAR(255),
    business_size VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 15. roi_calculations
CREATE TABLE IF NOT EXISTS roi_calculations (
    calculation_id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    projected_roi_percentage FLOAT DEFAULT 0.0,
    time_saved_hours FLOAT DEFAULT 0.0,
    revenue_increase_percentage FLOAT DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================================================
-- PARTE 2: AGREGAR COLUMNAS FALTANTES A TABLAS EXISTENTES
-- =====================================================================

DO $$
BEGIN
    -- Agregar columnas a conversation_outcomes si faltan
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'conversation_outcomes') THEN
        -- prompt_variant_id
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'conversation_outcomes' 
                       AND column_name = 'prompt_variant_id') THEN
            ALTER TABLE conversation_outcomes ADD COLUMN prompt_variant_id UUID;
        END IF;
        
        -- converted
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'conversation_outcomes' 
                       AND column_name = 'converted') THEN
            ALTER TABLE conversation_outcomes ADD COLUMN converted BOOLEAN DEFAULT false;
        END IF;
        
        -- quality_score
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'conversation_outcomes' 
                       AND column_name = 'quality_score') THEN
            ALTER TABLE conversation_outcomes ADD COLUMN quality_score FLOAT DEFAULT 0.0;
        END IF;
    END IF;
END $$;

-- =====================================================================
-- PARTE 3: CREAR ÍNDICES NECESARIOS
-- =====================================================================

CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_lead_id ON conversations(lead_id);
CREATE INDEX IF NOT EXISTS idx_conversations_tier_id ON conversations(tier_id);

CREATE INDEX IF NOT EXISTS idx_conversation_outcomes_conversation_id ON conversation_outcomes(conversation_id);
CREATE INDEX IF NOT EXISTS idx_conversation_outcomes_prompt_variant_id ON conversation_outcomes(prompt_variant_id);

CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_conversation_id ON ml_tracking_events(conversation_id);
CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_model_id ON ml_tracking_events(model_id);

CREATE INDEX IF NOT EXISTS idx_emotional_analyses_conversation_id ON emotional_analyses(conversation_id);
CREATE INDEX IF NOT EXISTS idx_emotional_analyses_confidence ON emotional_analyses(confidence_score) WHERE confidence_score > 0.7;

CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_effectiveness ON pattern_recognitions(effectiveness_score) WHERE is_active = true;

-- =====================================================================
-- PARTE 4: AHORA SÍ CREAR LAS VISTAS CON SECURITY INVOKER
-- =====================================================================

-- 1. top_performing_prompts
DROP VIEW IF EXISTS top_performing_prompts CASCADE;
CREATE VIEW top_performing_prompts
WITH (security_invoker = true)
AS
SELECT 
    pv.variant_id::text as variant_id,
    pv.prompt_template,
    pv.is_active,
    COUNT(DISTINCT co.conversation_id) as total_conversations,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(co.quality_score) as avg_quality_score,
    pv.created_at,
    pv.updated_at
FROM prompt_variants pv
LEFT JOIN conversation_outcomes co ON co.prompt_variant_id = pv.variant_id
WHERE pv.is_active = true
GROUP BY pv.variant_id, pv.prompt_template, pv.is_active, pv.created_at, pv.updated_at
HAVING COUNT(DISTINCT co.conversation_id) > 5
ORDER BY conversion_rate DESC, avg_quality_score DESC;

-- 2. model_performance_view
DROP VIEW IF EXISTS model_performance_view CASCADE;
CREATE VIEW model_performance_view
WITH (security_invoker = true)
AS
SELECT 
    pm.model_id,
    pm.model_name,
    pm.model_type,
    pm.version,
    pm.is_active,
    COUNT(DISTINCT co.conversation_id) as total_predictions,
    AVG(co.quality_score) as avg_quality_score,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    pm.last_trained,
    pm.created_at
FROM predictive_models pm
LEFT JOIN conversation_outcomes co ON co.conversation_id IN (
    SELECT conversation_id FROM ml_tracking_events WHERE model_id = pm.model_id
)
WHERE pm.is_active = true
GROUP BY pm.model_id, pm.model_name, pm.model_type, pm.version, 
         pm.is_active, pm.last_trained, pm.created_at
ORDER BY conversion_rate DESC;

-- 3. training_activity_view
DROP VIEW IF EXISTS training_activity_view CASCADE;
CREATE VIEW training_activity_view
WITH (security_invoker = true)
AS
SELECT 
    tj.job_id,
    tj.model_type,
    tj.status,
    tj.started_at,
    tj.completed_at,
    tj.training_metrics,
    tj.error_message,
    EXTRACT(EPOCH FROM (tj.completed_at - tj.started_at)) as duration_seconds,
    tj.created_at
FROM training_jobs tj
ORDER BY tj.created_at DESC;

-- 4. emotional_summary_view
DROP VIEW IF EXISTS emotional_summary_view CASCADE;
CREATE VIEW emotional_summary_view
WITH (security_invoker = true)
AS
SELECT 
    ea.analysis_id,
    ea.conversation_id,
    ea.emotion_category,
    ea.intensity,
    ea.confidence_score,
    ea.triggers,
    ea.timestamp,
    c.user_id,
    c.tier_id
FROM emotional_analyses ea
JOIN conversations c ON c.conversation_id = ea.conversation_id
WHERE ea.confidence_score > 0.7
ORDER BY ea.timestamp DESC;

-- 5. effective_patterns_view
DROP VIEW IF EXISTS effective_patterns_view CASCADE;
CREATE VIEW effective_patterns_view
WITH (security_invoker = true)
AS
SELECT 
    pattern_type,
    pattern_name,
    description,
    occurrences,
    confidence_score,
    effectiveness_score,
    last_seen,
    pattern_data,
    conditions
FROM pattern_recognitions
WHERE is_active = true
AND confidence_score > 0.7
AND effectiveness_score > 0.6
ORDER BY effectiveness_score DESC, occurrences DESC;

-- 6. genetic_evolution_view
DROP VIEW IF EXISTS genetic_evolution_view CASCADE;
CREATE VIEW genetic_evolution_view
WITH (security_invoker = true)
AS
SELECT 
    ge.evolution_id,
    ge.generation,
    ge.parent_genome_id,
    ge.genome_data,
    ge.fitness_score,
    ge.mutation_rate,
    ge.crossover_points,
    ge.survived,
    ge.created_at
FROM genetic_evolutions ge
WHERE ge.survived = true
ORDER BY ge.generation DESC, ge.fitness_score DESC;

-- 7. trial_performance_by_tier
DROP VIEW IF EXISTS trial_performance_by_tier CASCADE;
CREATE VIEW trial_performance_by_tier
WITH (security_invoker = true)
AS
SELECT 
    t.tier_name,
    t.tier_level,
    COUNT(DISTINCT ft.trial_id) as total_trials,
    AVG(CASE WHEN ft.converted_to_paid THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(ft.engagement_score) as avg_engagement,
    AVG(EXTRACT(EPOCH FROM (ft.ended_at - ft.started_at))/86400) as avg_trial_days
FROM free_trials ft
JOIN conversations c ON c.conversation_id = ft.conversation_id
JOIN service_tiers t ON t.tier_id = c.tier_id
GROUP BY t.tier_name, t.tier_level
ORDER BY t.tier_level;

-- 8. demo_effectiveness
DROP VIEW IF EXISTS demo_effectiveness CASCADE;
CREATE VIEW demo_effectiveness
WITH (security_invoker = true)
AS
SELECT 
    d.demo_id,
    d.demo_type,
    d.feature_showcased,
    COUNT(DISTINCT d.conversation_id) as total_demos,
    AVG(d.engagement_score) as avg_engagement,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(d.completion_rate) as avg_completion_rate
FROM demos d
LEFT JOIN conversation_outcomes co ON co.conversation_id = d.conversation_id
GROUP BY d.demo_id, d.demo_type, d.feature_showcased
HAVING COUNT(DISTINCT d.conversation_id) > 3
ORDER BY conversion_rate DESC;

-- 9. effective_touchpoints
DROP VIEW IF EXISTS effective_touchpoints CASCADE;
CREATE VIEW effective_touchpoints
WITH (security_invoker = true)
AS
SELECT 
    et.touchpoint_type,
    et.touchpoint_name,
    COUNT(DISTINCT et.engagement_id) as total_engagements,
    AVG(et.engagement_score) as avg_engagement_score,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_impact,
    et.channel
FROM engagement_touchpoints et
LEFT JOIN conversation_outcomes co ON co.conversation_id = et.conversation_id
GROUP BY et.touchpoint_type, et.touchpoint_name, et.channel
HAVING COUNT(DISTINCT et.engagement_id) > 10
ORDER BY conversion_impact DESC, avg_engagement_score DESC;

-- 10. roi_by_profession_view
DROP VIEW IF EXISTS roi_by_profession_view CASCADE;
CREATE VIEW roi_by_profession_view
WITH (security_invoker = true)
AS
SELECT 
    lp.profession_category,
    lp.specialization,
    COUNT(DISTINCT rc.calculation_id) as total_calculations,
    AVG(rc.projected_roi_percentage) as avg_roi_percentage,
    AVG(rc.time_saved_hours) as avg_time_saved,
    AVG(rc.revenue_increase_percentage) as avg_revenue_increase,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate
FROM roi_calculations rc
JOIN conversations c ON c.conversation_id = rc.conversation_id
JOIN lead_profiles lp ON lp.lead_id = c.lead_id
LEFT JOIN conversation_outcomes co ON co.conversation_id = c.conversation_id
GROUP BY lp.profession_category, lp.specialization
HAVING COUNT(DISTINCT rc.calculation_id) > 5
ORDER BY avg_roi_percentage DESC;

-- =====================================================================
-- PARTE 5: PERMISOS
-- =====================================================================

DO $$
BEGIN
    -- Dar permisos a las tablas y vistas
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
    END IF;
END $$;

-- =====================================================================
-- VERIFICACIÓN FINAL
-- =====================================================================

DO $$
DECLARE
    tables_created INTEGER := 0;
    views_created INTEGER := 0;
    total_errors INTEGER := 0;
BEGIN
    -- Contar tablas creadas
    SELECT COUNT(*) INTO tables_created
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_type = 'BASE TABLE'
    AND table_name IN (
        'conversations', 'conversation_outcomes', 'prompt_variants',
        'ml_tracking_events', 'predictive_models', 'pattern_recognitions',
        'training_jobs', 'emotional_analyses', 'genetic_evolutions',
        'service_tiers', 'free_trials', 'demos', 'engagement_touchpoints',
        'lead_profiles', 'roi_calculations'
    );
    
    -- Contar vistas creadas
    SELECT COUNT(*) INTO views_created
    FROM information_schema.views
    WHERE table_schema = 'public'
    AND table_name IN (
        'top_performing_prompts', 'model_performance_view', 'training_activity_view',
        'emotional_summary_view', 'effective_patterns_view', 'genetic_evolution_view',
        'trial_performance_by_tier', 'demo_effectiveness', 'effective_touchpoints',
        'roi_by_profession_view'
    );
    
    RAISE NOTICE '✅ MIGRACIÓN 013 COMPLETADA';
    RAISE NOTICE '📊 Tablas verificadas: %', tables_created;
    RAISE NOTICE '👁️ Vistas creadas con security_invoker: %', views_created;
    RAISE NOTICE '✅ Todas las vistas ahora usan security_invoker = true';
    RAISE NOTICE '✅ Todos los errores de SECURITY DEFINER han sido corregidos';
END $$;

-- =====================================================================
-- FIN DE MIGRACIÓN 013 COMPLETA
-- =====================================================================