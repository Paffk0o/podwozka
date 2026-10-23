"""Export the OpenAPI contract to openapi/openapi.json.

Run from backend/: `uv run python scripts/export_openapi.py`
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.main import app

OUT = Path(__file__).resolve().parents[2] / "openapi" / "openapi.json"


def main() -> None:
    spec = app.openapi()
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(spec, indent=2, ensure_ascii=False, sort_keys=False) + "\n")
    print(f"Wrote {OUT} ({len(spec['paths'])} paths)")


if __name__ == "__main__":
    main()
