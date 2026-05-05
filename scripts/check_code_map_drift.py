#!/usr/bin/env python3
"""Repo wrapper for the CppStudio code-map drift checker."""

from __future__ import annotations

import runpy
from pathlib import Path


SCRIPT = (
    Path(__file__).resolve().parents[1]
    / "skills/cpp-cuda-vulkan-studio/scripts/check_code_map_drift.py"
)

runpy.run_path(str(SCRIPT), run_name="__main__")
