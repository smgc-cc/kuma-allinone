# ==========================================
# 阶段 1: 构建阶段 (Builder)
# 使用最新的 Go 镜像 (会自动包含最新的安全补丁)
# ==========================================
FROM golang:alpine AS builder

WORKDIR /build

# 安装 git 以便拉取代码
RUN apk add --no-cache git

# 克隆 komari-agent 源码
RUN git clone https://github.com/komari-monitor/komari-agent.git .

# 编译二进制文件
# CGO_ENABLED=0 确保生成静态链接文件，兼容性更好
# -ldflags="-s -w" 用于减小体积
RUN go mod download && \
    CGO_ENABLED=0 go build -ldflags="-s -w" -o komari-agent .


# ==========================================
# 阶段 2: 最终镜像 (Runtime)
# 基于轻量化的 uptime-kuma:2-slim 镜像
# ==========================================
FROM louislam/uptime-kuma:2-slim

# 切换回 root 以进行系统级配置
USER root

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends zip unzip \
    && rm -rf /var/lib/apt/lists/*

# --- 修改点开始 ---
# 不再从旧镜像复制，而是从上面的 builder 阶段复制新编译的文件
COPY --from=builder /build/komari-agent /app/komari-agent
# --- 修改点结束 ---

# 设置工作目录
WORKDIR /app

# 1. 删除有漏洞的 healthcheck 二进制文件 (如果 uptime-kuma 自带的也有问题)
# 2. 预创建数据目录
# 3. 统一授权给 10014 和 root 组
RUN rm -f /app/extra/healthcheck && \
    chown -R 10014:0 /app && \
    chmod -R 775 /app

# 复制脚本并修改所有权
COPY entrypoint.sh /app/entrypoint.sh
COPY backup.sh /app/backup.sh
COPY restore.sh /app/restore.sh
RUN chmod +x /app/*.sh && chown 10014:0 /app/*.sh

# 环境变量：确保 Kuma 知道数据存哪
ENV DATA_DIR=/tmp/data/

# 切换到特定的 UID
USER 10014

# 暴露端口
EXPOSE 3001

# 设置入口点脚本
CMD ["/app/entrypoint.sh"]
