"""
Empathy Configuration for NGX Voice Sales Agent

This module contains optimized parameters for achieving 10/10 empathy scores
in customer interactions. These settings override defaults for maximum warmth.
"""

from typing import Dict, Any


class EmpathyConfig:
    """Configuration for ultra-empathetic responses."""
    
    # GPT-4o Optimized Parameters for Maximum Empathy AND Speed
    EMPATHY_MODEL_PARAMS = {
        "model": "gpt-4o",
        "temperature": 0.85,  # Balanced for warmth and coherence
        "max_tokens": 400,    # Drastically reduced for speed (3 short paragraphs)
        "presence_penalty": -0.2,  # Allow natural empathy
        "frequency_penalty": 0.3,  # Avoid repetition
        "top_p": 0.95,  # Good vocabulary range
    }
    
    # Context-Specific Adjustments
    CONTEXT_PARAMS = {
        "greeting": {
            "temperature": 0.90,  # Warm but coherent
            "max_tokens": 300,    # Shorter greetings
            "presence_penalty": -0.3,
            "system_prompt_addon": "\nPRIMER CONTACTO: Sé cálido, usa su nombre, haz pregunta abierta sobre sus desafíos."
        },
        "price_objection": {
            "temperature": 0.85,
            "max_tokens": 400,  # Concise value explanation
            "system_prompt_addon": "\nPRECIO: Valida su preocupación, muestra comprensión, ofrece opciones flexibles."
        },
        "emotional_moment": {
            "temperature": 0.90,
            "max_tokens": 350,
            "presence_penalty": -0.3,
            "system_prompt_addon": "\nEMOCIONAL: Valida profundamente, comparte que otros han pasado por esto, ofrece esperanza."
        },
        "closing": {
            "temperature": 0.85,
            "max_tokens": 300,
            "system_prompt_addon": "\nCIERRE: Transmite confianza sin presión, pinta su éxito futuro, muestra entusiasmo genuino."
        },
        "general": {
            "max_tokens": 400  # Default for all other contexts
        }
    }
    
    # Empathy Phrase Banks
    EMPATHY_PHRASES = {
        "validation": [
            "Entiendo completamente cómo te sientes",
            "Es totalmente comprensible que pienses así",
            "Tu preocupación es muy válida",
            "Aprecio mucho tu honestidad al compartir esto",
            "Tiene todo el sentido del mundo que te sientas así",
            "Es completamente natural tener esas dudas"
        ],
        "connection": [
            "No estás solo en esto",
            "Muchos de nuestros clientes más exitosos empezaron exactamente donde estás",
            "He acompañado a personas en tu misma situación",
            "Conozco esa sensación perfectamente",
            "Es más común de lo que imaginas"
        ],
        "support": [
            "Estoy aquí para apoyarte en cada paso",
            "Vamos a encontrar la mejor solución para ti",
            "Tu bienestar es mi prioridad",
            "No hay prisa, tomemos el tiempo que necesites",
            "Estoy completamente comprometido con tu éxito"
        ],
        "encouragement": [
            "El hecho de que estés aquí habla muy bien de ti",
            "Tu decisión de buscar ayuda es admirable",
            "Veo mucho potencial en ti",
            "Has dado el paso más difícil al buscar apoyo",
            "Tu compromiso contigo mismo es inspirador"
        ]
    }
    
    # Micro-Expression Responses
    MICRO_EXPRESSION_RESPONSES = {
        "hesitation": "Percibo cierta duda, y es perfectamente normal. ¿Qué es lo que más te preocupa?",
        "fatigue": "Escucho el cansancio en tus palabras. Debe ser agotador cargar con eso todos los días.",
        "fear": "Entiendo que esto puede dar un poco de miedo. El cambio siempre genera incertidumbre.",
        "frustration": "Tu frustración es completamente justificada. Has intentado tanto y mereces resultados.",
        "hope": "Me encanta escuchar esa chispa de esperanza. Es el primer paso hacia algo mejor.",
        "overwhelm": "Sé que puede parecer abrumador. Vamos paso a paso, sin presión."
    }
    
    # Empathy Scoring Weights
    EMPATHY_SCORING = {
        "uses_customer_name": 0.15,
        "validates_emotion": 0.25,
        "asks_open_questions": 0.20,
        "offers_flexibility": 0.15,
        "shows_understanding": 0.25
    }
    
    @staticmethod
    def get_context_params(context_type: str) -> Dict[str, Any]:
        """Get parameters for specific context."""
        base_params = EmpathyConfig.EMPATHY_MODEL_PARAMS.copy()
        
        if context_type in EmpathyConfig.CONTEXT_PARAMS:
            context_specific = EmpathyConfig.CONTEXT_PARAMS[context_type]
            base_params.update({
                k: v for k, v in context_specific.items() 
                if k != "system_prompt_addon"
            })
        
        return base_params
    
    @staticmethod
    def get_system_prompt_addon(context_type: str) -> str:
        """Get additional system prompt for context."""
        if context_type in EmpathyConfig.CONTEXT_PARAMS:
            return EmpathyConfig.CONTEXT_PARAMS[context_type].get("system_prompt_addon", "")
        return ""
    
    @staticmethod
    def enhance_with_empathy_instructions(base_prompt: str, context_type: str = "general") -> str:
        """Enhance any prompt with empathy instructions."""
        addon = EmpathyConfig.get_system_prompt_addon(context_type)
        
        empathy_core = """
        REGLAS DE EMPATÍA SUPREMA:
        1. SIEMPRE valida emociones antes de ofrecer soluciones
        2. Usa el nombre del cliente naturalmente (no excesivamente)
        3. Refleja su lenguaje y nivel de energía
        4. Comparte que otros han pasado por lo mismo
        5. Nunca uses frases genéricas o robóticas
        6. Muestra vulnerabilidad cuando sea apropiado
        7. Haz preguntas que demuestren interés genuino
        8. Ofrece opciones sin que las pidan
        9. Celebra pequeños pasos hacia el cambio
        10. Termina cada respuesta con esperanza
        """
        
        return f"{base_prompt}\n\n{empathy_core}\n\n{addon}"


# Usage example
def get_empathy_enhanced_params(context_type: str = "general") -> Dict[str, Any]:
    """Get model parameters enhanced for empathy."""
    return EmpathyConfig.get_context_params(context_type)