#!/bin/bash

# 检查root权限
if [ "$EUID" -ne 0 ]; then
  echo "❌ 权限错误: 请使用 root 身份运行此脚本 (可以尝试 sudo bash socks.sh)"
  exit 1
fi

echo "=========================================================="
echo "  Debian/Ubuntu 通用版 SOCKS5 (MicroSOCKS) 自动部署"
echo "  支持: Debian 11-13 | Ubuntu 20.04/22.04/24.04"
echo "=========================================================="

# 配置端口和用户名密码
read -p "请输入 SOCKS5 监听端口 [默认 1080]: " PORT
PORT=${PORT:-1080}

read -p "请输入 SOCKS5 认证用户名 [默认 socksuser]: " SOCKS_USER
SOCKS_USER=${SOCKS_USER:-socksuser}

read -p "请输入 SOCKS5 认证密码 [默认随机生成]: " SOCKS_PASS
if [ -z "$SOCKS_PASS" ]; then
    SOCKS_PASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 12)
    echo "✅ 已自动生成安全密码: $SOCKS_PASS"
fi

echo "⏳ 正在更新软件源并安装 MicroSOCKS..."
# 防止因为弹窗导致安装卡顿，加入非交互环境变量
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y microsocks

# 写入系统服务配置
cat > /etc/systemd/system/microsocks.service <<EOF
[Unit]
Description=MicroSOCKS SOCKS5 Proxy Server
After=network.target

[Service]
Type=simple
User=nobody
# 允许非root用户绑定端口
AmbientCapabilities=CAP_NET_BIND_SERVICE
ExecStart=/usr/bin/microsocks -i 0.0.0.0 -p ${PORT} -u ${SOCKS_USER} -P ${SOCKS_PASS}
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# 启动服务并设置开机自启
echo "⏳ 正在配置并启动后台服务..."
systemctl daemon-reload
systemctl enable microsocks
systemctl restart microsocks

# 防火墙配置 (自动适配UFW)
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        ufw allow $PORT/tcp >/dev/null 2>&1
        echo "✅ UFW 防火墙已放行 $PORT (TCP) 端口"
    else
        echo "⚠️ UFW 已安装但未开启，跳过防火墙配置。"
    fi
else
    echo "⚠️ 系统未安装 UFW 防火墙，请确保云服务商(如存在)的安全组已开放 $PORT 端口。"
fi

# 获取公网IP
PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me || echo "你的公网IP")

echo ""
echo "=========================================================="
echo "🎉 通用版 SOCKS5 代理安装完成！"
echo "=========================================================="
echo "🌐 代理地址 (IP) : $PUBLIC_IP"
echo "🔌 代理端口 (Port): $PORT"
echo "👤 认证用户 (User): $SOCKS_USER"
echo "🔑 认证密码 (Pass): $SOCKS_PASS"
echo "=========================================================="
echo "🔍 查看运行状态: systemctl status microsocks"
echo "=========================================================="
