#!/usr/bin/env bash
# Regenerates the OpenAPI contract and the Dart API client.
#   1. backend -> openapi/openapi.json            (source of truth)
#   2. openapi.json -> openapi/openapi.codegen.json (3.0.3 for the generator)
#   3. openapi.codegen.json -> mobile/packages/api_client (dart-dio + json_serializable)
# Requires: uv, Docker, Flutter/Dart. Run from the repo root: ./scripts/gen-api-client.sh
set -euo pipefail

GENERATOR_VERSION="v7.26.0"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="mobile/packages/api_client"

cd "$ROOT/backend"
uv run python scripts/export_openapi.py
uv run python scripts/openapi_for_codegen.py

cd "$ROOT"
rm -rf "$OUT/lib" "$OUT/doc" "$OUT/test"
docker run --rm -u "$(id -u):$(id -g)" -v "$ROOT:/local" \
  "openapitools/openapi-generator-cli:${GENERATOR_VERSION}" generate \
  -i /local/openapi/openapi.codegen.json \
  -g dart-dio \
  -o "/local/$OUT" \
  --additional-properties=pubName=podwozka_api,pubAuthor=Podwozka,serializationLibrary=json_serializable,dateLibrary=core \
  --global-property=apiTests=false,modelTests=false

# Make the generated package part of the pub workspace (mobile/pubspec.yaml).
python3 - "$OUT/pubspec.yaml" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path).read()
text = re.sub(r"(?m)^  sdk: .*$", "  sdk: ^3.13.0", text)
if "resolution: workspace" not in text:
    text = text.replace("environment:", "resolution: workspace\n\nenvironment:", 1)
# The generator pins old versions of its codegen deps (e.g. copy_with_extension_gen ^7 ->
# analyzer ^7), which conflict with the current Flutter SDK. Let pub pick compatible ones.
for pkg, constraint in (("build_runner", "any"), ("json_serializable", "any"),
                        ("json_annotation", "^4.12.0"), ("copy_with_extension", "any"),
                        ("copy_with_extension_gen", "any")):
    text = re.sub(rf"(?m)^(  {pkg}:)\s*['\"]?[^\n'\"]*['\"]?$", rf"\1 {constraint}", text)
# Generated tests are disabled; `test` would pin analyzer to a conflicting range.
text = re.sub(r"(?m)^  test:.*\n", "", text)
open(path, "w").write(text)
PY

cd "$ROOT/mobile"
dart pub get
cd "$ROOT/$OUT"
dart run build_runner build --delete-conflicting-outputs
dart format lib >/dev/null
echo "OK: $OUT regenerated"
