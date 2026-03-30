---
title: "web（CTFshow知识点)"
date: 2026-03-23
lastUpdated: 2026-03-30
draft: false
categories: ["笔记"]
---

# web1

右键打开网页源代码

CTF的web入门——flag的含义与简单使用理解（一） flag相当于题目的答案凭证，是需要自己攻破题目获取的秘密字符串。这道题目比较简单，flag直接藏在源码或者注释里面，利用右键检查网页源代码，可以明显看到ctfshow{...} 这一明显的flag

# web2

右键打不开，使用快捷键`Command + Option + U`

CTF的web入门——flag的含义与简单使用理解（信息搜集）（二） 查看网页源码的方式 有三种方式：右键 、网址前边加view-source、ctrl+u。题目中js代码明确给出了禁用右键、禁止文本选择、拦 F12来试图防止普通用户查看源码，但是还可以继续利用view-source以及ctrl+u来继续查看，从而阅读到ctfshow{...}中的flag

# web3

F12打开开发者工具，定位到网络面板，展开所有的响应标头，向下滑找到flag

CTF的web入门——flag的含义与简单使用理解（信息搜集）（三）抓包： 在 Web 里，“抓包”就是把浏览器和服务器之间的 HTTP/HTTPS 请求拦下来、看清楚、必要时改一改的过程，用来分析网站有哪些接口、传了什么参数、Cookie 里有什么等。最基础的是用浏览器自带的 F12 开发者工具里的 Network 面板：刷新页面或执行操作，就能看到每个请求的 URL、方法（GET/POST）、参数、请求头和响应内容，这是做信息搜集、理解网站数据流的必备手段。更进一步会用到 Burp Suite、Fiddler、Charles、mitmproxy 等“抓包代理”工具，把浏览器流量导到它们身上，这样不仅能查看，还能拦截并修改请求（比如改参数、改 Content-Type、伪造前端发不出来的奇怪请求），在 CTF 和 Web 安全测试中，抓包几乎是所有漏洞利用的起点。 这道入门题目里面，利用开发者工具的网络面板，对页面进行刷新，查看https://0853d982-ccf9-40d3-bfc0-0c86f69a89b2.challenge.ctf.show/这条记录，明显看到其响应体里的flag信息ctfshow{...}， 通过这次题目训练，对抓包有了较为基础的理解

# web4

题目提示robos.txt可能泄露信息，尝试访问url/robots.txt,响应结果出现flagishere.txt文件，又尝试访问url/flagishere.txt，拿到flag

CTF的web入门——flag的含义与简单使用理解（信息搜集）（四）robots.txt robots.txt 是放在网站根目录下的一个纯文本文件，相当于一个用来告诉搜索引擎爬虫“哪些地方可以爬，哪些地方不要爬” 的说明书。这道入门题目中 ，提示了robots.txt的信息，进而可以在题目url中添加robots.txt的后缀，获取到/flagishere.txt的关键信息，继续访问/flagishere.txt的内容，获取到flag

# web5

根据题目提示：phps源码泄露有时候能帮上忙，在地址栏输入/index.phps，下载文件，打开后发现flag

CTF的web入门——flag的含义与简单使用理解（信息搜集）（五）phps泄露初步理解 phps泄露一般指的是服务器把 ".phps" 结尾的 PHP 源码文件直接当“高亮源码”给你看了，导致代码泄露，在ctf中，主要包括两种方式第一种比较基础，为直接修改后缀，添加index.phps的后缀可以直接下载php源码，进而直接获取flag等直接信息；第二种稍为进阶，利用/ robots.txt / 备份目录。这道题目提示为phps源码泄露，直接利用第一种方式，添加后缀直接下载源码，获取到flag信息

# web6

在url后加www.zip，然后得到文本文档，这个题需要注意的是点开文本文档是拿不到flag，需要把文件名复制到url后面回车得到

CTF的web入门——flag的含义与简单使用理解（信息搜集）（六）dirsearch脚本的初步使用与解压源码 dirsearch:一个用字典暴力枚举 Web 目录 / 文件的 Python 脚本;www.zip:把整站源码打包备份成 [www.zip](http://www.zip/) 放在网站根目录，却没做好访问控制，结果你可以直接通过 URL 把它下回来。先扫描，后访问，得到对应的flag信息。

# web7

直接访问url/.git/index.php

CTF的web入门——flag的含义与简单使用理解（信息搜集）（七）版本控制与git仓库的初步理解 Git 是一个分布式的版本控制系统，广泛应用于代码管理。它允许开发者追踪项目文件的更改历史，并协作开发。 Git 泄露 、版本控制漏洞是常见的安全问题，在开发者没有适当配置 Git 的情况下，直接利用dirsearch进行扫描，得到对应的git文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

# web8

直接访问url/.svn/

CTF的web入门——flag的含义与简单使用理解（信息搜集）（八）版本控制与svn仓库的初步理解 在 CTF Web 题中， SVN（Subversion）和版本控制系统经常作为 漏洞和信息泄露的来源 ，类似于 Git，但其工作方式和使用场景有所不同。通过对 SVN 版本控制系统的配置不当或目录泄露，攻击者可以访问到项目的源代码、历史记录、敏感信息甚至是 flag。 svn泄露 、版本控制漏洞是常见的安全问题，在开发人员和系统管理员忽略配置 svn的情况下，直接利用dirsearch进行扫描，得到对应的.svn文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

# Web9

直接访问url/index.php.swp

CTF的web入门——flag的含义与简单使用理解（信息搜集）（九）vim缓存信息泄露的初步理解 “vim 缓存信息泄露”，本质就是出题人 / 开发在服务器上用 vim 编辑源码 ，留下了各种 编辑器缓存 / 备份文件 （`.swp`、`~`、`.bak` 等），结果这些文件也被 Web 服务器当成普通文件对外开放了，导致 **源代码泄露** 。 根据提示信息，采取手动猜路径的方法，直接得到.swp文件，得到flag。

# web10

F12,cookie中包含flag，url解码

CTF的web入门——flag的含义与简单使用理解（信息搜集）（十）cookie的初步理解 在ctf中， cooki相当于“服务器放在你浏览器里的小纸条，你用它上交‘身份’，而我们要想法看懂、改掉甚至伪造这张纸条。 根据题目中对于cookie的提示，先采用最简单的抓包方式，直接利用f12开发者工具进行抓包，获取到对应的信息如下，从中可以明显看到cookie中包含flag信息

# web11

通过dns检查查询flag https://zijian.aliyun.com/ TXT 记录，一般指为某个主机名或域名设置的说明。

查找flag.ctfshow.com域名下的txt记录

###### 由于动态更新，txt记录会变

最终flag flag{just_seesee}

# web12

查看robots.txt文件

```
User-agent: *
Disallow: /admin/
```

查看源代码找到密码，访问url/admin/输入用户名：admin 和密码

