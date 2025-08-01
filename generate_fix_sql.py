#!/usr/bin/env python3
"""
Genera los comandos SQL para ejecutar en el dashboard de Supabase
"""

print("🔧 COMANDOS SQL PARA ELIMINAR VISTAS CON SECURITY DEFINER")
print("=" * 60)
print("\nPASO 1: Copia y ejecuta este comando en el SQL Editor de Supabase para identificar las vistas problemáticas:\n")

identify_sql = """-- Identificar todas las vistas con SECURITY DEFINER
SELECT 
    schemaname,
    viewname,
    LEFT(definition, 100) as definition_preview
FROM pg_views
WHERE schemaname = 'public'
AND definition LIKE '%SECURITY DEFINER%'
ORDER BY viewname;"""

print(identify_sql)

print("\n" + "=" * 60)
print("\nPASO 2: Para cada vista encontrada, ejecuta este comando (reemplaza [nombre_vista] con el nombre real):\n")

drop_template = """-- Eliminar vista con SECURITY DEFINER
DROP VIEW IF EXISTS public.[nombre_vista] CASCADE;"""

print(drop_template)

print("\n" + "=" * 60)
print("\nPASO 3: Si quieres eliminar TODAS las vistas con SECURITY DEFINER de una vez, ejecuta:\n")

drop_all_sql = """-- ADVERTENCIA: Esto eliminará TODAS las vistas con SECURITY DEFINER
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT viewname 
        FROM pg_views 
        WHERE schemaname = 'public' 
        AND definition LIKE '%SECURITY DEFINER%'
    LOOP
        EXECUTE 'DROP VIEW IF EXISTS public.' || quote_ident(r.viewname) || ' CASCADE';
        RAISE NOTICE 'Eliminada vista: %', r.viewname;
    END LOOP;
END $$;"""

print(drop_all_sql)

print("\n" + "=" * 60)
print("\nPASO 4: Verifica que no queden vistas con SECURITY DEFINER:\n")

verify_sql = """-- Verificar si quedan vistas con SECURITY DEFINER
SELECT COUNT(*) as vistas_restantes
FROM pg_views
WHERE schemaname = 'public'
AND definition LIKE '%SECURITY DEFINER%';"""

print(verify_sql)

print("\n" + "=" * 60)
print("\nPASO 5: Si necesitas recrear alguna vista sin SECURITY DEFINER:\n")

recreate_template = """-- Primero obtén la definición de la vista
SELECT definition 
FROM pg_views 
WHERE schemaname = 'public' 
AND viewname = '[nombre_vista]';

-- Luego recréala sin SECURITY DEFINER
CREATE OR REPLACE VIEW public.[nombre_vista] AS
[pega aquí la definición sin la línea SECURITY DEFINER];"""

print(recreate_template)

print("\n" + "=" * 60)
print("\n💡 INSTRUCCIONES:")
print("1. Ve a tu proyecto en https://supabase.com")
print("2. Navega a SQL Editor")
print("3. Ejecuta los comandos en orden")
print("4. Después de eliminar las vistas, ve a Database > Security Advisor")
print("5. Verifica que los errores hayan desaparecido")
print("\n⚠️  IMPORTANTE: Hacer un backup de tu base de datos antes de ejecutar estos comandos")
print("=" * 60)