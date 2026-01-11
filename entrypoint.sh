#!/bin/sh

# ==============================
# 0. 数据目录动态初始化 (关键修复)
# ==============================
# 即使 Docker 挂载了持久化卷，脚本也会在运行时确保子目录存在
DATA_DIR="/app/data"
echo "[System] 正在初始化数据目录结构..."

# 显式创建 Kuma 2.x 启动所需的所有子目录
mkdir -p "$DATA_DIR/upload" "$DATA_DIR/screenshots" "$DATA_DIR/db"

# ==============================
# 环境变量配置与默认值
# ==============================
KOMARI_SERVER="${KOMARI_SERVER:-}"
KOMARI_SECRET="${KOMARI_SECRET:-}"

# 赋予默认端口防止 JSON 语法错误
SB_PORT=${SB_PORT:-""}
SB_PASSWD=${SB_PASSWD:-""}

# 清理函数的定义
cleanup() {
    echo "正在关闭后台进程..."
    kill $(jobs -p) 2>/dev/null
}
trap cleanup EXIT

# ==============================
# 1. 配置并启动 sing-box
# ==============================
if [ -n "$SB_PORT" ] && [ -n "$SB_PASSWD" ]; then
    echo "[sing-box] 生成配置..."
    
    cat <<EOF > /app/sing-box.json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "trojan",
      "tag": "trojan-in",
      "listen": "127.0.0.1",
      "listen_port": ${SB_PORT},
      "sniff": true,
      "users": [{ "name": "trojan", "password": "${SB_PASSWD}" }],
      "transport": {
        "type": "ws",
        "path": "/media-cdn",
        "early_data_header_name": "Sec-WebSocket-Protocol"
      }
    }
  ],
  "outbounds": [{ "type": "direct", "tag": "direct" }],
  "experimental": { "cache_file": { "enabled": true } }
}
EOF

    echo "[sing-box] 启动..."
    # 将日志放在 /app 目录下，确保 10014 用户有权写入
    sing-box run -c /app/sing-box.json > /app/sing-box.log 2>&1 &
    
    sleep 1
    if ! kill -0 $! 2>/dev/null; then
        echo "[sing-box] 启动失败! 日志内容:"
        cat /app/sing-box.log
        exit 1
    fi
else
    echo "[sing-box] 未配置，跳过。"
fi

# ==============================
# 2. 启动 komari-agent
# ==============================
if [ -n "$KOMARI_SERVER" ] && [ -n "$KOMARI_SECRET" ]; then
    echo "[Komari] 启动监控..."
    /app/komari-agent -e "$KOMARI_SERVER" -t "$KOMARI_SECRET" --disable-auto-update >/dev/null 2>&1 &
else
    echo "[Komari] 未配置，跳过。"
fi

# ==============================
# 3. 启动主应用
# ==============================
echo "[Kuma] 启动主应用..."
# 环境变量 UPTIME_KUMA_DATA_DIR 是 Kuma 官方认可的绝对路径变量
export UPTIME_KUMA_DATA_DIR="$DATA_DIR/"
exec node server/server.js
