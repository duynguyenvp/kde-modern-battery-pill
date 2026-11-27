#!/usr/bin/env bash
set -euo pipefail

WIDGET_ID="com.duy.batterypill"
PLASMOID_DIR="$HOME/.local/share/plasma/plasmoids/$WIDGET_ID"
APPLETS_RC="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

echo "Đang gỡ hoàn toàn widget $WIDGET_ID..."

# 1. Gỡ package widget qua kpackagetool6
if kpackagetool6 --type Plasma/Applet --list 2>/dev/null | grep -qx "$WIDGET_ID"; then
    echo "Đang gỡ package $WIDGET_ID qua kpackagetool6..."
    kpackagetool6 --type Plasma/Applet --remove "$WIDGET_ID"
else
    echo "Widget $WIDGET_ID chưa được đăng ký trong kpackagetool6 (bỏ qua)."
fi

# 2. Xóa thư mục cài đặt còn sót (nếu có)
if [ -d "$PLASMOID_DIR" ]; then
    echo "Đang xóa thư mục $PLASMOID_DIR..."
    rm -rf "$PLASMOID_DIR"
fi

# 3. Xóa cấu hình & instance widget đã lưu trong Plasma (nếu có)
if [ -f "$APPLETS_RC" ] && grep -q "plugin=$WIDGET_ID" "$APPLETS_RC"; then
    echo "Đang dừng Plasma Shell để xóa sạch cấu hình widget đã lưu..."
    systemctl --user stop plasma-plasmashell.service || true

    trap 'echo "Đang khởi động lại Plasma Shell..."; systemctl --user start plasma-plasmashell.service || true' EXIT

    cp "$APPLETS_RC" "${APPLETS_RC}.bak.$(date +%Y%m%d%H%M%S)"

    python3 - "$APPLETS_RC" "$WIDGET_ID" <<'PYEOF'
import re
import sys

rc_path, widget_id = sys.argv[1], sys.argv[2]

with open(rc_path, "r", encoding="utf-8") as f:
    lines = f.readlines()

# Tách file thành danh sách (header, body_lines)
sections = []
current_header = None
current_body = []

for line in lines:
    stripped = line.strip()
    if stripped.startswith("[") and stripped.endswith("]"):
        sections.append((current_header, current_body))
        current_header = stripped
        current_body = []
    else:
        current_body.append(line)
sections.append((current_header, current_body))

# Tìm các prefix [Containments][X][Applets][Y] có plugin=<widget_id>
applet_header_re = re.compile(r"^(\[Containments\]\[(\d+)\]\[Applets\]\[(\d+)\])$")
removed_prefixes = []
removed_by_containment = {}

for header, body in sections:
    if not header:
        continue
    m = applet_header_re.match(header)
    if m and any(b.strip() == f"plugin={widget_id}" for b in body):
        prefix, cid, aid = m.group(1), m.group(2), m.group(3)
        removed_prefixes.append(prefix)
        removed_by_containment.setdefault(cid, set()).add(aid)

if removed_prefixes:
    new_sections = []
    for header, body in sections:
        if header and any(header == p or header.startswith(p + "[") for p in removed_prefixes):
            continue

        # Cập nhật AppletOrder trong [Containments][X][General]
        if header:
            gm = re.match(r"^\[Containments\]\[(\d+)\]\[General\]$", header)
            if gm and gm.group(1) in removed_by_containment:
                rm_ids = removed_by_containment[gm.group(1)]
                updated_body = []
                for b in body:
                    if b.startswith("AppletOrder="):
                        val = b[len("AppletOrder="):].strip()
                        parts = [p for p in val.split(";") if p and p not in rm_ids]
                        updated_body.append("AppletOrder=" + ";".join(parts) + "\n")
                    else:
                        updated_body.append(b)
                body = updated_body

        new_sections.append((header, body))

    with open(rc_path, "w", encoding="utf-8") as f:
        for header, body in new_sections:
            if header is not None:
                f.write(header + "\n")
            f.writelines(body)

    print(f"Đã xóa {len(removed_prefixes)} instance/cấu hình của {widget_id} khỏi {rc_path}.")
PYEOF

    trap - EXIT
    echo "Đang khởi động lại Plasma Shell..."
    systemctl --user start plasma-plasmashell.service
else
    echo "Không tìm thấy cấu hình $WIDGET_ID trong Plasma."
    echo "Đang khởi động lại Plasma Shell để áp dụng thay đổi..."
    systemctl --user restart plasma-plasmashell.service
fi

echo "Đã gỡ hoàn toàn widget $WIDGET_ID!"
