---
title: "web（CTFshow知识点)"
date: 2026-03-23
draft: false
categories: ["web"]
---

## 信息搜集

### web1

右键打开网页源代码

### web2

右键打不开，使用快捷键`Command + Option + U`

### web3

F12打开开发者工具，定位到网络面板，展开所有的响应标头，向下滑找到flag

 在 Web 里，“抓包”就是把浏览器和服务器之间的 HTTP/HTTPS 请求拦下来、看清楚、必要时改一改的过程，用来分析网站有哪些接口、传了什么参数、Cookie 里有什么等。最基础的是用浏览器自带的 F12 开发者工具里的 Network 面板：刷新页面或执行操作，就能看到每个请求的 URL、方法（GET/POST）、参数、请求头和响应内容，这是做信息搜集、理解网站数据流的必备手段。更进一步会用到 Burp Suite、Fiddler、Charles、mitmproxy 等“抓包代理”工具，把浏览器流量导到它们身上，这样不仅能查看，还能拦截并修改请求（比如改参数、改 Content-Type、伪造前端发不出来的奇怪请求），在 CTF 和 Web 安全测试中，抓包几乎是所有漏洞利用的起点。 这道入门题目里面，利用开发者工具的网络面板，对页面进行刷新，查看https://0853d982-ccf9-40d3-bfc0-0c86f69a89b2.challenge.ctf.show/这条记录，明显看到其响应体里的flag信息ctfshow{...}， 通过这次题目训练，对抓包有了较为基础的理解

### web4

题目提示robos.txt可能泄露信息，尝试访问url/robots.txt,响应结果出现flagishere.txt文件，又尝试访问url/flagishere.txt，拿到flag

 robots.txt 是放在网站根目录下的一个纯文本文件，相当于一个用来告诉搜索引擎爬虫“哪些地方可以爬，哪些地方不要爬” 的说明书。这道入门题目中 ，提示了robots.txt的信息，进而可以在题目url中添加robots.txt的后缀，获取到/flagishere.txt的关键信息，继续访问/flagishere.txt的内容，获取到flag

### web5

根据题目提示：phps源码泄露有时候能帮上忙，在地址栏输入/index.phps，下载文件，打开后发现flag

 phps泄露一般指的是服务器把 ".phps" 结尾的 PHP 源码文件直接当“高亮源码”给你看了，导致代码泄露，在ctf中，主要包括两种方式第一种比较基础，为直接修改后缀，添加index.phps的后缀可以直接下载php源码，进而直接获取flag等直接信息；第二种稍为进阶，利用/ robots.txt / 备份目录。这道题目提示为phps源码泄露，直接利用第一种方式，添加后缀直接下载源码，获取到flag信息

### web6

在url后加www.zip，然后得到文本文档，这个题需要注意的是点开文本文档是拿不到flag，需要把文件名复制到url后面回车得到

dirsearch脚本的初步使用与解压源码 dirsearch:一个用字典暴力枚举 Web 目录 / 文件的 Python 脚本;www.zip:把整站源码打包备份成 [www.zip](http://www.zip/) 放在网站根目录，却没做好访问控制，结果你可以直接通过 URL 把它下回来。先扫描，后访问，得到对应的flag信息。

### web7

直接访问url/.git/index.php

版本控制与git仓库的初步理解 Git 是一个分布式的版本控制系统，广泛应用于代码管理。它允许开发者追踪项目文件的更改历史，并协作开发。 Git 泄露 、版本控制漏洞是常见的安全问题，在开发者没有适当配置 Git 的情况下，直接利用dirsearch进行扫描，得到对应的git文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

### web8

直接访问url/.svn/

版本控制与svn仓库的初步理解 在 CTF Web 题中， SVN（Subversion）和版本控制系统经常作为 漏洞和信息泄露的来源 ，类似于 Git，但其工作方式和使用场景有所不同。通过对 SVN 版本控制系统的配置不当或目录泄露，攻击者可以访问到项目的源代码、历史记录、敏感信息甚至是 flag。 svn泄露 、版本控制漏洞是常见的安全问题，在开发人员和系统管理员忽略配置 svn的情况下，直接利用dirsearch进行扫描，得到对应的.svn文件与ok状态的访问地址；之后直接进行访问，得到对应的flag

### web9

直接访问url/index.php.swp

vim缓存信息泄露的初步理解 “vim 缓存信息泄露”，本质就是出题人 / 开发在服务器上用 vim 编辑源码 ，留下了各种 编辑器缓存 / 备份文件 （`.swp`、`~`、`.bak` 等），结果这些文件也被 Web 服务器当成普通文件对外开放了，导致 **源代码泄露** 。 根据提示信息，采取手动猜路径的方法，直接得到.swp文件，得到flag。

### web10

F12,cookie中包含flag，url解码

cookie的初步理解 在ctf中， cooki相当于“服务器放在你浏览器里的小纸条，你用它上交‘身份’，而我们要想法看懂、改掉甚至伪造这张纸条。 根据题目中对于cookie的提示，先采用最简单的抓包方式，直接利用f12开发者工具进行抓包，获取到对应的信息如下，从中可以明显看到cookie中包含flag信息

### web11

通过dns检查查询flag https://zijian.aliyun.com/ TXT 记录，一般指为某个主机名或域名设置的说明。

查找flag.ctfshow.com域名下的txt记录

由于动态更新，txt记录会变，最终flag flag{just_seesee}

### web12

查看robots.txt文件

```
User-agent: *
Disallow: /admin/
```

查看源代码找到密码，访问url/admin/输入用户名：admin 和密码

### web13

根据题目提示 技术文档 在页面下面发现 document 下载发现里面存在后台地址和用户名密码登录成功获 得flag

### web14

根据提示，打开网页源码，搜索editor，访问editor发现编辑器，在上传文件的图片空间里，/var/www/html下面发现flag url/nothinghere/fl0000g.txt，访问目录得到flag

### web15

根据提示在页面下方发现QQ号码，url/admin，忘记密码，通过QQ号码查找到地址在西安，输入然后重置密码，获得flag

### web16

url/tz.php 发现PHPINFO能点进去找到flag

根据题目对于php探针的提示，同时了解到php相关概念后，采用最基础的直接猜路径，在靶场url后添加 `/phpinfo.php`等探针类型依次尝试，最后添加/tz.php后访问成功，确定该web网页使用的是雅黑php探针;之后继续查看phpinfo，经过一番搜索后得到flag

### web17

下载了dirsearch，扫描url得到[20:13:23] 200 -  934B - /backup.sql  ，直接访问url/backup.sql，下载sql文件得到flag

### web18

查看源代码，发现[js/Flappy_js.js](https://463f16d3-48d8-4451-938b-586ee7ce35d9.challenge.ctf.show/js/Flappy_js.js) ，在里面发现\u4f60\u8d62\u4e86\uff0c\u53bb\u5e7a\u5e7a\u96f6\u70b9\u76ae\u7231\u5403\u76ae\u770b\u770b直接丢给CyberChef，解出你赢了，去幺幺零点皮爱吃皮看看，url/110.php，得到flag

### web19

查看源代码，发现$u==='admin' && $p ==='a599ac85a73384ee3219fa684296eaa62667238d608efa81837030bd1ce1bf04，密文为AES加密，密钥为key = "0000000372619038";偏移量为iv = "ilove36dverymuch";模式为CBC填充为ZeroPadding编码为Hex，通过CyberChef解出密码，回到原页面输入用户名和密码得到flag

### web20

用dirsearch扫描，得到[19:27:25] 301 -  169B - /db -> http://f83cd3ef-7cf5-4e10-a200-c49856940f2d.challenge.ctf.show/db/，再dirsearch -u https://f83cd3ef-7cf5-4e10-a200-c49856940f2d.challenge.ctf.show/db/ -e sql,bak,txt,zip,db,sqlite -x 400,403,404，得到[19:29:20] 200 - 348KB - /db/db.mdb  ，直接url//db/db.mdb ，下载一个db.mdb文件，用mdbtools直接strings db.mdb | grep -i "flag"找到flag（mac打不开，win直接用记事本打开检索flag）

## 爆破

### web21

前提条件：已知用户名是admin。打开代理和Burp Suite，随便输入密码123尝试登陆同时利用Burp Suite抓包。解码发现格式为admin:123，可以进行爆破。爆破原理：利用多个payload（进攻指令），对返回数据进行对比分析，得到唯一不同的就是可能的密码。将所抓包send to intruder，选择sniper模式。加载题目所给字典，设置前缀admin:（因为字典中只包含了密码），并对其进行base64编码（匹配Authorization请求头格式）。进行爆破，找到状态不同的即为正确答案。解码，登录，找到flag。

### web22

域名更新后，flag.ctf.show域名失效，内容是flag{ctf_show_web}

### web23

写脚本，但我不会，得到/?token=422

### web24

终端运行php -r 'mt_srand(372619038); echo mt_rand();'得到1155388967**%**  ，然后填入?r=1155388967得到flag

### web25

mt_scrand(seed)这个函数的意思，是通过分发seed种子，然后种子有了后，靠mt_rand()生成随机 数。 在之前自己还以为需要暴力破解cookie,最后师傅们给我介绍了一个脚本，专门用来跑mt_srand()种子和 mt_rand()随机数的 这里自己解释一下为什么每一次的mt_rand()+mt_rand()不是第一次的随机数相加？？ 因为生成的随机数可以说是一个线性变换（实际上非常复杂）的每一次的确定的但是每一次是不一样的，所以不能 进行第一次*2就得到mt_rand()+mt_rand() 使用说只要我们得到种子就可以在本地进行获得自己想要的值 解题：通过随机数来寻找种子 我们让 ?r=0 得到随机数。这里我得到的是 183607393 每一次不一样(因为flag值在变化) 然后下载 php_mt_seed4.0 我们在linux下面使用 gcc进行编译 gcc php_mt_seed.c -o php_mt_seed 之后运行脚本添加随机数 ./php_mt_seed 183607393

找到对应的版本这里自己的运气好第一个出来的自己验证了一下发现就是这个 注：可能存在多个种子需要自己进行判断 通过种子找到第一个随机数就是上面的随机数。

payload： ?r=183607393 Cookie: token=794171094

### web26

打开bp抓包点击安装后的请求包，发送至Repeater重发器模块，点击Send发送，查看响应包，即可获取flag

### web27

burpsuit爆破，学生学籍信息查询系统可以查询学号，录取名单有姓名和身份证号码（不全）所以爆破身份证号，得到身份证号：621022199002015237登录得到学号，然后登录得到flag

这题主要是身份证出生日期爆破，先拦截然后将出生日期设置为变量，attack type默认为狙击手模式，Payloads选项卡中payload type改为Dates模式，payload settings中为Dates设置起始和终止日期，注意Format项改为自定义的yyyyMMdd，然后开始爆破，爆破结束后length字段降序排序，相应包最长的应该就是响应成功的包

### web28

打开靶机，发现跳转到url/0/1/2.txt，发现上两级目录都是纯数字，猜测爆破一下目录试试，打开bp抓到请求包，发送到Intruder攻击模块将目录中的0和1设置为变量，Attack type设置为Cluster bomb模式，Payloads中两个Payload type都改为Numbers，给Numbers设置初始值0和终止值为100，开始爆破，爆破结束后，将Status code字段升序排序，找到一个状态码为200的响应包，查看响应包，可获取falg

## 命令执行

### web29

#### 代码逻辑分析

1. **`error_reporting(0);`**: 关闭错误报告，防止报错信息泄露。
2. **`if(isset($_GET['c']))`**: 检查是否通过 GET 请求传递了参数 `c`。
3. **`if(!preg_match("/flag/i", $c))`**: 核心防御逻辑。使用正则表达式检查变量 `$c` 中是否包含 "flag" 字符串（`i` 表示不区分大小写）。如果不包含，则执行下一步。
4. **`eval($c);`**: 这是一个极其危险的函数，它会将字符串 `$c` 当作 PHP 代码直接执行。
5. **`highlight_file(__FILE__);`**: 如果没有参数 `c`，则显示当前源代码。

#### 绕过思路

由于后端过滤了 `flag` 这个词，我们无法直接使用类似 `system("cat flag.php");` 的命令。我们需要通过一些技巧来绕过正则检测。

##### 1. 使用通配符 (Wildcards)

在 Linux Shell 中，`?` 匹配单个字符，`*` 匹配任意字符。

- **Payload:** `?c=system("cat f*");`
- **Payload:** `?c=system("cat fla?.php");`

##### 2. 使用 PHP 变量拼接

我们可以将字符串拆开，避开正则检测。

- **Payload:** `?c=$a="fla";$b="g.php";system("cat ".$a.$b);`

这两种都可以，但要查看源代码才能得到flag

### web30

代码的核心逻辑是：通过 `GET` 方式接收参数 `c`，在过滤了关键词 `flag`、`system` 和 `php`（不区分大小写）后，将内容传递给 `eval()` 执行。

#### 第一步：查看目录文件

首先确定 flag 文件的确切名称。

```
?c=echo(`ls`);
```

#### 第二步：读取文件内容

假设目录下有 `flag.php`，使用通配符绕过：

```
?c=passthru("cat f*");
```

查看源代码

### web31

代码的核心逻辑是：通过 `GET` 方式接收参数 `c`，在经过一个正则表达式过滤后，使用 `eval()` 执行该字符串。

#### 核心限制分析

正则表达式 `/flag|system|php|cat|sort|shell|\.| |\’/i` 禁用了以下内容：

- **关键词**：`flag`, `system`, `php`, `cat`, `sort`, `shell`（且不区分大小写）。
- **特殊符号**：`.` (点), ` ` (空格), `'` (单引号)。

#### 绕过思路

##### 1. 绕过 `system` 限制

虽然 `system` 被禁用了，但 PHP 中还有其他执行系统命令的函数：

- `passthru()`
- `exec()`
- `shell_exec()`
- **反引号 (```)**：这是 `shell_exec()` 的快捷方式，非常适合绕过关键字过滤。

##### 2. 绕过空格限制

在 Linux 环境下，可以使用以下字符代替空格：

- `%09` (Tab 键的 URL 编码)
- `${IFS}` (Shell 的内部字段分隔符)
- `$IFS$9`

##### 3. 绕过 `flag` 和 `cat` 限制

- **文件名通配符**：用 `f*` 或 `f???` 代替 `flag`。
- **替代命令**：用 `tac` (倒序读取), `more`, `less`, `nl` (带行号读取) 代替 `cat`。

#### 构造 Payload

##### 利用反引号和 `tac`

利用 `echo` 配合反引号执行命令。

```
?c=echo%09`tac%09f*`;
```

- `%09` 绕过空格。
- `tac` 绕过 `cat`。
- `f*` 绕过 `flag`。

### web32

#### 1. 代码逻辑分析

1. **`error_reporting(0);`**：关闭错误报告，增加调试难度。
2. **`isset($_GET['c'])`**：检查是否通过 GET 请求传入了参数 `c`。
3. **`preg_match(...)`**：这是一个**黑名单**过滤。如果你的输入包含以下任何字符或单词，程序就会停止：
   - 关键字：`flag`, `system`, `php`, `cat`, `sort`, `shell`, `echo`
   - 特殊符号：`.` (点), ` ` (空格), `'` (单引号), ``` (反引号), `;` (分号), `(` (左括号)
4. **`eval($c);`**：如果绕过了过滤，参数 `c` 的内容将作为 PHP 代码执行。

#### 2. 绕过思路

由于 `(` 和 `;` 被过滤，我们无法直接调用函数（如 `system()`），也无法写出标准的多行语句。我们需要利用 PHP 的**语言构造器**和**短标签**特性。

##### A. 绕过分号 `;`

在 PHP 的 `eval()` 中，你可以使用 `?>`（PHP 结束标签）来代替分号。

##### B. 绕过括号 `(`

`include` 和 `require` 是 PHP 的**语言构造器**，不是函数，因此调用它们不需要括号。 例如：`include $_GET[1]?>`

##### C. 绕过空格

在 Linux 环境下，URL 中可以使用 `%09` (Tab 键) 或 `$IFS$9` 等方式绕过。但在 PHP 代码中，如果 `include` 后紧跟变量，有时连空格都不需要。

##### D. 绕过 `flag` 等关键字

最常用的技巧是**参数逃逸**：在 `c` 中执行一个不被过滤的语句，去调用另一个不受过滤限制的参数（如 `$_GET[1]`）。

#### 3. 常见的攻击 Payload

##### 利用 `include` 和伪协议读取文件

```
?c=include$_GET[1]?>&1=php://filter/read=convert.base64-encode/resource=flag.php
```

- **原理**：`c` 的内容是 `include$_GET[1]?>`，没有触碰任何黑名单。
- **执行**：它会包含参数 `1` 指向的内容。由于 `flag.php` 直接读取会被服务器解析而不显示源码，我们使用 `php://filter` 将其转为 Base64 编码，读出来后再自行解码。

得到` PD9waHANCg0KLyoNCiMgLSotIGNvZGluZzogdXRmLTggLSotDQojIEBBdXRob3I6IGgxeGENCiMgQERhdGU6ICAgMjAyMC0wOS0wNCAwMDo0OToxOQ0KIyBATGFzdCBNb2RpZmllZCBieTogICBoMXhhDQojIEBMYXN0IE1vZGlmaWVkIHRpbWU6IDIwMjAtMDktMDQgMDA6NDk6MjYNCiMgQGVtYWlsOiBoMXhhQGN0ZmVyLmNvbQ0KIyBAbGluazogaHR0cHM6Ly9jdGZlci5jb20NCg0KKi8NCg0KJGZsYWc9ImN0ZnNob3d7ZWVhYTg5NTgtNDZhMC00NDUwLTk1NWUtZTM2MTk5ZGNiMTkyfSI7DQo=`

用CyberChef直接解出flag

### web33

#### 1. 核心过滤分析

正则表达式 

```
/flag|system|php|cat|sort|shell|\.| |\'|\`|echo|\;|\(|\"/i
```

过滤了以下内容：

- **关键词**：`flag`, `system`, `php`, `cat`, `sort`, `shell`, `echo`（堵死了直接读取和常用的系统调用）。
- **符号**：
  - `.` (点)：无法直接写文件名或后缀。
  - ` ` (空格)：无法分隔命令参数。
  - `'` 和 `"` (引号)：无法构造字符串。
  - `(反引号)：无法执行 Shell 命令。
  - `;` (分号)：无法结束语句（**关键限制**）。
  - `(` (括号)：无法直接调用函数，如 `system()` 或 `eval()`。

#### 2. 绕过思路：文件包含 (Include)

在 PHP 中，`include` 是一个**语言结构**而非函数，因此它**不需要括号**。利用这一点，我们可以尝试通过 `include` 包含一个受控的外部变量。

由于分号 `;` 被禁，我们可以利用 PHP 的**闭合标签 `?>`** 来代替分号结束当前的语句。

#### Payload 构造：

```
?c=include$_GET[1]?>&1=php://filter/read=convert.base64-encode/resource=flag.php
```

1. **`include$_GET[1]`**：`include` 后面直接跟变量，绕过了括号限制；使用 `$_GET` 数组绕过了引号限制（PHP 数组键名不加引号在某些配置下会当作字符串处理，或者利用 PHP 特性直接拼接）。
2. **`?>`**：成功绕过分号 `;` 限制，告诉 PHP 解析器当前代码段结束。
3. **`1` 参数**：因为正则只检测变量 `c`，所以我们在参数 `1` 中可以自由书写被禁用的关键词，如 `php`、`flag`、`.` 等。
4. **`php://filter`**：使用伪协议读取文件并将内容进行 Base64 编码。这是因为 `flag.php` 通常包含 PHP 代码，直接 include 会被解析而不显示内容，编码后可以拿到源码。
