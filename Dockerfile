FROM louislam/uptime-kuma:2-slim

USER root

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 复制文件
COPY --from=ghcr.io/sagernet/sing-box:latest /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=ghcr.io/komari-monitor/komari-agent:latest /app/komari-agent /app/komari-agent

WORKDIR /app

# 移除漏洞文件，并清理不必要的权限设置（因为我们将使用 /tmp）
RUN rm -f /app/extra/healthcheck

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh && chown 10014:0 /app/entrypoint.sh

# 环境变量：默认指向可写的 /tmp
ENV UPTIME_KUMA_DATA_DIR=/tmp/data/

USER 10014

EXPOSE 3001

CMD ["/app/entrypoint.sh"]
