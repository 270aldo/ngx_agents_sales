#!/usr/bin/env python3
"""
Script para ELIMINAR vistas con SECURITY DEFINER usando conexión directa
"""
import os
import psycopg2
from urllib.parse import urlparse
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Obtener URL de Supabase
supabase_url = os.getenv("SUPABASE_URL")
if not supabase_url:
    print("❌ Error: SUPABASE_URL no encontrada")
    exit(1)

# Parsear la URL para obtener el host
parsed = urlparse(supabase_url)
db_host = parsed.hostname.replace('.supabase.co', '')

# Construir la URL de conexión PostgreSQL
# Formato: postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
db_url = f"postgresql://postgres.{db_host}:{os.getenv('SUPABASE_SERVICE_ROLE_KEY')}@aws-0-us-east-1.pooler.supabase.com:6543/postgres"

print("🔧 ELIMINANDO ERRORES DE SECURITY DEFINER...\n")

try:
    # Conectar a la base de datos
    print("Conectando a la base de datos...")
    conn = psycopg2.connect(db_url)
    cur = conn.cursor()
    
    # Query para identificar vistas con SECURITY DEFINER
    identify_query = """
    SELECT 
        schemaname,
        viewname,
        definition
    FROM pg_views
    WHERE schemaname = 'public'
    AND definition LIKE '%SECURITY DEFINER%'
    ORDER BY viewname;
    """
    
    print("1. Identificando vistas con SECURITY DEFINER...")
    cur.execute(identify_query)
    views = cur.fetchall()
    
    if views:
        print(f"\n✅ Encontradas {len(views)} vistas con SECURITY DEFINER:")
        for view in views:
            print(f"   - {view[1]}")
        
        print(f"\n⚠️  ADVERTENCIA: Se eliminarán {len(views)} vistas.")
        response = input("¿Deseas continuar? (s/n): ")
        
        if response.lower() == 's':
            # Eliminar cada vista
            for i, view in enumerate(views, 1):
                schema_name = view[0]
                view_name = view[1]
                drop_query = f"DROP VIEW IF EXISTS {schema_name}.{view_name} CASCADE;"
                
                try:
                    print(f"\n{i}/{len(views)} Eliminando: {view_name}...")
                    cur.execute(drop_query)
                    conn.commit()
                    print(f"   ✅ Vista {view_name} eliminada")
                except Exception as e:
                    conn.rollback()
                    print(f"   ❌ Error eliminando {view_name}: {str(e)}")
            
            # Verificar si quedan vistas
            print("\n🔍 Verificando si quedan vistas con SECURITY DEFINER...")
            cur.execute(identify_query)
            remaining = cur.fetchall()
            
            if not remaining:
                print("✅ No quedan vistas con SECURITY DEFINER")
            else:
                print(f"⚠️  Aún quedan {len(remaining)} vistas")
                
        else:
            print("\n❌ Operación cancelada")
    else:
        print("\n✅ No se encontraron vistas con SECURITY DEFINER")
        
        # Buscar en otros esquemas
        print("\n🔍 Buscando en otros esquemas...")
        cur.execute("""
            SELECT DISTINCT schemaname 
            FROM pg_views 
            WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
            ORDER BY schemaname;
        """)
        schemas = cur.fetchall()
        
        if schemas:
            print(f"Esquemas encontrados: {[s[0] for s in schemas]}")
            
            for schema in schemas:
                cur.execute(f"""
                    SELECT count(*) 
                    FROM pg_views 
                    WHERE schemaname = %s
                    AND definition LIKE '%SECURITY DEFINER%';
                """, (schema[0],))
                count = cur.fetchone()[0]
                if count > 0:
                    print(f"   - {schema[0]}: {count} vistas con SECURITY DEFINER")
    
    # Cerrar conexión
    cur.close()
    conn.close()
    
    print("\n✅ PROCESO COMPLETADO")
    
except psycopg2.OperationalError as e:
    print(f"\n❌ Error de conexión: {str(e)}")
    print("\n💡 Alternativa: Usa el dashboard de Supabase")
    print("   1. Ve a SQL Editor en tu proyecto")
    print("   2. Ejecuta esta query para identificar las vistas:")
    print("      SELECT viewname FROM pg_views WHERE schemaname = 'public' AND definition LIKE '%SECURITY DEFINER%';")
    print("   3. Para cada vista, ejecuta: DROP VIEW IF EXISTS public.[nombre_vista] CASCADE;")
    
except Exception as e:
    print(f"\n❌ Error inesperado: {str(e)}")

print("\n💡 Si los errores persisten en el Security Advisor:")
print("   1. Verifica en el dashboard de Supabase > Database > Tables")
print("   2. Busca vistas con candados o permisos especiales")
print("   3. Considera hacer un backup y recrear las vistas sin SECURITY DEFINER")