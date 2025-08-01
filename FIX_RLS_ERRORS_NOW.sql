-- =====================================================================
-- SOLUCIÓN RÁPIDA: HABILITAR RLS EN TODAS LAS TABLAS
-- =====================================================================
-- Este script habilita Row Level Security en todas las tablas que lo necesitan

DO $$
DECLARE
    tabla RECORD;
    contador INTEGER := 0;
BEGIN
    RAISE NOTICE '🔒 HABILITANDO ROW LEVEL SECURITY EN TODAS LAS TABLAS...';
    
    -- Lista de tablas que necesitan RLS según los errores
    FOR tabla IN 
        SELECT unnest(ARRAY[
            'high_impact_value_components',
            'adaptive_learning_config',
            'learned_models',
            'ml_experiments',
            'experiment_results',
            'customer_profiles',
            'conversation_outcomes',
            'ab_test_variants',
            'ab_test_results',
            'pattern_recognitions'
        ]) AS table_name
    LOOP
        BEGIN
            -- Habilitar RLS
            EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', tabla.table_name);
            
            -- Crear política permisiva para service_role (permite todo)
            EXECUTE format('
                CREATE POLICY "Service role can do anything" ON %I
                FOR ALL
                TO service_role
                USING (true)
                WITH CHECK (true)
            ', tabla.table_name);
            
            -- Crear política para authenticated users (solo lectura por ahora)
            EXECUTE format('
                CREATE POLICY "Authenticated users can read" ON %I
                FOR SELECT
                TO authenticated
                USING (true)
            ', tabla.table_name);
            
            RAISE NOTICE '✅ RLS habilitado en: %', tabla.table_name;
            contador := contador + 1;
            
        EXCEPTION
            WHEN duplicate_object THEN
                RAISE NOTICE '⚠️ Las políticas ya existen para: %', tabla.table_name;
            WHEN undefined_table THEN
                RAISE NOTICE '⚠️ La tabla % no existe', tabla.table_name;
            WHEN OTHERS THEN
                RAISE NOTICE '❌ Error con %: %', tabla.table_name, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE '';
    RAISE NOTICE '🎉 PROCESO COMPLETADO';
    RAISE NOTICE '📊 Tablas procesadas: %', contador;
    RAISE NOTICE '';
    RAISE NOTICE '✅ Los errores de RLS deberían estar resueltos.';
    RAISE NOTICE '👉 Verifica en Database > Security Advisor';
END $$;

-- Verificar el estado de RLS
SELECT 
    '--- ESTADO DE RLS EN LAS TABLAS ---' as info;
SELECT 
    schemaname,
    tablename,
    CASE 
        WHEN rowsecurity = true THEN '✅ RLS Habilitado'
        ELSE '❌ RLS Deshabilitado'
    END as rls_status
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN (
    'high_impact_value_components',
    'adaptive_learning_config',
    'learned_models',
    'ml_experiments',
    'experiment_results',
    'customer_profiles',
    'conversation_outcomes',
    'ab_test_variants',
    'ab_test_results',
    'pattern_recognitions'
)
ORDER BY tablename;

-- =====================================================================
-- NOTA: Este script habilita RLS con políticas básicas:
-- - service_role: Acceso completo
-- - authenticated: Solo lectura
-- 
-- Puedes ajustar las políticas más adelante según tus necesidades
-- =====================================================================