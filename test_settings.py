#!/usr/bin/env python3
import os
os.environ['ALLOWED_ORIGINS'] = 'http://localhost:3000,http://localhost:8000,http://localhost'

try:
    from src.config.settings import Settings
    settings = Settings()
    print(f"Success! allowed_origins = {settings.allowed_origins}")
except Exception as e:
    print(f"Error: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()