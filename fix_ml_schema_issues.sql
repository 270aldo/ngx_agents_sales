-- =====================================================================
-- SCRIPT DE CORRECCIÓN DE ESQUEMA ML
-- Generado: 2025-07-27T19:37:56.884303
-- =====================================================================

-- TODO: Error verificando relaciones: {'code': '42703', 'details': None, 'hint': None, 'message': 'column ml_experiments.experiment_id does not exist'}

-- Aplicar migración 012 para corregir estructura:
-- 1. Ejecutar scripts/migrations/012_ml_tracking_schema_fix.sql
-- 2. Verificar nuevamente con este script
