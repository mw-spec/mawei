---
title: "汇编语言进阶学习笔记"
date: 2026-03-08
draft: false
categories: ["笔记"]
---

------

## 栈与函数调用机制

### 栈结构

```
高地址 ↑
       |           |
       |  参数      |
       | 返回地址   |
       | 保存的 EBP |
低地址 ↓
```

- 栈由 ESP/RSP 指向栈顶
- PUSH：压入栈
- POP：弹出栈
- CALL：将返回地址压入栈
- RET：弹出返回地址并跳转

### 函数调用示例

```
; 参数通过栈传递，32位 x86
global _start

_start:
    push 5          ; 参数
    push 10         ; 参数
    call add_nums
    add esp, 8      ; 清理栈
    ; 返回值在 EAX

    mov eax, 1
    xor ebx, ebx
    int 0x80

add_nums:
    push ebp
    mov ebp, esp
    mov eax, [ebp+8] ; 参数1
    add eax, [ebp+12]; 参数2
    pop ebp
    ret
```

> 小技巧：CTF 中 stack smashing、ret overwrite、ROP 技巧都是基于栈结构的。

------

## 中断与系统调用

### x86 Linux 系统调用 (32-bit)

```
mov eax, SYS_write ; 系统调用号
mov ebx, 1         ; 文件描述符 stdout
mov ecx, msg       ; 消息地址
mov edx, len       ; 消息长度
int 0x80
```

### x86-64 Linux 系统调用

- 参数通过寄存器传递：

```
RDI, RSI, RDX, R10, R8, R9
mov rax, 1         ; sys_exit
xor rdi, rdi       ; exit code 0
syscall
```

### 常用系统调用号

| 系统调用 | x86  | x86-64 |
| -------- | ---- | ------ |
| exit     | 1    | 60     |
| write    | 4    | 1      |
| read     | 3    | 0      |
| execve   | 11   | 59     |

------

## 条件跳转与循环

- 标志位：
  - ZF（零标志）、SF（符号标志）、CF（进位标志）、OF（溢出标志）
- 条件跳转示例：

```
cmp eax, ebx
je equal_label
jne notequal_label
jg greater
jl less
```

- 循环示例：

```
mov ecx, 5
loop_start:
    ; do something
    loop loop_start  ; 自动 dec ecx, jnz
```

> CTF 逆向中，判断条件通常通过 cmp + j* 指令实现。

------

## 字符串与内存操作

### 字符串指令

- `MOVSB` / `MOVSW` / `MOVSD`：复制字节/字/双字
- `STOSB` / `STOSD`：将 AL/EAX 存入内存
- `LODSB` / `LODSD`：加载 AL/EAX 从内存

### 内存扫描技巧

- 可以通过 REP 指令实现批量操作

```
rep movsb ; 将 ECX 个字节从 [ESI] 复制到 [EDI]
```

------

## Shellcode 编写基础

### Shellcode 特性

- 无 NULL 字节（避免字符串结束）
- 精简指令
- 常见功能：
  - execve("/bin/sh")
  - bind shell / reverse shell
  - read / write 文件

### 简单 32-bit Linux shellcode 示例

```
section .text
global _start

_start:
    xor eax, eax
    push eax
    push 0x68732f2f ; //sh
    push 0x6e69622f ; /bin
    mov ebx, esp
    push eax
    push ebx
    mov ecx, esp
    xor edx, edx
    mov al, 11       ; sys_execve
    int 0x80
```

------

## 寄存器状态与标志位

- EFLAGS 标志位：
  - CF：进位
  - ZF：零
  - SF：符号
  - OF：溢出
- 寄存器常用分工：
  - EAX：返回值
  - EBX/ECX/EDX：参数/临时
  - EBP/ESP：栈管理

------

## 常见反汇编技巧

1. **函数入口识别**
   - `push ebp / mov ebp, esp` → 函数开始
2. **循环识别**
   - `dec/jnz` 或 `cmp/j*` → 循环结构
3. **系统调用识别**
   - `mov eax, sys_XXX / int 0x80` 或 `syscall`
4. **字符串/数据引用**
   - `[ebp+X]` 或 `[esp+X]` → 参数
   - `[label]` → 全局变量/数据段

------

## 调试技巧

- 使用 GDB
  - `break main`：设置断点
  - `disas`：查看汇编
  - `x/s address`：查看字符串
  - `info registers`：查看寄存器
- 观察 ESP/EBP，分析栈帧
- 在 CTF 中常结合 pwntools 自动化调试

------

## 常用 CTF 汇编套路

1. **栈溢出**
   - 利用 `ret` 地址覆盖，ROP 链
2. **格式化字符串漏洞**
   - `%x`, `%n` → 内存读写
3. **shellcode 注入**
   - 精简无 NULL 字节
   - 可直接写入栈或 heap 执行
4. **函数跳转分析**
   - 找到关键函数调用 → 解密/解码
5. **循环/条件逆向**
   - cmp + j* 组合 → 分析逻辑
