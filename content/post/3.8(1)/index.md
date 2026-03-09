---
title: "流量抓包学习笔记（Wireshark）"
date: 2026-03-08
draft: false
categories: ["笔记"]
---
## 一、什么是流量抓包

流量抓包（Packet Capture）是指通过工具捕获网络中传输的数据包，并对其进行分析。

常见用途：

- 网络故障排查
- 网络安全分析
- CTF比赛取证
- 协议学习
- 发现异常流量

常见抓包工具：

- Wireshark
- tcpdump
- Burp Suite
- Fiddler

------

# 二、Wireshark简介

Wireshark 是最常用的网络抓包分析工具。

特点：

- 免费开源
- 支持 Windows / Linux / macOS
- 支持上千种协议解析
- 可视化数据包分析

官方网站：

https://www.wireshark.org/

------

# 三、Wireshark安装

## Windows

1. 进入官网
    https://www.wireshark.org/download.html
2. 下载 Windows Installer
3. 安装时注意勾选

```
Npcap
```

Npcap 用于抓取网络数据包。

------

## Linux（Ubuntu）

安装命令：

```
sudo apt update
sudo apt install wireshark
```

运行：

```
wireshark
```

------

# 四、Wireshark界面介绍

Wireshark界面主要分为三部分：

## 1 数据包列表（Packet List）

显示所有抓到的数据包。

包含：

- No. 包编号
- Time 时间
- Source 源地址
- Destination 目标地址
- Protocol 协议
- Length 数据长度
- Info 信息

------

## 2 数据包详情（Packet Details）

显示协议解析，例如：

```
Frame
Ethernet
IP
TCP
HTTP
```

------

## 3 数据包原始数据（Packet Bytes）

显示十六进制数据：

```
0000  00 1a 2b 3c 4d 5e ...
```

------

# 五、开始抓包

步骤：

1. 打开 Wireshark
2. 选择网卡

常见网卡：

- Ethernet（有线）
- Wi-Fi（无线）

1. 双击网卡开始抓包

------

# 六、停止抓包

点击：

```
红色方块按钮
```

即可停止抓包。

------

# 七、常用过滤器

Wireshark 过滤器用于快速定位数据包。

## 1 IP过滤

只看某个IP：

```
ip.addr == 192.168.1.1
```

------

## 2 TCP过滤

```
tcp
```

------

## 3 HTTP流量

```
http
```

------

## 4 DNS查询

```
dns
```

------

## 5 指定端口

例如80端口：

```
tcp.port == 80
```

------

## 6 ICMP（ping）

```
icmp
```

------

# 八、寻找可疑流量

在安全分析中，可以重点关注：

## 1 异常IP

例如：

- 未知外网IP
- 频繁通信的IP

------

## 2 异常协议

例如：

- Modbus
- Telnet
- FTP
- 未知协议

------

## 3 异常端口

例如：

```
4444
6666
1337
```

这些端口可能用于攻击或后门。

------

## 4 异常数据包大小

例如：

```
Length 非常大
```

可能隐藏数据。

------

# 九、Follow Stream（跟踪流）

Wireshark可以重组通信数据。

步骤：

1. 右键数据包
2. 选择

```
Follow → TCP Stream
```

或

```
Follow → UDP Stream
```

作用：

- 还原完整通信
- 查看明文数据
- 找 flag

------

# 十、CTF抓包找Flag方法

常见思路：

## 方法1：搜索flag

快捷键：

```
Ctrl + F
```

搜索：

```
flag
ctf
key
```

------

## 方法2：Follow TCP Stream

很多flag直接在通信里。

------

## 方法3：导出对象

路径：

```
File → Export Objects
```

可导出：

- HTTP文件
- 图片
- 文档
- ZIP

------

## 方法4：查看DNS

过滤：

```
dns
```

有时flag在域名里。

------

# 十一、常见协议

| 协议   | 作用         |
| ------ | ------------ |
| HTTP   | 网页通信     |
| HTTPS  | 加密网页     |
| DNS    | 域名解析     |
| TCP    | 传输协议     |
| UDP    | 无连接传输   |
| ICMP   | ping         |
| FTP    | 文件传输     |
| Modbus | 工业控制协议 |

------

# 十二、Modbus协议

Modbus 是工业控制系统（ICS）常见协议。

常见端口：

```
502
```

在抓包中可能看到：

```
Modbus/TCP
```

攻击者可能：

- 读取寄存器
- 修改设备状态
- 伪造指令

------

# 十三、导出数据包

保存抓包：

```
File → Save As
```

文件格式：

```
.pcap
.pcapng
```

用于：

- 取证
- CTF分析
- 离线分析

------

# 十四、实战分析流程

1. 打开 pcap 文件
2. 查看协议统计

```
Statistics → Protocol Hierarchy
```

1. 查异常协议
2. 查异常IP
3. Follow TCP Stream
4. 搜索 flag
5. 导出文件

------

# 十五、常用快捷键

| 快捷键           | 功能          |
| ---------------- | ------------- |
| Ctrl + F         | 搜索          |
| Ctrl + E         | 开始/停止抓包 |
| Ctrl + W         | 关闭文件      |
| Ctrl + S         | 保存          |
| Ctrl + Shift + F | 深度搜索      |

------

# 十六、总结

流量分析核心思路：

```
先看协议
再找异常
最后还原通信
```

重点技能：

- 过滤器使用
- Follow Stream
- 导出文件
- 协议识别