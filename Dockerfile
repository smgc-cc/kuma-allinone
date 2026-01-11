FROM louislam/uptime-kuma:2-slim

USER root

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制二进制文件
COPY --from=ghcr.io/sagernet/sing-box:latest /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=ghcr.io/komari-monitor/komari-agent:latest /app/komari-agent /app/komari-agent

# 确保目录存在
RUN mkdir -p /app

# 核心修改：先复制，再统一授权，路径使用绝对路径
COPY entrypoint.sh /app/entrypoint.sh

# 移除漏洞文件并确保脚本可执行
RUN rm -f /app/extra/healthcheck && \
    chmod +x /app/entrypoint.sh && \
    chown -R 10014:0 /app

# 设置环境变量
ENV UPTIME_KUMA_DATA_DIR=/tmp/data/

# 显式指定工作目录
WORKDIR /app

USER 10014

EXPOSE 3001

# 使用绝对路径启动
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/sh", "/app/entrypoint.sh"]
