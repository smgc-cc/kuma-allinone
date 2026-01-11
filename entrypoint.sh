#!/bin/sh

# 确保在任何报错时退出
set -e

# ==============================
# 0. 目录初始化
# ==============================
DATA_DIR="/tmp/data"
echo "[System] 正在初始化数据目录于 $DATA_DIR ..."
mkdir -p "$DATA_DIR/upload" "$DATA_DIR/screenshots" "$DATA_DIR/db"

# ==============================
# 1. sing-box 配置 (如果环境变量存在)
# ==============================
if [ -n "$SB_PORT" ] && [ -n "$SB_PASSWD" ]; then
    echo "[sing-box] 启动中..."
    cat <<EOF > /tmp/sing-box.json
{
  "log": { "level": "info" },
  "inbounds": [{
      "type": "trojan",
      "listen": "127.0.0.1",
      "listen_port": ${SB_PORT},
      "sniff": true,
      "users": [{ "password": "${SB_PASSWD}" }],
      "transport": { "type": "ws", "path": "/media-cdn" }
  }],
  "outbounds": [{ "type": "direct" }]
}
EOF
    sing-box run -c /tmp/sing-box.json > /tmp/sing-box.log 2>&1 &
fi

# ==============================
# 2. komari-agent
# ==============================
if [ -n "$KOMARI_SERVER" ] && [ -n "$KOMARI_SECRET" ]; then
    echo "[Komari] 启动中..."
    /app/komari-agent -e "$KOMARI_SERVER" -t "$KOMARI_SECRET" --disable-auto-update >/dev/null 2>&1 &
fi

# ==============================
# 3. 运行主应用
# ==============================
echo "[Kuma] 启动主应用..."
export UPTIME_KUMA_DATA_DIR="$DATA_DIR/"
export UPTIME_KUMA_DB_SSL=true
# 确保我们在正确的目录下执行 node
cd /app
exec node server/server.js
