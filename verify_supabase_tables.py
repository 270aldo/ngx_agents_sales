#!/usr/bin/env python3
"""
Script para verificar qué tablas existen en Supabase vs las que necesita el sistema.
"""

import asyncio
import os
from dotenv import load_dotenv
from supabase import create_client, Client

# Cargar variables de entorno
load_dotenv()

# Tablas que el sistema necesita (basado en los errores y el código)
REQUIRED_TABLES = [
    "conversations",
    "adaptive_learning_config", 
    "learned_models",
    "ml_experiments",
    "experiment_results",
    "customer_profiles",
    "conversation_outcomes",
    "ab_test_variants",
    "ab_test_results",
    "pattern_recognitions",
    "prompt_variants",
    "prompt_performance",
    "roi_calculations",
    "tier_detections",
    "emotional_analysis",
    "personality_analysis",
    "conversation_patterns",
    "hie_prompt_optimizations",
    "hie_gene_performance",
    "trial_users",
    "demo_events", 
    "demo_sessions",
    "scheduled_touchpoints",
    "roi_profession_benchmarks",
    "roi_success_stories",
    "predictive_models",
    "prediction_results",
    "model_training_data",
    "prediction_feedback"
]

async def check_supabase_tables():
    """Verificar qué tablas existen en Supabase."""
    
    # Crear cliente Supabase
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_ANON_KEY")
    
    if not url or not key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configuradas")
        return
        
    supabase: Client = create_client(url, key)
    
    print(f"🔍 Verificando tablas en Supabase...")
    print(f"URL: {url}")
    print("="*60)
    
    # Query para obtener todas las tablas
    query = """
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_type = 'BASE TABLE'
    ORDER BY table_name;
    """
    
    try:
        # Ejecutar query usando la API REST de Supabase
        result = supabase.postgrest.from_("conversations").select("*").limit(0).execute()
        
        # Si llegamos aquí, al menos conversations existe
        print("✅ Tabla 'conversations' existe")
        existing_tables = ["conversations"]
        
    except Exception as e:
        if "does not exist" in str(e):
            print("❌ Tabla 'conversations' NO existe")
            existing_tables = []
        else:
            print(f"❓ Error verificando: {e}")
            existing_tables = []
    
    # Verificar cada tabla requerida
    print("\n📊 Estado de tablas requeridas:")
    print("-"*60)
    
    missing_tables = []
    
    for table in REQUIRED_TABLES:
        try:
            # Intentar hacer un select vacío para verificar si existe
            result = supabase.postgrest.from_(table).select("*").limit(0).execute()
            print(f"✅ {table}")
            if table not in existing_tables:
                existing_tables.append(table)
        except Exception as e:
            if "does not exist" in str(e):
                print(f"❌ {table} - NO EXISTE")
                missing_tables.append(table)
            else:
                print(f"❓ {table} - Error: {str(e)[:50]}...")
                missing_tables.append(table)
    
    # Resumen
    print("\n📈 RESUMEN:")
    print("-"*60)
    print(f"Total tablas requeridas: {len(REQUIRED_TABLES)}")
    print(f"Tablas existentes: {len(existing_tables)}")
    print(f"Tablas faltantes: {len(missing_tables)}")
    
    if missing_tables:
        print(f"\n❌ Tablas que faltan crear ({len(missing_tables)}):")
        for table in missing_tables:
            print(f"   - {table}")
    
    # Verificar qué tablas existen que no están en nuestra lista
    print("\n🔍 Verificando otras tablas en la base de datos...")
    
    # Lista de tablas conocidas de Supabase que podemos ignorar
    system_tables = ["schema_migrations", "buckets", "objects", "hooks", "secrets"]
    
    # Intentar listar todas las tablas con una query directa
    try:
        # Este approach no funcionará con el cliente REST, pero lo dejamos para referencia
        print("ℹ️  Nota: Para ver todas las tablas, necesitas acceso directo a PostgreSQL")
    except:
        pass
    
    return existing_tables, missing_tables

if __name__ == "__main__":
    existing, missing = asyncio.run(check_supabase_tables())
    
    if missing:
        print("\n⚠️  ACCIÓN REQUERIDA: Necesitas crear las tablas faltantes en Supabase")
        print("Puedes usar los scripts SQL en la carpeta 'migrations/'")