---
title: "web（CTFshow知识点)"
date: 2026-03-23
draft: false
categories: ["笔记"]
---

# 信息搜集

## web1

右键打开网页源代码

## web2

右键打不开，使用快捷键`Command + Option + U`

## web3

F12打开开发者工具，定位到网络面板，展开所有的响应标头，向下滑找到flag

 在 Web 里，“抓包”就是把浏览器和服务器之间的 HTTP/HTTPS 请求拦下来、看清楚、必要时改一改的过程，用来分析网站有哪些接口、传了什么参数、Cookie 里有什么等。最基础的是用浏览器自带的 F12 开发者工具里的 Network 面板：刷新页面或执行操作，就能看到每个请求的 URL、方法（GET/POST）、参数、请求头和响应内容，这是做信息搜集、理解网站数据流的必备手段。更进一步会用到 Burp Suite、Fiddler、Charles、mitmproxy 等“抓包代理”工具，把浏览器流量导到它们身上，这样不仅能查看，还能拦截并修改请求（比如改参数、改 Content-Type、伪造前端发不出来的奇怪请求），在 CTF 和 Web 安全测试中，抓包几乎是所有漏洞利用的起点。 这道入门题目里面，利用开发者工具的网络面板，对页面进行刷新，查看https://0853d982-ccf9-40d3-bfc0-0c86f69a89b2.challenge.ctf.show/这条记录，明显看到其响应体里的flag信息ctfshow{...}， 通过这次题目训练，对抓包有了较为基础的理解

## web4

题目提示robos.txt可能泄露信息，尝试访问url/robots.txt,响应结果出现flagishere.txt文件，又尝试访问url/flagishere.txt，拿到flag

 robots.txt 是放在网站根目录下的一个纯文本文件，相当于一个用来告诉搜索引擎爬虫“哪些地方可以爬，哪些地方不要爬” 的说明书。这道入门题目中 ，提示了robots.txt的信息，进而可以在题目url中添加robots.txt的后缀，获取到/flagishere.txt的关键信息，继续访问/flagishere.txt的内容，获取到flag

## web5

根据题目提示：phps源码泄露有时候能帮上忙，在地址栏输入/index.phps，下载文件，打开后发现flag

 phps泄露一般指的是服务器把 ".phps" 结尾的 PHP 源码文件直接当“高亮源码”给你看了，导致代码泄露，在ctf中，主要包括两种方式第一种比较基础，为直接修改后缀，添加index.phps的后缀可以直接下载php源码，进而直接获取flag等直接信息；第二种稍为进阶，利用/ robots.txt / 备份目录。这道题目提示为phps源码泄露，直接利用第一种方式，添加后缀直接下载源码，获取到flag信息

## web6

在url后加www.zip，然后得到文本文档，这个题需要注意的是点开文本文档是拿不到flag，需要把文件名复制到url后面回车得到

dirsearch脚本的初步使用与解压源码 dirsearch:一个用字典暴力枚举 Web 目录 / 文件的 Python 脚本;www.zip:把整站源码打包备份成 [www.zip](http://www.zip/) 放在网站根目录，却没做好访问控制，结果你可以直接通过 URL 把它下回来。先扫描，后访问，得到对应的flag信息。

## web7

直接访问url/.git/index.php

版本控制与git仓库的初步理解 Git 是一个分布式的版本控制系统，广泛应用于代码管理。它允许开发者追踪项目文件的更改历史，并协作开发。 Git 泄露 、版本控制漏洞是常见的安全问题，在开发者没有适当配置 Git 的情况下，直接利用dirsearch进行扫描，得到对应的git文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

## web8

直接访问url/.svn/

版本控制与svn仓库的初步理解 在 CTF Web 题中， SVN（Subversion）和版本控制系统经常作为 漏洞和信息泄露的来源 ，类似于 Git，但其工作方式和使用场景有所不同。通过对 SVN 版本控制系统的配置不当或目录泄露，攻击者可以访问到项目的源代码、历史记录、敏感信息甚至是 flag。 svn泄露 、版本控制漏洞是常见的安全问题，在开发人员和系统管理员忽略配置 svn的情况下，直接利用dirsearch进行扫描，得到对应的.svn文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

## Web9

直接访问url/index.php.swp

vim缓存信息泄露的初步理解 “vim 缓存信息泄露”，本质就是出题人 / 开发在服务器上用 vim 编辑源码 ，留下了各种 编辑器缓存 / 备份文件 （`.swp`、`~`、`.bak` 等），结果这些文件也被 Web 服务器当成普通文件对外开放了，导致 **源代码泄露** 。 根据提示信息，采取手动猜路径的方法，直接得到.swp文件，得到flag。

## web10

F12,cookie中包含flag，url解码

cookie的初步理解 在ctf中， cooki相当于“服务器放在你浏览器里的小纸条，你用它上交‘身份’，而我们要想法看懂、改掉甚至伪造这张纸条。 根据题目中对于cookie的提示，先采用最简单的抓包方式，直接利用f12开发者工具进行抓包，获取到对应的信息如下，从中可以明显看到cookie中包含flag信息

## web11

通过dns检查查询flag https://zijian.aliyun.com/ TXT 记录，一般指为某个主机名或域名设置的说明。

查找flag.ctfshow.com域名下的txt记录

由于动态更新，txt记录会变，最终flag flag{just_seesee}

## web12

查看robots.txt文件

```
User-agent: *
Disallow: /admin/
```

查看源代码找到密码，访问url/admin/输入用户名：admin 和密码

## Web13

根据题目提示 技术文档 在页面下面发现 document 下载发现里面存在后台地址和用户名密码登录成功获 得flag

## web14

根据提示，打开网页源码，搜索editor，访问editor发现编辑器，在上传文件的图片空间里，/var/www/html下面发现flag url/nothinghere/fl0000g.txt，访问目录得到flag

## web15

根据提示在页面下方发现QQ号码，url/admin，忘记密码，通过QQ号码查找到地址在西安，输入然后重置密码，获得flag

## web16

url/tz.php 发现PHPINFO能点进去找到flag

根据题目对于php探针的提示，同时了解到php相关概念后，采用最基础的直接猜路径，在靶场url后添加 `/phpinfo.php`等探针类型依次尝试，最后添加/tz.php后访问成功，确定该web网页使用的是雅黑php探针;之后继续查看phpinfo，经过一番搜索后得到flag

## web17

下载了dirsearch，扫描url得到[20:13:23] 200 -  934B - /backup.sql  ，直接访问url/backup.sql，下载sql文件得到flag

## web18

查看源代码，发现[js/Flappy_js.js](https://463f16d3-48d8-4451-938b-586ee7ce35d9.challenge.ctf.show/js/Flappy_js.js) ，在里面发现\u4f60\u8d62\u4e86\uff0c\u53bb\u5e7a\u5e7a\u96f6\u70b9\u76ae\u7231\u5403\u76ae\u770b\u770b直接丢给CyberChef，解出你赢了，去幺幺零点皮爱吃皮看看，url/110.php，得到flag

## web19

查看源代码，发现$u==='admin' && $p ==='a599ac85a73384ee3219fa684296eaa62667238d608efa81837030bd1ce1bf04，密文为AES加密，密钥为key = "0000000372619038";偏移量为iv = "ilove36dverymuch";模式为CBC填充为ZeroPadding编码为Hex，通过CyberChef解出密码，回到原页面输入用户名和密码得到flag

## web20

用dirsearch扫描，得到[19:27:25] 301 -  169B - /db -> http://f83cd3ef-7cf5-4e10-a200-c49856940f2d.challenge.ctf.show/db/，再dirsearch -u https://f83cd3ef-7cf5-4e10-a200-c49856940f2d.challenge.ctf.show/db/ -e sql,bak,txt,zip,db,sqlite -x 400,403,404，得到[19:29:20] 200 - 348KB - /db/db.mdb  ，直接url//db/db.mdb ，下载一个db.mdb文件，用mdbtools直接strings db.mdb | grep -i "flag"找到flag（mac打不开，win直接用记事本打开检索flag）

# 爆破

## web21

前提条件：已知用户名是admin。打开代理和Burp Suite，随便输入密码123尝试登陆同时利用Burp Suite抓包。解码发现格式为admin:123，可以进行爆破。爆破原理：利用多个payload（进攻指令），对返回数据进行对比分析，得到唯一不同的就是可能的密码。将所抓包send to intruder，选择sniper模式。加载题目所给字典，设置前缀admin:（因为字典中只包含了密码），并对其进行base64编码（匹配Authorization请求头格式）。进行爆破，找到状态不同的即为正确答案。解码，登录，找到flag。

## web22

域名更新后，flag.ctf.show域名失效，内容是flag{ctf_show_web}

## Web23

写脚本，但我不会，得到/?token=422
