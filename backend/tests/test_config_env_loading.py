from pathlib import Path

from app.core.config import Settings


def test_settings_env_file_is_relative_to_backend_project():
    env_file = Settings.model_config["env_file"]

    assert Path(env_file).name == ".env"
    assert Path(env_file).parent.name == "backend"
