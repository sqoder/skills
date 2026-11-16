#!/usr/bin/env bash
# 从 LiquidGlassLens.metal 重新编译 default.metallib。
#
# 用法：
#   ./scripts/build-metallib.sh          重新生成 default.metallib
#   ./scripts/build-metallib.sh --check  校验产物是否与源码同步（不同步则退出码 1）
#
# 注意：SwiftPM 的 .process("Shaders") 只复制文件、不会编译 .metal，
# 所以修改 shader 后必须运行本脚本，否则 App 实际加载的仍是旧 metallib。
set -euo pipefail

cd "$(dirname "$0")/.."
SRC="Sources/LiquidGlassKit/Shaders/LiquidGlassLens.metal"
OUT="Sources/LiquidGlassKit/Shaders/default.metallib"
TMP="$(mktemp -d -t liquidglass)"
trap 'rm -rf "$TMP"' EXIT

xcrun -sdk macosx metal -c "$SRC" -o "$TMP/out.air"
xcrun -sdk macosx metallib "$TMP/out.air" -o "$TMP/out.metallib"

if [[ "${1:-}" == "--check" ]]; then
    if cmp -s "$TMP/out.metallib" "$OUT"; then
        echo "✓ $OUT 与 $SRC 同步"
    else
        echo "✗ $OUT 与 $SRC 不同步，请运行 ./scripts/build-metallib.sh" >&2
        exit 1
    fi
else
    cp "$TMP/out.metallib" "$OUT"
    echo "✓ $OUT ($(wc -c < "$OUT" | tr -d ' ') bytes)"
fi
