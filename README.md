MicroSOCKS One-Click Installer

这是一个专为 Debian 和 Ubuntu 系统设计的 轻量级 SOCKS5 代理 (MicroSOCKS) 一键部署脚本。

抛弃笨重且容易报错的传统代理（如 Dante），本脚本利用官方原生 APT 源，在一分钟内为你搭建好一个占用内存仅 1MB-3MB、由 Systemd 守护的纯净 SOCKS5 代理服务端。非常适合小内存 VPS（如 512MB/1GB 内存的机器）。

✨ 核心特性

极致轻量：基于纯 C 语言编写的 MicroSOCKS，几乎不占用 CPU 和系统内存。

开箱即用：无需繁琐的配置文件，交互式引导输入端口和账号密码。

安全加固：服务强制以 nobody 降权身份运行，保障宿主机系统安全。

系统包管：使用 apt 进行原生安装，完美适配 systemd 开机自启，卸载无残留。

智能防火墙：自动检测并适配 UFW 防火墙端口放行。

🚀 一键安装命令 (Quick Start)

请使用 root 用户登录你的服务器，然后复制以下任意一行命令直接执行即可：

(注意：发布前请将命令中的 你的用户名 和 你的仓库名 替换为你真实的 GitHub 路径)

使用 curl (推荐):
``
bash <(curl -sSL https://raw.githubusercontent.com/RocGP/microsocks-installer/main/install.sh)
``

🛠️ 连通性测试

安装完成后，可以在本地电脑的终端运行以下命令，测试代理是否通畅：
``
curl --socks5-hostname 用户名:密码@服务器IP:端口 https://www.google.com -v
``

📖 进阶指南

1. 修改账号密码

MicroSOCKS 的配置直接作为参数传递给 Systemd。如需修改，请编辑服务文件：
``
sudo nano /etc/systemd/system/microsocks.service
``

修改 ExecStart= 这一行中的 -u (用户名) 和 -P (密码) 参数。修改后重启服务即可生效：
``
sudo systemctl daemon-reload
sudo systemctl restart microsocks
``

2. 检查运行状态
``
systemctl status microsocks
``

3. 一键彻底卸载

如果你不想用了，可以通过以下命令将其从系统中彻底清除：
``
apt-get purge -y microsocks && rm -f /etc/systemd/system/microsocks.service && systemctl daemon-reload
``

⚠️ 注意事项

如果你的服务器位于云服务商（如阿里云、腾讯云、AWS、RackNerd 等），请务必在云服务商的网页控制台 -> 安全组规则中，放行你设置的 TCP 端口，否则即使系统内防火墙放行了，外网依然无法连接。

📄 许可证

本项目基于 MIT 许可证开源。
