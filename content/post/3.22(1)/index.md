---
title: "CTF Web 学习方案（mac）"
date: 2026-03-22
draft: false
categories: ["笔记"]
---



## 一、 环境配置

Mac 自带的终端（Terminal）和 Unix 内核是你的核心优势。

## 1. 终端增强

- **Homebrew**：Mac 必备包管理器。安装后可一键安装各类安全工具。
- **Oh My Zsh**：提升终端操作效率，方便查看路径和命令历史。
- **iTerm2**：比自带终端更好用的终端工具。

## 2. 核心安服工具

- **Burp Suite (Community/Professional)**：Web 渗透核心，Mac 运行非常流畅。
- **Docker Desktop**：**极其重要**。Mac 建议通过 Docker 运行漏洞环境（如 Vulhub），避免直接在物理机上安装复杂的后端服务。
- **Python 3**：Mac 自带或通过 Brew 安装。用于编写自动化脚本（如 SQL 盲注脚本）。

## 3. 编辑器

- **VS Code**：安装 PHP、SQL、JSON 相关插件，用于代码审计。
- **Sublime Text**：极其轻量，适合快速查看大型日志或源码文件。

------

## 二、 基础学习路径（由浅入深）

## 1. HTTP 协议与抓包 (第 1-2 周)

- **学习重点**：理解 Header、Method、Cookie、Session。
- **Mac 实操**：开启 Burp Suite，配置浏览器代理（建议用 Firefox 配合 HTTP Proxy），尝试截获、修改并重发自己的请求。

## 2. PHP 特性与代码审计 (第 3-5 周)

- **学习重点**：PHP 弱类型（`==` 绕过）、反序列化漏洞、常用危险函数（`eval`, `system`, `include`）。
- **Mac 实操**：利用 Mac 自带的 PHP 环境进行简单测试。学习使用 `php -S localhost:8000` 快速启动本地 Web 服务验证 Payload。

## 3. 经典漏洞专项 (第 6-10 周)

- **SQL 注入**：手动练习 Union 注入、盲注。熟练后学习使用 `sqlmap` (Brew 可安装)。
- **文件上传/包含**：理解一句话木马，掌握 PHP 伪协议读取系统文件。
- **RCE (远程命令执行)**：学习如何在 Unix 环境下绕过命令过滤（如使用 `${IFS}` 代替空格）。

------

## 三、 针对 Mac 硬件的学习策略

## 1. 充分利用 Docker

不要在 Mac 上直接配置复杂的 LAMP/WAMP 环境。

- 使用 `docker pull` 拉取 CTF 题目镜像。
- 使用 `docker-compose` 搭建本地漏洞实验室。

## 2. 熟练使用 Unix 命令行

CTF Web 经常涉及对 Linux 服务器的操作。由于 Mac 终端命令与 Linux 高度一致：

- 练习使用 `grep`, `awk`, `find`, `cat`, `base64` 等命令处理数据。
- 掌握 SSH 连接远程服务器的方法。

## 3. 虚拟机补充

虽然 Docker 能解决 90% 的问题，但某些特定环境（如复杂的 Windows Web 服务）可能需要安装 **Parallels Desktop** 或 **VMware Fusion** 来运行 Win 虚拟机。

------

## 四、 推荐练习资源

1. **本地练习**：下载 **DVWA** 或 **sqli-labs**，通过 Docker 在本地运行。
2. **在线平台**：
   - **BUUCTF**：国内最全的真题库。
   - **CTFshow**：适合从 0 开始刷专项题。
3. **必备书单**：
   - 《白帽子讲 Web 安全》（吴翰清著）：经典入门，建立宏观视野。

------

## 五、 朴素建议

- **保持干净**：所有的实验环境尽量放在 Docker 里，保持 Mac 物理系统的整洁。
- **不要过度依赖工具**：在入门阶段，尽量手写 Payload，不要一上来就用 sqlmap 等全自动工具。
- **重视原理**：Web 安全本质上是“信息不对称”和“逻辑严密性”的博弈。