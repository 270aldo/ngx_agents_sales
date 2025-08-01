#!/usr/bin/env python3
"""Test script v2 - Using str field with computed property."""

import os
from typing import List
from pydantic import Field, computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict

# Set test environment variable
os.environ['ALLOWED_ORIGINS'] = 'http://localhost:3000,http://localhost:8000'
os.environ['TEST_SINGLE'] = 'single_value'

class TestSettings(BaseSettings):
    """Test settings with str field and computed property."""
    
    # Store as string from env
    allowed_origins_str: str = Field(
        default="http://localhost:3000,http://localhost:5173",
        alias="ALLOWED_ORIGINS"
    )
    
    test_single: str = Field(default="default", alias="TEST_SINGLE")
    
    model_config = SettingsConfigDict(
        env_file=None,  # Don't load .env file
        case_sensitive=False,
        populate_by_name=True,
        extra='ignore',  # Ignore extra fields
    )
    
    @computed_field
    @property
    def allowed_origins(self) -> List[str]:
        """Convert string to list."""
        return [origin.strip() for origin in self.allowed_origins_str.split(",")]

try:
    settings = TestSettings()
    print(f"Success!")
    print(f"allowed_origins_str = {settings.allowed_origins_str}")
    print(f"allowed_origins (computed) = {settings.allowed_origins}")
    print(f"test_single = {settings.test_single}")
except Exception as e:
    print(f"Error: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()