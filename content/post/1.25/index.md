---
title: "RDCTF"
date: 2026-01-25
draft: false
categories: ["WP"]
---

# RDCTF

## AI

### ez_pth

1. 打开文件，看到了 `ez_pth/data.pkl` ,说明里面含有一个 Pickle 序列化文件。
2. 用记事本打开，按下 **Ctrl + F**，输入 `flag` 进行查找。
3. 看到`flagqYX   RDCTF{so_ez_pth}` 。
4. 即flag为RDCTF{so_ez_pth}。

## Crypto 

### Fibonacci?Tribonacci!

1. 发现问题关键

   循环次数 n 极大（≈10⁷⁵），显然无法直接模拟：

   ```python
   for _ in range(n):
   	a, b, c = ...
   ```

   说明这是一个伪循环题，需要寻找数学结构。

2. 构造 AES Key 并解密

   题目中 AES key 的生成方式为：

   ```python
   key = md5((str(a) + str(b) + str(c)).encode()).digest()
   ```

   得到 key 后使用 AES-ECB 解密，并去除 PKCS7 padding。

3. 解题代码

   ```python
   from Crypto.Util.number import *
   from Crypto.Util.Padding import unpad
   from Crypto.Cipher import AES
   from hashlib import md5
   
   a = 114514
   b = 1919810
   c = 3502344
   
   n = 2441279589855072012185493681589677978850030233737936622124189385966876579465581965714739695219635524618006351540383392462915145232447242610170569115379
   p = 12558003803926122355192856799223219808675997425382453316279914088710915515394834253948359113075685634044322094918238512778425787825701396013393798956758721
   
   enc = bytes.fromhex(
       "3c1a9e8de775f9bf61fbb34673c44818d3522477c7f51a803de8e180e101eb00726992cc5906116801f7d8c893c28129"
   )
   
   M = [
       [0, 1, 0],
       [0, 0, 1],
       [1, 2, 3]
   ]
   
   def mat_mul(A, B):
       res = [[0]*3 for _ in range(3)]
       for i in range(3):
           for k in range(3):
               for j in range(3):
                   res[i][j] = (res[i][j] + A[i][k]*B[k][j]) % p
       return res
   
   def mat_pow(M, e):
       R = [[1 if i==j else 0 for j in range(3)] for i in range(3)]
       while e:
           if e & 1:
               R = mat_mul(R, M)
           M = mat_mul(M, M)
           e >>= 1
       return R
   
   Mn = mat_pow(M, n)
   
   a_n = (Mn[0][0]*a + Mn[0][1]*b + Mn[0][2]*c) % p
   b_n = (Mn[1][0]*a + Mn[1][1]*b + Mn[1][2]*c) % p
   c_n = (Mn[2][0]*a + Mn[2][1]*b + Mn[2][2]*c) % p
   
   key = md5((str(a_n)+str(b_n)+str(c_n)).encode()).digest()
   flag = AES.new(key, AES.MODE_ECB).decrypt(enc)
   
   print(unpad(flag, 16))
   
   ```

4. 解出flag：RDCTF{f1b0n4cc1_l1k3_m4tr1x_f4st_p0w3r1ng}。

### SignIn

1. 解题代码

   ```python
   from Crypto.Util.number import *
   
   n = 83610798024925996648722630840747741512160508464965077648771075713632110318019200478493732677123542935882911305260389877760512607737802888571342438313863571732100527920357582235174437380618197302176558064322291286593318848683606673398314867336824733065854850256295795835039309323300624958907561523898787253639
   
   c = 77329031239551747098741279001766373605032807568073411648374335618913647229622551339221811139169208870251932566758930221945464120608981930902671426680176002899986807783654758555033244967299081953242525118242614366948888146435154917839074238457570488865817546147078192396282106365527579625709133854277995299788
   
   # m ≡ c^{-1} mod n
   m = inverse(c, n)
   
   flag = long_to_bytes(m)
   print(flag)
   ```

2. 解出flag：RDCTF{N3W_Y34R_N3W_T45K}。

## misc

### Hello RDCTF

直接谷歌图片扫描解出flag：RDCTF{hello_RDCTF_I'm_coming!!!}