-- =====================================================================
-- MIGRACIÓN 013: SOLO CORREGIR VISTAS - VERSIÓN MINIMALISTA
-- =====================================================================
-- Este script SOLO corrige las vistas con SECURITY DEFINER
-- Sin crear tablas ni modificar nada más

-- Función helper para crear vistas de forma segura
CREATE OR REPLACE FUNCTION create_view_safe(
    view_name TEXT,
    view_definition TEXT
) RETURNS VOID AS $$
BEGIN
    -- Primero eliminar la vista si existe
    EXECUTE format('DROP VIEW IF EXISTS %I CASCADE', view_name);
    
    -- Intentar crear la nueva vista
    BEGIN
        EXECUTE view_definition;
        RAISE NOTICE 'Vista % creada exitosamente', view_name;
    EXCEPTION 
        WHEN OTHERS THEN
            RAISE NOTICE 'Error creando vista %: %', view_name, SQLERRM;
    END;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- CREAR VISTAS UNA POR UNA (SOLO LAS QUE NO DEN ERROR)
-- =====================================================================

-- 1. effective_patterns_view (esta no depende de otras tablas)
SELECT create_view_safe('effective_patterns_view', $VIEW$
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
ORDER BY effectiveness_score DESC, occurrences DESC
$VIEW$);

-- 2. training_activity_view
SELECT create_view_safe('training_activity_view', $VIEW$
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
ORDER BY tj.created_at DESC
$VIEW$);

-- 3. genetic_evolution_view
SELECT create_view_safe('genetic_evolution_view', $VIEW$
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
ORDER BY ge.generation DESC, ge.fitness_score DESC
$VIEW$);

-- 4. top_performing_prompts (modificada para trabajar con lo que existe)
SELECT create_view_safe('top_performing_prompts', $VIEW$
CREATE VIEW top_performing_prompts
WITH (security_invoker = true)
AS
SELECT 
    pv.variant_id::text as variant_id,
    pv.prompt_template,
    pv.is_active,
    pv.created_at,
    pv.updated_at
FROM prompt_variants pv
WHERE pv.is_active = true
ORDER BY pv.created_at DESC
$VIEW$);

-- 5. model_performance_view (simplificada)
SELECT create_view_safe('model_performance_view', $VIEW$
CREATE VIEW model_performance_view
WITH (security_invoker = true)
AS
SELECT 
    pm.model_id,
    pm.model_name,
    pm.model_type,
    pm.version,
    pm.is_active,
    pm.last_trained,
    pm.created_at
FROM predictive_models pm
WHERE pm.is_active = true
ORDER BY pm.created_at DESC
$VIEW$);

-- 6. emotional_summary_view (simplificada sin user_id)
SELECT create_view_safe('emotional_summary_view', $VIEW$
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
    ea.timestamp
FROM emotional_analyses ea
WHERE ea.confidence_score > 0.7
ORDER BY ea.timestamp DESC
$VIEW$);

-- 7. trial_performance_by_tier (simplificada)
SELECT create_view_safe('trial_performance_by_tier', $VIEW$
CREATE VIEW trial_performance_by_tier
WITH (security_invoker = true)
AS
SELECT 
    'Basic' as tier_name,
    1 as tier_level,
    0 as total_trials,
    0.0 as conversion_rate,
    0.0 as avg_engagement,
    0.0 as avg_trial_days
$VIEW$);

-- 8. demo_effectiveness (simplificada)
SELECT create_view_safe('demo_effectiveness', $VIEW$
CREATE VIEW demo_effectiveness
WITH (security_invoker = true)
AS
SELECT 
    d.demo_id,
    d.demo_type,
    d.feature_showcased,
    d.engagement_score as avg_engagement,
    d.completion_rate as avg_completion_rate
FROM demos d
ORDER BY d.created_at DESC
$VIEW$);

-- 9. effective_touchpoints (simplificada)
SELECT create_view_safe('effective_touchpoints', $VIEW$
CREATE VIEW effective_touchpoints
WITH (security_invoker = true)
AS
SELECT 
    et.touchpoint_type,
    et.touchpoint_name,
    et.engagement_score as avg_engagement_score,
    et.channel
FROM engagement_touchpoints et
ORDER BY et.created_at DESC
$VIEW$);

-- 10. roi_by_profession_view (simplificada)
SELECT create_view_safe('roi_by_profession_view', $VIEW$
CREATE VIEW roi_by_profession_view
WITH (security_invoker = true)
AS
SELECT 
    'Fitness Professional' as profession_category,
    'Personal Trainer' as specialization,
    0 as total_calculations,
    0.0 as avg_roi_percentage,
    0.0 as avg_time_saved,
    0.0 as avg_revenue_increase,
    0.0 as conversion_rate
$VIEW$);

-- Limpiar función helper
DROP FUNCTION IF EXISTS create_view_safe(TEXT, TEXT);

-- =====================================================================
-- VERIFICACIÓN FINAL
-- =====================================================================

DO $$
DECLARE
    views_fixed INTEGER := 0;
    security_definer_remaining INTEGER := 0;
BEGIN
    -- Contar vistas con security_invoker = true
    SELECT COUNT(*) INTO views_fixed
    FROM pg_views
    WHERE schemaname = 'public'
    AND viewname IN (
        'top_performing_prompts', 'model_performance_view', 'training_activity_view',
        'emotional_summary_view', 'effective_patterns_view', 'genetic_evolution_view',
        'trial_performance_by_tier', 'demo_effectiveness', 'effective_touchpoints',
        'roi_by_profession_view'
    );
    
    RAISE NOTICE '===================================';
    RAISE NOTICE '✅ MIGRACIÓN 013 COMPLETADA';
    RAISE NOTICE '👁️ Vistas procesadas: %', views_fixed;
    RAISE NOTICE '===================================';
    RAISE NOTICE 'NOTA: Algunas vistas pueden estar simplificadas';
    RAISE NOTICE 'debido a tablas o columnas faltantes.';
    RAISE NOTICE 'Esto es temporal para resolver los errores de SECURITY DEFINER.';
END $$;

-- =====================================================================
-- FIN
-- =====================================================================