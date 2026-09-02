---
title: "Web 安全代码审计与漏洞防御学习笔记"
date: 2026-08-31
draft: false
categories: ["web"]
---
# Web 安全代码审计与漏洞防御学习笔记

> **学习目标：** 从代码审计、安全开发和漏洞防御角度理解常见 Web 漏洞的形成原因，建立 `Source → Data Flow → Validation → Sink` 的统一安全分析思维。
>
> **适用范围：** 本笔记仅用于本地实验、安全自查、代码修复和漏洞防御研究，不包含攻击利用载荷、数据库数据提取、自动化攻击或未授权安全测试方法。


## 1. Web 漏洞统一分析模型

很多 Web 漏洞表面上完全不同，例如：

- SQL 注入
- 文件上传
- 代码执行
- 反序列化
- XSS
- 路径遍历
- SSRF
- XXE
- 模板注入

但是从代码审计角度，它们通常都可以抽象成类似的数据流：

```
用户可控输入
      ↓
    Source
      ↓
变量传递 / 转换 / 业务处理
      ↓
Validation / Security Control
      ↓
────── 安全边界 ──────
      ↓
     Sink
      ↓
数据库 / Shell / 浏览器 / 文件系统 / 反序列化器
```

最核心的问题是：

> **用户可控的数据，有没有跨越“数据边界”，进入本应由程序控制的解释器、文件系统或执行环境。**

### 1.1 Source：用户可控输入

`Source` 指可能受到用户或外部环境影响的数据来源。

常见 Source：

```
GET 参数
POST 表单
JSON Body
Cookie
HTTP Header
URL Path
上传文件
WebSocket 消息
数据库已有内容
Redis 数据
消息队列
第三方 API 返回值
Webhook
本地文件内容
环境变量
```

PHP 示例：

```
$name = $_GET['name'];
```

Python Flask 示例：

```
name = request.args.get("name")
```

两种情况下：

```
外部数据
   ↓
用户可以影响
   ↓
默认不可信
```

需要特别注意：

> **来自数据库的数据也不一定可信。**

例如：

```
用户第一次提交内容
        ↓
保存到数据库
        ↓
几天后程序重新读取
        ↓
进入另一个危险 Sink
```

因此不能简单认为：

```
数据库数据 = 可信数据
```

### 1.2 Sink：危险数据使用位置

`Sink` 指程序最终把数据交给某个具有解释、执行或敏感操作能力的位置。

#### SQL Sink

常见：

```
cursor.execute()
PDO::query()
mysqli_query()
ORM raw()
原生 SQL API
```

#### 系统命令 Sink

常见：

```
system()
exec()
shell_exec()
os.system()
subprocess.run()
```

#### 动态代码执行 Sink

常见：

```
eval()
exec()
```

#### 文件 Sink

常见：

```
open()
write()
file_put_contents()
move_uploaded_file()
save()
rename()
copy()
```

#### 反序列化 Sink

常见：

```
unserialize()
pickle.loads()
yaml.load()
```

#### 浏览器输出 Sink

常见：

```
echo
模板 safe / raw
Markup
innerHTML
动态 HTML 拼接
```

看到这些函数时不能直接判断：

```
存在危险函数
=
一定存在漏洞
```

真正需要继续分析的是：

```
用户数据是否可以到达这个 Sink？
```

### 1.3 Source → Sink 数据流模型

源码审计时不要只搜索函数名。

应该完整追踪：

```
Source
   ↓
变量 A
   ↓
函数 B
   ↓
变量 C
   ↓
Validation
   ↓
Sink
```

例如：

```
user_id = request.args.get("id")

sql = f"SELECT * FROM users WHERE id = {user_id}"

cursor.execute(sql)
```

数据流：

```
request.args
    ↓
 user_id
    ↓
 f-string
    ↓
 SQL字符串
    ↓
cursor.execute()
```

其中：

```
Source = request.args
Sink   = cursor.execute()
```

真正的问题发生在：

```
用户数据
   ↓
字符串拼接
   ↓
进入 SQL 结构
```

### 1.4 数据与代码边界

安全代码最重要的目标之一：

```
让用户输入始终保持“数据”身份
```

危险模式：

```
用户数据
   ↓
字符串拼接
   ↓
解释器重新解析
   ↓
数据成为程序结构
```

正确模式：

```
用户数据
   ↓
业务验证
   ↓
安全 API
   ↓
普通参数 / 普通文本 / 普通数据结构
```

以后学习任何 Web 漏洞，都可以先问：

> **这段用户输入最后被谁解释？**

## 2. SQL 注入缺陷

### 2.1 漏洞根源

SQL 注入的根本问题不是：

> 用户输入了某个特殊字符。

真正的问题是：

> **用户可控数据进入了 SQL 结构，数据库无法继续可靠地区分“SQL 程序结构”和“普通参数数据”。**

错误数据流：

```
HTTP 参数
    ↓
字符串拼接
    ↓
完整 SQL 文本
    ↓
数据库 SQL Parser
```

正确数据流：

```
HTTP 参数
    ↓
业务验证
    ↓
SQL 模板
+
独立参数
    ↓
数据库驱动参数绑定
```

### 2.2 错误案例一：PHP 字符串拼接 SQL

#### 错误代码

```
$name = $_GET['name'];

$sql = "SELECT id, name FROM users WHERE name='$name'";

$result = $pdo->query($sql);
```

#### 逐行分析

第一行：

```
$name = $_GET['name'];
```

`$_GET` 是用户可控数据。

因此：

```
$name = 不可信输入
```

第二行：

```
$sql = "SELECT id, name FROM users WHERE name='$name'";
```

这里发生：

```
固定 SQL
+
用户数据
```

最终得到：

```
一个完整 SQL 字符串
```

数据与 SQL 代码之间的边界已经被破坏。

第三行：

```
$result = $pdo->query($sql);
```

数据库开始解析整个字符串。

#### 安全修复

```
$name = $_GET['name'] ?? '';

$stmt = $pdo->prepare(
    'SELECT id, name FROM users WHERE name = :name'
);

$stmt->execute([
    ':name' => $name
]);

$result = $stmt->fetchAll(PDO::FETCH_ASSOC);
```

修复后：

```
SQL结构
+
独立参数
```

数据库驱动负责把：

```
:name
```

绑定为：

```
普通数据值
```

### 2.3 错误案例二：Python f-string SQL

#### 错误代码

```
user_id = request.args.get("id")

sql = f"SELECT username FROM users WHERE id = {user_id}"

cursor.execute(sql)
```

数据流：

```
request.args
    ↓
user_id
    ↓
f-string
    ↓
SQL结构
```

#### 安全修复

SQLite 示例：

```
user_id = request.args.get(
    "id",
    type=int,
)

if user_id is None:
    return {
        "error": "invalid id"
    }, 400

cursor.execute(
    "SELECT username FROM users WHERE id = ?",
    (user_id,),
)

row = cursor.fetchone()
```

这里有两层保护：

```
第一层：
数据类型验证

第二层：
SQL参数绑定
```

注意：

> **类型验证不能代替 SQL 参数化。**

类型验证解决的是：

```
业务输入是否合法
```

参数化解决的是：

```
数据是否可能改变 SQL 结构
```

### 2.4 错误案例三：动态 ORDER BY

#### 错误代码

```
sort = request.args.get(
    "sort",
    "name",
)

sql = (
    "SELECT id, name "
    "FROM users "
    "ORDER BY " + sort
)

cursor.execute(sql)
```

问题在于：

```
sort
```

最终成为：

```
SQL标识符
```

例如列名。

普通 SQL 参数绑定主要用于：

```
数据值
```

而不是：

```
表名
列名
排序方向
SQL关键字
```

因此不能简单依赖：

```
ORDER BY ?
```

实现任意动态列名。

#### 安全修复

```
SORT_FIELDS = {
    "name": "name",
    "time": "created_at",
    "id": "id",
}

sort_key = request.args.get(
    "sort",
    "name",
)

column = SORT_FIELDS.get(
    sort_key
)

if column is None:
    return {
        "error": "invalid sort field"
    }, 400

sql = (
    "SELECT id, name "
    f"FROM users ORDER BY {column}"
)

cursor.execute(sql)
```

数据流：

```
用户输入
   ↓
固定白名单映射
   ↓
程序预定义SQL字段
   ↓
SQL结构
```

这里进入 SQL 的：

```
不是用户原始输入
```

而是：

```
程序内部提前定义好的字段
```

### 2.5 为什么黑名单防 SQL 不可靠

例如开发人员尝试：

```
删除引号
删除空格
屏蔽几个SQL关键词
大量replace()
```

这种思路的问题：

> **SQL 是一门语言，而不是一张危险字符表。**

同一种逻辑可能具有：

```
不同语法表示
不同大小写
不同数据库方言
不同函数
不同表达式
不同空白形式
```

所以正确问题不是：

> 用户有没有输入“坏字符串”？

而应该是：

> 用户数据有没有机会成为 SQL 结构的一部分？

### 2.6 SQL 防御原则

推荐优先级：

```
1. 参数化查询
2. 动态标识符使用 allowlist
3. 输入类型和业务校验
4. 数据库最小权限
5. 不向前端泄漏数据库错误
6. WAF作为辅助防御
```

可以记成：

```
值
→ 参数化

结构
→ 白名单
```

## 3. 文件上传风险

### 3.1 漏洞根源

文件上传问题本质上是：

```
用户控制文件
    ↓
服务器接受
    ↓
服务器保存
    ↓
Web服务器 / 文件解析器继续处理
```

需要同时关注：

```
文件名
扩展名
MIME
真实文件内容
文件大小
保存路径
访问权限
执行权限
Web服务器配置
```

### 3.2 错误案例一：直接使用原始文件名

#### 错误代码

```
$file = $_FILES['file'];

$name = $file['name'];

move_uploaded_file(
    $file['tmp_name'],
    __DIR__ . '/uploads/' . $name
);
```

问题：

```
$file['name']
```

由客户端提供。

服务器直接拿：

```
用户控制的文件名
```

作为：

```
真实磁盘文件名
```

同时：

```
/uploads/
```

如果位于 WebRoot 中，上传内容还可能被 Web 服务器直接访问。

#### 安全修复

```
$uploadDir = '/srv/app-data/uploads/';

$file = $_FILES['file'] ?? null;

if (
    !$file ||
    $file['error'] !== UPLOAD_ERR_OK
) {
    http_response_code(400);
    exit('invalid upload');
}

if ($file['size'] > 5 * 1024 * 1024) {
    http_response_code(400);
    exit('file too large');
}

$extension = strtolower(
    pathinfo(
        $file['name'],
        PATHINFO_EXTENSION
    )
);

$allowed = [
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
];

if (!isset($allowed[$extension])) {
    http_response_code(400);
    exit('unsupported extension');
}

$finfo = new finfo(
    FILEINFO_MIME_TYPE
);

$mime = $finfo->file(
    $file['tmp_name']
);

if ($mime !== $allowed[$extension]) {
    http_response_code(400);
    exit('content mismatch');
}

$newName =
    bin2hex(random_bytes(16))
    . '.'
    . $extension;

$destination =
    $uploadDir . $newName;

if (
    !move_uploaded_file(
        $file['tmp_name'],
        $destination
    )
) {
    http_response_code(500);
    exit('cannot store file');
}
```

这里使用：

```
扩展名 allowlist
+
服务端 MIME 检测
+
文件大小限制
+
服务器随机文件名
+
WebRoot 外保存
```

### 3.3 错误案例二：只相信 Content-Type

#### 错误代码

```
f = request.files["file"]

if f.content_type == "image/png":
    f.save(
        "static/uploads/"
        + f.filename
    )
```

问题一：

```
Content-Type
```

来自 HTTP 请求。

它本质是：

```
客户端提供的数据
```

不能把它当作服务器安全证明。

问题二：

```
static/uploads/
```

通常可以直接通过 Web 访问。

问题三：

```
f.filename
```

也是客户端提供的原始文件名。

#### 安全修复

```
from pathlib import Path
import secrets
import magic


UPLOAD_DIR = Path(
    "/srv/app-data/uploads"
)

ALLOWED = {
    ".png": {"image/png"},
    ".jpg": {"image/jpeg"},
    ".jpeg": {"image/jpeg"},
}


def save_upload(file):

    original = Path(
        file.filename or ""
    )

    extension = (
        original.suffix.lower()
    )

    if extension not in ALLOWED:
        raise ValueError(
            "unsupported extension"
        )

    file.stream.seek(0, 2)

    size = file.stream.tell()

    file.stream.seek(0)

    if size > 5 * 1024 * 1024:
        raise ValueError(
            "file too large"
        )

    header = file.stream.read(
        8192
    )

    file.stream.seek(0)

    mime = magic.from_buffer(
        header,
        mime=True
    )

    if mime not in ALLOWED[extension]:
        raise ValueError(
            "file type mismatch"
        )

    filename = (
        secrets.token_hex(16)
        + extension
    )

    destination = (
        UPLOAD_DIR / filename
    )

    file.save(destination)

    return filename
```

### 3.4 错误案例三：只过滤文件名

#### 错误代码

```
$name = $_FILES['file']['name'];

$name = str_replace(
    '..',
    '',
    $name
);

move_uploaded_file(
    $_FILES['file']['tmp_name'],
    '/var/www/html/uploads/' . $name
);
```

开发者可能认为：

```
删除 ..
=
文件名安全
```

但实际上它没有解决：

```
文件内容是否合法
扩展名是否合法
文件是否应该被Web访问
用户是否应该控制磁盘名
保存目录权限是否安全
```

#### 安全修复思路

原则：

```
客户端文件名
≠
磁盘文件名
```

例如：

```
客户端：

毕业照片.jpg
```

服务器实际保存：

```
8f60e1353a22a1c9c681.jpg
```

数据库单独记录：

```
upload_id
owner_id
original_filename
storage_filename
mime
size
created_at
```

下载时：

```
用户请求 upload_id
        ↓
检查用户权限
        ↓
查询 storage_filename
        ↓
服务器读取 WebRoot 外文件
        ↓
返回文件
```

而不是：

```
用户直接访问磁盘路径
```

### 3.5 文件上传防御原则

推荐：

```
1. 扩展名 allowlist
2. 服务端 MIME 检测
3. 必要时解析文件内部格式
4. 限制文件大小
5. 限制上传数量
6. 服务器生成随机文件名
7. 上传目录放在 WebRoot 外
8. 上传目录禁止执行
9. 下载时重新检查权限
10. 复杂文件可增加病毒扫描或内容重建
```

不能单独依赖：

```
Content-Type
文件扩展名
前端JavaScript验证
字符串replace()
```

## 4. 代码执行风险

### 4.1 漏洞根源

代码执行类问题本质：

```
用户数据
   ↓
解释器
   ↓
用户数据被当成程序指令
```

这里的解释器可能包括：

```
PHP Parser
Python Parser
Shell
Bash
PowerShell
操作系统命令解析器
```

### 4.2 错误案例一：PHP eval

#### 错误代码

```
$expr = $_POST['expr'];

$result = eval(
    'return ' . $expr . ';'
);
```

数据流：

```
POST
 ↓
$expr
 ↓
eval()
 ↓
PHP Parser
```

这里用户数据直接进入：

```
PHP代码解释器
```

#### 安全修复

假设业务只是一个简单计算器：

```
function calculate(
    string $op,
    float $a,
    float $b
): float {

    return match ($op) {

        'add' =>
            $a + $b,

        'sub' =>
            $a - $b,

        'mul' =>
            $a * $b,

        'div' =>
            $b != 0.0
                ? $a / $b
                : throw new InvalidArgumentException(
                    'division by zero'
                ),

        default =>
            throw new InvalidArgumentException(
                'invalid operation'
            ),
    };
}
```

现在数据流：

```
用户输入操作名称
       ↓
固定白名单
       ↓
程序已有逻辑
```

用户不再提供：

```
要执行的PHP代码
```

### 4.3 错误案例二：Python shell=True

#### 错误代码

```
filename = request.args[
    "file"
]

cmd = (
    "tool "
    + filename
)

subprocess.run(
    cmd,
    shell=True
)
```

数据流：

```
用户输入
   ↓
字符串拼接
   ↓
命令字符串
   ↓
shell=True
   ↓
Shell Parser
```

Shell 会对整个字符串再次解释。

#### 安全修复

```
from pathlib import Path
import subprocess


BASE = Path(
    "/srv/app-data/files"
).resolve()


def process_file(
    file_id: str
):

    if not file_id.isalnum():
        raise ValueError(
            "invalid id"
        )

    path = (
        BASE / file_id
    ).resolve()

    if path.parent != BASE:
        raise ValueError(
            "invalid path"
        )

    subprocess.run(
        [
            "/usr/bin/fixed-tool",
            str(path),
        ],
        shell=False,
        check=True,
        timeout=10,
    )
```

安全措施：

```
固定可执行程序
+
参数数组
+
shell=False
+
业务验证
+
超时
```

### 4.4 错误案例三：PHP system

#### 错误代码

```
$target = $_GET['target'];

system(
    "some-tool " . $target
);
```

问题：

```
用户数据
 ↓
Shell命令字符串
 ↓
system()
```

#### 安全修复思路

最优解决方案通常不是：

```
添加越来越多replace()
```

而是：

```
不要使用Shell实现业务
```

例如：

```
需要访问HTTP资源
→ 使用HTTP客户端库

需要处理图片
→ 使用图片处理库

需要处理文件
→ 使用语言文件API

需要数据库操作
→ 使用数据库驱动
```

只有确实必须启动外部程序时，才考虑：

```
固定程序路径
+
独立参数列表
+
严格业务allowlist
+
最小权限
+
执行超时
```

### 4.5 代码执行防御原则

推荐优先级：

```
语言原生 API
     ↓
成熟第三方库
     ↓
固定外部程序 + 独立参数
     ↓
Shell字符串
```

越往下：

```
风险越大
```

代码审计时重点关注：

```
eval
exec
system
shell_exec
os.system
subprocess
shell=True
动态import
动态模板执行
```

然后继续确认：

```
用户数据是否真正可以到达这里？
```

## 5. 反序列化风险

### 5.1 什么是序列化

序列化：

```
程序对象
   ↓
文本 / 字节
```

反序列化：

```
文本 / 字节
   ↓
程序对象
```

JSON：

```
{
  "name": "Alice",
  "age": 20
}
```

主要表达：

```
普通数据结构
```

而某些语言原生对象序列化格式可能包含：

```
对象类型
类
对象关系
特殊方法
复杂对象状态
```

所以：

```
不可信数据
   ↓
复杂对象反序列化器
```

属于高风险数据边界。

### 5.2 错误案例一：PHP unserialize

#### 错误代码

```
$data = $_COOKIE['profile'];

$profile = unserialize(
    $data
);
```

数据流：

```
Cookie
 ↓
客户端控制
 ↓
unserialize()
```

客户端数据进入：

```
PHP对象反序列化器
```

#### 安全修复

```
$data =
    $_COOKIE['profile']
    ?? '{}';

try {

    $profile = json_decode(
        $data,
        true,
        32,
        JSON_THROW_ON_ERROR
    );

} catch (JsonException $e) {

    http_response_code(400);
    exit('invalid profile');
}

if (!is_array($profile)) {

    http_response_code(400);
    exit('invalid profile');
}
```

更加推荐的 Session 模型：

```
Cookie
 ↓
随机Session ID
 ↓
服务器查询真实用户状态
```

数据实际保存在：

```
Server Session
Redis
Database
```

### 5.3 错误案例二：Python pickle

#### 错误代码

```
body = request.get_data()

obj = pickle.loads(
    body
)
```

问题：

```
HTTP Body
   ↓
pickle.loads()
```

客户端控制的数据直接进入：

```
Python原生对象反序列化器
```

#### 安全修复

```
import json


def parse_json(
    body: bytes
) -> dict:

    if len(body) > 64 * 1024:
        raise ValueError(
            "payload too large"
        )

    try:

        data = json.loads(
            body.decode("utf-8")
        )

    except (
        UnicodeDecodeError,
        json.JSONDecodeError,
    ) as exc:

        raise ValueError(
            "invalid json"
        ) from exc

    if not isinstance(
        data,
        dict
    ):
        raise ValueError(
            "invalid structure"
        )

    return data
```

JSON 解析之后还要继续：

```
Schema验证
```

例如：

```
name：
字符串
最大长度50

age：
整数
范围0~150

email：
合法格式

role：
不允许客户端直接决定

is_admin：
不允许客户端直接提供
```

### 5.4 错误案例三：不安全 YAML

#### 错误代码

```
data = yaml.load(
    request.data,
    Loader=UnsafeLoader,
)
```

问题：

```
用户输入
   ↓
功能复杂的YAML Loader
```

#### 安全修复

如果业务确实需要 YAML：

```
data = yaml.safe_load(
    request.data
)
```

如果业务只需要普通数据：

```
优先JSON
```

原则：

> **输入语言越复杂，需要处理的安全语义通常越多。**

### 5.5 反序列化防御原则

推荐：

```
1. 不反序列化不可信原生对象
2. 客户端数据优先使用JSON
3. JSON继续进行Schema验证
4. Session状态尽量保存在服务端
5. 限制请求大小
6. 限制结构复杂度
7. 不允许客户端控制服务器内部类型
```

## 6. XSS 跨站脚本风险

### 6.1 漏洞根源

XSS 的核心安全边界：

```
服务器字符串
    ↓
HTTP Response
    ↓
Browser Parser
```

问题发生在：

```
用户数据
```

被浏览器解释成：

```
HTML
JavaScript
CSS
URL
DOM结构
```

而不是：

```
普通文本
```

### 6.2 错误案例一：PHP 直接输出

#### 错误代码

```
$name = $_GET['name'];

echo "<h1>Hello $name</h1>";
```

数据流：

```
GET
 ↓
$name
 ↓
HTML Response
 ↓
Browser Parser
```

#### 安全修复

```
$name =
    $_GET['name']
    ?? '';

$safeName = htmlspecialchars(
    $name,
    ENT_QUOTES | ENT_SUBSTITUTE,
    'UTF-8'
);

echo (
    "<h1>Hello {$safeName}</h1>"
);
```

数据流变成：

```
用户文本
 ↓
HTML编码
 ↓
HTML Response
 ↓
浏览器显示普通文本
```

### 6.3 错误案例二：Jinja 关闭自动转义

#### 错误模板

```
<p>
    {{ comment|safe }}
</p>
```

`safe` 的含义是：

```
告诉Jinja：
不要对该内容进行HTML自动转义
```

如果：

```
comment
```

来自用户，就会破坏重要的输出安全边界。

#### 安全修复

```
<p>
    {{ comment }}
</p>
```

原则：

```
不要无理由关闭模板自动转义
```

重点关注：

```
safe
raw
Markup
```

### 6.4 错误案例三：富文本直接保存并输出

#### 错误代码

```
article = request.form[
    "article"
]

db.save(article)
```

随后模板：

```
<div>
    {{ article|safe }}
</div>
```

数据流：

```
用户输入
 ↓
数据库
 ↓
再次读取
 ↓
关闭转义
 ↓
浏览器
```

这种类型叫：

```
Stored XSS
存储型XSS
```

#### 修复方案一：业务不需要 HTML

只保存：

```
纯文本
```

模板：

```
<div>
    {{ article }}
</div>
```

#### 修复方案二：业务确实需要富文本

使用成熟的 HTML Sanitizer：

```
HTML Parser
    ↓
标签 allowlist
    ↓
属性 allowlist
    ↓
协议 allowlist
    ↓
删除危险结构
```

不能简单：

```
html.replace(
    "<某个标签>",
    ""
)
```

因为：

```
HTML是一门结构化语言
```

而不是：

```
简单字符串
```

### 6.5 输出上下文非常重要

下面这些上下文：

```
HTML正文
HTML属性
JavaScript
CSS
URL
```

安全处理方式并不完全一样。

因此不能理解为：

```
只要调用一次HTML转义
=
所有XSS问题都解决
```

需要判断：

```
用户数据最终出现在哪个浏览器上下文？
```

### 6.6 XSS 防御原则

推荐：

```
1. 保持模板自动转义
2. 根据输出上下文进行编码
3. 普通内容尽量使用纯文本
4. 富文本使用成熟Sanitizer
5. 避免动态字符串拼HTML
6. 谨慎使用innerHTML
7. CSP作为纵深防御
8. 敏感Cookie使用HttpOnly
```

## 7. 五类漏洞的统一理解

| 漏洞     | 用户数据最终进入     | 根本问题               | 核心防御      |
| -------- | -------------------- | ---------------------- | ------------- |
| SQL 注入 | SQL Parser           | 数据进入 SQL 结构      | 参数化查询    |
| 文件上传 | 文件系统 / Web服务器 | 用户控制危险文件或路径 | 校验 + 隔离   |
| 代码执行 | Shell / 代码解释器   | 数据变成命令或代码     | 避免动态执行  |
| 反序列化 | Object Deserializer  | 不可信数据恢复复杂对象 | JSON + Schema |
| XSS      | Browser Parser       | 数据变成 HTML/JS 结构  | 上下文编码    |

统一模型：

```
用户数据
   ↓
进入错误的解释器
   ↓
解释器改变程序原本语义
```

所以源码审计最重要的问题不是：

> 这个漏洞叫什么名字？

而是：

> **用户数据最后被谁解释？**

## 8. 现代 WAF 检测原理

现代 WAF 通常不是简单使用几个正则表达式。

典型检测流程可以抽象成：

```
HTTP Request
      ↓
HTTP协议解析
      ↓
URL Decode
      ↓
Unicode规范化
      ↓
Canonicalization
      ↓
特征匹配
      ↓
Token / 语义分析
      ↓
异常评分
      ↓
行为分析
      ↓
Allow / Log / Challenge / Block
```

### 8.1 特征匹配

WAF 可以检查：

```
危险关键字组合
异常HTTP结构
异常编码
危险扩展名
异常参数格式
已知攻击特征
```

#### 优势

```
速度快
实现成熟
计算成本低
规则容易维护
对已知模式比较有效
```

#### 短板

最大的理论问题：

```
字符串特征
≠
程序真实语义
```

因此会出现：

```
False Positive
误报
```

以及：

```
False Negative
漏报
```

例如：

```
安全论坛讨论SQL代码
```

本身是正常业务，却可能包含大量：

```
SQL关键字
```

### 8.2 语义分析

更加先进的检测可能先把输入拆成：

```
KEYWORD
IDENTIFIER
OPERATOR
STRING
NUMBER
FUNCTION
```

例如数据库相关输入，不只是搜索：

```
某个关键词
```

而是分析：

```
Token之间的结构关系
```

#### 优势

可以更好地处理：

```
大小写变化
空格变化
部分编码差异
Token结构
部分语法变化
```

一般比：

```
普通字符串contains
```

更强。

#### 短板

存在一个重要理论问题：

```
WAF Parser
≠
后端真实 Parser
```

后端可能使用：

```
MySQL
PostgreSQL
SQL Server
Oracle
SQLite
```

这些数据库之间：

```
SQL语法
函数
类型
运算规则
```

存在差异。

因此可能出现：

```
Parser Differential
解析器差异
```

即：

```
WAF理解A
后端理解B
```

### 8.3 行为识别

安全系统还可以观察多个请求之间的关系。

例如：

```
IP请求频率
Session行为
参数变化规律
访问顺序
错误比例
User-Agent
账户行为
请求时间分布
历史行为基线
```

正常用户：

```
一分钟搜索几次
参数变化自然
访问路径合理
```

异常自动化行为可能表现：

```
大量相似请求
参数机械变化
连续出现异常响应
重复访问敏感接口
```

#### 优势

可以发现：

```
单个请求看起来正常
+
整体行为异常
```

#### 短板

正常业务也可能产生自动化行为：

```
搜索引擎
企业API
批处理程序
压力测试
监控程序
```

所以：

```
行为异常
≠
一定是攻击
```

### 8.4 异常评分

现代 WAF 经常使用：

```
Anomaly Score
异常评分
```

不是简单：

```
命中一条
=
立即阻断
```

而是类似：

```
规则A +2
规则B +3
规则C +1
---------------
总风险 6
```

超过某个阈值后：

```
记录日志
限速
挑战
阻断
```

这种模式的优点：

```
多个弱信号可以组合
```

降低对单个规则的依赖。

### 8.5 WAF 的正确定位

错误理解：

```
部署WAF
=
应用代码已经安全
```

正确结构：

```
Internet
    ↓
WAF
    ↓
HTTP输入检查
    ↓
业务验证
    ↓
参数化 / 编码 / 安全API
    ↓
最小权限
    ↓
数据库 / 文件系统
```

即：

```
Defense in Depth
纵深防御
```

所以：

```
WAF = 辅助防线
```

而不是：

```
WAF = 源码漏洞修复
```

## 9. Web 应用安全自检流程

完整安全自检流程：

```
资产梳理
   ↓
源码审计
   ↓
黑盒防御验证
   ↓
权限与部署检查
   ↓
上线前检查
   ↓
持续日志监控
```

### 9.1 第一阶段：资产梳理

首先整理应用所有输入入口：

```
GET
POST
JSON API
Cookie
Header
URL Path
WebSocket
文件上传
登录接口
后台管理
Webhook
第三方回调
定时任务
```

然后整理技术栈：

```
PHP / Python版本
Web框架
Nginx / Apache
数据库
Redis
消息队列
ORM
第三方依赖
Docker
操作系统
WAF
CDN
```

最终得到：

```
攻击面 / 输入面清单
```

### 9.2 第二阶段：源码审计

#### SQL Sink

搜索：

```
query(
execute(
raw(
cursor.execute
PDO::query
mysqli_query
```

然后检查附近有没有：

```
+
format
sprintf
f-string
%
字符串插值
```

核心问题：

```
用户数据是否进入SQL结构？
```

#### 文件 Sink

搜索：

```
move_uploaded_file
file_put_contents
open(
write(
save(
rename(
copy(
```

检查：

```
文件名是否用户可控
路径是否用户可控
扩展名是否验证
MIME是否服务器检测
文件大小是否限制
目录是否在WebRoot
目录是否可执行
```

#### 代码执行 Sink

PHP：

```
eval
system
exec
shell_exec
passthru
proc_open
```

Python：

```
eval
exec
os.system
subprocess
```

发现后继续：

```
Source
 ↓
Data Flow
 ↓
Sink
```

#### 反序列化 Sink

PHP：

```
unserialize
```

Python：

```
pickle.loads
yaml.load
```

继续问：

```
数据来自哪里？
为什么必须使用这种格式？
是否可以使用JSON？
```

#### XSS Sink

重点搜索：

```
safe
raw
Markup
innerHTML
直接拼HTML
关闭autoescape
```

然后检查：

```
用户数据最终进入哪个输出上下文？
```

### 9.3 第三阶段：黑盒防御验证

这里的目标：

```
验证安全控制
```

而不是：

```
追求攻击利用
```

#### SQL 自查

可以测试：

```
普通字符串
合法特殊字符文本
超长文本
错误数据类型
```

例如合法姓名：

```
O'Reilly
```

可以检查程序是否：

```
HTTP 500
数据库错误
返回结构异常
日志出现数据库异常
```

如果普通合法输入都能触发 SQL 错误：

```
应该立即检查SQL构造代码
```

#### 文件上传自查

测试：

```
正常图片
空文件
超大文件
未知扩展名
扩展名与MIME不一致
重复文件名
Unicode文件名
```

检查：

```
异常文件是否拒绝
文件是否随机重命名
是否保存在WebRoot外
下载时是否检查权限
```

#### XSS 自查

可以使用完全无害的标记：

```
<TEST_MARKER>
```

观察页面是否：

```
把它显示为普通文本
```

而不是：

```
解释成HTML结构
```

无需执行任何 JavaScript。

#### 代码执行自查

检查：

```
是否存在shell=True
是否存在用户数据进入system()
是否存在用户数据进入eval()
是否使用固定程序
是否使用allowlist
```

不需要真正执行系统命令。

#### 反序列化自查

检查接口有没有接受：

```
pickle
PHP serialize对象
Unsafe YAML
```

如果存在：

```
优先改成JSON
```

### 9.4 第四阶段：权限与部署检查

检查：

```
数据库账户是否最小权限
Web用户能否修改程序目录
上传目录是否可执行
数据库是否暴露公网
Redis是否暴露公网
Secret是否硬编码
Debug是否关闭
错误页面是否泄漏Stack Trace
日志是否记录明文密码
管理员接口是否权限隔离
备份文件是否安全保存
```

### 9.5 第五阶段：上线前安全检查

```
[ ] SQL全部使用参数化

[ ] 动态表名、列名、排序字段使用allowlist

[ ] 上传限制扩展名

[ ] 上传进行服务器端MIME检测

[ ] 上传限制文件大小

[ ] 上传使用服务器生成文件名

[ ] 上传目录位于WebRoot之外

[ ] 上传目录不可执行

[ ] 下载文件重新执行权限验证

[ ] 不存在用户可控eval

[ ] 不存在用户可控exec

[ ] 不存在用户可控Shell字符串

[ ] 外部程序优先使用shell=False

[ ] 不接受客户端pickle

[ ] 不接受客户端PHP原生对象序列化

[ ] JSON进行Schema和业务校验

[ ] 模板自动转义保持开启

[ ] 用户内容按照输出上下文编码

[ ] 富文本经过成熟Sanitizer

[ ] 配置合理CSP

[ ] Cookie启用HttpOnly

[ ] Cookie启用Secure

[ ] Cookie配置SameSite

[ ] 生产Debug关闭

[ ] 数据库使用最小权限账户

[ ] 文件系统使用最小权限

[ ] Secret没有提交进Git

[ ] 依赖漏洞扫描完成

[ ] SAST静态检查完成

[ ] Staging安全验证完成

[ ] WAF规则完成验证

[ ] 安全日志能够正常记录

[ ] 数据备份与恢复测试完成
```

## 10. 本地 Web 安全实验环境

### 10.1 推荐架构

推荐学习环境：

```
Windows
   ↓
WSL2 Ubuntu
   ↓
Docker
   ↓
Docker Compose
```

Web 实验结构：

```
Browser
   │
   │ 127.0.0.1:8080
   ↓
Nginx
   │
   ├──── PHP App
   │
   └──── Python App
             │
             ↓
          Database
```

推荐组件：

```
Nginx
PHP-FPM
Flask
MySQL / PostgreSQL
Docker
Docker Compose
```

### 10.2 Docker 网络原则

建立单独实验网络：

```
security_lab
```

Web 服务只暴露给本机：

```
127.0.0.1:8080
```

数据库：

```
只允许Docker内部访问
```

尽量避免实验数据库直接绑定：

```
0.0.0.0:3306
```

网络结构：

```
宿主机浏览器
      ↓
127.0.0.1
      ↓
Web Container
      ↓
Docker Internal Network
      ↓
Database
```

### 10.3 日志设计

实验环境建议记录：

```
timestamp
request_id
remote_ip
method
path
status
duration
content_type
content_length
user_id
security_event
```

不要直接记录：

```
用户密码
Session Token
Authorization Header
完整Cookie
银行卡数据
私钥
API Secret
```

### 10.4 Request ID

给每个 HTTP 请求生成：

```
request_id
```

例如：

```
HTTP Request
     │
     └── request_id = abc123
              │
              ├── Nginx日志
              │
              ├── PHP日志
              │
              ├── Python日志
              │
              └── Database日志
```

以后研究：

```
用户输入
   ↓
应用处理
   ↓
SQL / 文件系统
   ↓
HTTP Response
```

会非常方便。

### 10.5 正确实验方式

#### 第一步：构建本地错误代码

只在自己的实验环境中创建：

```
Source
 ↓
错误的数据处理
 ↓
Sink
```

目的是：

```
理解漏洞为什么产生
```

#### 第二步：记录正常行为

观察：

```
HTTP状态
响应长度
程序日志
数据库日志
文件变化
```

#### 第三步：修改安全代码

例如：

```
字符串SQL
→
参数化SQL
```

或：

```
WebRoot上传
→
隔离目录
```

#### 第四步：重复相同测试

重新输入：

```
相同正常数据
相同边界数据
```

#### 第五步：比较修复前后

```
修复前
vs
修复后
```

真正需要理解：

> **为什么修复以后，用户数据无法再跨越数据与代码的边界？**

## 11. 开发人员最容易踩的 8 个安全误区

### 11.1 过滤特殊字符就能防 SQL 注入

错误：

```
过滤
≠
SQL参数化
```

正确：

```
业务校验
+
SQL参数化
```

过滤解决：

```
输入是否符合业务
```

参数化解决：

```
数据是否可以改变SQL结构
```

### 11.2 文件扩展名正确就是安全文件

错误。

文件上传还需要考虑：

```
扩展名
MIME
真实内容
大小
文件名
保存目录
访问权限
执行权限
```

正确：

```
多层验证
+
隔离存储
```

### 11.3 Shell 参数经过 replace 就安全

错误。

正确优先级：

```
不要调用Shell
   ↓
使用语言API
   ↓
如果必须调用外部程序
   ↓
固定程序 + 参数数组 + shell=False
```

### 11.4 数据库中的数据一定可信

错误。

可能存在：

```
用户第一次输入
     ↓
数据库保存
     ↓
后续功能读取
     ↓
进入危险Sink
```

因此：

```
数据库数据
```

需要根据：

```
原始来源
+
当前使用上下文
```

重新判断安全性。

### 11.5 使用 ORM 就绝对安全

ORM 的标准接口通常会：

```
自动参数化
```

但是需要特别关注：

```
Raw SQL
动态ORDER BY
动态表名
动态列名
SQL Fragment
```

因此：

```
ORM
=
减少风险
```

而不是：

```
ORM
=
自动消除所有SQL问题
```

### 11.6 CSP 可以完全解决 XSS

错误。

CSP 更适合定位为：

```
纵深防御
```

XSS 的核心防线仍然是：

```
模板自动转义
+
正确上下文编码
+
HTML Sanitization
```

### 11.7 WAF 没报警就没有漏洞

错误。

WAF 很难完全理解：

```
业务逻辑
数据库关系
ORM
后端二次处理
权限关系
应用状态
```

所以：

```
WAF
≠
代码安全证明
```

### 11.8 内部系统不需要安全设计

错误。

内部系统通常具有：

```
更高数据库权限
更多内部信息
更多管理接口
更高系统权限
```

因此同样应该遵守：

```
Zero Trust Input
```

即：

```
外部数据默认不可信
```

## 12. 长期可持续的安全开发规范

### 12.1 安全开发生命周期

推荐：

```
需求分析
   ↓
Threat Modeling
   ↓
安全设计
   ↓
编码
   ↓
Code Review
   ↓
SAST
   ↓
Dependency Scan
   ↓
Secret Scan
   ↓
Unit Test
   ↓
Security Test
   ↓
Staging
   ↓
DAST
   ↓
Production
   ↓
Logging
   ↓
Monitoring
   ↓
Patch Management
```

安全不能只发生在：

```
上线前一天
```

而应该贯穿：

```
整个软件生命周期
```

### 12.2 Code Review 三问

每发现一个危险 Sink，都问下面三个问题。

#### 第一问：输入来自哪里？

```
Source是什么？
```

例如：

```
GET
POST
JSON
Cookie
数据库
第三方API
```

#### 第二问：经过了什么安全处理？

例如：

```
参数化？
Allowlist？
类型验证？
长度限制？
输出编码？
文件隔离？
```

#### 第三问：为什么必须使用这个危险 API？

例如发现：

```
system()
eval()
pickle.loads()
```

先问：

```
这个功能真的必须这么实现吗？
```

很多时候：

```
取消危险设计
```

比：

```
增加过滤
```

更加可靠。

### 12.3 Source → Sink 审计方法

固定流程：

```
第一步：找Source
        ↓
GET / POST / Cookie / JSON / File

第二步：追踪Data Flow
        ↓
变量 / 函数 / 数据库

第三步：寻找Sink
        ↓
SQL / Shell / File / HTML / Deserialize

第四步：检查Validation
        ↓
参数化？
Allowlist？
编码？
类型验证？
隔离？

第五步：判断边界
        ↓
用户能否改变程序原本语义？

第六步：进行安全修复
        ↓
从结构上消除数据与代码混淆
```

## 13. PHP 安全代码模板

下面是一套适合作为学习参考的 PHP 安全代码骨架。

```
<?php

declare(strict_types=1);


/*
|--------------------------------------------------------------------------
| 1. 数据库连接
|--------------------------------------------------------------------------
*/

$pdo = new PDO(
    'mysql:host=db;dbname=app;charset=utf8mb4',
    getenv('DB_USER'),
    getenv('DB_PASSWORD'),
    [
        PDO::ATTR_ERRMODE =>
            PDO::ERRMODE_EXCEPTION,

        PDO::ATTR_DEFAULT_FETCH_MODE =>
            PDO::FETCH_ASSOC,

        PDO::ATTR_EMULATE_PREPARES =>
            false,
    ]
);


/*
|--------------------------------------------------------------------------
| 2. SQL参数化查询
|--------------------------------------------------------------------------
*/

function findUser(
    PDO $pdo,
    int $userId
): ?array {

    $stmt = $pdo->prepare(
        'SELECT id, username
         FROM users
         WHERE id = :id'
    );

    $stmt->execute([
        ':id' => $userId
    ]);

    $row = $stmt->fetch();

    return $row ?: null;
}


/*
|--------------------------------------------------------------------------
| 3. 动态SQL结构使用Allowlist
|--------------------------------------------------------------------------
*/

function getSortColumn(
    string $input
): string {

    $allowed = [
        'name' =>
            'username',

        'time' =>
            'created_at',

        'id' =>
            'id',
    ];

    if (
        !isset(
            $allowed[$input]
        )
    ) {
        throw new InvalidArgumentException(
            'invalid sort field'
        );
    }

    return $allowed[$input];
}


/*
|--------------------------------------------------------------------------
| 4. HTML安全输出
|--------------------------------------------------------------------------
*/

function h(
    string $value
): string {

    return htmlspecialchars(
        $value,
        ENT_QUOTES | ENT_SUBSTITUTE,
        'UTF-8'
    );
}


/*
|--------------------------------------------------------------------------
| 5. JSON输入解析
|--------------------------------------------------------------------------
*/

function parseJsonBody(): array
{
    $raw = file_get_contents(
        'php://input'
    );

    if (strlen($raw) > 65536) {
        throw new RuntimeException(
            'request too large'
        );
    }

    $data = json_decode(
        $raw,
        true,
        32,
        JSON_THROW_ON_ERROR
    );

    if (!is_array($data)) {
        throw new RuntimeException(
            'invalid json structure'
        );
    }

    return $data;
}


/*
|--------------------------------------------------------------------------
| 6. 安全文件上传
|--------------------------------------------------------------------------
*/

function saveUpload(
    array $file
): string {

    $uploadDir =
        '/srv/app-data/uploads/';

    /*
     * 检查上传状态。
     */
    if (
        !isset($file['error']) ||
        $file['error'] !== UPLOAD_ERR_OK
    ) {
        throw new RuntimeException(
            'upload failed'
        );
    }

    /*
     * 最大5MB。
     */
    if (
        !isset($file['size']) ||
        $file['size'] > 5 * 1024 * 1024
    ) {
        throw new RuntimeException(
            'file too large'
        );
    }

    /*
     * 获取扩展名。
     */
    $extension = strtolower(
        pathinfo(
            (string)$file['name'],
            PATHINFO_EXTENSION
        )
    );

    /*
     * 严格Allowlist。
     */
    $allowed = [
        'png' =>
            'image/png',

        'jpg' =>
            'image/jpeg',

        'jpeg' =>
            'image/jpeg',
    ];

    if (
        !isset(
            $allowed[$extension]
        )
    ) {
        throw new RuntimeException(
            'unsupported extension'
        );
    }

    /*
     * 使用服务端Fileinfo检测。
     *
     * 不相信客户端Content-Type。
     */
    $finfo = new finfo(
        FILEINFO_MIME_TYPE
    );

    $mime = $finfo->file(
        $file['tmp_name']
    );

    if (
        $mime !==
        $allowed[$extension]
    ) {
        throw new RuntimeException(
            'invalid file content'
        );
    }

    /*
     * 不使用客户端原始文件名作为磁盘文件名。
     */
    $filename =
        bin2hex(
            random_bytes(16)
        )
        . '.'
        . $extension;

    $destination =
        $uploadDir
        . $filename;

    if (
        !move_uploaded_file(
            $file['tmp_name'],
            $destination
        )
    ) {
        throw new RuntimeException(
            'cannot store file'
        );
    }

    return $filename;
}


/*
|--------------------------------------------------------------------------
| 7. 动态执行安全规范
|--------------------------------------------------------------------------
|
| 不允许用户输入直接进入：
|
| eval()
| system()
| exec()
| shell_exec()
| passthru()
|
| 优先使用PHP API或成熟库完成业务。
|
*/


/*
|--------------------------------------------------------------------------
| 8. Security Headers
|--------------------------------------------------------------------------
*/

header(
    'X-Content-Type-Options: nosniff'
);

header(
    'Referrer-Policy: strict-origin-when-cross-origin'
);

header(
    "Content-Security-Policy: "
    . "default-src 'self'; "
    . "object-src 'none'; "
    . "base-uri 'self'; "
    . "frame-ancestors 'none'"
);


/*
|--------------------------------------------------------------------------
| 9. Session Cookie
|--------------------------------------------------------------------------
*/

session_set_cookie_params([
    'secure' =>
        true,

    'httponly' =>
        true,

    'samesite' =>
        'Lax',
]);


/*
|--------------------------------------------------------------------------
| 10. 错误处理原则
|--------------------------------------------------------------------------
|
| 生产环境：
|
| - 不向客户端显示数据库堆栈
| - 不显示服务器绝对路径
| - 不显示Secret
| - 详细错误记录到服务器日志
|
*/
```

## 14. Python Flask 安全代码模板

下面是一套经过整理的 Python Flask 示例骨架。

```
from __future__ import annotations

import json
import secrets
import sqlite3
import subprocess

from pathlib import Path

from flask import (
    Flask,
    abort,
    jsonify,
    render_template,
    request,
)


app = Flask(__name__)


# ==========================================================
# 1. 基础安全配置
# ==========================================================

app.config.update(
    MAX_CONTENT_LENGTH=5 * 1024 * 1024,
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SAMESITE="Lax",
)


DATABASE = Path(
    "/srv/app-data/app.db"
)

UPLOAD_DIR = Path(
    "/srv/app-data/uploads"
)

UPLOAD_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


# ==========================================================
# 2. 数据库连接
# ==========================================================

def get_db():
    return sqlite3.connect(
        DATABASE
    )


# ==========================================================
# 3. SQL参数化
# ==========================================================

def find_user(
    user_id: int,
):

    with get_db() as db:

        cursor = db.execute(
            """
            SELECT
                id,
                username
            FROM users
            WHERE id = ?
            """,
            (user_id,),
        )

        return cursor.fetchone()


# ==========================================================
# 4. 动态SQL结构Allowlist
# ==========================================================

SORT_COLUMNS = {
    "name": "username",
    "id": "id",
    "time": "created_at",
}


def get_sort_column(
    user_value: str,
) -> str:

    try:
        return SORT_COLUMNS[
            user_value
        ]

    except KeyError as exc:

        raise ValueError(
            "invalid sort"
        ) from exc


# ==========================================================
# 5. JSON输入
# ==========================================================

def get_json_body() -> dict:

    if (
        request.content_length
        and
        request.content_length
        > 64 * 1024
    ):
        abort(413)

    data = request.get_json(
        silent=True
    )

    if not isinstance(
        data,
        dict
    ):
        abort(400)

    return data


# ==========================================================
# 6. JSON代替Pickle
# ==========================================================

def parse_client_data(
    raw: bytes,
) -> dict:

    if len(raw) > 65536:
        raise ValueError(
            "payload too large"
        )

    try:
        data = json.loads(
            raw.decode("utf-8")
        )

    except (
        UnicodeDecodeError,
        json.JSONDecodeError,
    ) as exc:

        raise ValueError(
            "invalid json"
        ) from exc

    if not isinstance(
        data,
        dict
    ):
        raise ValueError(
            "invalid structure"
        )

    return data


# ==========================================================
# 7. 文件上传
# ==========================================================

ALLOWED_UPLOADS = {
    ".png": {
        "image/png"
    },

    ".jpg": {
        "image/jpeg"
    },

    ".jpeg": {
        "image/jpeg"
    },
}


def save_upload(
    file,
) -> str:

    import magic

    original = Path(
        file.filename or ""
    )

    extension = (
        original
        .suffix
        .lower()
    )

    if (
        extension
        not in ALLOWED_UPLOADS
    ):
        raise ValueError(
            "unsupported extension"
        )

    # 读取少量文件头，用于服务端类型识别。
    header = file.stream.read(
        8192
    )

    file.stream.seek(0)

    mime = magic.from_buffer(
        header,
        mime=True
    )

    if (
        mime
        not in
        ALLOWED_UPLOADS[
            extension
        ]
    ):
        raise ValueError(
            "file type mismatch"
        )

    # 服务器生成随机磁盘文件名。
    filename = (
        secrets.token_hex(16)
        + extension
    )

    destination = (
        UPLOAD_DIR
        / filename
    )

    file.save(
        destination
    )

    return filename


# ==========================================================
# 8. 外部程序安全调用
# ==========================================================

def run_fixed_tool(
    file_id: str,
):

    """
    如果业务必须启动外部程序：

    1. 可执行程序路径固定
    2. shell=False
    3. 参数通过列表分离
    4. 输入执行严格业务验证
    5. 设置执行超时
    """

    if not file_id.isalnum():
        raise ValueError(
            "invalid file id"
        )

    subprocess.run(
        [
            "/usr/bin/fixed-tool",
            file_id,
        ],
        shell=False,
        check=True,
        timeout=10,
    )


# ==========================================================
# 9. XSS安全模板
# ==========================================================

@app.get("/hello")
def hello():

    name = request.args.get(
        "name",
        "",
    )

    # Jinja默认进行HTML自动转义。
    #
    # hello.html:
    #
    # <h1>Hello {{ name }}</h1>
    #
    # 不要无理由使用：
    #
    # {{ name|safe }}

    return render_template(
        "hello.html",
        name=name,
    )


# ==========================================================
# 10. HTTP安全响应头
# ==========================================================

@app.after_request
def security_headers(
    response,
):

    response.headers[
        "X-Content-Type-Options"
    ] = "nosniff"

    response.headers[
        "Referrer-Policy"
    ] = (
        "strict-origin-when-cross-origin"
    )

    response.headers[
        "Content-Security-Policy"
    ] = (
        "default-src 'self'; "
        "object-src 'none'; "
        "base-uri 'self'; "
        "frame-ancestors 'none'"
    )

    return response


# ==========================================================
# 11. API示例
# ==========================================================

@app.get("/user")
def user():

    user_id = request.args.get(
        "id",
        type=int,
    )

    if user_id is None:

        return jsonify(
            error="invalid id"
        ), 400

    result = find_user(
        user_id
    )

    if result is None:

        return jsonify(
            error="not found"
        ), 404

    return jsonify(
        id=result[0],
        username=result[1],
    )


# ==========================================================
# 12. 本地实验启动
# ==========================================================

if __name__ == "__main__":

    # 仅用于本地学习实验。
    #
    # 生产环境：
    #
    # - 不使用Flask开发服务器
    # - 不开启Debug
    # - 使用正规的WSGI服务器
    # - 配置TLS和反向代理

    app.run(
        host="127.0.0.1",
        port=5000,
        debug=False,
    )
```

## 15. Web 源码审计速查表

| 看到的代码        | 第一反应                     |
| ----------------- | ---------------------------- |
| SQL + 用户变量    | 是否使用参数化？             |
| f-string SQL      | 用户数据是否进入 SQL 结构？  |
| 动态 ORDER BY     | 是否严格 allowlist？         |
| 动态表名/列名     | 是否通过程序白名单映射？     |
| 文件名 + 用户输入 | 是否存在路径或上传风险？     |
| 上传到 static/www | Web 是否能够直接访问？       |
| `eval()`          | 为什么需要动态执行？         |
| `exec()`          | 用户数据是否能够到达？       |
| `system()`        | 为什么必须使用 Shell？       |
| `shell=True`      | 是否可以改为 `shell=False`？ |
| `unserialize()`   | 数据是否来自外部？           |
| `pickle.loads()`  | 为什么不用 JSON？            |
| `yaml.load()`     | Loader 是否安全？            |
| `safe/raw`        | 为什么关闭自动转义？         |
| HTML + 用户变量   | 是否根据上下文编码？         |
| `innerHTML`       | 数据是否可信？               |
| 大量 `replace()`  | 是否在用黑名单代替安全 API？ |
| 数据库高权限账户  | 能否降低权限？               |
| Debug 开启        | 是否可能泄漏敏感信息？       |
| Secret 写进源码   | 是否应该移动到安全配置？     |

## 16. 最终安全模型

整个 Web 安全开发可以压缩成：

```
不可信输入
    ↓
明确业务验证
    ↓
保持“数据”身份
    ↓
安全API
    │
    ├── SQL参数绑定
    ├── HTML输出编码
    ├── 文件隔离
    ├── JSON Schema
    └── shell=False
    ↓
最小权限
    ↓
纵深防御
    │
    ├── WAF
    ├── CSP
    ├── Security Headers
    ├── Logging
    └── Monitoring
```

最重要的一句话：

> **安全开发的目标不是识别所有恶意字符串，而是从程序结构上保证：无论用户输入什么，它都无法从“数据”变成“代码”。**

## 17. 推荐源码审计思维

以后拿到一个 PHP 或 Python Web 项目，可以按照下面顺序审计。

### 17.1 第一步：找 Source

```
GET
POST
Cookie
JSON
Header
File
WebSocket
Database
Third-party API
```

先确认：

```
哪些数据可以受到用户影响？
```

### 17.2 第二步：追踪 Data Flow

```
用户输入
 ↓
变量
 ↓
函数参数
 ↓
数据库
 ↓
另外一个函数
 ↓
Sink
```

不要只看：

```
当前这一行
```

还要理解：

```
数据完整生命周期
```

### 17.3 第三步：寻找 Sink

重点关注：

```
SQL
Shell
File
HTML
Deserialize
Template
Network
```

### 17.4 第四步：检查 Validation

问：

```
有没有参数化？
有没有Allowlist？
有没有类型检查？
有没有长度限制？
有没有输出编码？
有没有文件隔离？
```

注意：

```
Validation
```

不是单纯：

```
过滤危险字符
```

### 17.5 第五步：判断数据边界

问：

> **用户是否能够改变程序原本应该执行的语义？**

例如本来：

```
用户只应该提供一个用户名
```

如果输入能够影响：

```
SQL结构
```

那么边界出现问题。

本来：

```
用户只应该上传图片数据
```

如果文件最终可以被：

```
服务器当程序处理
```

边界也出现问题。

### 17.6 第六步：进行安全修复

不要优先思考：

```
还能增加哪些黑名单？
```

而应该优先思考：

```
能否从程序结构上取消危险解释过程？
```

例如：

```
动态SQL
→
参数化
Shell字符串
→
安全API
pickle
→
JSON
用户文件名
→
服务器随机文件名
动态HTML
→
模板自动转义
```

### 17.7 最终审计公式

最终记住：

```
Source
   ↓
Data Flow
   ↓
Validation
   ↓
Sink
```

对应四个问题：

```
Source：
数据从哪里来？

Data Flow：
数据经过哪里？

Validation：
中间进行了什么安全控制？

Sink：
最后由谁解释或执行？
```

这套模型可以继续扩展到：

```
SQL注入
文件上传
代码执行
反序列化
XSS
路径遍历
文件包含
SSRF
XXE
模板注入
以及其他Web安全问题
```

## 18. 全文总结

Web 安全源码审计最重要的思维并不是：

```
背Payload
```

也不是：

```
背危险字符串
```

而是：

```
找到用户输入
      ↓
追踪数据流
      ↓
找到危险Sink
      ↓
检查安全边界
      ↓
理解漏洞形成原因
      ↓
从代码结构进行修复
```

以后看到任何 Web 代码，可以先问五个问题：

1. **数据从哪里来？**
2. **用户可以控制多少？**
3. **数据中间经过了哪些处理？**
4. **数据最终进入哪个 Sink？**
5. **程序如何保证数据永远只是数据，而不会成为代码？**

如果这五个问题能够逐渐回答清楚，就已经开始真正建立 **Web 源码审计与漏洞防御** 的分析思维。