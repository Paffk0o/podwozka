"""Down-convert openapi/openapi.json (OpenAPI 3.1, from FastAPI) to 3.0.3 for code generators.

openapi-generator's Dart generator handles 3.0 `nullable: true` well, but turns 3.1
`anyOf: [X, {type: null}]` into awkward wrapper classes. This script rewrites:
  - anyOf/oneOf [X, null]   -> X + nullable: true   ($ref is wrapped in allOf)
  - type: [X, "null"]       -> type: X + nullable: true
  - exclusiveMinimum/Maximum numbers -> minimum/maximum + boolean flag
  - const -> enum: [value]
Output: openapi/openapi.codegen.json (generated, do not edit).
"""

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "openapi" / "openapi.json"
DST = ROOT / "openapi" / "openapi.codegen.json"

NULL = {"type": "null"}


def _nullable(schema: dict[str, Any], extra: dict[str, Any]) -> dict[str, Any]:
    if "$ref" in schema:
        result: dict[str, Any] = {"allOf": [schema], "nullable": True}
    else:
        result = {**schema, "nullable": True}
    result.update({k: v for k, v in extra.items() if k not in result})
    return result


def convert(node: Any) -> Any:
    if isinstance(node, list):
        return [convert(item) for item in node]
    if not isinstance(node, dict):
        return node

    node = {k: convert(v) for k, v in node.items()}

    for key in ("anyOf", "oneOf"):
        options = node.get(key)
        if isinstance(options, list) and NULL in options:
            rest = [o for o in options if o != NULL]
            extra = {k: v for k, v in node.items() if k != key}
            if len(rest) == 1:
                return _nullable(rest[0], extra)
            node = {**extra, key: rest, "nullable": True}
            options = rest
        # Unions of plain scalars (e.g. FastAPI's ValidationError.loc: string | integer)
        # produce broken Dart classes -> treat them as "any JSON value".
        if (
            isinstance(options, list)
            and options
            and all(isinstance(o, dict) and "$ref" not in o and "type" in o for o in options)
            and all(o["type"] in ("string", "integer", "number", "boolean") for o in options)
        ):
            return {k: v for k, v in node.items() if k != key}

    type_ = node.get("type")
    if isinstance(type_, list) and "null" in type_:
        rest_types = [t for t in type_ if t != "null"]
        node["type"] = rest_types[0] if len(rest_types) == 1 else rest_types
        node["nullable"] = True

    for exclusive, bound in (("exclusiveMinimum", "minimum"), ("exclusiveMaximum", "maximum")):
        value = node.get(exclusive)
        if isinstance(value, int | float) and not isinstance(value, bool):
            node[bound] = value
            node[exclusive] = True

    if "const" in node:
        node["enum"] = [node.pop("const")]

    return node


def main() -> None:
    spec = json.loads(SRC.read_text())
    out = convert(spec)
    out["openapi"] = "3.0.3"
    DST.write_text(json.dumps(out, indent=2, ensure_ascii=False) + "\n")
    print(f"Wrote {DST}")


if __name__ == "__main__":
    main()
