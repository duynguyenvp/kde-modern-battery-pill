#!/usr/bin/env bash
set -e

WIDGET_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIDGET_ID="com.duy.batterypill"

if kpackagetool6 --type Plasma/Applet --list | grep -q "$WIDGET_ID"; then
    echo "Đang cập nhật widget $WIDGET_ID..."
    kpackagetool6 --type Plasma/Applet --upgrade "$WIDGET_DIR"
else
    echo "Đang cài đặt widget $WIDGET_ID..."
    kpackagetool6 --type Plasma/Applet --install "$WIDGET_DIR"
fi

echo "Xong! Bạn có thể thêm 'Modern Battery Pill' vào taskbar (chuột phải Taskbar -> Enter Edit Mode -> Add Widgets)."
