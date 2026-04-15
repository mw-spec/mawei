---
title: "Data URI Scheme (data: 协议)"
date: 2026-04-15
draft: false
categories: ["web笔记"]
---

## 1. 协议概述

`data:` 协议允许开发者在网页中直接嵌入小型数据，而不是引用外部资源。它将资源转换为字符串形式，随 HTML/CSS 一起下载。

## 2. 标准语法结构

`data:` URL 的组成非常严谨，公式如下：

> **`data:[<mediatype>][;base64],<data>`**

| **组成部分**      | **说明**                                                     | **示例**                     |
| ----------------- | ------------------------------------------------------------ | ---------------------------- |
| **`data:`**       | 协议前缀（必须）。                                           | `data:`                      |
| **`<mediatype>`** | MIME 类型，标识数据种类。缺省默认为 `text/plain;charset=US-ASCII`。 | `image/png`, `text/html`     |
| **`;base64`**     | 可选。标识数据是否经过 Base64 编码。二进制数据通常必须使用。 | `;base64`                    |
| **`<data>`**      | 实际内容。Base64 字符串或经过 URL 编码的文本。               | `iVBORw...` 或 `%3Ch1%3E...` |

------

## 3. 常见应用场景

### 3.1 嵌入图片 (Base64)

常用于小图标（Icons）以减少 HTTP 请求数。

HTML

```
<img src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==" alt="Red dot">
```

### 3.2 嵌入 SVG (URL 编码)

SVG 是文本格式，通常不使用 Base64，直接对特殊字符进行转义（如 `#` 变为 `%23`）效率更高。

HTML

```
<div style="background-image: url(&quot;data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10'%3E%3Ccircle cx='5' cy='5' r='5' fill='red'/%3E%3C/svg%3E&quot;);"></div>
```

### 3.3 嵌入 HTML

可用于测试或在 `iframe` 中快速加载内容。

Plaintext

```
data:text/html;charset=utf-8,<h1>Hello!</h1><p>This is a data URI page.</p>
```

------

## 4. 核心优缺点对比

### ✅ 优点

1. **减少 HTTP 请求**：合并小资源到主文档，减少 TCP 握手开销。
2. **离线可用**：整个页面是一个独立的文件，不依赖外部服务器上的图片。
3. **解决跨域**：在某些 Canvas 绘图场景下，可以避免跨域图片污染画布的问题。

### ❌ 缺点

1. **体积膨胀**：Base64 编码会使原始二进制数据体积增加约 **33%**。
2. **浏览器缓存失效**：数据随 HTML 加载，无法像独立资源那样被浏览器单独缓存。
3. **阻塞渲染**：若在 CSS 中嵌入过大的 Data URI，会显著延迟页面的首次渲染（First Paint）。
4. **安全隐患**：容易被利用进行 XSS 注入，现代 CSP（内容安全策略）常对其进行限制。

------

## 5. 开发建议与技巧

- **大小限制**：建议仅对 **4KB** 以下的资源使用 Data URI。
- **编码工具**：可以使用 Linux 命令 `base64` 或在线工具进行转换。
- **CSS 预处理器**：Sass/Less 有插件可以自动将小图转换为 Data URI，提高开发效率。