# agi-auth

> Lightweight multi-account manager & shortcut CLI for Google Antigravity CLI (`agy`).

Simple, fast account switching inspired by `codex-auth`.

---

## ⚡ Quick Install

### Linux / macOS / WSL / Git Bash
```bash
curl -fsSL https://raw.githubusercontent.com/DK625/agi-auth/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/DK625/agi-auth/main/install.ps1 | iex
```

---

## 🚀 Usage

### 1. Đăng nhập tài khoản mới
```bash
agi-auth login acc1
```
> CLI sẽ mở trình duyệt để xác thực Google OAuth và tự động lưu phiên thành profile `acc1`.

### 2. Xem danh sách các tài khoản đã lưu
```bash
agi-auth list
```
Output ví dụ:
```text
=== Antigravity Accounts ===
  * acc1 (active)
    acc2
    work-email@gmail.com
```

### 3. Chuyển đổi tài khoản (Switch)
```bash
agi-auth switch acc2
# hoặc: agi-auth use acc2
```

### 4. Xóa tài khoản
```bash
agi-auth remove acc2
# hoặc: agi-auth rm acc2
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
* **Windows:** Lưu trữ an toàn bằng Windows Credential Manager (`advapi32.dll`), sao lưu cấu hình vào `~/.gemini/accounts/`.
* **Linux/macOS:** Tương thích với `secret-tool` / macOS Keychain.
* **Không yêu cầu cài thêm package ngoài:** Sử dụng thuần Python Standard Library.

---

## 📄 License
MIT © [DK625](https://github.com/DK625)
