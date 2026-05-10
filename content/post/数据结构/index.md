---
title: "苏北编程竞赛联盟OJ"
date: 2026-05-10
draft: false
categories: ["数据结构"]
---

### 问题 DQ: 栈模拟

```c++
#include <iostream>
#include <string>
using namespace std;

const int MAXN = 1000005;
unsigned long long st[MAXN];
int top_idx = 0;

void stack_init() {
    top_idx = 0;
}

void stack_push(unsigned long long x) {
    st[++top_idx] = x;
}

void stack_pop() {
    if (top_idx == 0) {
        cout << "Empty\n";
    } else {
        top_idx--;
    }
}

void stack_query() {
    if (top_idx == 0) {
        cout << "Anguei!\n";
    } else {
        cout << st[top_idx] << "\n";
    }
}

void stack_size() {
    cout << top_idx << "\n";
}

void solve() {
    int n;
    cin >> n;
    stack_init();
    string op;
    unsigned long long x;
    while (n--) {
        cin >> op;
        if (op == "push") {
            cin >> x;
            stack_push(x);
        } else if (op == "pop") {
            stack_pop();
        } else if (op == "query") {
            stack_query();
        } else if (op == "size") {
            stack_size();
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    int t;
    if (cin >> t) {
        while (t--) {
            solve();
        }
    }
    return 0;
}
```

### 问题 DR: 一查到底

```c++
#include <iostream>
using namespace std;

const int MAXN = 105;
int st[MAXN];
int top_idx = 0;

void stack_push(int x) {
    st[++top_idx] = x;
}

void stack_pop_until(int x) {
    int count = 0;
    while (top_idx > 0) {
        int val = st[top_idx];
        top_idx--;
        count++;
        if (val == x) {
            break;
        }
    }
    cout << count << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    
    int n;
    if (cin >> n) {
        while (n--) {
            int opt, x;
            cin >> opt >> x;
            if (opt == 1) {
                stack_push(x);
            } else if (opt == 2) {
                stack_pop_until(x);
            }
        }
    }
    
    return 0;
}
```

### 问题 DS: 表达式括号匹配

```c++
#include <iostream>
#include <string>
using namespace std;

int main() {
    char ch;
    int balance = 0;
    
    while (cin >> ch) {
        if (ch == '@') {
            break;
        }
        if (ch == '(') {
            balance++;
        } else if (ch == ')') {
            balance--;
            if (balance < 0) {
                cout << "NO\n";
                return 0;
            }
        }
    }
    
    if (balance == 0) {
        cout << "YES\n";
    } else {
        cout << "NO\n";
    }
    
    return 0;
}
```

### 问题 DT: 字符串消消乐

```c++
#include <iostream>
#include <string>
using namespace std;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    
    string s;
    if (cin >> s) {
        string st;
        st.reserve(s.size());
        
        for (char ch : s) {
            if (!st.empty() && (st.back() ^ ch) == 32) {
                st.pop_back();
            } else {
                st.push_back(ch);
            }
        }
        
        cout << st << "\n";
    }
    
    return 0;
}
```

### 问题 DU: 溶液模拟器

```c++
#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
using namespace std;

struct State {
    double v;
    double c;
};

vector<State> history;

void init(double v, double c) {
    history.push_back({v, c});
}

void push_solution(double v, double c) {
    State cur = history.back();
    double total_v = cur.v + v;
    double total_c = (cur.v * cur.c + v * c) / total_v;
    history.push_back({total_v, total_c});
}

void pop_solution() {
    if (history.size() > 1) {
        history.pop_back();
    }
}

void print_current() {
    State cur = history.back();
    cout << (long long)cur.v << " " << fixed << setprecision(5) << cur.c << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    double v0, c0;
    int n;
    
    if (cin >> v0 >> c0) {
        init(v0, c0);
        cin >> n;
        while (n--) {
            string op;
            cin >> op;
            if (op == "P") {
                double v, c;
                cin >> v >> c;
                push_solution(v, c);
            } else if (op == "Z") {
                pop_solution();
            }
            print_current();
        }
    }

    return 0;
}
```

### 问题 DV: 出栈序列操作

```c++
#include <iostream>
#include <vector>
using namespace std;

const int MAXN = 100005;
int target[MAXN];
int st[MAXN];
int top_idx = 0;

void solve() {
    int n;
    if (!(cin >> n)) return;

    for (int i = 0; i < n; ++i) {
        cin >> target[i];
    }

    int current_push = 1;
    int target_ptr = 0;

    for (int i = 0; i < n * 2; ++i) {
        if (top_idx > 0 && st[top_idx] == target[target_ptr]) {
            cout << "pop\n";
            top_idx--;
            target_ptr++;
        } else if (current_push <= n) {
            cout << "push " << current_push << "\n";
            st[++top_idx] = current_push;
            current_push++;
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    solve();

    return 0;
}
```

### 问题 DW: 车厢调度

```c++
#include <iostream>
using namespace std;

const int MAXN = 1005;
int target[MAXN];
int st[MAXN];
int top_idx = 0;

void solve() {
    int n;
    if (!(cin >> n)) return;

    for (int i = 0; i < n; ++i) {
        cin >> target[i];
    }

    top_idx = 0;
    int cur = 1;
    int ptr = 0;

    for (int i = 1; i <= n; ++i) {
        st[++top_idx] = i;
        while (top_idx > 0 && st[top_idx] == target[ptr]) {
            top_idx--;
            ptr++;
        }
    }

    if (ptr == n) {
        cout << "YES\n";
    } else {
        cout << "NO\n";
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    solve();

    return 0;
}
```

### 问题 DX: 出栈序列统计

```c++
#include <iostream>
using namespace std;

long long f[20];

long long solve(int n) {
    if (n == 0 || n == 1) return 1;
    if (f[n] > 0) return f[n];
    
    long long res = 0;
    for (int i = 0; i < n; ++i) {
        res += solve(i) * solve(n - 1 - i);
    }
    return f[n] = res;
}

int main() {
    int n;
    cin >> n;
    cout << solve(n) << endl;
    return 0;
}
```

### 问题 DY: 后缀表达式求值

```c++
#include <iostream>
#include <stack>
#include <string>
using namespace std;

stack<long long> st;

void calculate(string op) {
    long long b = st.top(); st.pop();
    long long a = st.top(); st.pop();
    
    if (op == "+") st.push(a + b);
    else if (op == "-") st.push(a - b);
    else if (op == "*") st.push(a * b);
    else if (op == "/") st.push(a / b);
}

int main() {
    string s;
    while (cin >> s && s != "@") {
        if (s == "+" || s == "-" || s == "*" || s == "/") {
            calculate(s);
        } else {
            st.push(stoll(s));
        }
    }
    
    if (!st.empty()) {
        cout << st.top() << endl;
    }
    
    return 0;
}
```

### 问题 DZ: 中缀表达式求值

```c++
#include <iostream>
#include <vector>
using namespace std;

const int MOD = 10000;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    long long num;
    char op;
    vector<int> st;

    if (cin >> num) {
        st.push_back(num % MOD);
        while (cin >> op >> num) {
            if (op == '*') {
                int last = st.back();
                st.pop_back();
                st.push_back((last * (num % MOD)) % MOD);
            } else if (op == '+') {
                st.push_back(num % MOD);
            }
        }
    }

    int ans = 0;
    for (int x : st) {
        ans = (ans + x) % MOD;
    }

    cout << ans << endl;

    return 0;
}
```

### 问题 EA: 下一个更大的数

```c++
#include <iostream>
using namespace std;

int n;
int a[200005];
int s[200005];
int r[200005];
int t = 0;

void read() {
    cin >> n;
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
}

void work() {
    for (int i = 1; i <= n; i++) {
        while (t > 0 && a[i] > a[s[t]]) {
            r[s[t]] = i;
            t--;
        }
        s[++t] = i;
    }
}

void put() {
    for (int i = 1; i <= n; i++) {
        cout << r[i] << (i == n ? "" : " ");
    }
    cout << endl;
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    read();
    work();
    put();

    return 0;
}
```

### 问题 EB: 排队

```c++
#include <iostream>
using namespace std;

int n;
int s[80005];
int t = 0;

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    if (!(cin >> n)) return 0;

    long long sum = 0;
    for (int i = 0; i < n; i++) {
        int h;
        cin >> h;

        while (t > 0 && s[t] <= h) {
            t--;
        }

        sum += t;
        s[++t] = h;
    }

    cout << sum << endl;

    return 0;
}
```

### 问题 EC: 最大矩形面积

```c++
#include <iostream>
using namespace std;

int n;
int h[1000005];
int s[1000005];
int t = 0;
long long ans = 0;

void read() {
    if (!(cin >> n)) return;
    for (int i = 1; i <= n; i++) {
        cin >> h[i];
    }
    h[n + 1] = 0;
}

void work() {
    for (int i = 1; i <= n + 1; i++) {
        while (t > 0 && h[i] < h[s[t]]) {
            int c = s[t];
            t--;
            int l = (t == 0) ? 0 : s[t];
            long long w = i - l - 1;
            long long cur = w * h[c];
            if (cur > ans) {
                ans = cur;
            }
        }
        s[++t] = i;
    }
}

void put() {
    cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    read();
    work();
    put();

    return 0;
}
```

### 问题 ED: 数对统计

```c++
#include <iostream>
using namespace std;

int n;
int a[200005];
int s[200005];
int t = 0;
long long ans = 0;

void read() {
    if (!(cin >> n)) return;
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
}

void work() {
    for (int i = 1; i <= n; i++) {
        while (t > 0 && a[i] > a[s[t]]) {
            ans++;
            t--;
        }
        if (t > 0) {
            ans++;
        }
        s[++t] = i;
    }
}

void put() {
        cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    read();
    work();
    put();

    return 0;
}
```

### 问题 EE: 队列模拟

```c++
#include <iostream>
#include <string>
using namespace std;

int m;
int q[100005];
int head = 1;
int tail = 0;

void read_and_work() {
    if (!(cin >> m)) return;
    string op;
    int x;
    while (m--) {
        cin >> op;
        if (op == "push") {
            cin >> x;
            q[++tail] = x;
        } else if (op == "pop") {
            if (head <= tail) {
                head++;
            }
        } else if (op == "query") {
            cin >> x;
            cout << q[head + x - 1] << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    read_and_work();

    return 0;
}
```

### 问题 EF: 核酸检测

```c++
#include <iostream>
#include <string>
using namespace std;

int n;
string q[105];
int h = 1;
int t = 0;

void work() {
    if (!(cin >> n)) return;
    while (n--) {
        int opt;
        cin >> opt;
        if (opt == 1) {
            string s;
            cin >> s;
            q[++t] = s;
        } else if (opt == 2) {
            int c = 0;
            bool f = true;
            while (h <= t && c < 10) {
                if (!f) cout << " ";
                cout << q[h][0];
                h++;
                c++;
                f = false;
            }
            cout << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EG: 队列练习

```c++
#include <iostream>
using namespace std;

long long q[1000005];
int head = 1;
int tail = 0;

void work() {
    long long x;
    int k;
    if (!(cin >> x >> k)) return;
    
    q[++tail] = x;
    
    while (k--) {
        long long y = q[head++];
        cout << y << "\n";
        q[++tail] = 2 * y;
        q[++tail] = 2 * y + 1;
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);
    
    work();
    
    return 0;
}
```

### 问题 EH: 排队买票

```c++
#include <iostream>
#include <algorithm>
using namespace std;

int n;
long long a[1005];
long long ans[1005];

void work() {
    if (!(cin >> n)) return;
    
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    
    for (int i = 1; i <= n; i++) {
        long long sum = a[i];
        for (int j = 1; j < i; j++) {
            sum += min(a[j], a[i]);
        }
        for (int j = i + 1; j <= n; j++) {
            sum += min(a[j], a[i] - 1);
        }
        ans[i] = sum;
    }
    
    for (int i = 1; i <= n; i++) {
        cout << ans[i] << (i == n ? "" : " ");
    }
    cout << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EI: 追查到底

```c++
#include <iostream>
using namespace std;

int n;
int q[105];
int h = 1;
int t = 0;

void work() {
    if (!(cin >> n)) return;
    while (n--) {
        int opt, x;
        cin >> opt >> x;
        if (opt == 1) {
            q[++t] = x;
        } else if (opt == 2) {
            int c = 0;
            while (h <= t) {
                int v = q[h++];
                c++;
                if (v == x) {
                    break;
                }
            }
            cout << c << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EJ: 循环队列练习

```c++
#include <iostream>
#include <string>
using namespace std;

int m;
int q[1000005];
int h = 1;
int t = 0;

void work() {
    if (!(cin >> m)) return;
    while (m--) {
        string op;
        cin >> op;
        if (op == "push") {
            int x;
            cin >> x;
            t++;
            if (t >= 1000005) t = 0;
            q[t] = x;
        } else if (op == "pop") {
            h++;
            if (h >= 1000005) h = 0;
        } else if (op == "query") {
            int k;
            cin >> k;
            int idx = h + k - 1;
            if (idx >= 1000005) idx -= 1000005;
            cout << q[idx] << "\n";
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EK: 约瑟夫环

```c++
#include <iostream>
#include <vector>
using namespace std;

int n, m;
vector<int> v;

void work() {
    if (!(cin >> n >> m)) return;
    
    for (int i = 1; i <= n; i++) {
        v.push_back(i);
    }
    
    int idx = 0;
    while (v.size() > 0) {
        idx = (idx + m - 1) % v.size();
        cout << v[idx] << " ";
        v.erase(v.begin() + idx);
    }
    cout << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EL: 机器翻译

```c++
#include <iostream>
#include <queue>
using namespace std;

int m, n;
bool v[1005];
queue<int> q;
int ans = 0;

void work() {
    if (!(cin >> m >> n)) return;
    
    for (int i = 0; i < n; i++) {
        int w;
        cin >> w;
        
        if (!v[w]) {
            ans++;
            if (q.size() == m) {
                v[q.front()] = false;
                q.pop();
            }
            q.push(w);
            v[w] = true;
        }
    }
    
    cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EM: 海港

```c++
#include <iostream>
using namespace std;

int n;
int qt[300005];
int qx[300005];
int c[100005];
int h = 1;
int t = 0;
int ans = 0;

void work() {
    if (!(cin >> n)) return;
    while (n--) {
        int time, k;
        cin >> time >> k;
        while (k--) {
            int x;
            cin >> x;
            qt[++t] = time;
            qx[t] = x;
            if (c[x] == 0) ans++;
            c[x]++;
        }
        while (h <= t && time - qt[h] >= 86400) {
            c[qx[h]]--;
            if (c[qx[h]] == 0) ans--;
            h++;
        }
        cout << ans << "\n";
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EN: 生成窗口最大值数组

```c++
#include <iostream>
using namespace std;

int n, w;
int a[100005];
int q[100005];
int h = 1;
int t = 0;

void work() {
    if (!(cin >> n >> w)) return;
    
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    
    for (int i = 1; i <= n; i++) {
        while (h <= t && a[q[t]] <= a[i]) {
            t--;
        }
        q[++t] = i;
        
        while (h <= t && q[h] <= i - w) {
            h++;
        }
        
        if (i >= w) {
            cout << a[q[h]] << (i == n ? "" : " ");
        }
    }
    cout << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EO: 区间取数1

```c++
#include <iostream>
using namespace std;

int n, k, c;
int ans = 0;
int cnt = 0;

void work() {
    if (!(cin >> n >> k >> c)) return;
    
    for (int i = 1; i <= n; i++) {
        int a;
        cin >> a;
        if (a <= k) {
            cnt++;
            if (cnt >= c) {
                ans++;
            }
        } else {
            cnt = 0;
        }
    }
    
    cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EP: 合并果子

```c++
#include <iostream>
#include <queue>
#include <vector>
using namespace std;

int n;
long long ans = 0;
priority_queue<int, vector<int>, greater<int>> q;

void work() {
    if (!(cin >> n)) return;
    
    for (int i = 0; i < n; i++) {
        int x;
        cin >> x;
        q.push(x);
    }
    
    while (q.size() > 1) {
        int a = q.top();
        q.pop();
        int b = q.top();
        q.pop();
        
        ans += (a + b);
        q.push(a + b);
    }
    
    cout << ans << "\n";
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

### 问题 EQ: 有序表的最小和

```c++
#include <iostream>
#include <vector>
#include <queue>
using namespace std;

int n;
long long a[400005];
long long b[400005];

struct Node {
    long long sum;
    int i;
    int j;
    
    bool operator>(const Node& other) const {
        return sum > other.sum;
    }
};

priority_queue<Node, vector<Node>, greater<Node>> pq;

void work() {
    if (!(cin >> n)) return;
    
    for (int i = 1; i <= n; i++) {
        cin >> a[i];
    }
    for (int i = 1; i <= n; i++) {
        cin >> b[i];
    }
    
    for (int i = 1; i <= n; i++) {
        pq.push({a[i] + b[1], i, 1});
    }
    
    for (int k = 1; k <= n; k++) {
        Node curr = pq.top();
        pq.pop();
        
        cout << curr.sum << "\n";
        
        if (curr.j < n) {
            pq.push({a[curr.i] + b[curr.j + 1], curr.i, curr.j + 1});
        }
    }
}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(0);

    work();

    return 0;
}
```

