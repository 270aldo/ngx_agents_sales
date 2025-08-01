#!/usr/bin/env python3
"""
Script para verificar la estructura de las tablas principales de ML tracking en Supabase.
"""

import asyncio
import os
from dotenv import load_dotenv
from supabase import create_client, Client
import json

# Cargar variables de entorno
load_dotenv()

# Tablas principales de ML que queremos verificar
ML_TRACKING_TABLES = [
    "conversations",
    "ml_experiments", 
    "experiment_results",
    "conversation_outcomes",
    "ab_test_variants",
    "ab_test_results",
    "pattern_recognitions",
    "predictive_models",
    "prediction_results"
]

async def check_table_structure(supabase: Client, table_name: str):
    """Verificar la estructura de una tabla específica."""
    print(f"\n📋 Tabla: {table_name}")
    print("-" * 60)
    
    try:
        # Hacer una consulta vacía para obtener la estructura
        result = supabase.table(table_name).select("*").limit(1).execute()
        
        if result.data and len(result.data) > 0:
            # Si hay datos, mostrar las columnas
            columns = list(result.data[0].keys())
            print(f"✅ Columnas encontradas ({len(columns)}):")
            for col in sorted(columns):
                print(f"   - {col}")
        else:
            # Si no hay datos, intentar insertar y luego eliminar para ver estructura
            print("ℹ️  Tabla vacía, verificando estructura...")
            # No podemos determinar estructura sin datos
            print("   (No se pueden determinar columnas sin datos)")
            
    except Exception as e:
        print(f"❌ Error al verificar tabla: {str(e)}")

async def check_table_counts(supabase: Client):
    """Verificar el conteo de registros en cada tabla."""
    print("\n📊 Conteo de registros por tabla:")
    print("-" * 60)
    
    for table in ML_TRACKING_TABLES:
        try:
            # Contar registros
            result = supabase.table(table).select("*", count="exact").execute()
            count = result.count if hasattr(result, 'count') else len(result.data)
            print(f"✅ {table}: {count} registros")
        except Exception as e:
            print(f"❌ {table}: Error - {str(e)[:50]}...")

async def check_recent_activity(supabase: Client):
    """Verificar actividad reciente en las tablas principales."""
    print("\n🕐 Actividad reciente (últimos registros):")
    print("-" * 60)
    
    # Tablas con timestamps conocidos
    tables_with_timestamps = {
        "conversations": "created_at",
        "ml_experiments": "created_at",
        "experiment_results": "created_at",
        "conversation_outcomes": "created_at"
    }
    
    for table, timestamp_col in tables_with_timestamps.items():
        try:
            # Obtener último registro
            result = supabase.table(table)\
                .select("*")\
                .order(timestamp_col, desc=True)\
                .limit(1)\
                .execute()
            
            if result.data and len(result.data) > 0:
                last_record = result.data[0]
                timestamp = last_record.get(timestamp_col, "N/A")
                print(f"✅ {table}: Último registro en {timestamp}")
            else:
                print(f"ℹ️  {table}: Sin registros")
                
        except Exception as e:
            print(f"❌ {table}: Error - {str(e)[:50]}...")

async def check_relationships(supabase: Client):
    """Verificar relaciones entre tablas."""
    print("\n🔗 Verificando relaciones entre tablas:")
    print("-" * 60)
    
    # Verificar si hay conversaciones con experimentos
    try:
        # Verificar conversations con ml_experiments
        conv_result = supabase.table("conversations")\
            .select("conversation_id")\
            .limit(5)\
            .execute()
        
        if conv_result.data:
            conv_ids = [c['conversation_id'] for c in conv_result.data if 'conversation_id' in c]
            if conv_ids:
                # Buscar experimentos relacionados
                exp_result = supabase.table("ml_experiments")\
                    .select("*")\
                    .in_("conversation_id", conv_ids)\
                    .execute()
                
                print(f"✅ Conversaciones con experimentos: {len(exp_result.data) if exp_result.data else 0}")
    except Exception as e:
        print(f"❌ Error verificando relaciones: {str(e)}")

async def main():
    """Función principal."""
    # Crear cliente Supabase
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_ANON_KEY")
    
    if not url or not key:
        print("❌ Error: SUPABASE_URL o SUPABASE_ANON_KEY no configuradas")
        return
        
    supabase: Client = create_client(url, key)
    
    print("🔍 Verificando estructura de tablas ML en Supabase...")
    print(f"URL: {url}")
    print("=" * 60)
    
    # Verificar estructura de cada tabla
    for table in ML_TRACKING_TABLES:
        await check_table_structure(supabase, table)
    
    # Verificar conteos
    await check_table_counts(supabase)
    
    # Verificar actividad reciente
    await check_recent_activity(supabase)
    
    # Verificar relaciones
    await check_relationships(supabase)
    
    print("\n✅ Verificación completada")

if __name__ == "__main__":
    asyncio.run(main())