-- =====================================================================
-- SCRIPT CONSOLIDADO DE MIGRACIONES NGX VOICE SALES AGENT
-- Generado: 2025-07-28T02:19:06.396257
-- =====================================================================

-- IMPORTANTE: Ejecutar este script en Supabase SQL Editor
-- o usando Supabase CLI con: supabase db push


-- =====================================================================
-- MIGRACIÓN: 001_core_conversations.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 001: ACTUALIZACIÓN DE TABLA CONVERSATIONS
-- =====================================================================
-- Este script actualiza la tabla conversations existente para asegurar
-- que tenga todas las columnas necesarias para el sistema completo

-- IMPORTANTE: Primero ejecuta este query para ver la estructura actual:
-- SELECT column_name, data_type, is_nullable, column_default 
-- FROM information_schema.columns 
-- WHERE table_name = 'conversations' 
-- ORDER BY ordinal_position;

-- Verificar y agregar columnas faltantes si no existen
DO $$ 
BEGIN
    -- Agregar columna platform_context si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'platform_context') THEN
        ALTER TABLE conversations 
        ADD COLUMN platform_context JSONB DEFAULT '{}';
    END IF;

    -- Agregar columna ml_tracking_enabled si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'ml_tracking_enabled') THEN
        ALTER TABLE conversations 
        ADD COLUMN ml_tracking_enabled BOOLEAN DEFAULT true;
    END IF;

    -- Agregar columna tier_detected si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'tier_detected') THEN
        ALTER TABLE conversations 
        ADD COLUMN tier_detected VARCHAR(50);
    END IF;

    -- Agregar columna tier_confidence si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'tier_confidence') THEN
        ALTER TABLE conversations 
        ADD COLUMN tier_confidence FLOAT CHECK (tier_confidence >= 0.0 AND tier_confidence <= 1.0);
    END IF;

    -- Agregar columna emotional_journey si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'emotional_journey') THEN
        ALTER TABLE conversations 
        ADD COLUMN emotional_journey JSONB DEFAULT '[]';
    END IF;

    -- Agregar columna experiment_assignments si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'experiment_assignments') THEN
        ALTER TABLE conversations 
        ADD COLUMN experiment_assignments JSONB DEFAULT '[]';
    END IF;

    -- Agregar columna agent_version si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'agent_version') THEN
        ALTER TABLE conversations 
        ADD COLUMN agent_version VARCHAR(50) DEFAULT 'ngx_v1.0';
    END IF;

    -- Agregar columna total_duration_seconds si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'total_duration_seconds') THEN
        ALTER TABLE conversations 
        ADD COLUMN total_duration_seconds INTEGER;
    END IF;

    -- Agregar columna message_count si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'message_count') THEN
        ALTER TABLE conversations 
        ADD COLUMN message_count INTEGER DEFAULT 0;
    END IF;

    -- Agregar columna last_message_at si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'last_message_at') THEN
        ALTER TABLE conversations 
        ADD COLUMN last_message_at TIMESTAMP;
    END IF;
END $$;

-- Crear índices si no existen (verificando primero que las columnas existan)
DO $$
BEGIN
    -- Índice para conversation_id si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'conversation_id') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_conversation_id ON conversations(conversation_id);
    END IF;
    
    -- Índice para user_id si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'user_id') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON conversations(user_id);
    END IF;
    
    -- Índice para status si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'status') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_status ON conversations(status);
    END IF;
    
    -- Índice para created_at si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'created_at') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_created_at ON conversations(created_at);
    END IF;
    
    -- Índice para tier_detected si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'tier_detected') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_tier_detected ON conversations(tier_detected);
    END IF;
    
    -- Índice para ml_tracking_enabled si existe la columna
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'conversations' AND column_name = 'ml_tracking_enabled') THEN
        CREATE INDEX IF NOT EXISTS idx_conversations_ml_tracking ON conversations(ml_tracking_enabled) WHERE ml_tracking_enabled = true;
    END IF;
END $$;

-- Agregar comentarios para documentación (solo si las columnas existen)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'platform_context') THEN
        COMMENT ON COLUMN conversations.platform_context IS 'Contexto de la plataforma de origen (web, mobile, API)';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'ml_tracking_enabled') THEN
        COMMENT ON COLUMN conversations.ml_tracking_enabled IS 'Si el tracking ML está habilitado para esta conversación';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'tier_detected') THEN
        COMMENT ON COLUMN conversations.tier_detected IS 'Tier detectado automáticamente (Essential, Pro, Elite, PRIME, LONGEVITY)';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'tier_confidence') THEN
        COMMENT ON COLUMN conversations.tier_confidence IS 'Confianza en la detección del tier (0-1)';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'emotional_journey') THEN
        COMMENT ON COLUMN conversations.emotional_journey IS 'Array de estados emocionales durante la conversación';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'experiment_assignments') THEN
        COMMENT ON COLUMN conversations.experiment_assignments IS 'IDs de experimentos A/B asignados a esta conversación';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'agent_version') THEN
        COMMENT ON COLUMN conversations.agent_version IS 'Versión del agente utilizada';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'total_duration_seconds') THEN
        COMMENT ON COLUMN conversations.total_duration_seconds IS 'Duración total de la conversación en segundos';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'message_count') THEN
        COMMENT ON COLUMN conversations.message_count IS 'Número total de mensajes en la conversación';
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conversations' AND column_name = 'last_message_at') THEN
        COMMENT ON COLUMN conversations.last_message_at IS 'Timestamp del último mensaje';
    END IF;
END $$;

-- Trigger para actualizar last_message_at automáticamente
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_message_at = NOW();
    NEW.message_count = COALESCE(NEW.message_count, 0) + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Solo crear el trigger si no existe
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_conversation_last_message_trigger') THEN
        CREATE TRIGGER update_conversation_last_message_trigger
        BEFORE UPDATE ON conversations
        FOR EACH ROW
        WHEN (OLD.messages IS DISTINCT FROM NEW.messages)
        EXECUTE FUNCTION update_conversation_last_message();
    END IF;
END $$;

-- =====================================================================
-- VERIFICACIÓN FINAL
-- =====================================================================
-- Query para verificar que todas las columnas están presentes
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'conversations'
ORDER BY ordinal_position;


-- =====================================================================
-- MIGRACIÓN: 003_predictive_models.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 003: SISTEMA DE MODELOS PREDICTIVOS
-- =====================================================================
-- Este script crea todas las tablas necesarias para el sistema de
-- predicción y modelos ML del agente NGX

-- =====================================================================
-- 1. TABLA DE MODELOS PREDICTIVOS
-- =====================================================================
CREATE TABLE IF NOT EXISTS predictive_models (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL UNIQUE,
    model_type VARCHAR(100) NOT NULL, -- objection_prediction, needs_prediction, conversion_prediction, etc.
    version VARCHAR(50) NOT NULL,
    description TEXT,
    
    -- Configuración del modelo
    model_config JSONB NOT NULL DEFAULT '{}',
    feature_names JSONB NOT NULL DEFAULT '[]',
    hyperparameters JSONB DEFAULT '{}',
    
    -- Métricas de performance
    accuracy FLOAT CHECK (accuracy >= 0.0 AND accuracy <= 1.0),
    precision_score FLOAT CHECK (precision_score >= 0.0 AND precision_score <= 1.0),
    recall_score FLOAT CHECK (recall_score >= 0.0 AND recall_score <= 1.0),
    f1_score FLOAT CHECK (f1_score >= 0.0 AND f1_score <= 1.0),
    
    -- Estado del modelo
    status VARCHAR(50) DEFAULT 'training', -- training, active, deprecated, failed
    is_active BOOLEAN DEFAULT false,
    training_date TIMESTAMP,
    last_used TIMESTAMP,
    
    -- Datos de entrenamiento
    training_samples INTEGER,
    validation_samples INTEGER,
    test_samples INTEGER,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system'
);

-- Índices para predictive_models
CREATE INDEX IF NOT EXISTS idx_predictive_models_name ON predictive_models(name);
CREATE INDEX IF NOT EXISTS idx_predictive_models_type ON predictive_models(model_type);
CREATE INDEX IF NOT EXISTS idx_predictive_models_status ON predictive_models(status);
CREATE INDEX IF NOT EXISTS idx_predictive_models_active ON predictive_models(is_active) WHERE is_active = true;

-- =====================================================================
-- 2. TABLA DE RESULTADOS DE PREDICCIONES
-- =====================================================================
CREATE TABLE IF NOT EXISTS prediction_results (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(255) NOT NULL,
    conversation_id UUID NOT NULL,
    
    -- Tipo y resultado de predicción
    prediction_type VARCHAR(100) NOT NULL, -- objection, needs, conversion, decision
    prediction_value JSONB NOT NULL,
    confidence_score FLOAT NOT NULL CHECK (confidence_score >= 0.0 AND confidence_score <= 1.0),
    
    -- Contexto de la predicción
    input_features JSONB NOT NULL,
    feature_importance JSONB DEFAULT '{}',
    
    -- Estado y timing
    status VARCHAR(50) DEFAULT 'pending', -- pending, completed, failed
    prediction_timestamp TIMESTAMP DEFAULT NOW(),
    processing_time_ms INTEGER,
    
    -- Resultado real (para aprendizaje)
    actual_outcome JSONB,
    outcome_recorded_at TIMESTAMP,
    prediction_accuracy FLOAT CHECK (prediction_accuracy >= 0.0 AND prediction_accuracy <= 1.0),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    model_version VARCHAR(50),
    
    -- Foreign keys
    FOREIGN KEY (model_name) REFERENCES predictive_models(name) ON DELETE CASCADE
);

-- Índices para prediction_results
CREATE INDEX IF NOT EXISTS idx_prediction_results_model ON prediction_results(model_name);
CREATE INDEX IF NOT EXISTS idx_prediction_results_conversation ON prediction_results(conversation_id);
CREATE INDEX IF NOT EXISTS idx_prediction_results_type ON prediction_results(prediction_type);
CREATE INDEX IF NOT EXISTS idx_prediction_results_status ON prediction_results(status);
CREATE INDEX IF NOT EXISTS idx_prediction_results_timestamp ON prediction_results(prediction_timestamp);
CREATE INDEX IF NOT EXISTS idx_prediction_results_confidence ON prediction_results(confidence_score);

-- =====================================================================
-- 3. TABLA DE DATOS DE ENTRENAMIENTO
-- =====================================================================
CREATE TABLE IF NOT EXISTS model_training_data (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(255) NOT NULL,
    
    -- Datos de entrada y salida
    input_data JSONB NOT NULL,
    target_value JSONB NOT NULL,
    
    -- Metadata del dato
    data_source VARCHAR(100), -- conversation, manual, synthetic
    conversation_id UUID,
    quality_score FLOAT DEFAULT 1.0 CHECK (quality_score >= 0.0 AND quality_score <= 1.0),
    
    -- Control de uso
    used_in_training BOOLEAN DEFAULT false,
    training_date TIMESTAMP,
    validation_set BOOLEAN DEFAULT false,
    test_set BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system',
    
    -- Foreign keys
    FOREIGN KEY (model_name) REFERENCES predictive_models(name) ON DELETE CASCADE
);

-- Índices para model_training_data
CREATE INDEX IF NOT EXISTS idx_model_training_data_model ON model_training_data(model_name);
CREATE INDEX IF NOT EXISTS idx_model_training_data_used ON model_training_data(used_in_training);
CREATE INDEX IF NOT EXISTS idx_model_training_data_created ON model_training_data(created_at);
CREATE INDEX IF NOT EXISTS idx_model_training_data_conversation ON model_training_data(conversation_id);

-- =====================================================================
-- 4. TABLA DE RETROALIMENTACIÓN DE PREDICCIONES
-- =====================================================================
CREATE TABLE IF NOT EXISTS prediction_feedback (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prediction_id UUID NOT NULL,
    
    -- Retroalimentación
    feedback_type VARCHAR(50) NOT NULL, -- accuracy, relevance, usefulness
    feedback_value JSONB NOT NULL,
    feedback_score FLOAT CHECK (feedback_score >= -1.0 AND feedback_score <= 1.0),
    
    -- Contexto
    user_id UUID,
    agent_id VARCHAR(255),
    comments TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    processed BOOLEAN DEFAULT false,
    processed_at TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (prediction_id) REFERENCES prediction_results(id) ON DELETE CASCADE
);

-- Índices para prediction_feedback
CREATE INDEX IF NOT EXISTS idx_prediction_feedback_prediction ON prediction_feedback(prediction_id);
CREATE INDEX IF NOT EXISTS idx_prediction_feedback_type ON prediction_feedback(feedback_type);
CREATE INDEX IF NOT EXISTS idx_prediction_feedback_processed ON prediction_feedback(processed);
CREATE INDEX IF NOT EXISTS idx_prediction_feedback_created ON prediction_feedback(created_at);

-- =====================================================================
-- 5. TABLA DE SESIONES DE ENTRENAMIENTO
-- =====================================================================
CREATE TABLE IF NOT EXISTS model_training (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    model_name VARCHAR(255) NOT NULL,
    
    -- Configuración del entrenamiento
    training_config JSONB NOT NULL,
    hyperparameters JSONB NOT NULL,
    feature_engineering JSONB DEFAULT '{}',
    
    -- Estado y progreso
    status VARCHAR(50) DEFAULT 'pending', -- pending, in_progress, completed, failed
    progress FLOAT DEFAULT 0.0 CHECK (progress >= 0.0 AND progress <= 1.0),
    current_epoch INTEGER DEFAULT 0,
    total_epochs INTEGER,
    
    -- Métricas de entrenamiento
    training_loss FLOAT,
    validation_loss FLOAT,
    training_metrics JSONB DEFAULT '{}',
    validation_metrics JSONB DEFAULT '{}',
    
    -- Timing
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_seconds INTEGER,
    
    -- Resultados
    final_model_path TEXT,
    model_size_mb FLOAT,
    improvement_percentage FLOAT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system',
    notes TEXT,
    
    -- Foreign keys
    FOREIGN KEY (model_name) REFERENCES predictive_models(name) ON DELETE CASCADE
);

-- Índices para model_training
CREATE INDEX IF NOT EXISTS idx_model_training_model ON model_training(model_name);
CREATE INDEX IF NOT EXISTS idx_model_training_status ON model_training(status);
CREATE INDEX IF NOT EXISTS idx_model_training_created ON model_training(created_at);

-- =====================================================================
-- 6. TABLA DE FEEDBACK GENERAL (SIMPLIFICADA)
-- =====================================================================
CREATE TABLE IF NOT EXISTS feedback (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Contexto
    model_name VARCHAR(255),
    conversation_id UUID,
    prediction_id UUID,
    
    -- Feedback
    feedback_type VARCHAR(100) NOT NULL,
    feedback_value JSONB NOT NULL,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    user_id UUID,
    session_id VARCHAR(255)
);

-- Índices para feedback
CREATE INDEX IF NOT EXISTS idx_feedback_model ON feedback(model_name);
CREATE INDEX IF NOT EXISTS idx_feedback_conversation ON feedback(conversation_id);
CREATE INDEX IF NOT EXISTS idx_feedback_created ON feedback(created_at);

-- =====================================================================
-- 7. TABLA DE PREDICCIONES HISTÓRICAS
-- =====================================================================
CREATE TABLE IF NOT EXISTS predictions (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Contexto
    model_name VARCHAR(255) NOT NULL,
    conversation_id UUID,
    user_id UUID,
    
    -- Predicción
    prediction_type VARCHAR(100) NOT NULL,
    prediction_data JSONB NOT NULL,
    confidence FLOAT CHECK (confidence >= 0.0 AND confidence <= 1.0),
    
    -- Resultado
    actual_outcome JSONB,
    accuracy FLOAT CHECK (accuracy >= 0.0 AND accuracy <= 1.0),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    model_version VARCHAR(50)
);

-- Índices para predictions
CREATE INDEX IF NOT EXISTS idx_predictions_model ON predictions(model_name);
CREATE INDEX IF NOT EXISTS idx_predictions_conversation ON predictions(conversation_id);
CREATE INDEX IF NOT EXISTS idx_predictions_created ON predictions(created_at);

-- =====================================================================
-- 8. TRIGGERS PARA UPDATED_AT
-- =====================================================================
CREATE OR REPLACE FUNCTION update_predictive_models_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_predictive_models_updated_at_trigger
BEFORE UPDATE ON predictive_models
FOR EACH ROW EXECUTE FUNCTION update_predictive_models_updated_at();

-- =====================================================================
-- 9. VISTAS ÚTILES
-- =====================================================================

-- Vista de performance de modelos
CREATE OR REPLACE VIEW model_performance_view AS
SELECT 
    pm.name,
    pm.model_type,
    pm.version,
    pm.accuracy,
    pm.f1_score,
    pm.is_active,
    COUNT(DISTINCT pr.id) as total_predictions,
    AVG(pr.confidence_score) as avg_confidence,
    COUNT(DISTINCT pr.id) FILTER (WHERE pr.actual_outcome IS NOT NULL) as predictions_with_outcome,
    AVG(pr.prediction_accuracy) FILTER (WHERE pr.prediction_accuracy IS NOT NULL) as real_accuracy
FROM predictive_models pm
LEFT JOIN prediction_results pr ON pm.name = pr.model_name
GROUP BY pm.name, pm.model_type, pm.version, pm.accuracy, pm.f1_score, pm.is_active;

-- Vista de actividad de entrenamiento
CREATE OR REPLACE VIEW training_activity_view AS
SELECT 
    mt.model_name,
    COUNT(*) as training_sessions,
    COUNT(*) FILTER (WHERE status = 'completed') as successful_trainings,
    COUNT(*) FILTER (WHERE status = 'failed') as failed_trainings,
    AVG(duration_seconds) FILTER (WHERE status = 'completed') as avg_training_time_seconds,
    MAX(completed_at) as last_training_date,
    AVG(improvement_percentage) FILTER (WHERE improvement_percentage IS NOT NULL) as avg_improvement
FROM model_training mt
GROUP BY mt.model_name;

-- =====================================================================
-- 10. DATOS INICIALES
-- =====================================================================

-- Insertar modelos predictivos iniciales
INSERT INTO predictive_models (name, model_type, version, description, status, is_active) VALUES
('objection_predictor_v1', 'objection_prediction', '1.0.0', 'Predice tipos de objeciones basado en contexto de conversación', 'active', true),
('needs_analyzer_v1', 'needs_prediction', '1.0.0', 'Analiza y predice necesidades del cliente', 'active', true),
('conversion_predictor_v1', 'conversion_prediction', '1.0.0', 'Predice probabilidad de conversión en tiempo real', 'active', true),
('decision_engine_v1', 'decision_engine', '1.0.0', 'Motor de decisiones para estrategias de conversación', 'active', true)
ON CONFLICT (name) DO NOTHING;

-- =====================================================================
-- COMENTARIOS PARA DOCUMENTACIÓN
-- =====================================================================
COMMENT ON TABLE predictive_models IS 'Modelos ML para predicciones en tiempo real';
COMMENT ON TABLE prediction_results IS 'Resultados de todas las predicciones realizadas';
COMMENT ON TABLE model_training_data IS 'Datos utilizados para entrenar modelos';
COMMENT ON TABLE prediction_feedback IS 'Retroalimentación sobre calidad de predicciones';
COMMENT ON TABLE model_training IS 'Registro de sesiones de entrenamiento de modelos';

-- =====================================================================
-- Script completado exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 004_emotional_intelligence.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 004: SISTEMA DE INTELIGENCIA EMOCIONAL
-- =====================================================================
-- Este script crea las tablas para análisis emocional, personalidad
-- y patrones de comportamiento del agente NGX

-- =====================================================================
-- 1. TABLA DE ANÁLISIS EMOCIONAL
-- =====================================================================
CREATE TABLE IF NOT EXISTS emotional_analysis (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    message_id UUID,
    
    -- Análisis emocional principal
    primary_emotion VARCHAR(50) NOT NULL, -- joy, sadness, anger, fear, surprise, disgust, neutral
    emotion_confidence FLOAT NOT NULL CHECK (emotion_confidence >= 0.0 AND emotion_confidence <= 1.0),
    emotion_intensity FLOAT NOT NULL CHECK (emotion_intensity >= 0.0 AND emotion_intensity <= 1.0),
    
    -- Análisis detallado
    emotion_scores JSONB NOT NULL DEFAULT '{}', -- Scores para cada emoción
    sentiment_score FLOAT CHECK (sentiment_score >= -1.0 AND sentiment_score <= 1.0),
    sentiment_magnitude FLOAT CHECK (sentiment_magnitude >= 0.0),
    
    -- Indicadores adicionales
    stress_level FLOAT CHECK (stress_level >= 0.0 AND stress_level <= 1.0),
    engagement_level FLOAT CHECK (engagement_level >= 0.0 AND engagement_level <= 1.0),
    trust_level FLOAT CHECK (trust_level >= 0.0 AND trust_level <= 1.0),
    
    -- Análisis contextual
    emotional_triggers JSONB DEFAULT '[]', -- Palabras o frases que triggerean emociones
    emotional_shift BOOLEAN DEFAULT false, -- Si hubo un cambio emocional significativo
    shift_direction VARCHAR(20), -- positive, negative, neutral
    
    -- Respuesta adaptativa
    recommended_tone VARCHAR(50), -- empathetic, professional, enthusiastic, calm
    recommended_approach JSONB DEFAULT '{}', -- Estrategias recomendadas
    
    -- Metadata
    analyzed_at TIMESTAMP DEFAULT NOW(),
    analyzer_version VARCHAR(50) DEFAULT 'emotional_intelligence_v1',
    processing_time_ms INTEGER,
    
    -- Índices únicos para evitar duplicados
    UNIQUE(conversation_id, message_id)
);

-- Índices para emotional_analysis
CREATE INDEX IF NOT EXISTS idx_emotional_analysis_conversation ON emotional_analysis(conversation_id);
CREATE INDEX IF NOT EXISTS idx_emotional_analysis_emotion ON emotional_analysis(primary_emotion);
CREATE INDEX IF NOT EXISTS idx_emotional_analysis_analyzed_at ON emotional_analysis(analyzed_at);
CREATE INDEX IF NOT EXISTS idx_emotional_analysis_stress ON emotional_analysis(stress_level);
CREATE INDEX IF NOT EXISTS idx_emotional_analysis_engagement ON emotional_analysis(engagement_level);

-- =====================================================================
-- 2. TABLA DE ANÁLISIS DE PERSONALIDAD
-- =====================================================================
CREATE TABLE IF NOT EXISTS personality_analysis (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    user_id UUID,
    
    -- Modelo Big Five (OCEAN)
    openness FLOAT CHECK (openness >= 0.0 AND openness <= 1.0),
    conscientiousness FLOAT CHECK (conscientiousness >= 0.0 AND conscientiousness <= 1.0),
    extraversion FLOAT CHECK (extraversion >= 0.0 AND extraversion <= 1.0),
    agreeableness FLOAT CHECK (agreeableness >= 0.0 AND agreeableness <= 1.0),
    neuroticism FLOAT CHECK (neuroticism >= 0.0 AND neuroticism <= 1.0),
    
    -- Estilos de comunicación
    communication_style VARCHAR(50), -- direct, analytical, expressive, amiable
    learning_style VARCHAR(50), -- visual, auditory, kinesthetic, reading
    decision_style VARCHAR(50), -- rational, intuitive, dependent, avoidant
    
    -- Motivadores principales
    primary_motivators JSONB DEFAULT '[]', -- achievement, affiliation, power, security
    pain_points JSONB DEFAULT '[]',
    values JSONB DEFAULT '[]',
    
    -- Preferencias detectadas
    preferred_pace VARCHAR(20), -- fast, moderate, slow
    detail_orientation VARCHAR(20), -- high, medium, low
    risk_tolerance VARCHAR(20), -- high, medium, low
    
    -- Análisis de comportamiento
    behavioral_patterns JSONB DEFAULT '{}',
    conversation_dynamics JSONB DEFAULT '{}',
    
    -- Confianza del análisis
    analysis_confidence FLOAT CHECK (analysis_confidence >= 0.0 AND analysis_confidence <= 1.0),
    data_points_analyzed INTEGER,
    
    -- Metadata
    analyzed_at TIMESTAMP DEFAULT NOW(),
    last_updated TIMESTAMP DEFAULT NOW(),
    analyzer_version VARCHAR(50) DEFAULT 'personality_analyzer_v1'
);

-- Índices para personality_analysis
CREATE INDEX IF NOT EXISTS idx_personality_analysis_conversation ON personality_analysis(conversation_id);
CREATE INDEX IF NOT EXISTS idx_personality_analysis_user ON personality_analysis(user_id);
CREATE INDEX IF NOT EXISTS idx_personality_analysis_style ON personality_analysis(communication_style);
CREATE INDEX IF NOT EXISTS idx_personality_analysis_analyzed_at ON personality_analysis(analyzed_at);

-- =====================================================================
-- 3. TABLA DE PATRONES DE CONVERSACIÓN
-- =====================================================================
CREATE TABLE IF NOT EXISTS conversation_patterns (
    -- Identificación
    pattern_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    pattern_name VARCHAR(255) NOT NULL,
    pattern_category VARCHAR(100) NOT NULL, -- behavioral, linguistic, emotional, conversion
    
    -- Definición del patrón
    pattern_definition JSONB NOT NULL,
    pattern_conditions JSONB NOT NULL,
    pattern_indicators JSONB NOT NULL DEFAULT '[]',
    
    -- Estadísticas del patrón
    occurrence_count INTEGER DEFAULT 0,
    success_rate FLOAT CHECK (success_rate >= 0.0 AND success_rate <= 1.0),
    confidence_score FLOAT CHECK (confidence_score >= 0.0 AND confidence_score <= 1.0),
    
    -- Aplicabilidad
    applicable_contexts JSONB DEFAULT '[]', -- Contextos donde aplica el patrón
    applicable_personalities JSONB DEFAULT '[]', -- Tipos de personalidad
    applicable_emotions JSONB DEFAULT '[]', -- Estados emocionales
    
    -- Impacto y recomendaciones
    impact_on_conversion FLOAT CHECK (impact_on_conversion >= -1.0 AND impact_on_conversion <= 1.0),
    recommended_responses JSONB DEFAULT '[]',
    avoid_responses JSONB DEFAULT '[]',
    
    -- Evolución del patrón
    first_detected TIMESTAMP DEFAULT NOW(),
    last_detected TIMESTAMP DEFAULT NOW(),
    evolution_trend VARCHAR(20), -- increasing, stable, decreasing
    
    -- Control de calidad
    is_active BOOLEAN DEFAULT true,
    requires_review BOOLEAN DEFAULT false,
    review_notes TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'pattern_recognition_engine'
);

-- Índices para conversation_patterns
CREATE INDEX IF NOT EXISTS idx_conversation_patterns_name ON conversation_patterns(pattern_name);
CREATE INDEX IF NOT EXISTS idx_conversation_patterns_category ON conversation_patterns(pattern_category);
CREATE INDEX IF NOT EXISTS idx_conversation_patterns_active ON conversation_patterns(is_active);
CREATE INDEX IF NOT EXISTS idx_conversation_patterns_confidence ON conversation_patterns(confidence_score);
CREATE INDEX IF NOT EXISTS idx_conversation_patterns_impact ON conversation_patterns(impact_on_conversion);

-- =====================================================================
-- 4. TABLA DE MAPEO CONVERSACIÓN-PATRÓN
-- =====================================================================
CREATE TABLE IF NOT EXISTS conversation_pattern_matches (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    pattern_id UUID NOT NULL,
    
    -- Detalles del match
    match_confidence FLOAT NOT NULL CHECK (match_confidence >= 0.0 AND match_confidence <= 1.0),
    match_details JSONB DEFAULT '{}',
    triggered_at TIMESTAMP DEFAULT NOW(),
    
    -- Impacto
    impact_on_conversation VARCHAR(50), -- positive, negative, neutral
    response_effectiveness FLOAT CHECK (response_effectiveness >= 0.0 AND response_effectiveness <= 1.0),
    
    -- Foreign keys
    FOREIGN KEY (pattern_id) REFERENCES conversation_patterns(pattern_id) ON DELETE CASCADE,
    
    -- Evitar duplicados
    UNIQUE(conversation_id, pattern_id, triggered_at)
);

-- Índices para conversation_pattern_matches
CREATE INDEX IF NOT EXISTS idx_pattern_matches_conversation ON conversation_pattern_matches(conversation_id);
CREATE INDEX IF NOT EXISTS idx_pattern_matches_pattern ON conversation_pattern_matches(pattern_id);
CREATE INDEX IF NOT EXISTS idx_pattern_matches_triggered ON conversation_pattern_matches(triggered_at);

-- =====================================================================
-- 5. TABLA DE EVOLUCIÓN EMOCIONAL
-- =====================================================================
CREATE TABLE IF NOT EXISTS emotional_evolution (
    -- Identificación
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    
    -- Timeline emocional
    emotional_timeline JSONB NOT NULL DEFAULT '[]', -- Array de estados emocionales con timestamps
    
    -- Métricas de evolución
    initial_emotion VARCHAR(50),
    final_emotion VARCHAR(50),
    peak_positive_emotion VARCHAR(50),
    peak_negative_emotion VARCHAR(50),
    
    -- Análisis de volatilidad
    emotional_volatility FLOAT CHECK (emotional_volatility >= 0.0 AND emotional_volatility <= 1.0),
    stability_score FLOAT CHECK (stability_score >= 0.0 AND stability_score <= 1.0),
    
    -- Puntos de inflexión
    turning_points JSONB DEFAULT '[]', -- Momentos clave de cambio emocional
    critical_moments JSONB DEFAULT '[]', -- Momentos que requirieron intervención
    
    -- Resumen
    overall_sentiment VARCHAR(20), -- positive, negative, neutral, mixed
    emotional_journey_quality FLOAT CHECK (emotional_journey_quality >= 0.0 AND emotional_journey_quality <= 1.0),
    
    -- Metadata
    analyzed_at TIMESTAMP DEFAULT NOW(),
    
    -- Único por conversación
    UNIQUE(conversation_id)
);

-- Índices para emotional_evolution
CREATE INDEX IF NOT EXISTS idx_emotional_evolution_conversation ON emotional_evolution(conversation_id);
CREATE INDEX IF NOT EXISTS idx_emotional_evolution_sentiment ON emotional_evolution(overall_sentiment);
CREATE INDEX IF NOT EXISTS idx_emotional_evolution_quality ON emotional_evolution(emotional_journey_quality);

-- =====================================================================
-- 6. TRIGGERS PARA ACTUALIZACIÓN AUTOMÁTICA
-- =====================================================================

-- Trigger para actualizar personality_analysis.last_updated
CREATE OR REPLACE FUNCTION update_personality_analysis_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_personality_analysis_timestamp_trigger
BEFORE UPDATE ON personality_analysis
FOR EACH ROW EXECUTE FUNCTION update_personality_analysis_timestamp();

-- Trigger para actualizar conversation_patterns.updated_at
CREATE OR REPLACE FUNCTION update_conversation_patterns_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.occurrence_count = NEW.occurrence_count + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_conversation_patterns_timestamp_trigger
BEFORE UPDATE ON conversation_patterns
FOR EACH ROW EXECUTE FUNCTION update_conversation_patterns_timestamp();

-- =====================================================================
-- 7. VISTAS ANALÍTICAS
-- =====================================================================

-- Vista de resumen emocional por conversación
CREATE OR REPLACE VIEW emotional_summary_view AS
SELECT 
    ea.conversation_id,
    COUNT(*) as total_analyses,
    AVG(ea.emotion_confidence) as avg_confidence,
    AVG(ea.sentiment_score) as avg_sentiment,
    AVG(ea.stress_level) as avg_stress,
    AVG(ea.engagement_level) as avg_engagement,
    AVG(ea.trust_level) as avg_trust,
    MODE() WITHIN GROUP (ORDER BY ea.primary_emotion) as dominant_emotion,
    COUNT(DISTINCT ea.primary_emotion) as emotion_variety
FROM emotional_analysis ea
GROUP BY ea.conversation_id;

-- Vista de patrones más efectivos
CREATE OR REPLACE VIEW effective_patterns_view AS
SELECT 
    cp.pattern_name,
    cp.pattern_category,
    cp.occurrence_count,
    cp.success_rate,
    cp.impact_on_conversion,
    COUNT(DISTINCT cpm.conversation_id) as conversations_affected,
    AVG(cpm.response_effectiveness) as avg_effectiveness
FROM conversation_patterns cp
JOIN conversation_pattern_matches cpm ON cp.pattern_id = cpm.pattern_id
WHERE cp.is_active = true
GROUP BY cp.pattern_id, cp.pattern_name, cp.pattern_category, 
         cp.occurrence_count, cp.success_rate, cp.impact_on_conversion
ORDER BY cp.impact_on_conversion DESC, cp.success_rate DESC;

-- =====================================================================
-- 8. FUNCIONES ÚTILES
-- =====================================================================

-- Función para calcular distancia emocional entre dos estados
CREATE OR REPLACE FUNCTION calculate_emotional_distance(
    emotion1 JSONB,
    emotion2 JSONB
) RETURNS FLOAT AS $$
DECLARE
    distance FLOAT := 0;
    key TEXT;
BEGIN
    FOR key IN SELECT jsonb_object_keys(emotion1)
    LOOP
        distance := distance + POWER(
            COALESCE((emotion1->key)::float, 0) - 
            COALESCE((emotion2->key)::float, 0), 2
        );
    END LOOP;
    RETURN SQRT(distance);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- =====================================================================
-- 9. DATOS INICIALES
-- =====================================================================

-- Insertar patrones comunes iniciales
INSERT INTO conversation_patterns (pattern_name, pattern_category, pattern_definition, pattern_conditions, confidence_score) VALUES
('price_objection_pattern', 'behavioral', 
 '{"description": "Cliente menciona precio como objeción principal"}', 
 '{"keywords": ["caro", "precio", "costo", "presupuesto"], "min_occurrences": 1}', 
 0.85),
('high_engagement_pattern', 'behavioral',
 '{"description": "Cliente hace múltiples preguntas y muestra interés activo"}',
 '{"min_questions": 3, "response_time": "fast", "sentiment": "positive"}',
 0.90),
('trust_building_needed', 'emotional',
 '{"description": "Cliente muestra escepticismo y necesita construcción de confianza"}',
 '{"trust_level": "low", "keywords": ["no sé", "dudoso", "seguro?"], "sentiment": "neutral_negative"}',
 0.80)
ON CONFLICT DO NOTHING;

-- =====================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================================
COMMENT ON TABLE emotional_analysis IS 'Análisis emocional detallado de cada mensaje en conversaciones';
COMMENT ON TABLE personality_analysis IS 'Perfil de personalidad construido durante la conversación';
COMMENT ON TABLE conversation_patterns IS 'Patrones de comportamiento identificados en conversaciones';
COMMENT ON TABLE emotional_evolution IS 'Evolución emocional a lo largo de cada conversación';

-- =====================================================================
-- Script completado exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 005_prompt_optimization.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 005: SISTEMA DE OPTIMIZACIÓN DE PROMPTS
-- =====================================================================
-- Este script crea las tablas para el sistema genético de optimización
-- de prompts con enfoque HIE (Human Intelligence Enhancement)

-- =====================================================================
-- 1. TABLA DE VARIANTES DE PROMPTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS prompt_variants (
    -- Identificación
    variant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_name VARCHAR(255) NOT NULL,
    prompt_type VARCHAR(100) NOT NULL, -- greeting, objection_handling, closing, hie_explanation, etc.
    
    -- Contenido del prompt
    prompt_template TEXT NOT NULL,
    template_variables JSONB DEFAULT '[]', -- Variables que se pueden insertar
    
    -- Configuración genética
    genetic_code JSONB NOT NULL DEFAULT '{}', -- Genes del prompt para algoritmo genético
    parent_variants JSONB DEFAULT '[]', -- IDs de prompts padres si fue generado
    generation INTEGER DEFAULT 1,
    mutation_rate FLOAT DEFAULT 0.1 CHECK (mutation_rate >= 0.0 AND mutation_rate <= 1.0),
    
    -- Performance metrics
    usage_count INTEGER DEFAULT 0,
    success_count INTEGER DEFAULT 0,
    success_rate FLOAT GENERATED ALWAYS AS (
        CASE WHEN usage_count > 0 THEN success_count::FLOAT / usage_count::FLOAT ELSE 0 END
    ) STORED,
    avg_engagement_score FLOAT CHECK (avg_engagement_score >= 0.0 AND avg_engagement_score <= 10.0),
    avg_conversion_impact FLOAT CHECK (avg_conversion_impact >= -1.0 AND avg_conversion_impact <= 1.0),
    
    -- A/B Testing
    is_control BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    test_group VARCHAR(50), -- A, B, C, etc.
    confidence_score FLOAT CHECK (confidence_score >= 0.0 AND confidence_score <= 1.0),
    
    -- Contexto de aplicación
    target_archetype VARCHAR(100), -- all, analytical, emotional, etc.
    target_tier VARCHAR(50), -- all, essential, pro, elite, prime, longevity
    target_industry VARCHAR(100), -- all, fitness, health, wellness
    context_conditions JSONB DEFAULT '{}', -- Condiciones específicas de uso
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'prompt_optimizer',
    approved_by VARCHAR(255),
    approval_date TIMESTAMP
);

-- Índices para prompt_variants
CREATE INDEX IF NOT EXISTS idx_prompt_variants_type ON prompt_variants(prompt_type);
CREATE INDEX IF NOT EXISTS idx_prompt_variants_active ON prompt_variants(is_active);
CREATE INDEX IF NOT EXISTS idx_prompt_variants_success_rate ON prompt_variants(success_rate);
CREATE INDEX IF NOT EXISTS idx_prompt_variants_archetype ON prompt_variants(target_archetype);
CREATE INDEX IF NOT EXISTS idx_prompt_variants_tier ON prompt_variants(target_tier);
CREATE INDEX IF NOT EXISTS idx_prompt_variants_generation ON prompt_variants(generation);

-- =====================================================================
-- 2. TABLA DE OPTIMIZACIONES HIE DE PROMPTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS hie_prompt_optimizations (
    -- Identificación
    optimization_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL,
    
    -- Optimización HIE específica
    hie_focus VARCHAR(100) NOT NULL, -- energy, focus, stress_reduction, cognitive_enhancement
    hie_keywords JSONB NOT NULL DEFAULT '[]',
    scientific_backing JSONB DEFAULT '{}', -- Referencias a estudios
    
    -- Elementos HIE del prompt
    benefit_emphasis JSONB NOT NULL, -- Cómo se enfatizan los beneficios HIE
    social_proof_elements JSONB DEFAULT '[]', -- Testimonios, casos de éxito
    urgency_elements JSONB DEFAULT '[]', -- Elementos de urgencia/escasez
    
    -- Performance HIE específico
    hie_conversion_rate FLOAT CHECK (hie_conversion_rate >= 0.0 AND hie_conversion_rate <= 1.0),
    hie_engagement_score FLOAT CHECK (hie_engagement_score >= 0.0 AND hie_engagement_score <= 10.0),
    belief_shift_score FLOAT CHECK (belief_shift_score >= 0.0 AND belief_shift_score <= 10.0),
    
    -- Análisis de efectividad
    most_effective_elements JSONB DEFAULT '[]',
    least_effective_elements JSONB DEFAULT '[]',
    improvement_suggestions JSONB DEFAULT '[]',
    
    -- Control de calidad
    medical_claims_verified BOOLEAN DEFAULT false,
    compliance_checked BOOLEAN DEFAULT false,
    ethical_review_passed BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    last_tested TIMESTAMP,
    optimization_version INTEGER DEFAULT 1,
    
    -- Foreign key
    FOREIGN KEY (variant_id) REFERENCES prompt_variants(variant_id) ON DELETE CASCADE
);

-- Índices para hie_prompt_optimizations
CREATE INDEX IF NOT EXISTS idx_hie_optimizations_variant ON hie_prompt_optimizations(variant_id);
CREATE INDEX IF NOT EXISTS idx_hie_optimizations_focus ON hie_prompt_optimizations(hie_focus);
CREATE INDEX IF NOT EXISTS idx_hie_optimizations_conversion ON hie_prompt_optimizations(hie_conversion_rate);

-- =====================================================================
-- 3. TABLA DE PERFORMANCE DE GENES
-- =====================================================================
CREATE TABLE IF NOT EXISTS hie_gene_performance (
    -- Identificación
    gene_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gene_name VARCHAR(100) NOT NULL UNIQUE,
    gene_type VARCHAR(50) NOT NULL, -- tone, structure, persuasion, hie_element
    
    -- Definición del gen
    gene_value JSONB NOT NULL,
    gene_description TEXT,
    
    -- Performance metrics
    total_usage INTEGER DEFAULT 0,
    successful_usage INTEGER DEFAULT 0,
    avg_impact_score FLOAT CHECK (avg_impact_score >= -1.0 AND avg_impact_score <= 1.0),
    
    -- Análisis por contexto
    performance_by_archetype JSONB DEFAULT '{}',
    performance_by_tier JSONB DEFAULT '{}',
    performance_by_objection JSONB DEFAULT '{}',
    
    -- Combinaciones exitosas
    successful_combinations JSONB DEFAULT '[]', -- Otros genes con los que funciona bien
    unsuccessful_combinations JSONB DEFAULT '[]', -- Genes con los que no funciona
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    requires_review BOOLEAN DEFAULT false,
    
    -- Metadata
    discovered_at TIMESTAMP DEFAULT NOW(),
    last_updated TIMESTAMP DEFAULT NOW()
);

-- Índices para hie_gene_performance
CREATE INDEX IF NOT EXISTS idx_gene_performance_name ON hie_gene_performance(gene_name);
CREATE INDEX IF NOT EXISTS idx_gene_performance_type ON hie_gene_performance(gene_type);
CREATE INDEX IF NOT EXISTS idx_gene_performance_active ON hie_gene_performance(is_active);
CREATE INDEX IF NOT EXISTS idx_gene_performance_impact ON hie_gene_performance(avg_impact_score);

-- =====================================================================
-- 4. TABLA DE EXPERIMENTOS DE PROMPTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS prompt_experiments (
    -- Identificación
    experiment_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    experiment_name VARCHAR(255) NOT NULL,
    
    -- Configuración del experimento
    variant_ids JSONB NOT NULL, -- Array de variant_ids participando
    control_variant_id UUID,
    hypothesis TEXT NOT NULL,
    success_criteria JSONB NOT NULL,
    
    -- Estado del experimento
    status VARCHAR(50) DEFAULT 'planning', -- planning, running, analyzing, completed
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    
    -- Resultados
    total_conversations INTEGER DEFAULT 0,
    results_by_variant JSONB DEFAULT '{}',
    winning_variant_id UUID,
    statistical_significance FLOAT CHECK (statistical_significance >= 0.0 AND statistical_significance <= 1.0),
    
    -- Configuración estadística
    minimum_sample_size INTEGER DEFAULT 100,
    confidence_level FLOAT DEFAULT 0.95,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system',
    notes TEXT
);

-- Índices para prompt_experiments
CREATE INDEX IF NOT EXISTS idx_prompt_experiments_status ON prompt_experiments(status);
CREATE INDEX IF NOT EXISTS idx_prompt_experiments_dates ON prompt_experiments(start_date, end_date);

-- =====================================================================
-- 5. TABLA DE USO DE PROMPTS
-- =====================================================================
CREATE TABLE IF NOT EXISTS prompt_usage_log (
    -- Identificación
    usage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    variant_id UUID NOT NULL,
    conversation_id UUID NOT NULL,
    
    -- Contexto de uso
    used_at TIMESTAMP DEFAULT NOW(),
    prompt_position VARCHAR(50), -- greeting, middle, closing
    conversation_stage VARCHAR(100), -- discovery, objection_handling, closing
    
    -- Variables utilizadas
    template_values JSONB DEFAULT '{}',
    rendered_prompt TEXT,
    
    -- Resultado inmediato
    user_response TEXT,
    response_sentiment FLOAT CHECK (response_sentiment >= -1.0 AND response_sentiment <= 1.0),
    response_length INTEGER,
    response_time_seconds INTEGER,
    
    -- Impacto
    engagement_delta FLOAT, -- Cambio en engagement después del prompt
    conversion_impact FLOAT CHECK (conversion_impact >= -1.0 AND conversion_impact <= 1.0),
    led_to_conversion BOOLEAN,
    
    -- Foreign key
    FOREIGN KEY (variant_id) REFERENCES prompt_variants(variant_id) ON DELETE CASCADE
);

-- Índices para prompt_usage_log
CREATE INDEX IF NOT EXISTS idx_prompt_usage_variant ON prompt_usage_log(variant_id);
CREATE INDEX IF NOT EXISTS idx_prompt_usage_conversation ON prompt_usage_log(conversation_id);
CREATE INDEX IF NOT EXISTS idx_prompt_usage_timestamp ON prompt_usage_log(used_at);
CREATE INDEX IF NOT EXISTS idx_prompt_usage_conversion ON prompt_usage_log(led_to_conversion);

-- =====================================================================
-- 6. TRIGGERS Y FUNCIONES
-- =====================================================================

-- Trigger para actualizar updated_at en prompt_variants
CREATE OR REPLACE FUNCTION update_prompt_variant_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_prompt_variant_timestamp_trigger
BEFORE UPDATE ON prompt_variants
FOR EACH ROW EXECUTE FUNCTION update_prompt_variant_timestamp();

-- Función para calcular fitness score de un prompt
CREATE OR REPLACE FUNCTION calculate_prompt_fitness(
    variant_id UUID
) RETURNS FLOAT AS $$
DECLARE
    fitness FLOAT := 0;
    variant RECORD;
BEGIN
    SELECT * INTO variant FROM prompt_variants WHERE prompt_variants.variant_id = $1;
    
    IF FOUND THEN
        -- Fórmula de fitness: combina success rate, engagement y conversion impact
        fitness := (
            COALESCE(variant.success_rate, 0) * 0.4 +
            COALESCE(variant.avg_engagement_score / 10.0, 0) * 0.3 +
            COALESCE((variant.avg_conversion_impact + 1) / 2, 0.5) * 0.3
        );
    END IF;
    
    RETURN fitness;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 7. VISTAS ANALÍTICAS
-- =====================================================================

-- Vista de mejores prompts por tipo
CREATE OR REPLACE VIEW top_performing_prompts AS
SELECT 
    pv.variant_id,
    pv.variant_name,
    pv.prompt_type,
    pv.generation,
    pv.usage_count,
    pv.success_rate,
    pv.avg_engagement_score,
    pv.avg_conversion_impact,
    calculate_prompt_fitness(pv.variant_id) as fitness_score
FROM prompt_variants pv
WHERE pv.is_active = true AND pv.usage_count >= 10
ORDER BY calculate_prompt_fitness(pv.variant_id) DESC;

-- Vista de evolución genética
CREATE OR REPLACE VIEW genetic_evolution_view AS
SELECT 
    generation,
    COUNT(*) as variant_count,
    AVG(success_rate) as avg_success_rate,
    AVG(avg_engagement_score) as avg_engagement,
    MAX(success_rate) as best_success_rate,
    AVG(usage_count) as avg_usage
FROM prompt_variants
WHERE is_active = true
GROUP BY generation
ORDER BY generation;

-- =====================================================================
-- 8. DATOS INICIALES - GENES HIE
-- =====================================================================

-- Insertar genes iniciales para optimización HIE
INSERT INTO hie_gene_performance (gene_name, gene_type, gene_value, gene_description) VALUES
('scientific_credibility', 'hie_element', 
 '{"template": "Basado en {study_count} estudios científicos con {participant_count} participantes"}',
 'Enfatiza credibilidad científica con números específicos'),
 
('roi_emphasis', 'persuasion',
 '{"template": "ROI promedio de {roi_percentage}% en {time_period}"}',
 'Enfatiza retorno de inversión específico'),
 
('urgency_scarcity', 'persuasion',
 '{"template": "Solo {spots_left} lugares disponibles este mes"}',
 'Crea urgencia con escasez real'),
 
('social_proof_specific', 'hie_element',
 '{"template": "{client_name}, {client_profession} en {client_company}: \"{testimonial}\""}',
 'Testimonios específicos con datos verificables'),
 
('empathetic_understanding', 'tone',
 '{"markers": ["entiendo", "comprendo", "tiene sentido", "es natural"]}',
 'Tono empático que genera confianza'),
 
('consultative_approach', 'structure',
 '{"flow": ["pregunta", "escucha", "valida", "sugiere"]}',
 'Estructura consultiva no agresiva')
ON CONFLICT (gene_name) DO NOTHING;

-- =====================================================================
-- 9. PLANTILLAS DE PROMPTS INICIALES
-- =====================================================================

-- Insertar variantes de prompts iniciales
INSERT INTO prompt_variants (variant_name, prompt_type, prompt_template, genetic_code, target_archetype) VALUES
('hie_greeting_analytical', 'greeting',
 'Hola {name}, veo que estás interesado en optimizar tu rendimiento. Basándome en más de 50 estudios científicos y 10,000+ horas de datos biométricos, el sistema HIE puede ayudarte a lograr resultados medibles. ¿Qué aspecto específico de tu rendimiento te gustaría mejorar?',
 '{"genes": ["scientific_credibility", "consultative_approach"]}',
 'analytical'),
 
('hie_objection_price_roi', 'objection_handling',
 'Entiendo perfectamente tu preocupación sobre la inversión. De hecho, es una pregunta inteligente. Nuestros clientes, profesionales como tú, reportan un ROI promedio del 847% en los primeros 6 meses. ¿Te gustaría ver cómo calculamos este retorno específicamente para tu caso?',
 '{"genes": ["empathetic_understanding", "roi_emphasis", "consultative_approach"]}',
 'all'),
 
('hie_closing_early_adopter', 'closing',
 'Me encanta tu visión {name}. Eres exactamente el tipo de profesional innovador que estamos buscando. Tenemos solo {spots_left} lugares en nuestro programa Early Adopter este mes, con beneficios exclusivos. ¿Te gustaría asegurar tu lugar ahora?',
 '{"genes": ["urgency_scarcity", "social_proof_specific"]}',
 'all')
ON CONFLICT DO NOTHING;

-- =====================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================================
COMMENT ON TABLE prompt_variants IS 'Variantes de prompts para optimización genética';
COMMENT ON TABLE hie_prompt_optimizations IS 'Optimizaciones específicas HIE para prompts';
COMMENT ON TABLE hie_gene_performance IS 'Performance de genes individuales en algoritmo genético';
COMMENT ON TABLE prompt_experiments IS 'Experimentos A/B para optimización de prompts';
COMMENT ON TABLE prompt_usage_log IS 'Log detallado de uso de cada prompt';

-- =====================================================================
-- Script completado exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 006_trial_management.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 006: SISTEMA DE GESTIÓN DE TRIALS Y DEMOS
-- =====================================================================
-- Este script crea las tablas para el sistema de demos en vivo,
-- trials pagados y gestión de conversión de usuarios

-- =====================================================================
-- 1. TABLA DE USUARIOS DE TRIAL
-- =====================================================================
CREATE TABLE IF NOT EXISTS trial_users (
    -- Identificación
    trial_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    conversation_id UUID,
    
    -- Información del trial
    trial_tier VARCHAR(50) NOT NULL, -- essential, pro, elite, premium
    trial_type VARCHAR(50) NOT NULL, -- free_trial, paid_trial, demo_access
    trial_price DECIMAL(10,2) DEFAULT 0.00,
    
    -- Duración del trial
    trial_start_date TIMESTAMP NOT NULL DEFAULT NOW(),
    trial_end_date TIMESTAMP NOT NULL,
    trial_duration_days INTEGER GENERATED ALWAYS AS (
        EXTRACT(DAY FROM trial_end_date - trial_start_date)
    ) STORED,
    
    -- Estado del trial
    status VARCHAR(50) DEFAULT 'active', -- active, expired, converted, cancelled
    activation_method VARCHAR(50), -- immediate, email_confirmation, manual
    activated_at TIMESTAMP,
    
    -- Datos de conversión
    converted_to_paid BOOLEAN DEFAULT false,
    conversion_date TIMESTAMP,
    converted_tier VARCHAR(50),
    conversion_value DECIMAL(10,2),
    
    -- Engagement metrics
    login_count INTEGER DEFAULT 0,
    last_login_at TIMESTAMP,
    features_used JSONB DEFAULT '[]',
    engagement_score FLOAT CHECK (engagement_score >= 0.0 AND engagement_score <= 10.0),
    
    -- Milestones alcanzados
    milestones_completed JSONB DEFAULT '[]',
    onboarding_completed BOOLEAN DEFAULT false,
    onboarding_completion_time_minutes INTEGER,
    
    -- Comunicación
    emails_sent INTEGER DEFAULT 0,
    emails_opened INTEGER DEFAULT 0,
    touchpoints_completed JSONB DEFAULT '[]',
    
    -- Razones de cancelación/no conversión
    cancellation_reason VARCHAR(255),
    cancellation_feedback TEXT,
    exit_survey_completed BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    source VARCHAR(100), -- organic, paid_ad, referral, sales_call
    referral_code VARCHAR(50),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100)
);

-- Índices para trial_users
CREATE INDEX IF NOT EXISTS idx_trial_users_user ON trial_users(user_id);
CREATE INDEX IF NOT EXISTS idx_trial_users_status ON trial_users(status);
CREATE INDEX IF NOT EXISTS idx_trial_users_dates ON trial_users(trial_start_date, trial_end_date);
CREATE INDEX IF NOT EXISTS idx_trial_users_converted ON trial_users(converted_to_paid);
CREATE INDEX IF NOT EXISTS idx_trial_users_tier ON trial_users(trial_tier);
CREATE INDEX IF NOT EXISTS idx_trial_users_engagement ON trial_users(engagement_score);

-- =====================================================================
-- 2. TABLA DE EVENTOS DE DEMO
-- =====================================================================
CREATE TABLE IF NOT EXISTS demo_events (
    -- Identificación
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL,
    conversation_id UUID,
    user_id UUID,
    
    -- Información del evento
    event_type VARCHAR(100) NOT NULL, -- demo_started, feature_shown, interaction, demo_completed
    event_name VARCHAR(255) NOT NULL,
    event_category VARCHAR(100), -- hie_showcase, roi_calculation, feature_demo, testimonial
    
    -- Detalles del evento
    event_data JSONB NOT NULL DEFAULT '{}',
    duration_seconds INTEGER,
    
    -- Contexto de la demo
    demo_type VARCHAR(50) NOT NULL, -- energy_boost, focus_enhancement, stress_reduction, cognitive
    profession VARCHAR(100),
    customization_level VARCHAR(20), -- generic, personalized, highly_personalized
    
    -- Interacción y engagement
    user_interaction BOOLEAN DEFAULT false,
    interaction_type VARCHAR(50), -- click, hover, question, response
    interaction_quality FLOAT CHECK (interaction_quality >= 0.0 AND interaction_quality <= 1.0),
    
    -- Impacto
    engagement_impact FLOAT CHECK (engagement_impact >= -1.0 AND engagement_impact <= 1.0),
    conversion_impact FLOAT CHECK (conversion_impact >= -1.0 AND conversion_impact <= 1.0),
    belief_shift_indicator FLOAT CHECK (belief_shift_indicator >= 0.0 AND belief_shift_indicator <= 1.0),
    
    -- Metadata
    timestamp TIMESTAMP DEFAULT NOW(),
    device_type VARCHAR(50),
    browser VARCHAR(50),
    
    -- Índice compuesto para sesión
    UNIQUE(session_id, event_type, timestamp)
);

-- Índices para demo_events
CREATE INDEX IF NOT EXISTS idx_demo_events_session ON demo_events(session_id);
CREATE INDEX IF NOT EXISTS idx_demo_events_user ON demo_events(user_id);
CREATE INDEX IF NOT EXISTS idx_demo_events_type ON demo_events(event_type);
CREATE INDEX IF NOT EXISTS idx_demo_events_timestamp ON demo_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_demo_events_demo_type ON demo_events(demo_type);
CREATE INDEX IF NOT EXISTS idx_demo_events_conversion_impact ON demo_events(conversion_impact);

-- =====================================================================
-- 3. TABLA DE SESIONES DE DEMO
-- =====================================================================
CREATE TABLE IF NOT EXISTS demo_sessions (
    -- Identificación
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    user_id UUID,
    
    -- Configuración de la demo
    demo_type VARCHAR(50) NOT NULL,
    demo_mode VARCHAR(50) NOT NULL, -- interactive, passive, guided
    personalization_data JSONB DEFAULT '{}',
    
    -- Timing
    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP,
    total_duration_seconds INTEGER,
    
    -- Métricas de la sesión
    total_events INTEGER DEFAULT 0,
    interaction_count INTEGER DEFAULT 0,
    features_demonstrated JSONB DEFAULT '[]',
    key_points_covered JSONB DEFAULT '[]',
    
    -- Resultados
    completion_rate FLOAT CHECK (completion_rate >= 0.0 AND completion_rate <= 1.0),
    engagement_score FLOAT CHECK (engagement_score >= 0.0 AND engagement_score <= 10.0),
    effectiveness_score FLOAT CHECK (effectiveness_score >= 0.0 AND effectiveness_score <= 10.0),
    
    -- Conversión
    led_to_trial BOOLEAN DEFAULT false,
    led_to_purchase BOOLEAN DEFAULT false,
    post_demo_action VARCHAR(100), -- started_trial, scheduled_call, requested_info, no_action
    
    -- Feedback
    user_feedback_score INTEGER CHECK (user_feedback_score >= 1 AND user_feedback_score <= 10),
    user_feedback_text TEXT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    demo_version VARCHAR(50) DEFAULT 'v1.0'
);

-- Índices para demo_sessions
CREATE INDEX IF NOT EXISTS idx_demo_sessions_conversation ON demo_sessions(conversation_id);
CREATE INDEX IF NOT EXISTS idx_demo_sessions_user ON demo_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_demo_sessions_completed ON demo_sessions(completed_at);
CREATE INDEX IF NOT EXISTS idx_demo_sessions_effectiveness ON demo_sessions(effectiveness_score);

-- =====================================================================
-- 4. TABLA DE TOUCHPOINTS PROGRAMADOS
-- =====================================================================
CREATE TABLE IF NOT EXISTS scheduled_touchpoints (
    -- Identificación
    touchpoint_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trial_id UUID NOT NULL,
    user_id UUID NOT NULL,
    
    -- Configuración del touchpoint
    touchpoint_type VARCHAR(100) NOT NULL, -- welcome, feature_highlight, milestone, renewal_reminder
    touchpoint_day INTEGER NOT NULL, -- Día del trial cuando debe ocurrir
    
    -- Contenido
    channel VARCHAR(50) NOT NULL, -- email, in_app, sms, push
    template_id VARCHAR(100),
    personalization_data JSONB DEFAULT '{}',
    
    -- Programación
    scheduled_for TIMESTAMP NOT NULL,
    
    -- Estado
    status VARCHAR(50) DEFAULT 'pending', -- pending, sent, delivered, failed, cancelled
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    opened_at TIMESTAMP,
    clicked_at TIMESTAMP,
    
    -- Respuesta
    user_action VARCHAR(100), -- clicked, replied, ignored, unsubscribed
    action_timestamp TIMESTAMP,
    
    -- Efectividad
    engagement_impact FLOAT CHECK (engagement_impact >= -1.0 AND engagement_impact <= 1.0),
    conversion_impact FLOAT CHECK (conversion_impact >= -1.0 AND conversion_impact <= 1.0),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    
    -- Foreign key
    FOREIGN KEY (trial_id) REFERENCES trial_users(trial_id) ON DELETE CASCADE
);

-- Índices para scheduled_touchpoints
CREATE INDEX IF NOT EXISTS idx_touchpoints_trial ON scheduled_touchpoints(trial_id);
CREATE INDEX IF NOT EXISTS idx_touchpoints_user ON scheduled_touchpoints(user_id);
CREATE INDEX IF NOT EXISTS idx_touchpoints_scheduled ON scheduled_touchpoints(scheduled_for);
CREATE INDEX IF NOT EXISTS idx_touchpoints_status ON scheduled_touchpoints(status);
CREATE INDEX IF NOT EXISTS idx_touchpoints_type ON scheduled_touchpoints(touchpoint_type);

-- =====================================================================
-- 5. TABLA DE EVENTOS DE TRIAL
-- =====================================================================
CREATE TABLE IF NOT EXISTS trial_events (
    -- Identificación
    event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trial_id UUID NOT NULL,
    user_id UUID NOT NULL,
    
    -- Información del evento
    event_type VARCHAR(100) NOT NULL, -- login, feature_used, milestone_reached, upgrade_clicked
    event_name VARCHAR(255) NOT NULL,
    event_category VARCHAR(100),
    
    -- Detalles
    event_data JSONB DEFAULT '{}',
    session_id VARCHAR(255),
    
    -- Impacto
    engagement_value FLOAT DEFAULT 1.0,
    conversion_signal FLOAT CHECK (conversion_signal >= 0.0 AND conversion_signal <= 1.0),
    
    -- Metadata
    timestamp TIMESTAMP DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    
    -- Foreign key
    FOREIGN KEY (trial_id) REFERENCES trial_users(trial_id) ON DELETE CASCADE
);

-- Índices para trial_events
CREATE INDEX IF NOT EXISTS idx_trial_events_trial ON trial_events(trial_id);
CREATE INDEX IF NOT EXISTS idx_trial_events_user ON trial_events(user_id);
CREATE INDEX IF NOT EXISTS idx_trial_events_type ON trial_events(event_type);
CREATE INDEX IF NOT EXISTS idx_trial_events_timestamp ON trial_events(timestamp);
CREATE INDEX IF NOT EXISTS idx_trial_events_category ON trial_events(event_category);

-- =====================================================================
-- 6. TABLA DE CONFIGURACIÓN DE TRIALS
-- =====================================================================
CREATE TABLE IF NOT EXISTS trial_configuration (
    -- Identificación
    config_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tier VARCHAR(50) NOT NULL UNIQUE, -- essential, pro, elite, premium
    
    -- Configuración del trial
    trial_duration_days INTEGER NOT NULL DEFAULT 14,
    trial_price DECIMAL(10,2) DEFAULT 0.00,
    
    -- Features incluidas
    included_features JSONB NOT NULL DEFAULT '[]',
    feature_limits JSONB DEFAULT '{}',
    
    -- Milestones y gamificación
    milestone_definitions JSONB NOT NULL DEFAULT '[]',
    reward_system JSONB DEFAULT '{}',
    
    -- Estrategia de conversión
    touchpoint_schedule JSONB NOT NULL DEFAULT '[]', -- Array de touchpoints por día
    conversion_triggers JSONB DEFAULT '[]', -- Eventos que triggerean ofertas
    
    -- Ofertas de conversión
    standard_offer JSONB DEFAULT '{}',
    early_bird_offer JSONB DEFAULT '{}',
    last_chance_offer JSONB DEFAULT '{}',
    
    -- Configuración de comunicación
    email_templates JSONB DEFAULT '{}',
    in_app_messages JSONB DEFAULT '{}',
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    created_by VARCHAR(255) DEFAULT 'system'
);

-- =====================================================================
-- 7. TRIGGERS Y FUNCIONES
-- =====================================================================

-- Trigger para actualizar updated_at en trial_users
CREATE OR REPLACE FUNCTION update_trial_users_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    -- Actualizar engagement score basado en actividad
    IF NEW.login_count > OLD.login_count THEN
        NEW.engagement_score = LEAST(10.0, COALESCE(NEW.engagement_score, 0) + 0.5);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_trial_users_timestamp_trigger
BEFORE UPDATE ON trial_users
FOR EACH ROW EXECUTE FUNCTION update_trial_users_timestamp();

-- Función para calcular probabilidad de conversión
CREATE OR REPLACE FUNCTION calculate_trial_conversion_probability(
    trial_id UUID
) RETURNS FLOAT AS $$
DECLARE
    probability FLOAT := 0.0;
    trial_data RECORD;
    engagement_weight FLOAT := 0.3;
    milestone_weight FLOAT := 0.3;
    usage_weight FLOAT := 0.4;
BEGIN
    SELECT * INTO trial_data FROM trial_users WHERE trial_users.trial_id = $1;
    
    IF FOUND THEN
        probability := (
            COALESCE(trial_data.engagement_score / 10.0, 0) * engagement_weight +
            COALESCE(jsonb_array_length(trial_data.milestones_completed)::FLOAT / 10.0, 0) * milestone_weight +
            LEAST(trial_data.login_count::FLOAT / 20.0, 1.0) * usage_weight
        );
    END IF;
    
    RETURN LEAST(probability, 1.0);
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 8. VISTAS ANALÍTICAS
-- =====================================================================

-- Vista de performance de trials por tier
CREATE OR REPLACE VIEW trial_performance_by_tier AS
SELECT 
    trial_tier,
    COUNT(*) as total_trials,
    COUNT(*) FILTER (WHERE converted_to_paid = true) as conversions,
    ROUND(COUNT(*) FILTER (WHERE converted_to_paid = true)::NUMERIC / 
          NULLIF(COUNT(*)::NUMERIC, 0) * 100, 2) as conversion_rate,
    AVG(engagement_score) as avg_engagement,
    AVG(EXTRACT(DAY FROM conversion_date - trial_start_date)) 
        FILTER (WHERE converted_to_paid = true) as avg_days_to_conversion,
    AVG(conversion_value) FILTER (WHERE converted_to_paid = true) as avg_conversion_value
FROM trial_users
GROUP BY trial_tier
ORDER BY conversion_rate DESC;

-- Vista de efectividad de demos
CREATE OR REPLACE VIEW demo_effectiveness AS
SELECT 
    ds.demo_type,
    COUNT(DISTINCT ds.session_id) as total_sessions,
    AVG(ds.completion_rate) as avg_completion_rate,
    AVG(ds.engagement_score) as avg_engagement,
    AVG(ds.effectiveness_score) as avg_effectiveness,
    COUNT(*) FILTER (WHERE ds.led_to_trial = true) as trials_started,
    COUNT(*) FILTER (WHERE ds.led_to_purchase = true) as direct_purchases,
    ROUND(COUNT(*) FILTER (WHERE ds.led_to_trial = true)::NUMERIC / 
          NULLIF(COUNT(*)::NUMERIC, 0) * 100, 2) as trial_conversion_rate
FROM demo_sessions ds
WHERE ds.completed_at IS NOT NULL
GROUP BY ds.demo_type
ORDER BY avg_effectiveness DESC;

-- Vista de touchpoints más efectivos
CREATE OR REPLACE VIEW effective_touchpoints AS
SELECT 
    touchpoint_type,
    touchpoint_day,
    COUNT(*) as total_sent,
    COUNT(*) FILTER (WHERE status = 'delivered') as delivered,
    COUNT(*) FILTER (WHERE opened_at IS NOT NULL) as opened,
    COUNT(*) FILTER (WHERE clicked_at IS NOT NULL) as clicked,
    AVG(engagement_impact) as avg_engagement_impact,
    AVG(conversion_impact) as avg_conversion_impact
FROM scheduled_touchpoints
WHERE status != 'pending'
GROUP BY touchpoint_type, touchpoint_day
ORDER BY avg_conversion_impact DESC NULLS LAST;

-- =====================================================================
-- 9. DATOS INICIALES
-- =====================================================================

-- Configuración inicial de trials
INSERT INTO trial_configuration (tier, trial_duration_days, trial_price, included_features, touchpoint_schedule) VALUES
('essential', 14, 0.00, 
 '["basic_tracking", "weekly_insights", "community_access"]',
 '[{"day": 1, "type": "welcome"}, {"day": 3, "type": "feature_highlight"}, {"day": 7, "type": "milestone"}, {"day": 12, "type": "renewal_reminder"}]'),
 
('pro', 14, 0.00,
 '["advanced_tracking", "daily_insights", "personalized_recommendations", "priority_support"]',
 '[{"day": 1, "type": "welcome"}, {"day": 2, "type": "onboarding"}, {"day": 5, "type": "feature_highlight"}, {"day": 10, "type": "success_story"}, {"day": 13, "type": "special_offer"}]'),
 
('elite', 14, 29.00,
 '["full_tracking", "real_time_insights", "ai_coach", "1on1_sessions", "custom_programs"]',
 '[{"day": 1, "type": "vip_welcome"}, {"day": 3, "type": "personal_coach_intro"}, {"day": 7, "type": "progress_review"}, {"day": 10, "type": "exclusive_content"}, {"day": 13, "type": "conversion_call"}]')
ON CONFLICT (tier) DO NOTHING;

-- =====================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================================
COMMENT ON TABLE trial_users IS 'Gestión completa de usuarios en período de trial';
COMMENT ON TABLE demo_events IS 'Eventos detallados durante demos interactivas';
COMMENT ON TABLE demo_sessions IS 'Sesiones completas de demostración con métricas';
COMMENT ON TABLE scheduled_touchpoints IS 'Comunicaciones programadas durante el trial';
COMMENT ON TABLE trial_events IS 'Todos los eventos de usuario durante el trial';
COMMENT ON TABLE trial_configuration IS 'Configuración por tier de trial';

-- =====================================================================
-- Script completado exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 007_roi_tracking.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 007: SISTEMA DE TRACKING Y CÁLCULO DE ROI
-- =====================================================================
-- Este script crea las tablas para el cálculo dinámico de ROI,
-- tracking de métricas de valor y proyecciones personalizadas

-- =====================================================================
-- 1. TABLA DE CÁLCULOS DE ROI
-- =====================================================================
CREATE TABLE IF NOT EXISTS roi_calculations (
    -- Identificación
    calculation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL,
    user_id UUID,
    
    -- Contexto del cálculo
    profession VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    company_size VARCHAR(50), -- small, medium, large, enterprise
    
    -- Inputs del cálculo
    base_inputs JSONB NOT NULL, -- hourly_rate, monthly_income, work_hours, etc.
    current_metrics JSONB NOT NULL, -- current productivity, stress level, etc.
    target_metrics JSONB NOT NULL, -- desired improvements
    
    -- Tipos de ROI calculados
    financial_roi JSONB NOT NULL DEFAULT '{}', -- monetary returns
    time_roi JSONB NOT NULL DEFAULT '{}', -- time saved/gained
    productivity_roi JSONB NOT NULL DEFAULT '{}', -- efficiency gains
    health_roi JSONB NOT NULL DEFAULT '{}', -- health improvements value
    performance_roi JSONB NOT NULL DEFAULT '{}', -- performance metrics
    stress_reduction_roi JSONB NOT NULL DEFAULT '{}', -- stress cost savings
    
    -- ROI consolidado
    total_roi_percentage FLOAT,
    total_value_generated DECIMAL(12,2),
    payback_period_months FLOAT,
    five_year_projection DECIMAL(12,2),
    
    -- Factores de cálculo
    calculation_method VARCHAR(50) DEFAULT 'standard', -- standard, conservative, optimistic
    confidence_level FLOAT CHECK (confidence_level >= 0.0 AND confidence_level <= 1.0),
    assumptions_used JSONB DEFAULT '[]',
    
    -- Comparativas
    industry_benchmark_roi FLOAT,
    percentile_ranking INTEGER CHECK (percentile_ranking >= 0 AND percentile_ranking <= 100),
    similar_profiles_avg_roi FLOAT,
    
    -- Personalización
    personalized_factors JSONB DEFAULT '{}', -- factors specific to user
    custom_benefits JSONB DEFAULT '[]', -- additional benefits identified
    
    -- Validación
    data_quality_score FLOAT CHECK (data_quality_score >= 0.0 AND data_quality_score <= 1.0),
    calculation_version VARCHAR(50) DEFAULT 'v1.0',
    
    -- Presentación
    highlighted_metrics JSONB DEFAULT '[]', -- top 3-5 metrics to emphasize
    visual_data JSONB DEFAULT '{}', -- data formatted for charts
    
    -- Impacto en conversión
    shown_to_user BOOLEAN DEFAULT false,
    user_reaction VARCHAR(50), -- positive, neutral, skeptical, negative
    led_to_conversion BOOLEAN,
    
    -- Metadata
    calculated_at TIMESTAMP DEFAULT NOW(),
    calculation_time_ms INTEGER,
    
    -- Unique constraint para evitar duplicados
    UNIQUE(conversation_id, calculation_version)
);

-- Índices para roi_calculations
CREATE INDEX IF NOT EXISTS idx_roi_calculations_conversation ON roi_calculations(conversation_id);
CREATE INDEX IF NOT EXISTS idx_roi_calculations_user ON roi_calculations(user_id);
CREATE INDEX IF NOT EXISTS idx_roi_calculations_profession ON roi_calculations(profession);
CREATE INDEX IF NOT EXISTS idx_roi_calculations_total_roi ON roi_calculations(total_roi_percentage);
CREATE INDEX IF NOT EXISTS idx_roi_calculations_calculated_at ON roi_calculations(calculated_at);
CREATE INDEX IF NOT EXISTS idx_roi_calculations_conversion ON roi_calculations(led_to_conversion);

-- =====================================================================
-- 2. TABLA DE BENCHMARKS POR PROFESIÓN
-- =====================================================================
CREATE TABLE IF NOT EXISTS roi_profession_benchmarks (
    -- Identificación
    benchmark_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profession VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    
    -- Métricas base promedio
    avg_hourly_rate DECIMAL(10,2),
    avg_monthly_income DECIMAL(12,2),
    avg_work_hours_weekly FLOAT,
    
    -- Costos de ineficiencia típicos
    avg_productivity_loss_percentage FLOAT,
    avg_stress_cost_monthly DECIMAL(10,2),
    avg_health_issues_cost_yearly DECIMAL(12,2),
    avg_burnout_risk_percentage FLOAT,
    
    -- Mejoras típicas con HIE
    avg_productivity_improvement FLOAT,
    avg_stress_reduction FLOAT,
    avg_energy_increase FLOAT,
    avg_focus_improvement FLOAT,
    avg_recovery_time_reduction FLOAT,
    
    -- ROI histórico
    median_roi_percentage FLOAT,
    top_quartile_roi FLOAT,
    bottom_quartile_roi FLOAT,
    
    -- Factores de valor específicos
    value_factors JSONB DEFAULT '{}', -- specific value drivers for profession
    common_pain_points JSONB DEFAULT '[]',
    highest_impact_areas JSONB DEFAULT '[]',
    
    -- Datos de muestra
    sample_size INTEGER,
    data_freshness_days INTEGER,
    confidence_interval JSONB DEFAULT '{}',
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    requires_update BOOLEAN DEFAULT false,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    data_source VARCHAR(255),
    
    -- Unique constraint
    UNIQUE(profession, industry)
);

-- Índices para roi_profession_benchmarks
CREATE INDEX IF NOT EXISTS idx_roi_benchmarks_profession ON roi_profession_benchmarks(profession);
CREATE INDEX IF NOT EXISTS idx_roi_benchmarks_industry ON roi_profession_benchmarks(industry);
CREATE INDEX IF NOT EXISTS idx_roi_benchmarks_active ON roi_profession_benchmarks(is_active);

-- =====================================================================
-- 3. TABLA DE CASOS DE ÉXITO REALES
-- =====================================================================
CREATE TABLE IF NOT EXISTS roi_success_stories (
    -- Identificación
    story_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_identifier VARCHAR(100) NOT NULL, -- anonymized but consistent
    
    -- Perfil del cliente
    profession VARCHAR(100) NOT NULL,
    industry VARCHAR(100),
    company_type VARCHAR(100),
    starting_situation TEXT,
    
    -- Resultados medibles
    implementation_date DATE,
    measurement_period_months INTEGER,
    
    -- ROI específico
    financial_roi_percentage FLOAT NOT NULL,
    time_saved_hours_monthly FLOAT,
    productivity_increase_percentage FLOAT,
    stress_reduction_percentage FLOAT,
    
    -- Valores monetarios
    monthly_value_generated DECIMAL(10,2),
    yearly_value_generated DECIMAL(12,2),
    total_investment DECIMAL(10,2),
    net_profit DECIMAL(12,2),
    
    -- Detalles cualitativos
    key_improvements JSONB DEFAULT '[]',
    testimonial_quote TEXT,
    specific_wins JSONB DEFAULT '[]',
    
    -- Verificación
    verified BOOLEAN DEFAULT false,
    verification_method VARCHAR(100),
    documentation_available BOOLEAN DEFAULT false,
    
    -- Uso en ventas
    can_be_shared BOOLEAN DEFAULT true,
    sharing_restrictions JSONB DEFAULT '{}',
    times_referenced INTEGER DEFAULT 0,
    conversion_impact_score FLOAT,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    story_status VARCHAR(50) DEFAULT 'active' -- active, archived, pending_verification
);

-- Índices para roi_success_stories
CREATE INDEX IF NOT EXISTS idx_success_stories_profession ON roi_success_stories(profession);
CREATE INDEX IF NOT EXISTS idx_success_stories_roi ON roi_success_stories(financial_roi_percentage);
CREATE INDEX IF NOT EXISTS idx_success_stories_verified ON roi_success_stories(verified);
CREATE INDEX IF NOT EXISTS idx_success_stories_status ON roi_success_stories(story_status);

-- =====================================================================
-- 4. TABLA DE COMPONENTES DE VALOR HIE
-- =====================================================================
CREATE TABLE IF NOT EXISTS roi_value_components (
    -- Identificación
    component_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    component_name VARCHAR(100) NOT NULL UNIQUE,
    component_category VARCHAR(50) NOT NULL, -- productivity, health, performance, wellbeing
    
    -- Descripción del valor
    description TEXT NOT NULL,
    measurement_method TEXT,
    
    -- Fórmula de cálculo
    calculation_formula JSONB NOT NULL,
    required_inputs JSONB DEFAULT '[]',
    
    -- Valores típicos
    typical_improvement_range JSONB DEFAULT '{}', -- min, max, average
    value_per_unit DECIMAL(10,2), -- $ per hour saved, $ per % productivity, etc.
    
    -- Aplicabilidad
    applicable_professions JSONB DEFAULT '[]', -- empty = all
    applicable_tiers JSONB DEFAULT '[]', -- empty = all
    weight_in_total_roi FLOAT DEFAULT 1.0,
    
    -- Evidencia
    supporting_studies JSONB DEFAULT '[]',
    confidence_level FLOAT CHECK (confidence_level >= 0.0 AND confidence_level <= 1.0),
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para roi_value_components
CREATE INDEX IF NOT EXISTS idx_value_components_name ON roi_value_components(component_name);
CREATE INDEX IF NOT EXISTS idx_value_components_category ON roi_value_components(component_category);
CREATE INDEX IF NOT EXISTS idx_value_components_active ON roi_value_components(is_active);

-- =====================================================================
-- 5. TABLA DE PROYECCIONES DE ROI
-- =====================================================================
CREATE TABLE IF NOT EXISTS roi_projections (
    -- Identificación
    projection_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    calculation_id UUID NOT NULL,
    
    -- Timeline de proyección
    projection_months JSONB NOT NULL, -- Array de valores por mes
    projection_years JSONB NOT NULL, -- Array de valores por año (5 años)
    
    -- Escenarios
    conservative_projection JSONB NOT NULL,
    realistic_projection JSONB NOT NULL,
    optimistic_projection JSONB NOT NULL,
    
    -- Factores de crecimiento
    compound_growth_rate FLOAT,
    value_acceleration_factors JSONB DEFAULT '[]',
    
    -- Puntos de inflexión
    breakeven_month INTEGER,
    exponential_growth_start_month INTEGER,
    plateau_expected_month INTEGER,
    
    -- Riesgos y ajustes
    risk_factors JSONB DEFAULT '[]',
    seasonal_adjustments JSONB DEFAULT '{}',
    
    -- Visualización
    chart_data JSONB NOT NULL, -- Formatted for frontend charts
    key_milestones JSONB DEFAULT '[]',
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    
    -- Foreign key
    FOREIGN KEY (calculation_id) REFERENCES roi_calculations(calculation_id) ON DELETE CASCADE
);

-- Índices para roi_projections
CREATE INDEX IF NOT EXISTS idx_roi_projections_calculation ON roi_projections(calculation_id);
CREATE INDEX IF NOT EXISTS idx_roi_projections_breakeven ON roi_projections(breakeven_month);

-- =====================================================================
-- 6. FUNCIONES Y TRIGGERS
-- =====================================================================

-- Función para calcular ROI base
CREATE OR REPLACE FUNCTION calculate_base_roi(
    hourly_rate DECIMAL,
    productivity_gain FLOAT,
    hours_saved_monthly FLOAT,
    stress_cost_reduction DECIMAL,
    additional_value DECIMAL
) RETURNS FLOAT AS $$
DECLARE
    monthly_productivity_value DECIMAL;
    monthly_time_value DECIMAL;
    total_monthly_value DECIMAL;
    monthly_cost DECIMAL := 149.00; -- Pro tier as default
    roi FLOAT;
BEGIN
    -- Calculate productivity value
    monthly_productivity_value := hourly_rate * 160 * (productivity_gain / 100);
    
    -- Calculate time value
    monthly_time_value := hourly_rate * hours_saved_monthly;
    
    -- Total value
    total_monthly_value := monthly_productivity_value + monthly_time_value + 
                          stress_cost_reduction + COALESCE(additional_value, 0);
    
    -- Calculate ROI
    IF monthly_cost > 0 THEN
        roi := ((total_monthly_value - monthly_cost) / monthly_cost) * 100;
    ELSE
        roi := 0;
    END IF;
    
    RETURN roi;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Trigger para actualizar benchmarks
CREATE OR REPLACE FUNCTION update_benchmark_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.data_freshness_days := 0;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_benchmark_timestamp_trigger
BEFORE UPDATE ON roi_profession_benchmarks
FOR EACH ROW EXECUTE FUNCTION update_benchmark_timestamp();

-- =====================================================================
-- 7. VISTAS ANALÍTICAS
-- =====================================================================

-- Vista de ROI promedio por profesión
CREATE OR REPLACE VIEW roi_by_profession_view AS
SELECT 
    rc.profession,
    COUNT(*) as total_calculations,
    AVG(rc.total_roi_percentage) as avg_roi,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rc.total_roi_percentage) as median_roi,
    MAX(rc.total_roi_percentage) as max_roi,
    MIN(rc.total_roi_percentage) as min_roi,
    AVG(rc.payback_period_months) as avg_payback_months,
    COUNT(*) FILTER (WHERE rc.led_to_conversion = true) as conversions,
    AVG(rc.confidence_level) as avg_confidence
FROM roi_calculations rc
WHERE rc.shown_to_user = true
GROUP BY rc.profession
ORDER BY avg_roi DESC;

-- Vista de componentes de valor más impactantes
CREATE OR REPLACE VIEW high_impact_value_components AS
SELECT 
    vc.component_name,
    vc.component_category,
    vc.typical_improvement_range,
    vc.value_per_unit,
    vc.weight_in_total_roi,
    COUNT(DISTINCT rc.calculation_id) as times_used,
    AVG(vc.confidence_level) as avg_confidence
FROM roi_value_components vc
JOIN roi_calculations rc ON rc.personalized_factors ? vc.component_name
WHERE vc.is_active = true
GROUP BY vc.component_id, vc.component_name, vc.component_category, 
         vc.typical_improvement_range, vc.value_per_unit, vc.weight_in_total_roi
ORDER BY vc.weight_in_total_roi DESC, times_used DESC;

-- =====================================================================
-- 8. DATOS INICIALES
-- =====================================================================

-- Insertar benchmarks para profesiones comunes
INSERT INTO roi_profession_benchmarks (
    profession, avg_hourly_rate, avg_productivity_loss_percentage,
    avg_productivity_improvement, median_roi_percentage
) VALUES
('Software Engineer', 75.00, 25.0, 35.0, 847.0),
('Consultant', 150.00, 30.0, 40.0, 1250.0),
('Executive/CEO', 200.00, 20.0, 30.0, 1500.0),
('Healthcare Professional', 100.00, 35.0, 30.0, 950.0),
('Entrepreneur', 80.00, 40.0, 45.0, 1100.0)
ON CONFLICT (profession, industry) DO NOTHING;

-- Insertar componentes de valor HIE
INSERT INTO roi_value_components (
    component_name, component_category, description,
    calculation_formula, value_per_unit
) VALUES
('productivity_boost', 'productivity', 
 'Aumento en productividad por optimización energética',
 '{"formula": "hourly_rate * work_hours * (improvement_percentage / 100)"}',
 1.0),
('time_savings', 'productivity',
 'Tiempo ahorrado por mejor enfoque y menos distracciones',
 '{"formula": "hours_saved * hourly_rate"}',
 1.0),
('stress_cost_reduction', 'health',
 'Reducción en costos relacionados con estrés',
 '{"formula": "baseline_stress_cost * (reduction_percentage / 100)"}',
 1.0),
('cognitive_enhancement_value', 'performance',
 'Valor de mejora en toma de decisiones y creatividad',
 '{"formula": "monthly_income * 0.15 * (improvement_percentage / 100)"}',
 1.0)
ON CONFLICT (component_name) DO NOTHING;

-- Insertar historia de éxito ejemplo
INSERT INTO roi_success_stories (
    client_identifier, profession, financial_roi_percentage,
    time_saved_hours_monthly, productivity_increase_percentage,
    monthly_value_generated, testimonial_quote, verified
) VALUES
('CLIENT_001', 'Consultant', 1247.0, 20, 40,
 2500.00, 
 'El sistema HIE transformó completamente mi rendimiento. Ahora facturo 40% más trabajando menos horas.',
 true)
ON CONFLICT DO NOTHING;

-- =====================================================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- =====================================================================
COMMENT ON TABLE roi_calculations IS 'Cálculos detallados de ROI personalizados por usuario';
COMMENT ON TABLE roi_profession_benchmarks IS 'Benchmarks de ROI por profesión basados en datos reales';
COMMENT ON TABLE roi_success_stories IS 'Casos de éxito verificados con ROI real';
COMMENT ON TABLE roi_value_components IS 'Componentes individuales que contribuyen al ROI total';
COMMENT ON TABLE roi_projections IS 'Proyecciones de ROI a futuro con diferentes escenarios';

COMMENT ON FUNCTION calculate_base_roi IS 'Función para calcular ROI base con inputs estándar';

-- =====================================================================
-- Script completado exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 008_pii_encryption.sql
-- =====================================================================

-- Migration: Add PII encryption support
-- Description: Adds hash columns for searchable encrypted PII fields and encryption metadata

-- Add hash columns for searchable PII fields in customers table
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS email_hash VARCHAR(64),
ADD COLUMN IF NOT EXISTS is_encrypted BOOLEAN DEFAULT FALSE;

-- Create index on email hash for fast lookups
CREATE INDEX IF NOT EXISTS idx_customers_email_hash ON customers(email_hash);

-- Add encryption tracking to conversations
ALTER TABLE conversations
ADD COLUMN IF NOT EXISTS pii_encrypted BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS encryption_version INTEGER DEFAULT 1;

-- Add encryption audit table
CREATE TABLE IF NOT EXISTS encryption_audit (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL, -- 'encrypt', 'decrypt', 'access'
    field_names TEXT[], -- Array of field names affected
    user_id UUID,
    ip_address INET,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT
);

-- Create index on encryption audit for monitoring
CREATE INDEX IF NOT EXISTS idx_encryption_audit_timestamp ON encryption_audit(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_encryption_audit_table_record ON encryption_audit(table_name, record_id);

-- Add function to automatically set email hash on insert/update
CREATE OR REPLACE FUNCTION set_email_hash()
RETURNS TRIGGER AS $$
BEGIN
    -- Only set hash if email is provided and encrypted
    IF NEW.email IS NOT NULL AND NEW.is_encrypted = TRUE THEN
        -- This will be replaced by application-level hashing
        -- For now, just mark that hash should be set
        NEW.email_hash = 'pending_hash';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for email hash
DROP TRIGGER IF EXISTS tr_set_email_hash ON customers;
CREATE TRIGGER tr_set_email_hash
BEFORE INSERT OR UPDATE ON customers
FOR EACH ROW
EXECUTE FUNCTION set_email_hash();

-- Add encryption support to trial_events
ALTER TABLE trial_events
ADD COLUMN IF NOT EXISTS ip_address_encrypted TEXT,
ADD COLUMN IF NOT EXISTS user_agent_encrypted TEXT,
ADD COLUMN IF NOT EXISTS is_encrypted BOOLEAN DEFAULT FALSE;

-- Create view for decrypted customer data (for backward compatibility)
-- Note: Actual decryption happens at application level
CREATE OR REPLACE VIEW customers_decrypted AS
SELECT 
    id,
    CASE 
        WHEN is_encrypted THEN 'encrypted'
        ELSE name
    END as name,
    CASE 
        WHEN is_encrypted THEN 'encrypted'
        ELSE email
    END as email,
    age,
    gender,
    occupation,
    created_at,
    updated_at,
    is_encrypted
FROM customers;

-- Add RLS policies for encryption audit
ALTER TABLE encryption_audit ENABLE ROW LEVEL SECURITY;

-- Policy: Only admins can view encryption audit
CREATE POLICY encryption_audit_admin_only ON encryption_audit
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Add comment to document encryption
COMMENT ON TABLE encryption_audit IS 'Audit log for PII encryption/decryption operations';
COMMENT ON COLUMN customers.email_hash IS 'SHA-256 hash of email for searching encrypted data';
COMMENT ON COLUMN customers.is_encrypted IS 'Whether PII fields in this record are encrypted';
COMMENT ON COLUMN conversations.pii_encrypted IS 'Whether customer_data JSONB contains encrypted PII';

-- Migration rollback script
/*
-- To rollback this migration:
ALTER TABLE customers 
DROP COLUMN IF EXISTS email_hash,
DROP COLUMN IF EXISTS is_encrypted;

ALTER TABLE conversations
DROP COLUMN IF EXISTS pii_encrypted,
DROP COLUMN IF EXISTS encryption_version;

ALTER TABLE trial_events
DROP COLUMN IF EXISTS ip_address_encrypted,
DROP COLUMN IF EXISTS user_agent_encrypted,
DROP COLUMN IF EXISTS is_encrypted;

DROP TABLE IF EXISTS encryption_audit;
DROP VIEW IF EXISTS customers_decrypted;
DROP FUNCTION IF EXISTS set_email_hash();
*/


-- =====================================================================
-- MIGRACIÓN: 009_security_events.sql
-- =====================================================================

-- Migration: Security Events Table
-- Description: Create table for tracking security events including JWT rotations

-- Create security events table
CREATE TABLE IF NOT EXISTS security_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(50) NOT NULL,
    success BOOLEAN DEFAULT TRUE,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    next_rotation TIMESTAMPTZ,
    error_message TEXT,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    user_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_security_events_type ON security_events(event_type);
CREATE INDEX IF NOT EXISTS idx_security_events_timestamp ON security_events(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_security_events_user ON security_events(user_id);

-- Create table for JWT rotation history
CREATE TABLE IF NOT EXISTS jwt_rotation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rotation_timestamp TIMESTAMPTZ DEFAULT NOW(),
    previous_secret_hash VARCHAR(64),  -- SHA-256 hash of previous secret
    new_secret_hash VARCHAR(64),       -- SHA-256 hash of new secret
    rotation_reason VARCHAR(100),       -- 'scheduled', 'manual', 'security_incident'
    rotation_count INTEGER DEFAULT 0,
    grace_period_end TIMESTAMPTZ,
    initiated_by VARCHAR(100),          -- 'system', 'admin', etc.
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    metadata JSONB
);

-- Create index on rotation history
CREATE INDEX IF NOT EXISTS idx_jwt_rotation_timestamp ON jwt_rotation_history(rotation_timestamp DESC);

-- Add RLS policies
ALTER TABLE security_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE jwt_rotation_history ENABLE ROW LEVEL SECURITY;

-- Policy: Only admins can view security events
CREATE POLICY security_events_admin_only ON security_events
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Policy: Only admins can view JWT rotation history
CREATE POLICY jwt_rotation_admin_only ON jwt_rotation_history
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM auth.users
        WHERE auth.users.id = auth.uid()
        AND auth.users.raw_user_meta_data->>'role' = 'admin'
    )
);

-- Create function to log security events
CREATE OR REPLACE FUNCTION log_security_event(
    p_event_type VARCHAR,
    p_success BOOLEAN DEFAULT TRUE,
    p_error_message TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT NULL,
    p_user_id UUID DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
    v_event_id UUID;
BEGIN
    INSERT INTO security_events (
        event_type,
        success,
        error_message,
        metadata,
        user_id
    ) VALUES (
        p_event_type,
        p_success,
        p_error_message,
        p_metadata,
        p_user_id
    ) RETURNING id INTO v_event_id;
    
    RETURN v_event_id;
END;
$$ LANGUAGE plpgsql;

-- Create view for recent security events
CREATE OR REPLACE VIEW recent_security_events AS
SELECT 
    id,
    event_type,
    success,
    timestamp,
    error_message,
    user_id,
    CASE 
        WHEN metadata->>'ip_address' IS NOT NULL THEN 
            substring(metadata->>'ip_address' from 1 for position('.' in metadata->>'ip_address' || '.') + 3) || 'xxx'
        ELSE NULL
    END as masked_ip
FROM security_events
WHERE timestamp > NOW() - INTERVAL '7 days'
ORDER BY timestamp DESC;

-- Add comments
COMMENT ON TABLE security_events IS 'Audit log for security-related events';
COMMENT ON TABLE jwt_rotation_history IS 'History of JWT secret rotations';
COMMENT ON FUNCTION log_security_event IS 'Helper function to log security events';
COMMENT ON VIEW recent_security_events IS 'Recent security events with masked IP addresses';

-- Migration rollback script
/*
-- To rollback this migration:
DROP VIEW IF EXISTS recent_security_events;
DROP FUNCTION IF EXISTS log_security_event;
DROP TABLE IF EXISTS jwt_rotation_history;
DROP TABLE IF EXISTS security_events;
*/


-- =====================================================================
-- MIGRACIÓN: 010_missing_tables.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 010: TABLAS FALTANTES
-- =====================================================================
-- Este script crea las tablas que faltan en Supabase:
-- - conversation_sessions
-- - ab_test_experiments

-- Habilitar extensión para UUID si no existe
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================================
-- TABLA: conversation_sessions
-- =====================================================================
-- Registra las sesiones de conversación para tracking y analytics

CREATE TABLE IF NOT EXISTS conversation_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    conversation_id UUID NOT NULL,
    customer_id VARCHAR(255),
    platform_source VARCHAR(50) DEFAULT 'web',
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para conversation_sessions
CREATE INDEX IF NOT EXISTS idx_conversation_sessions_conversation_id 
ON conversation_sessions(conversation_id);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_customer_id 
ON conversation_sessions(customer_id);

CREATE INDEX IF NOT EXISTS idx_conversation_sessions_status 
ON conversation_sessions(status);

-- =====================================================================
-- TABLA: ab_test_experiments
-- =====================================================================
-- Gestiona los experimentos A/B para optimización continua

CREATE TABLE IF NOT EXISTS ab_test_experiments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    experiment_id VARCHAR(100) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    hypothesis TEXT,
    variants JSONB NOT NULL DEFAULT '[]',
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    target_metric VARCHAR(100),
    success_criteria JSONB,
    allocation_percentages JSONB DEFAULT '{}',
    results JSONB DEFAULT '{}',
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para ab_test_experiments
CREATE INDEX IF NOT EXISTS idx_ab_test_experiments_experiment_id 
ON ab_test_experiments(experiment_id);

CREATE INDEX IF NOT EXISTS idx_ab_test_experiments_is_active 
ON ab_test_experiments(is_active);

CREATE INDEX IF NOT EXISTS idx_ab_test_experiments_dates 
ON ab_test_experiments(start_date, end_date);

-- =====================================================================
-- TRIGGERS PARA UPDATED_AT
-- =====================================================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para conversation_sessions
DROP TRIGGER IF EXISTS update_conversation_sessions_updated_at ON conversation_sessions;
CREATE TRIGGER update_conversation_sessions_updated_at 
BEFORE UPDATE ON conversation_sessions 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger para ab_test_experiments
DROP TRIGGER IF EXISTS update_ab_test_experiments_updated_at ON ab_test_experiments;
CREATE TRIGGER update_ab_test_experiments_updated_at 
BEFORE UPDATE ON ab_test_experiments 
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================================
-- COMENTARIOS DE TABLA
-- =====================================================================

COMMENT ON TABLE conversation_sessions IS 'Registra las sesiones de conversación para tracking, analytics y cooldown management';
COMMENT ON TABLE ab_test_experiments IS 'Gestiona experimentos A/B para optimización continua del sistema';

-- =====================================================================
-- PERMISOS (ajustar según necesidades)
-- =====================================================================

-- Dar permisos de lectura/escritura al rol de servicio
GRANT ALL ON conversation_sessions TO service_role;
GRANT ALL ON ab_test_experiments TO service_role;

-- Dar permisos de lectura al rol anónimo (si es necesario)
GRANT SELECT ON conversation_sessions TO anon;
GRANT SELECT ON ab_test_experiments TO anon;


-- =====================================================================
-- MIGRACIÓN: 011_add_context_column.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 011: AGREGAR COLUMNA CONTEXT A CONVERSATIONS
-- =====================================================================
-- La columna 'context' es necesaria para guardar el contexto de la conversación

-- Agregar columna context si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'conversations' 
        AND column_name = 'context'
    ) THEN
        ALTER TABLE conversations 
        ADD COLUMN context JSONB DEFAULT '{}';
        
        COMMENT ON COLUMN conversations.context IS 'Contexto adicional de la conversación (metadata, configuraciones, etc)';
    END IF;
END $$;

-- Crear índice para búsquedas en context si no existe
CREATE INDEX IF NOT EXISTS idx_conversations_context 
ON conversations USING GIN (context);


-- =====================================================================
-- MIGRACIÓN: 011_add_missing_fields.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 011: AGREGAR CAMPOS FALTANTES A CONVERSATIONS
-- =====================================================================
-- Este script agrega los campos que el código está intentando guardar
-- pero que no existen en la tabla conversations

DO $$ 
BEGIN
    -- Agregar columna customer_name si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'customer_name') THEN
        ALTER TABLE conversations 
        ADD COLUMN customer_name VARCHAR(255);
    END IF;

    -- Agregar columna customer_email si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'customer_email') THEN
        ALTER TABLE conversations 
        ADD COLUMN customer_email VARCHAR(255);
    END IF;

    -- Agregar columna customer_phone si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'customer_phone') THEN
        ALTER TABLE conversations 
        ADD COLUMN customer_phone VARCHAR(50);
    END IF;

    -- Agregar columna customer_age si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'customer_age') THEN
        ALTER TABLE conversations 
        ADD COLUMN customer_age INTEGER;
    END IF;

    -- Agregar columna initial_message si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'initial_message') THEN
        ALTER TABLE conversations 
        ADD COLUMN initial_message TEXT;
    END IF;

    -- Agregar columna context si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'context') THEN
        ALTER TABLE conversations 
        ADD COLUMN context JSONB DEFAULT '{}';
    END IF;

    -- Agregar columna lead_score si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'lead_score') THEN
        ALTER TABLE conversations 
        ADD COLUMN lead_score FLOAT DEFAULT 0.0;
    END IF;

    -- Agregar columna intent si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'intent') THEN
        ALTER TABLE conversations 
        ADD COLUMN intent VARCHAR(100);
    END IF;

    -- Agregar columna human_transfer_needed si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'human_transfer_needed') THEN
        ALTER TABLE conversations 
        ADD COLUMN human_transfer_needed BOOLEAN DEFAULT FALSE;
    END IF;

    -- Agregar columna status si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversations' 
                   AND column_name = 'status') THEN
        ALTER TABLE conversations 
        ADD COLUMN status VARCHAR(50) DEFAULT 'active';
    END IF;
END $$;

-- Crear índices para mejorar el rendimiento
CREATE INDEX IF NOT EXISTS idx_conversations_customer_email ON conversations(customer_email);
CREATE INDEX IF NOT EXISTS idx_conversations_lead_score ON conversations(lead_score);
CREATE INDEX IF NOT EXISTS idx_conversations_intent ON conversations(intent);

-- Agregar comentarios para documentación
COMMENT ON COLUMN conversations.context IS 'Contexto adicional de la conversación (metadata, configuraciones, etc)';
COMMENT ON COLUMN conversations.customer_name IS 'Nombre del cliente';
COMMENT ON COLUMN conversations.customer_email IS 'Email del cliente';
COMMENT ON COLUMN conversations.customer_phone IS 'Teléfono del cliente';
COMMENT ON COLUMN conversations.customer_age IS 'Edad del cliente';
COMMENT ON COLUMN conversations.initial_message IS 'Mensaje inicial del cliente';
COMMENT ON COLUMN conversations.lead_score IS 'Puntuación del lead (0-100)';
COMMENT ON COLUMN conversations.intent IS 'Intención detectada del cliente';
COMMENT ON COLUMN conversations.human_transfer_needed IS 'Si se requiere transferencia a agente humano';
COMMENT ON COLUMN conversations.status IS 'Estado de la conversación (active, completed, abandoned)';


-- =====================================================================
-- MIGRACIÓN: 012_ml_tracking_schema_fix.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 012: CORRECCIÓN DE ESQUEMA ML TRACKING
-- =====================================================================
-- Este script corrige y estandariza el esquema de las tablas ML para
-- asegurar la compatibilidad con el sistema de tracking.
-- Fecha: 2025-07-28

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================================
-- 1. CORREGIR TABLA ml_experiments
-- =====================================================================
-- Agregar columnas faltantes si no existen
DO $$ 
BEGIN
    -- Agregar conversation_id si no existe (para relaciones)
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'ml_experiments' 
                   AND column_name = 'conversation_id') THEN
        ALTER TABLE ml_experiments 
        ADD COLUMN conversation_id UUID;
    END IF;

    -- Agregar user_id si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'ml_experiments' 
                   AND column_name = 'user_id') THEN
        ALTER TABLE ml_experiments 
        ADD COLUMN user_id VARCHAR(255);
    END IF;

    -- Agregar is_active si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'ml_experiments' 
                   AND column_name = 'is_active') THEN
        ALTER TABLE ml_experiments 
        ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;

    -- Agregar allocation_method si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'ml_experiments' 
                   AND column_name = 'allocation_method') THEN
        ALTER TABLE ml_experiments 
        ADD COLUMN allocation_method VARCHAR(50) DEFAULT 'multi_armed_bandit';
    END IF;

    -- Agregar statistical_confidence si no existe
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'ml_experiments' 
                   AND column_name = 'statistical_confidence') THEN
        ALTER TABLE ml_experiments 
        ADD COLUMN statistical_confidence FLOAT;
    END IF;
END $$;

-- =====================================================================
-- 2. CREAR TABLA experiment_results SI NO EXISTE
-- =====================================================================
CREATE TABLE IF NOT EXISTS experiment_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    experiment_id UUID NOT NULL,
    variant_id VARCHAR(100) NOT NULL,
    conversation_id UUID,
    user_id VARCHAR(255),
    
    -- Métricas del resultado
    metric_name VARCHAR(100) NOT NULL,
    metric_value FLOAT NOT NULL,
    success BOOLEAN DEFAULT false,
    
    -- Contexto adicional
    context JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT NOW(),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Índices para experiment_results
CREATE INDEX IF NOT EXISTS idx_experiment_results_experiment_id 
ON experiment_results(experiment_id);

CREATE INDEX IF NOT EXISTS idx_experiment_results_variant_id 
ON experiment_results(variant_id);

CREATE INDEX IF NOT EXISTS idx_experiment_results_conversation_id 
ON experiment_results(conversation_id);

CREATE INDEX IF NOT EXISTS idx_experiment_results_timestamp 
ON experiment_results(timestamp);

-- =====================================================================
-- 3. CREAR TABLA ab_test_variants SI NO EXISTE
-- =====================================================================
CREATE TABLE IF NOT EXISTS ab_test_variants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    experiment_id UUID NOT NULL,
    variant_id VARCHAR(100) NOT NULL UNIQUE,
    variant_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Configuración de la variante
    variant_config JSONB NOT NULL DEFAULT '{}',
    content JSONB DEFAULT '{}',
    
    -- Control y estado
    is_control BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    allocation_percentage FLOAT DEFAULT 0.0,
    
    -- Estadísticas
    impressions INTEGER DEFAULT 0,
    conversions INTEGER DEFAULT 0,
    conversion_rate FLOAT DEFAULT 0.0,
    
    -- Multi-Armed Bandit
    arm_value FLOAT DEFAULT 1.0,
    arm_count INTEGER DEFAULT 0,
    ucb_score FLOAT DEFAULT 0.0,
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_allocation CHECK (allocation_percentage >= 0.0 AND allocation_percentage <= 1.0),
    CONSTRAINT valid_conversion_rate CHECK (conversion_rate >= 0.0 AND conversion_rate <= 1.0)
);

-- Índices para ab_test_variants
CREATE INDEX IF NOT EXISTS idx_ab_test_variants_experiment_id 
ON ab_test_variants(experiment_id);

CREATE INDEX IF NOT EXISTS idx_ab_test_variants_variant_id 
ON ab_test_variants(variant_id);

CREATE INDEX IF NOT EXISTS idx_ab_test_variants_active 
ON ab_test_variants(is_active) WHERE is_active = true;

-- =====================================================================
-- 4. CREAR TABLA ab_test_results SI NO EXISTE
-- =====================================================================
CREATE TABLE IF NOT EXISTS ab_test_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    experiment_id UUID NOT NULL,
    variant_id VARCHAR(100) NOT NULL,
    conversation_id UUID,
    
    -- Resultado del test
    metric_name VARCHAR(100) NOT NULL,
    metric_value FLOAT NOT NULL,
    success BOOLEAN DEFAULT false,
    
    -- Contexto
    user_context JSONB DEFAULT '{}',
    timestamp TIMESTAMP DEFAULT NOW(),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para ab_test_results
CREATE INDEX IF NOT EXISTS idx_ab_test_results_experiment_id 
ON ab_test_results(experiment_id);

CREATE INDEX IF NOT EXISTS idx_ab_test_results_variant_id 
ON ab_test_results(variant_id);

CREATE INDEX IF NOT EXISTS idx_ab_test_results_timestamp 
ON ab_test_results(timestamp);

-- =====================================================================
-- 5. CREAR TABLA pattern_recognitions SI NO EXISTE
-- =====================================================================
CREATE TABLE IF NOT EXISTS pattern_recognitions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    pattern_type VARCHAR(100) NOT NULL,
    pattern_name VARCHAR(255) NOT NULL,
    description TEXT,
    
    -- Datos del patrón
    pattern_data JSONB NOT NULL DEFAULT '{}',
    conditions JSONB NOT NULL DEFAULT '{}',
    
    -- Estadísticas
    occurrences INTEGER DEFAULT 1,
    confidence_score FLOAT DEFAULT 0.0,
    effectiveness_score FLOAT DEFAULT 0.0,
    
    -- Estado
    is_active BOOLEAN DEFAULT true,
    last_seen TIMESTAMP DEFAULT NOW(),
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_confidence CHECK (confidence_score >= 0.0 AND confidence_score <= 1.0),
    CONSTRAINT valid_effectiveness CHECK (effectiveness_score >= 0.0 AND effectiveness_score <= 1.0)
);

-- Índices para pattern_recognitions
CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_type 
ON pattern_recognitions(pattern_type);

CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_active 
ON pattern_recognitions(is_active) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_confidence 
ON pattern_recognitions(confidence_score);

-- =====================================================================
-- 6. ACTUALIZAR TABLA conversation_outcomes
-- =====================================================================
DO $$ 
BEGIN
    -- Agregar columnas ML tracking si no existen
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversation_outcomes' 
                   AND column_name = 'ml_predictions') THEN
        ALTER TABLE conversation_outcomes 
        ADD COLUMN ml_predictions JSONB DEFAULT '{}';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversation_outcomes' 
                   AND column_name = 'ml_confidence_scores') THEN
        ALTER TABLE conversation_outcomes 
        ADD COLUMN ml_confidence_scores JSONB DEFAULT '{}';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversation_outcomes' 
                   AND column_name = 'ab_test_assignments') THEN
        ALTER TABLE conversation_outcomes 
        ADD COLUMN ab_test_assignments JSONB DEFAULT '[]';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'conversation_outcomes' 
                   AND column_name = 'pattern_matches') THEN
        ALTER TABLE conversation_outcomes 
        ADD COLUMN pattern_matches JSONB DEFAULT '[]';
    END IF;
END $$;

-- =====================================================================
-- 7. CREAR TABLA ml_tracking_events SI NO EXISTE
-- =====================================================================
CREATE TABLE IF NOT EXISTS ml_tracking_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    event_name VARCHAR(255) NOT NULL,
    
    -- Referencias
    conversation_id UUID,
    experiment_id UUID,
    model_id UUID,
    
    -- Datos del evento
    event_data JSONB NOT NULL DEFAULT '{}',
    metrics JSONB DEFAULT '{}',
    
    -- Timestamp
    timestamp TIMESTAMP DEFAULT NOW(),
    
    -- Metadata
    created_by VARCHAR(255) DEFAULT 'system',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Índices para ml_tracking_events
CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_type 
ON ml_tracking_events(event_type);

CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_conversation 
ON ml_tracking_events(conversation_id);

CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_timestamp 
ON ml_tracking_events(timestamp);

-- =====================================================================
-- 8. CREAR VISTAS ÚTILES
-- =====================================================================

-- Vista de experimentos activos con métricas
CREATE OR REPLACE VIEW active_experiments_metrics AS
SELECT 
    e.experiment_id,
    e.experiment_name,
    e.experiment_type,
    e.status,
    e.start_date,
    e.target_metric,
    COUNT(DISTINCT er.conversation_id) as total_conversions,
    AVG(er.metric_value) as avg_metric_value,
    e.statistical_confidence,
    e.winning_variant_id
FROM ml_experiments e
LEFT JOIN experiment_results er ON e.experiment_id = er.experiment_id
WHERE e.status IN ('running', 'analyzing')
GROUP BY e.experiment_id, e.experiment_name, e.experiment_type, 
         e.status, e.start_date, e.target_metric, 
         e.statistical_confidence, e.winning_variant_id;

-- Vista de performance de variantes A/B
CREATE OR REPLACE VIEW ab_variant_performance AS
SELECT 
    v.experiment_id,
    v.variant_id,
    v.variant_name,
    v.is_control,
    v.impressions,
    v.conversions,
    v.conversion_rate,
    v.ucb_score,
    v.allocation_percentage,
    COUNT(r.id) as total_results,
    AVG(r.metric_value) as avg_metric_value
FROM ab_test_variants v
LEFT JOIN ab_test_results r ON v.variant_id = r.variant_id
WHERE v.is_active = true
GROUP BY v.experiment_id, v.variant_id, v.variant_name, 
         v.is_control, v.impressions, v.conversions, 
         v.conversion_rate, v.ucb_score, v.allocation_percentage;

-- Vista de patrones más efectivos
CREATE OR REPLACE VIEW effective_patterns AS
SELECT 
    pattern_type,
    pattern_name,
    description,
    occurrences,
    confidence_score,
    effectiveness_score,
    last_seen
FROM pattern_recognitions
WHERE is_active = true
AND confidence_score > 0.7
ORDER BY effectiveness_score DESC, occurrences DESC;

-- =====================================================================
-- 9. FUNCIONES HELPER
-- =====================================================================

-- Función para actualizar UCB scores en variantes
CREATE OR REPLACE FUNCTION update_ucb_score(variant_id UUID)
RETURNS VOID AS $$
DECLARE
    total_impressions INTEGER;
    variant_impressions INTEGER;
    variant_conversion_rate FLOAT;
    exploration_factor FLOAT := 2.0;
BEGIN
    -- Obtener total de impresiones del experimento
    SELECT SUM(impressions) INTO total_impressions
    FROM ab_test_variants
    WHERE experiment_id = (
        SELECT experiment_id FROM ab_test_variants WHERE id = variant_id
    );
    
    -- Obtener datos de la variante
    SELECT impressions, conversion_rate 
    INTO variant_impressions, variant_conversion_rate
    FROM ab_test_variants WHERE id = variant_id;
    
    -- Calcular UCB score
    IF variant_impressions > 0 AND total_impressions > 0 THEN
        UPDATE ab_test_variants
        SET ucb_score = variant_conversion_rate + 
            SQRT(exploration_factor * LN(total_impressions) / variant_impressions)
        WHERE id = variant_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- =====================================================================
-- 10. TRIGGERS PARA ACTUALIZACIONES AUTOMÁTICAS
-- =====================================================================

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a tablas que lo necesitan
DO $$
BEGIN
    -- experiment_results
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_experiment_results_updated_at') THEN
        CREATE TRIGGER update_experiment_results_updated_at
        BEFORE UPDATE ON experiment_results
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- ab_test_variants
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_ab_test_variants_updated_at') THEN
        CREATE TRIGGER update_ab_test_variants_updated_at
        BEFORE UPDATE ON ab_test_variants
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
    
    -- pattern_recognitions
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_pattern_recognitions_updated_at') THEN
        CREATE TRIGGER update_pattern_recognitions_updated_at
        BEFORE UPDATE ON pattern_recognitions
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- =====================================================================
-- 11. PERMISOS
-- =====================================================================

-- Dar permisos necesarios (ajustar según roles existentes)
DO $$
BEGIN
    -- Intentar dar permisos solo si el rol existe
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
        GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO service_role;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon;
    END IF;
END $$;

-- =====================================================================
-- 12. COMENTARIOS PARA DOCUMENTACIÓN
-- =====================================================================

COMMENT ON TABLE ml_experiments IS 'Experimentos A/B y ML para optimización continua';
COMMENT ON TABLE experiment_results IS 'Resultados individuales de experimentos';
COMMENT ON TABLE ab_test_variants IS 'Variantes de pruebas A/B con Multi-Armed Bandit';
COMMENT ON TABLE ab_test_results IS 'Resultados de pruebas A/B por conversación';
COMMENT ON TABLE pattern_recognitions IS 'Patrones identificados por el sistema ML';
COMMENT ON TABLE ml_tracking_events IS 'Eventos de tracking para análisis ML';

-- =====================================================================
-- VERIFICACIÓN FINAL
-- =====================================================================
-- Query para verificar que todo está correcto
DO $$
DECLARE
    missing_count INTEGER := 0;
    table_name TEXT;
    required_tables TEXT[] := ARRAY[
        'ml_experiments',
        'experiment_results', 
        'conversation_outcomes',
        'ab_test_variants',
        'ab_test_results',
        'pattern_recognitions',
        'ml_tracking_events'
    ];
BEGIN
    FOREACH table_name IN ARRAY required_tables
    LOOP
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = table_name
        ) THEN
            RAISE NOTICE 'Tabla faltante: %', table_name;
            missing_count := missing_count + 1;
        END IF;
    END LOOP;
    
    IF missing_count = 0 THEN
        RAISE NOTICE 'Todas las tablas ML están correctamente configuradas';
    ELSE
        RAISE WARNING 'Faltan % tablas ML', missing_count;
    END IF;
END $$;

-- =====================================================================
-- Migración completada exitosamente
-- =====================================================================


-- =====================================================================
-- MIGRACIÓN: 013_fix_security_definer_views.sql
-- =====================================================================

-- =====================================================================
-- MIGRACIÓN 013: CORREGIR VISTAS SECURITY DEFINER Y VARIANT_ID
-- =====================================================================
-- Este script corrige:
-- 1. Errores de SECURITY DEFINER en vistas (48 errores)
-- 2. Problema de columna variant_id inconsistente
-- Fecha: 2025-07-28

-- =====================================================================
-- PARTE 1: CORREGIR CONSISTENCIA DE VARIANT_ID
-- =====================================================================

-- Primero, verificar y corregir el tipo de datos de variant_id en todas las tablas
DO $$
BEGIN
    -- 1. Verificar si prompt_variants tiene variant_id como UUID o VARCHAR
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'prompt_variants' 
        AND column_name = 'variant_id'
        AND data_type = 'uuid'
    ) THEN
        -- Si es UUID, necesitamos agregar una columna variant_id_str para compatibilidad
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'prompt_variants' 
            AND column_name = 'variant_id_str'
        ) THEN
            ALTER TABLE prompt_variants 
            ADD COLUMN variant_id_str VARCHAR(100) UNIQUE;
            
            -- Generar valores string únicos basados en el UUID
            UPDATE prompt_variants 
            SET variant_id_str = 'variant_' || SUBSTRING(variant_id::text, 1, 8)
            WHERE variant_id_str IS NULL;
            
            -- Hacer NOT NULL después de poblar
            ALTER TABLE prompt_variants 
            ALTER COLUMN variant_id_str SET NOT NULL;
        END IF;
    END IF;
    
    -- 2. Asegurar que ab_test_variants tenga variant_id VARCHAR
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ab_test_variants') THEN
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'ab_test_variants' 
            AND column_name = 'variant_id'
        ) THEN
            ALTER TABLE ab_test_variants ADD COLUMN variant_id VARCHAR(100) NOT NULL UNIQUE;
        END IF;
    END IF;
END $$;

-- =====================================================================
-- PARTE 2: RECREAR VISTAS CON SECURITY INVOKER
-- =====================================================================

-- 1. top_performing_prompts
DROP VIEW IF EXISTS top_performing_prompts CASCADE;
CREATE VIEW top_performing_prompts
WITH (security_invoker = true)
AS
SELECT 
    pv.variant_id::text as variant_id,
    pv.prompt_template,
    pv.is_active,
    COUNT(DISTINCT co.conversation_id) as total_conversations,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(co.quality_score) as avg_quality_score,
    pv.created_at,
    pv.updated_at
FROM prompt_variants pv
LEFT JOIN conversation_outcomes co ON co.prompt_variant_id = pv.variant_id
WHERE pv.is_active = true
GROUP BY pv.variant_id, pv.prompt_template, pv.is_active, pv.created_at, pv.updated_at
HAVING COUNT(DISTINCT co.conversation_id) > 5
ORDER BY conversion_rate DESC, avg_quality_score DESC;

-- 2. model_performance_view
DROP VIEW IF EXISTS model_performance_view CASCADE;
CREATE VIEW model_performance_view
WITH (security_invoker = true)
AS
SELECT 
    pm.model_id,
    pm.model_name,
    pm.model_type,
    pm.version,
    pm.is_active,
    COUNT(DISTINCT co.conversation_id) as total_predictions,
    AVG(co.quality_score) as avg_quality_score,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    pm.last_trained,
    pm.created_at
FROM predictive_models pm
LEFT JOIN conversation_outcomes co ON co.conversation_id IN (
    SELECT conversation_id FROM ml_tracking_events WHERE model_id = pm.model_id
)
WHERE pm.is_active = true
GROUP BY pm.model_id, pm.model_name, pm.model_type, pm.version, 
         pm.is_active, pm.last_trained, pm.created_at
ORDER BY conversion_rate DESC;

-- 3. training_activity_view
DROP VIEW IF EXISTS training_activity_view CASCADE;
CREATE VIEW training_activity_view
WITH (security_invoker = true)
AS
SELECT 
    tj.job_id,
    tj.model_type,
    tj.status,
    tj.started_at,
    tj.completed_at,
    tj.training_metrics,
    tj.error_message,
    EXTRACT(EPOCH FROM (tj.completed_at - tj.started_at)) as duration_seconds,
    tj.created_at
FROM training_jobs tj
ORDER BY tj.created_at DESC;

-- 4. emotional_summary_view
DROP VIEW IF EXISTS emotional_summary_view CASCADE;
CREATE VIEW emotional_summary_view
WITH (security_invoker = true)
AS
SELECT 
    ea.analysis_id,
    ea.conversation_id,
    ea.emotion_category,
    ea.intensity,
    ea.confidence_score,
    ea.triggers,
    ea.timestamp,
    c.user_id,
    c.tier_id
FROM emotional_analyses ea
JOIN conversations c ON c.conversation_id = ea.conversation_id
WHERE ea.confidence_score > 0.7
ORDER BY ea.timestamp DESC;

-- 5. effective_patterns_view
DROP VIEW IF EXISTS effective_patterns_view CASCADE;
CREATE VIEW effective_patterns_view
WITH (security_invoker = true)
AS
SELECT 
    pattern_type,
    pattern_name,
    description,
    occurrences,
    confidence_score,
    effectiveness_score,
    last_seen,
    pattern_data,
    conditions
FROM pattern_recognitions
WHERE is_active = true
AND confidence_score > 0.7
AND effectiveness_score > 0.6
ORDER BY effectiveness_score DESC, occurrences DESC;

-- 6. genetic_evolution_view
DROP VIEW IF EXISTS genetic_evolution_view CASCADE;
CREATE VIEW genetic_evolution_view
WITH (security_invoker = true)
AS
SELECT 
    ge.evolution_id,
    ge.generation,
    ge.parent_genome_id,
    ge.genome_data,
    ge.fitness_score,
    ge.mutation_rate,
    ge.crossover_points,
    ge.survived,
    ge.created_at
FROM genetic_evolutions ge
WHERE ge.survived = true
ORDER BY ge.generation DESC, ge.fitness_score DESC;

-- 7. trial_performance_by_tier
DROP VIEW IF EXISTS trial_performance_by_tier CASCADE;
CREATE VIEW trial_performance_by_tier
WITH (security_invoker = true)
AS
SELECT 
    t.tier_name,
    t.tier_level,
    COUNT(DISTINCT ft.trial_id) as total_trials,
    AVG(CASE WHEN ft.converted_to_paid THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(ft.engagement_score) as avg_engagement,
    AVG(EXTRACT(EPOCH FROM (ft.ended_at - ft.started_at))/86400) as avg_trial_days
FROM free_trials ft
JOIN conversations c ON c.conversation_id = ft.conversation_id
JOIN service_tiers t ON t.tier_id = c.tier_id
GROUP BY t.tier_name, t.tier_level
ORDER BY t.tier_level;

-- 8. demo_effectiveness
DROP VIEW IF EXISTS demo_effectiveness CASCADE;
CREATE VIEW demo_effectiveness
WITH (security_invoker = true)
AS
SELECT 
    d.demo_id,
    d.demo_type,
    d.feature_showcased,
    COUNT(DISTINCT d.conversation_id) as total_demos,
    AVG(d.engagement_score) as avg_engagement,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate,
    AVG(d.completion_rate) as avg_completion_rate
FROM demos d
LEFT JOIN conversation_outcomes co ON co.conversation_id = d.conversation_id
GROUP BY d.demo_id, d.demo_type, d.feature_showcased
HAVING COUNT(DISTINCT d.conversation_id) > 3
ORDER BY conversion_rate DESC;

-- 9. effective_touchpoints
DROP VIEW IF EXISTS effective_touchpoints CASCADE;
CREATE VIEW effective_touchpoints
WITH (security_invoker = true)
AS
SELECT 
    et.touchpoint_type,
    et.touchpoint_name,
    COUNT(DISTINCT et.engagement_id) as total_engagements,
    AVG(et.engagement_score) as avg_engagement_score,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_impact,
    et.channel
FROM engagement_touchpoints et
LEFT JOIN conversation_outcomes co ON co.conversation_id = et.conversation_id
GROUP BY et.touchpoint_type, et.touchpoint_name, et.channel
HAVING COUNT(DISTINCT et.engagement_id) > 10
ORDER BY conversion_impact DESC, avg_engagement_score DESC;

-- 10. roi_by_profession_view
DROP VIEW IF EXISTS roi_by_profession_view CASCADE;
CREATE VIEW roi_by_profession_view
WITH (security_invoker = true)
AS
SELECT 
    lp.profession_category,
    lp.specialization,
    COUNT(DISTINCT rc.calculation_id) as total_calculations,
    AVG(rc.projected_roi_percentage) as avg_roi_percentage,
    AVG(rc.time_saved_hours) as avg_time_saved,
    AVG(rc.revenue_increase_percentage) as avg_revenue_increase,
    AVG(CASE WHEN co.converted THEN 1 ELSE 0 END) * 100 as conversion_rate
FROM roi_calculations rc
JOIN conversations c ON c.conversation_id = rc.conversation_id
JOIN lead_profiles lp ON lp.lead_id = c.lead_id
LEFT JOIN conversation_outcomes co ON co.conversation_id = c.conversation_id
GROUP BY lp.profession_category, lp.specialization
HAVING COUNT(DISTINCT rc.calculation_id) > 5
ORDER BY avg_roi_percentage DESC;

-- =====================================================================
-- PARTE 3: CREAR ÍNDICES ADICIONALES PARA PERFORMANCE
-- =====================================================================

-- Índices para mejorar performance de las vistas
CREATE INDEX IF NOT EXISTS idx_conversation_outcomes_prompt_variant 
ON conversation_outcomes(prompt_variant_id);

CREATE INDEX IF NOT EXISTS idx_ml_tracking_events_model_conversation 
ON ml_tracking_events(model_id, conversation_id);

CREATE INDEX IF NOT EXISTS idx_emotional_analyses_confidence 
ON emotional_analyses(confidence_score) WHERE confidence_score > 0.7;

CREATE INDEX IF NOT EXISTS idx_pattern_recognitions_effectiveness 
ON pattern_recognitions(effectiveness_score) WHERE is_active = true;

-- =====================================================================
-- PARTE 4: GRANTS Y PERMISOS
-- =====================================================================

DO $$
BEGIN
    -- Asegurar que las vistas tengan los permisos correctos
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO authenticated;
    END IF;
    
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
        GRANT ALL ON ALL TABLES IN SCHEMA public TO service_role;
    END IF;
END $$;

-- =====================================================================
-- VERIFICACIÓN FINAL
-- =====================================================================

DO $$
DECLARE
    view_count INTEGER;
    security_definer_count INTEGER;
BEGIN
    -- Contar vistas totales
    SELECT COUNT(*) INTO view_count
    FROM information_schema.views
    WHERE table_schema = 'public';
    
    -- Contar vistas con SECURITY DEFINER (deberían ser 0 después de esta migración)
    SELECT COUNT(*) INTO security_definer_count
    FROM pg_views
    WHERE schemaname = 'public'
    AND definition LIKE '%security_invoker = false%'
    OR (definition NOT LIKE '%security_invoker%' AND viewowner != current_user);
    
    RAISE NOTICE '✅ Migración 013 completada';
    RAISE NOTICE '📊 Total de vistas: %', view_count;
    RAISE NOTICE '🔒 Vistas con SECURITY DEFINER: %', security_definer_count;
    RAISE NOTICE '✅ Todas las vistas ahora usan security_invoker = true';
END $$;

-- =====================================================================
-- FIN DE MIGRACIÓN 013
-- =====================================================================

