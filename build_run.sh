#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
APP_BIN="${BUILD_DIR}/NotebookApp"

mkdir -p "${BUILD_DIR}"

echo "==> 正在编译 1:1 Apple 原生三栏记事本 App..."
swiftc \
    -O \
    -target arm64-apple-macos13.0 \
    -sdk "$(xcrun --show-sdk-path --sdk macosx)" \
    -framework Foundation \
    -framework AppKit \
    "${SCRIPT_DIR}/Sources/AppDelegate.swift" \
    "${SCRIPT_DIR}/Sources/NotebookWindowController.swift" \
    "${SCRIPT_DIR}/Sources/NotebookSplitViewController.swift" \
    "${SCRIPT_DIR}/Sources/Models/NoteModel.swift" \
    "${SCRIPT_DIR}/Sources/Sidebar/AppleSidebarRowView.swift" \
    "${SCRIPT_DIR}/Sources/Sidebar/SidebarItemCell.swift" \
    "${SCRIPT_DIR}/Sources/Sidebar/SidebarBottomBarView.swift" \
    "${SCRIPT_DIR}/Sources/Sidebar/SidebarViewController.swift" \
    "${SCRIPT_DIR}/Sources/NoteList/NoteCardCell.swift" \
    "${SCRIPT_DIR}/Sources/NoteList/NoteListViewController.swift" \
    "${SCRIPT_DIR}/Sources/Editor/NoteEditorViewController.swift" \
    -o "${APP_BIN}"

echo "==> 编译成功！启动应用中..."
"${APP_BIN}" &
