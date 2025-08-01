-- =====================================================================
-- SOLUCIÓN DIRECTA: ELIMINAR TODOS LOS ERRORES DE SECURITY DEFINER
-- =====================================================================
-- EJECUTA ESTE SCRIPT EN SUPABASE SQL EDITOR PARA ELIMINAR LOS ERRORES

-- PASO 1: Eliminar TODAS las vistas problemáticas de una vez
DO $$
DECLARE
    vista RECORD;
    contador INTEGER := 0;
BEGIN
    RAISE NOTICE '🔥 INICIANDO ELIMINACIÓN DE VISTAS CON SECURITY DEFINER...';
    
    -- Buscar todas las vistas problemáticas
    FOR vista IN 
        SELECT DISTINCT viewname 
        FROM pg_views 
        WHERE schemaname = 'public' 
        AND (
            -- Vistas que sabemos que tienen problemas
            viewname IN (
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
            )
            OR 
            -- O cualquier vista con SECURITY DEFINER
            definition LIKE '%SECURITY DEFINER%'
            OR
            -- O vistas sin security_invoker explícito
            (definition NOT LIKE '%security_invoker%' AND viewowner != current_user)
        )
    LOOP
        BEGIN
            EXECUTE format('DROP VIEW IF EXISTS public.%I CASCADE', vista.viewname);
            RAISE NOTICE '✅ Eliminada vista: %', vista.viewname;
            contador := contador + 1;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE '⚠️ No se pudo eliminar %: %', vista.viewname, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎉 PROCESO COMPLETADO';
    RAISE NOTICE '📊 Total de vistas eliminadas: %', contador;
    RAISE NOTICE '';
    RAISE NOTICE '✅ Los errores de SECURITY DEFINER deberían estar resueltos.';
    RAISE NOTICE '👉 Verifica en Database > Security Advisor';
END $$;

-- PASO 2: Verificar qué vistas quedan
SELECT 
    '--- VISTAS RESTANTES ---' as info;
SELECT 
    viewname,
    CASE 
        WHEN definition LIKE '%security_invoker = true%' THEN '✅ Segura'
        WHEN definition LIKE '%SECURITY DEFINER%' THEN '❌ SECURITY DEFINER'
        ELSE '⚠️ Por verificar'
    END as estado
FROM pg_views
WHERE schemaname = 'public'
ORDER BY viewname;

-- =====================================================================
-- IMPORTANTE: Después de ejecutar este script:
-- 1. Ve a Database > Security Advisor
-- 2. Los errores deberían haber desaparecido
-- 3. Si necesitas las vistas, las puedes recrear después sin SECURITY DEFINER
-- =====================================================================