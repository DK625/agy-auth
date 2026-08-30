# agy-auth

> Lightweight multi-account manager & shortcut CLI for Google Antigravity CLI (`agy`).

Simple, fast account switching inspired by `codex-auth`.

---

## ⚡ Quick Install

### Linux / macOS / WSL / Git Bash
```bash
curl -fsSL https://raw.githubusercontent.com/DK625/agy-auth/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/DK625/agy-auth/main/install.ps1 | iex
```

---

## 🚀 Usage

### 1. Đăng nhập / Đăng ký tài khoản
```bash
agi-auth login acc1
```
* Nếu đang có sẵn phiên đăng nhập: tự động nhận diện và lưu thành `acc1`.
* Nếu muốn đăng nhập tài khoản Google mới: mở trình duyệt xác thực OAuth và lưu thành `acc2`.

### 2. Xem danh sách các tài khoản
```bash
agi-auth list
```
Output:
```text
=== Antigravity Accounts ===
  * acc1 (active)
    acc2
```

### 3. Chuyển đổi tài khoản (Switch)
```bash
agi-auth switch acc2
```

### 4. Xóa tài khoản
```bash
agi-auth remove acc2
```

---

## 🏎️ Quick CLI Shortcut: `agi`

Tự động cấu hình lệnh `agi` chạy Antigravity CLI không cần xác nhận quyền mỗi lần:
```bash
agi
# Tương đương với: agy --dangerously-skip-permissions "$@"
```

---

## 📄 License
MIT © [DK625](https://github.com/DK625)