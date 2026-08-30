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

### 1. Đăng nhập tài khoản mới (Mở trình duyệt trực tiếp)
```bash
agi-auth login
```
* **Mở trực tiếp link/trình duyệt** để xác thực Google OAuth (tương tự lệnh `/login` trong `agy`).
* Sau khi đăng nhập xong, hệ thống **tự động bóc tách Email Google (`@gmail.com`) và lưu profile**.

### 2. Xem danh sách tài khoản, Email & Quota (5h / 7d)
```bash
agi-auth list
```
Output định dạng chuẩn theo `codex-auth`:
```text
     ACCOUNT                         PLAN  5H USAGE                WEEKLY USAGE           LAST ACTIVITY
-------------------------------------------------------------------------------------------------------
* 01 minhha10c8@gmail.com            Plus  100% (00:35 on 31 Aug)  100% (19:35 on 6 Sep)  Now          
  02 sieunhanmanhme1511@gmail.com    Free  100%                    100%                   7m ago       
```

### 3. Chuyển đổi tài khoản (Switch)
Hỗ trợ chuyển bằng **Số thứ tự (Index)** hoặc **Email Google**:
```bash
# Chuyển bằng số thứ tự
agi-auth switch 02
# hoặc: agi-auth switch 2

# Chuyển bằng email
agi-auth switch sieunhanmanhme1511@gmail.com
```

### 4. Xóa tài khoản
```bash
# Xóa bằng số thứ tự
agi-auth remove 02

# Xóa bằng email
agi-auth remove sieunhanmanhme1511@gmail.com
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
* **Native OAuth:** Mở luồng xác thực Google OAuth 2.0 PKCE trực tiếp, không bị kẹt terminal.
* **Tự động nhận diện Email:** Trích xuất email thật từ Google OAuth userinfo API.
* **Theo dõi Quota:** Tự động lấy và hiển thị hạn mức 5h (5-hour limit), Weekly Limit (7-day limit) và gói Plan / Tier.
* **Bảo mật:** Lưu trữ an toàn bằng Windows Credential Manager (`advapi32.dll`) trên Windows và Keyring trên Unix.
* **Zero Dependency:** Sử dụng thuần Python Standard Library.

---

## 📄 License
MIT © [DK625](https://github.com/DK625)