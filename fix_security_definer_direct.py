#!/usr/bin/env python3
"""
Script para ELIMINAR DIRECTAMENTE los errores de SECURITY DEFINER
NO crear nuevas vistas - SOLO ELIMINAR las problemáticas
"""
import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Obtener credenciales
url = os.getenv("SUPABASE_URL")
service_key = os.getenv("SUPABASE_SERVICE_ROLE_KEY")

if not url or not service_key:
    print("❌ Error: Credenciales de Supabase no encontradas")
    exit(1)

# Crear cliente con service role key para operaciones administrativas
supabase: Client = create_client(url, service_key)

print("🔧 ELIMINANDO ERRORES DE SECURITY DEFINER...\n")

# Query para identificar todas las vistas con SECURITY DEFINER
query_views = """
SELECT 
    schemaname,
    viewname,
    definition
FROM pg_views
WHERE schemaname = 'public'
AND definition LIKE '%SECURITY DEFINER%'
ORDER BY viewname;
"""

try:
    # Ejecutar query para obtener vistas problemáticas
    print("1. Identificando vistas con SECURITY DEFINER...")
    result = supabase.rpc('execute_sql', {'query': query_views}).execute()
    
    if result.data:
        views = result.data
        print(f"\n✅ Encontradas {len(views)} vistas con SECURITY DEFINER:")
        
        for view in views:
            print(f"   - {view['viewname']}")
        
        # Preguntar confirmación
        print(f"\n⚠️  ADVERTENCIA: Se eliminarán {len(views)} vistas.")
        response = input("¿Deseas continuar? (s/n): ")
        
        if response.lower() == 's':
            # Eliminar cada vista
            for i, view in enumerate(views, 1):
                view_name = view['viewname']
                drop_query = f"DROP VIEW IF EXISTS public.{view_name} CASCADE;"
                
                try:
                    print(f"\n{i}/{len(views)} Eliminando: {view_name}...")
                    supabase.rpc('execute_sql', {'query': drop_query}).execute()
                    print(f"   ✅ Vista {view_name} eliminada exitosamente")
                except Exception as e:
                    print(f"   ❌ Error eliminando {view_name}: {str(e)}")
            
            print("\n✅ PROCESO COMPLETADO")
            print("Las vistas con SECURITY DEFINER han sido eliminadas.")
            print("Los errores del Security Advisor deberían estar resueltos.")
            
        else:
            print("\n❌ Operación cancelada por el usuario")
    else:
        print("\n✅ No se encontraron vistas con SECURITY DEFINER")
        print("Es posible que el problema esté en otro lugar.")

except Exception as e:
    print(f"\n❌ Error al ejecutar la consulta: {str(e)}")
    
    # Si no funciona con RPC, intentar con la API REST directamente
    print("\n🔄 Intentando método alternativo...")
    
    try:
        # Listar todas las tablas/vistas
        tables = supabase.table('information_schema.views').select('*').eq('table_schema', 'public').execute()
        
        if tables.data:
            print(f"\nEncontradas {len(tables.data)} vistas en el esquema público")
            # Aquí podrías procesar las vistas si el método anterior falla
        else:
            print("\nNo se pudieron obtener las vistas por este método")
            
    except Exception as e2:
        print(f"❌ Error con método alternativo: {str(e2)}")
        
print("\n🔍 Si los errores persisten, ejecuta 'supabase db push' para sincronizar el esquema.")