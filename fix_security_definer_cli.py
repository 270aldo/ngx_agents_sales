#!/usr/bin/env python3
"""
Script para ELIMINAR vistas con SECURITY DEFINER usando Supabase CLI
"""
import subprocess
import json
import os

print("🔧 ELIMINANDO ERRORES DE SECURITY DEFINER USANDO SUPABASE CLI...\n")

# Query para identificar vistas con SECURITY DEFINER
identify_query = """
SELECT 
    schemaname,
    viewname
FROM pg_views
WHERE schemaname = 'public'
AND definition LIKE '%SECURITY DEFINER%'
ORDER BY viewname;
"""

def execute_sql(query):
    """Ejecuta una query usando supabase db execute"""
    try:
        result = subprocess.run(
            ['supabase', 'db', 'execute', '--sql', query],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"❌ Error ejecutando SQL: {e.stderr}")
        return None

# Primero, obtener la lista de vistas problemáticas
print("1. Identificando vistas con SECURITY DEFINER...")
output = execute_sql(identify_query)

if output:
    # Parsear el output para obtener los nombres de las vistas
    lines = output.strip().split('\n')
    views = []
    
    # Buscar las líneas con nombres de vistas (después del header)
    in_data = False
    for line in lines:
        if '|' in line and 'viewname' not in line.lower():
            parts = [p.strip() for p in line.split('|')]
            if len(parts) >= 2 and parts[1]:  # viewname está en la segunda columna
                view_name = parts[1].strip()
                if view_name and view_name != '-' and not view_name.startswith('-'):
                    views.append(view_name)
    
    if views:
        print(f"\n✅ Encontradas {len(views)} vistas con SECURITY DEFINER:")
        for view in views:
            print(f"   - {view}")
        
        print(f"\n⚠️  ADVERTENCIA: Se eliminarán {len(views)} vistas.")
        response = input("¿Deseas continuar? (s/n): ")
        
        if response.lower() == 's':
            # Eliminar cada vista
            for i, view_name in enumerate(views, 1):
                drop_query = f"DROP VIEW IF EXISTS public.{view_name} CASCADE;"
                
                print(f"\n{i}/{len(views)} Eliminando: {view_name}...")
                result = execute_sql(drop_query)
                
                if result:
                    print(f"   ✅ Vista {view_name} eliminada")
                else:
                    print(f"   ❌ Error eliminando {view_name}")
            
            print("\n✅ PROCESO COMPLETADO")
            print("Las vistas con SECURITY DEFINER han sido eliminadas.")
            
            # Verificar si quedan errores
            print("\n🔍 Verificando si quedan vistas con SECURITY DEFINER...")
            check_output = execute_sql(identify_query)
            if check_output and 'rows)' in check_output and '(0 rows)' in check_output:
                print("✅ No quedan vistas con SECURITY DEFINER")
            else:
                print("⚠️  Puede que aún queden algunas vistas")
                
        else:
            print("\n❌ Operación cancelada")
    else:
        print("\n✅ No se encontraron vistas con SECURITY DEFINER en el output")
else:
    print("\n❌ No se pudo ejecutar la query de identificación")

print("\n💡 Si los errores persisten:")
print("   1. Ejecuta: supabase db push --dry-run")
print("   2. Revisa el Security Advisor en el dashboard de Supabase")
print("   3. Considera resetear las migraciones si es necesario")