#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$SCRIPT_DIR/install.sh"

echo "Đang khởi động lại Plasma Shell để áp dụng thay đổi..."
systemctl --user restart plasma-plasmashell.service
echo "Hoàn tất!"
