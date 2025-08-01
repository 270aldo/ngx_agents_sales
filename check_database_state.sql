-- =====================================================================
-- VERIFICAR ESTADO ACTUAL DE LA BASE DE DATOS
-- =====================================================================
-- Este script verifica qué tablas y columnas existen actualmente

-- 1. Listar TODAS las tablas que existen
SELECT 
    'TABLAS EXISTENTES:' as info;
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- 2. Verificar columnas de conversations
SELECT 
    '---' as separator,
    'COLUMNAS DE conversations:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'conversations'
ORDER BY ordinal_position;

-- 3. Verificar columnas de conversation_outcomes
SELECT 
    '---' as separator,
    'COLUMNAS DE conversation_outcomes:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'conversation_outcomes'
ORDER BY ordinal_position;

-- 4. Verificar columnas de prompt_variants
SELECT 
    '---' as separator,
    'COLUMNAS DE prompt_variants:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'prompt_variants'
ORDER BY ordinal_position;

-- 5. Verificar columnas de ml_tracking_events
SELECT 
    '---' as separator,
    'COLUMNAS DE ml_tracking_events:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'ml_tracking_events'
ORDER BY ordinal_position;

-- 6. Verificar columnas de predictive_models
SELECT 
    '---' as separator,
    'COLUMNAS DE predictive_models:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'predictive_models'
ORDER BY ordinal_position;

-- 7. Verificar vistas con problemas
SELECT 
    '---' as separator,
    'VISTAS CON SECURITY DEFINER:' as info;
SELECT 
    schemaname,
    viewname
FROM pg_views
WHERE schemaname = 'public'
AND viewname IN (
    'top_performing_prompts',
    'model_performance_view',
    'training_activity_view',
    'emotional_summary_view',
    'effective_patterns_view',
    'genetic_evolution_view',
    'trial_performance_by_tier',
    'demo_effectiveness',
    'effective_touchpoints',
    'roi_by_profession_view'
);

-- 8. Buscar columna user_id en TODAS las tablas
SELECT 
    '---' as separator,
    'TABLAS QUE TIENEN COLUMNA user_id:' as info;
SELECT 
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND column_name = 'user_id'
ORDER BY table_name;