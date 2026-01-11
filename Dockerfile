# 基于轻量化的 uptime-kuma:2-slim 镜像
FROM louislam/uptime-kuma:2-slim

# 切换回 root 以进行系统级配置
USER root

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 从其他镜像复制必要的二进制文件
COPY --from=ghcr.io/sagernet/sing-box:latest /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=ghcr.io/komari-monitor/komari-agent:latest /app/komari-agent /app/komari-agent

# 设置工作目录
WORKDIR /app

# 复制脚本并修改所有权
COPY entrypoint.sh /app/entrypoint.sh
# 确保新用户可以读取并执行脚本
RUN chmod +x /app/entrypoint.sh && chown 10014:0 /app/entrypoint.sh

# 创建数据目录并统一授权给 10014
RUN mkdir -p /app/data && \
    touch /app/sing-box.log && \
    chown -R 10014:0 /app && \
    chmod -R g+w /app

# 切换到特定的 UID
USER 10014

# 暴露端口
EXPOSE 3001

# 设置入口点脚本
CMD ["/app/entrypoint.sh"]
