-- Verificar estructura de prompt_variants
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'prompt_variants' 
AND table_schema = 'public';