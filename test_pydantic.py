#!/usr/bin/env python3
"""Test script to debug Pydantic settings issue."""

import os
from typing import List, Union
from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

# Set test environment variable
os.environ['TEST_LIST'] = 'http://localhost:3000,http://localhost:8000'

class TestSettings(BaseSettings):
    """Test settings class."""
    
    # Try without env parameter
    test_list: List[str] = Field(default=["default1", "default2"])
    
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=False,
    )
    
    @field_validator("test_list", mode='before')
    @classmethod
    def parse_test_list(cls, v: Union[str, List[str]]) -> List[str]:
        """Parse comma-separated string to list."""
        print(f"Validator called with: {v} (type: {type(v)})")
        # Check environment variable
        env_value = os.environ.get("TEST_LIST")
        if env_value:
            print(f"Found env value: {env_value}")
            return [item.strip() for item in env_value.split(",")]
        if isinstance(v, str):
            return [item.strip() for item in v.split(",")]
        return v

try:
    settings = TestSettings()
    print(f"Success! test_list = {settings.test_list}")
except Exception as e:
    print(f"Error: {type(e).__name__}: {e}")
    import traceback
    traceback.print_exc()