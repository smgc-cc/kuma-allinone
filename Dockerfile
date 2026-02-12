# ==========================================
# 阶段 1: 构建阶段 (Builder)
# ==========================================
FROM golang:alpine AS builder

WORKDIR /src

# 安装 git
RUN apk add --no-cache git

# 1. 拉取源码
RUN git clone https://github.com/komari-monitor/komari-agent.git .

# 2. 检出最新的 Tag
RUN git fetch --tags && \
    LATEST_TAG=$(git describe --tags --abbrev=0) && \
    git checkout $LATEST_TAG

# 3. 编译并注入版本号
RUN VERSION=$(git describe --tags --always) && \
    echo "--------------------------------------" && \
    echo "正在构建版本: $VERSION" && \
    echo "--------------------------------------" && \
    go mod download && \
    CGO_ENABLED=0 go build \
    -trimpath \
    -ldflags="-s -w -X github.com/komari-monitor/komari-agent/update.CurrentVersion=${VERSION}" \
    -o komari-agent .

# ==========================================
# 第二阶段：运行环境 (Final Image)
# 基于 uptime-kuma:2-slim
# ==========================================
FROM louislam/uptime-kuma:2-slim

# 切换回 root 进行配置
USER root

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装依赖
RUN apt-get update && apt-get install -y --no-install-recommends zip unzip \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 从第一阶段 (builder) 复制我们编译好的 komari-agent 二进制文件
# ------------------------------------------------------------
COPY --from=builder /src/komari-agent /app/komari-agent

# 设置工作目录
WORKDIR /app

# 1. 删除可能有漏洞的 healthcheck (如果需要)
# 2. 预创建数据目录
# 3. 统一授权
# 4. 给新复制的 komari-agent 执行权限
RUN rm -f /app/extra/healthcheck && \
    chown -R 10014:0 /app && \
    chmod -R 775 /app && \
    chmod +x /app/komari-agent

# 复制脚本并修改所有权
COPY entrypoint.sh /app/entrypoint.sh
COPY backup.sh /app/backup.sh
COPY restore.sh /app/restore.sh
RUN chmod +x /app/*.sh && chown 10014:0 /app/*.sh

# 环境变量
ENV DATA_DIR=/tmp/data/

# 切换用户
USER 10014

# 暴露端口
EXPOSE 3001

# 入口点
CMD ["/app/entrypoint.sh"]
