#!/bin/bash

# ==============================
# 环境变量配置与默认值
# ==============================
# Komari agent 配置
KOMARI_SERVER="${KOMARI_SERVER:-}"
KOMARI_SECRET="${KOMARI_SECRET:-}"

# Webdav 配置
WEBDAV_URL="${WEBDAV_URL:-}"
WEBDAV_USER="${WEBDAV_USER:-}"
WEBDAV_PASS="${WEBDAV_PASS:-}"

# 备份密码（可选，留空则不加密）
BACKUP_PASS="${BACKUP_PASS:-}"

# 每天备份时间（小时，0-23，支持多个时间点如 4,14,20）
BACKUP_HOUR="${BACKUP_HOUR:-4}"

# 保留备份天数
KEEP_DAYS="${KEEP_DAYS:-5}"

# 导出环境变量供子脚本使用
export WEBDAV_URL WEBDAV_USER WEBDAV_PASS BACKUP_PASS KEEP_DAYS DATA_DIR

# 清理函数的定义
cleanup() {
    echo "正在关闭后台进程..."
    kill $(jobs -p) 2>/dev/null
}
trap cleanup EXIT

# ==============================
# 1. 启动 komari-agent
# ==============================
if [ -n "$KOMARI_SERVER" ] && [ -n "$KOMARI_SECRET" ]; then
    echo "[Komari] 启动监控..."
    /app/komari-agent -e "$KOMARI_SERVER" -t "$KOMARI_SECRET" --disable-auto-update >/dev/null 2>&1 &
else
    echo "[Komari] 未配置，跳过。"
fi

# =========================
# 2. 首次启动恢复备份
# =========================
if [ -n "$WEBDAV_URL" ] && [ ! -f "$DATA_DIR/kuma.db" ]; then
    echo "[INFO] 首次启动，检查 WebDAV 备份..."
    bash "/app/restore.sh" || echo "[WARN] 恢复失败或无备份"
fi

# =========================
# 3. 备份守护进程
# =========================
# 检查当前小时是否在备份时间列表中
is_backup_hour() {
    local current_hour="$1"
    local hour_list="$2"
    # 移除前导零以便比较
    current_hour=$(echo "$current_hour" | sed 's/^0//')

    IFS=',' read -ra HOURS <<< "$hour_list"
    for hour in "${HOURS[@]}"; do
        hour=$(echo "$hour" | tr -d ' ')
        if [ "$current_hour" -eq "$hour" ] 2>/dev/null; then
            return 0
        fi
    done
    return 1
}

if [ -n "$WEBDAV_URL" ]; then
    (
        while true; do
            sleep 3600
            current_date=$(date +"%Y-%m-%d")
            current_hour=$(date +"%H")
            current_hour_num=$(echo "$current_hour" | sed 's/^0//')
            LAST_BACKUP_FILE="/tmp/last_backup_${current_hour_num}"

            if is_backup_hour "$current_hour" "$BACKUP_HOUR"; then
                # 检查该时间点今天是否已备份
                if [ -f "$LAST_BACKUP_FILE" ] && [ "$(cat "$LAST_BACKUP_FILE")" = "$current_date" ]; then
                    continue
                fi
                echo "[INFO] 执行定时备份 (${current_hour_num}:00)..."
                bash "/app/backup.sh" && echo "$current_date" > "$LAST_BACKUP_FILE"
            fi
        done
    ) &
    echo "[OK] 备份守护进程已启动 (备份时间: ${BACKUP_HOUR}:00)"
fi

# ==============================
# 4. 启动主应用
# ==============================
echo "[Kuma] 启动主应用..."
exec node server/server.js
