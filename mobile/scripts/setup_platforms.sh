#!/usr/bin/env bash
# One-time: generates android/ and ios/ folders for both apps and configures:
#   - OAuth redirect scheme for flutter_appauth (Android manifestPlaceholders, iOS CFBundleURLTypes)
#   - http://localhost allowed in DEBUG builds only (local Keycloak/API)
# Run from mobile/:  ./scripts/setup_platforms.sh     then commit the generated folders.
set -euo pipefail
cd "$(dirname "$0")/.."

setup_app() {
  local dir="$1" project="$2" scheme="$3" display="$4"
  echo "==> $dir"
  (cd "$dir" && flutter create --org pl.podwozka --project-name "$project" \
      --platforms android,ios --no-pub --no-overwrite .)
  rm -f "$dir/test/widget_test.dart"   # default counter test from the template

  python3 - "$dir" "$scheme" "$display" <<'PY'
import pathlib, re, sys
app, scheme, display = sys.argv[1], sys.argv[2], sys.argv[3]
root = pathlib.Path(app)

# --- Android: redirect scheme ---
gradle = root / "android/app/build.gradle.kts"
text = gradle.read_text()
if "appAuthRedirectScheme" not in text:
    text = re.sub(
        r"(defaultConfig\s*\{)",
        r'\1\n        manifestPlaceholders["appAuthRedirectScheme"] = "' + scheme + '"',
        text, count=1,
    )
    gradle.write_text(text)

# --- Android: app label ---
manifest = root / "android/app/src/main/AndroidManifest.xml"
m = manifest.read_text()
m = re.sub(r'android:label="[^"]*"', f'android:label="{display}"', m, count=1)
manifest.write_text(m)

# --- Android: cleartext http only in debug builds ---
debug_manifest = root / "android/app/src/debug/AndroidManifest.xml"
d = debug_manifest.read_text()
if "usesCleartextTraffic" not in d:
    d = d.replace("</manifest>", '    <application android:usesCleartextTraffic="true" />\n</manifest>')
    debug_manifest.write_text(d)

# --- iOS: URL scheme + display name + local networking (dev) ---
plist = root / "ios/Runner/Info.plist"
p = plist.read_text()
if "CFBundleURLSchemes" not in p:
    block = f"""	<key>CFBundleURLTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>CFBundleURLSchemes</key>
			<array>
				<string>{scheme}</string>
			</array>
		</dict>
	</array>
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsLocalNetworking</key>
		<true/>
	</dict>
"""
    idx = p.rfind("</dict>")
    p = p[:idx] + block + p[idx:]
p = re.sub(r"(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)", rf"\g<1>{display}\g<2>", p)
plist.write_text(p)
print(f"configured {app}: scheme={scheme}")
PY
}

setup_app apps/passenger podwozka_passenger pl.podwozka.passenger "Podwózka"
setup_app apps/driver podwozka_driver pl.podwozka.driver "Podwózka Kierowca"

flutter pub get
echo "OK. Teraz: git add apps/*/android apps/*/ios && git commit"
