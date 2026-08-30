# agy-auth

> Lightweight multi-account manager & quota monitor for Google Antigravity CLI (`agy`).

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
* **Tự động liên kết:** Nếu đang có sẵn phiên đăng nhập, hệ thống tự lấy Email Google (`@gmail.com`) và lưu thành `acc1`.
* **Đăng nhập tài khoản mới:** Mở trình duyệt xác thực Google OAuth và lưu thành profile mới.

### 2. Xem danh sách tài khoản, Email & Quota (5h / 7d)
```bash
agi-auth list
```
Output:
```text
=== Antigravity Accounts ===
 * acc1 (minhha10c8@gmail.com) [● active]
    ├─ 5h Limit:     100%
    ├─ Weekly Limit: 100%
    └─ Plan / Tier:  Standard

   acc2 (work-email@company.com) [○ inactive]
    ├─ 5h Limit:     85% (reset 23:45)
    ├─ Weekly Limit: 92%
    └─ Plan / Tier:  Pro
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

## 🛠️ How it works
* **Lấy Email tự động:** Trích xuất email thật từ Google OAuth userinfo API.
* **Theo dõi Quota:** Tự động lấy và hiển thị hạn mức 5h (5-hour limit), Weekly Limit (7-day limit) và gói Plan / Tier.
* **Bảo mật:** Lưu trữ an toàn bằng Windows Credential Manager (`advapi32.dll`) trên Windows và Keyring trên Unix.
* **Zero Dependency:** Sử dụng thuần Python Standard Library.

---

## 📄 License
MIT © [DK625](https://github.com/DK625)