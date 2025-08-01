#!/usr/bin/env python3
"""
Script para aplicar migraciones pendientes en Supabase.
"""

import asyncio
import os
from dotenv import load_dotenv
from supabase import create_client, Client
from datetime import datetime

# Cargar variables de entorno
load_dotenv()

# Lista de migraciones en orden
MIGRATIONS = [
    "001_core_conversations.sql",
    "003_predictive_models.sql", 
    "004_emotional_intelligence.sql",
    "005_prompt_optimization.sql",
    "006_trial_management.sql",
    "007_roi_tracking.sql",
    "008_pii_encryption.sql",
    "009_security_events.sql",
    "010_missing_tables.sql",
    "011_add_context_column.sql",
    "011_add_missing_fields.sql",
    "012_ml_tracking_schema_fix.sql",
    "013_fix_security_definer_views.sql"
]


def read_migration(filename):
    """Leer el contenido de un archivo de migración."""
    filepath = os.path.join("scripts/migrations", filename)
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            return f.read()
    return None

async def check_migration_status():
    """Verificar el estado de las migraciones."""
    print("📋 Estado de Migraciones")
    print("=" * 60)
    
    # Verificar que existen los archivos
    for i, migration in enumerate(MIGRATIONS, 1):
        filepath = os.path.join("scripts/migrations", migration)
        if os.path.exists(filepath):
            size = os.path.getsize(filepath)
            print(f"✅ {i:02d}. {migration} ({size:,} bytes)")
        else:
            print(f"❌ {i:02d}. {migration} - NO ENCONTRADO")
    
    print("\n" + "=" * 60)

async def generate_migration_script():
    """Generar un script SQL consolidado con todas las migraciones."""
    print("\n📝 Generando script consolidado de migraciones...")
    
    output_file = "apply_all_migrations.sql"
    
    with open(output_file, 'w') as out:
        out.write("-- =====================================================================\n")
        out.write("-- SCRIPT CONSOLIDADO DE MIGRACIONES NGX VOICE SALES AGENT\n")
        out.write(f"-- Generado: {datetime.now().isoformat()}\n")
        out.write("-- =====================================================================\n\n")
        out.write("-- IMPORTANTE: Ejecutar este script en Supabase SQL Editor\n")
        out.write("-- o usando Supabase CLI con: supabase db push\n\n")
        
        for migration in MIGRATIONS:
            content = read_migration(migration)
            if content:
                out.write(f"\n-- =====================================================================\n")
                out.write(f"-- MIGRACIÓN: {migration}\n")
                out.write(f"-- =====================================================================\n\n")
                out.write(content)
                out.write("\n\n")
            else:
                out.write(f"\n-- ⚠️  MIGRACIÓN NO ENCONTRADA: {migration}\n\n")
    
    print(f"✅ Script consolidado generado: {output_file}")
    print("\n📌 PRÓXIMOS PASOS:")
    print("1. Abre el Supabase Dashboard")
    print("2. Ve a SQL Editor")
    print("3. Copia y pega el contenido de 'apply_all_migrations.sql'")
    print("4. Ejecuta el script")
    print("\nAlternativamente, si tienes Supabase CLI configurado:")
    print("1. supabase migration new consolidated_ml_schema")
    print("2. Copia el contenido a la nueva migración")
    print("3. supabase db push")

async def verify_critical_tables():
    """Verificar tablas críticas para ML."""
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_ANON_KEY")
    
    if not url or not key:
        print("❌ Error: Variables de entorno no configuradas")
        return
        
    supabase: Client = create_client(url, key)
    
    print("\n🔍 Verificando tablas críticas para ML...")
    
    critical_tables = [
        "conversations",
        "ml_experiments",
        "experiment_results",
        "conversation_outcomes",
        "ab_test_variants",
        "pattern_recognitions"
    ]
    
    issues = []
    
    for table in critical_tables:
        try:
            result = supabase.table(table).select("*").limit(0).execute()
            print(f"✅ {table}")
        except Exception as e:
            if "does not exist" in str(e):
                print(f"❌ {table} - NO EXISTE")
                issues.append(f"Tabla '{table}' no existe")
            else:
                print(f"⚠️  {table} - Error: {str(e)[:50]}...")
                issues.append(f"Error en tabla '{table}': {str(e)[:50]}...")
    
    if issues:
        print(f"\n⚠️  Se encontraron {len(issues)} problemas:")
        for issue in issues:
            print(f"   - {issue}")
        print("\n✅ Ejecuta el script de migración para resolver estos problemas.")
    else:
        print("\n✅ Todas las tablas críticas están presentes.")

async def main():
    """Función principal."""
    print("🚀 NGX Voice Sales Agent - Verificador de Migraciones")
    print("=" * 60)
    
    # Verificar estado de migraciones
    await check_migration_status()
    
    # Verificar tablas críticas
    await verify_critical_tables()
    
    # Generar script consolidado
    await generate_migration_script()
    
    print("\n✅ Verificación completada")

if __name__ == "__main__":
    asyncio.run(main())