#!/usr/bin/env bash
# bootstrap.sh — spusť jednou na Macu po zkopírování projektu
# Vygeneruje .xcodeproj a otevře v Xcode.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║     MHD Průvodce — Bootstrap skript      ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── 1. Zkontroluj Xcode ──────────────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  echo "❌  Xcode Command Line Tools nenalezeny."
  echo "    Spusť: xcode-select --install"
  exit 1
fi
echo "✅  Xcode: $(xcodebuild -version 2>/dev/null | head -1)"

# ── 2. Nainstaluj XcodeGen ───────────────────────────────────────────────────
if ! command -v xcodegen &>/dev/null; then
  echo "⬇️   Instaluji XcodeGen přes Homebrew..."
  if ! command -v brew &>/dev/null; then
    echo "❌  Homebrew nenalezeno. Nainstaluj ho z https://brew.sh a spusť znovu."
    exit 1
  fi
  brew install xcodegen
fi
echo "✅  XcodeGen: $(xcodegen --version)"

# ── 3. Config.plist ──────────────────────────────────────────────────────────
CONFIG_SRC="MHDPruvodce/Config/Config.example.plist"
CONFIG_DST="MHDPruvodce/Config/Config.plist"

if [ ! -f "$CONFIG_DST" ]; then
  cp "$CONFIG_SRC" "$CONFIG_DST"
  echo "✅  Config.plist vytvořen z Config.example.plist"
  echo ""
  echo "⚠️  DŮLEŽITÉ: Vyplň API klíč v: $CONFIG_DST"
  echo "             Klíč:   CHAPS_API_KEY"
  echo ""
else
  echo "✅  Config.plist již existuje"
fi

# ── 4. Vygeneruj .xcodeproj ──────────────────────────────────────────────────
echo "🔨  Generuji MHDPruvodce.xcodeproj..."
xcodegen generate --spec project.yml

if [ -d "MHDPruvodce.xcodeproj" ]; then
  echo "✅  MHDPruvodce.xcodeproj vygenerován"
else
  echo "❌  Generování selhalo — zkontroluj výstup výše"
  exit 1
fi

# ── 5. Otevři v Xcode ────────────────────────────────────────────────────────
echo ""
echo "🚀  Otevírám v Xcode..."
open MHDPruvodce.xcodeproj

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║              Hotovo! ✅                   ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Další kroky v Xcode:                    ║"
echo "║  1. Nastav Team v Signing & Capabilities ║"
echo "║  2. Vyplň Config.plist s API klíčem      ║"
echo "║  3. ⌘R — Build & Run na simulátor        ║"
echo "╚══════════════════════════════════════════╝"
echo ""
