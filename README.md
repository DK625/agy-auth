# agy-auth

> Lightweight multi-account manager, quota monitor & real-time statusline for Google Antigravity CLI (`agy`).

Simple, fast account switching inspired by `codex-auth` + beautiful real-time terminal statusline.

---

## ⚡ Quick Install

### Windows (PowerShell)
```powershell
irm https://raw.githubusercontent.com/DK625/agy-auth/main/install.ps1 | iex
```

### Linux / macOS / WSL
```bash
curl -fsSL https://raw.githubusercontent.com/DK625/agy-auth/main/install.sh | bash
```

---

## 🎨 Antigravity Real-Time Statusline

Sau khi cài đặt bằng 1 lệnh trên, Antigravity CLI (`agy` / `agi`) sẽ tự động có **Statusline thời gian thực** hiển thị đầy đủ thông số:

```text
● READY / Gemini 3.7 Flash / game_tools (master*) │ ctx ███████████████ 100.0% · artifacts 12
plan: Google AI Pro
gemini 5h ●●●●●●●●●●  96% ⟳ 01:09
gemini 7d ●●●●●●○○○○  55% ⟳ sep 1, 16:28
```

* **Trạng thái Agent:** `● READY`, `◆ THINKING`, `⚙ WORKING`, `🔧 TOOL`.
* **Model & Workspace Git Branch:** Hiển thị model đang dùng và nhánh Git hiện tại kèm trạng thái dirty.
* **Context Bar (Remain %):** Thanh context hiển thị chính xác % context window còn lại.
* **Quota 5h & Quota 7d (Remain %):** Thanh chấm tròn trực quan hiển thị % Quota còn lại và thời gian hồi (Local time).

---

## 🚀 Usage

### 1. Đăng nhập tài khoản mới (Mở trình duyệt trực tiếp)
```bash
agi-auth login
```
* **Mở trực tiếp link/trình duyệt** với giao diện Landing Page hiện đại để xác thực Google OAuth.
* Tự động nhận diện Email Google (`@gmail.com`) và lưu profile.

### 2. Xem danh sách tài khoản, Email, Quota còn lại & Lỗi
```bash
agi-auth list
```
Output định dạng chuẩn theo `codex-auth` kèm **Kiểm tra trạng thái & Lỗi theo thời gian thực (Health Checks)**:
```text
     ACCOUNT                         PLAN            5H REMAIN               WEEKLY REMAIN          LAST ACTIVITY
-----------------------------------------------------------------------------------------------------------------
  01 lnhuyen160902@gmail.com         Disabled        Disabled (TOS)          Disabled (TOS)         19m ago      
* 02 minhha10c8@gmail.com            Google AI Pro   96% (01:09 on 31 Aug)   55% (16:28 on 01 Sep)  Now          
  03 onehammer256@gmail.com          Standard        TOS Required            TOS Required           21m ago      
  04 sieunhanmanhme1511@gmail.com    Google AI Pro   Verify Required         Verify Required        26m ago      
  05 thanhngan84672@gmail.com        Disabled        Disabled (TOS)          Disabled (TOS)         15m ago      
  06 trinhduchoang625dora@gmail.com  Google AI Pro   TOS Required            TOS Required           33m ago      

[!] Account Issues & Solutions:
  • lnhuyen160902@gmail.com: Disabled (TOS) - Service disabled for TOS violation
    -> Gửi đơn kháng nghị (Submit Appeal): https://forms.gle/hGzM9MEUv2azZsrb9
  • sieunhanmanhme1511@gmail.com: Verify Required - Account verification required in browser
    -> Mở link này để xác thực tài khoản: https://accounts.google.com/signin/continue?...
  • trinhduchoang625dora@gmail.com: TOS Required - Google TOS not accepted on web. Visit https://antigravity.google to activate.
```

### 3. Chuyển đổi tài khoản (Switch)
Hỗ trợ chuyển bằng **Số thứ tự (Index)** hoặc **Email Google**:
```bash
# Chuyển bằng số thứ tự
agi-auth switch 02
# hoặc: agi-auth switch 2

# Chuyển bằng email
agi-auth switch minhha10c8@gmail.com
```

### 4. Xóa tài khoản
```bash
# Xóa bằng số thứ tự
agi-auth remove 03

# Xóa bằng email
agi-auth remove onehammer256@gmail.com
```

### 5. Tự động đồng bộ tài khoản đang đăng nhập (Sync)
Tự động phát hiện và đồng bộ tài khoản Antigravity CLI đang hoạt động trong phiên hiện tại vào danh sách quản lý:
```bash
agi-auth sync
```

### 6. Cấu hình Telegram Notification & Task Speech Hook
Tự động phát âm thanh (TTS Speech) và gửi tin nhắn Telegram khi Agent **hoàn thành task (`Stop`)** hoặc **cần hỏi người dùng (`ask_question`)**:
```bash
# Xem trạng thái cấu hình Telegram hiện tại
agi-auth notify

# Cấu hình Bot Token & Chat ID Telegram
agi-auth notify <YOUR_TELEGRAM_BOT_TOKEN> <YOUR_TELEGRAM_CHAT_ID>
```
*Thông tin Credential Telegram sẽ được lưu cục bộ tại `~/.gemini/notify.json` (không push lên Git).*
*Hoặc bạn cũng có thể set qua biến môi trường: `TELEGRAM_BOT_TOKEN` và `TELEGRAM_CHAT_ID`.*

---

## 🏎️ Quick CLI Shortcut: `agi`

Tự động cấu hình lệnh `agi` chạy Antigravity CLI không cần xác nhận quyền mỗi lần:
```bash
agi
# Tương đương với: agy --dangerously-skip-permissions "$@"
```

---

## 🛠️ How it works
* **Native OAuth 2.0 PKCE:** Xác thực nhanh, an toàn, có UI success page đẹp mắt.
* **Token Lifecycle Auto-Refresh:** Tự động làm mới access token khi hết hạn.
* **Real-Time Health Checks:** Tự động phát hiện tài khoản bị khóa TOS (`Disabled`), cần xác thực (`Verify Required`), chưa kích hoạt web (`TOS Required`) kèm link xử lý trực tiếp.
* **Lifecycle Hooks & Telegram Notification:** Đăng ký tự động hook `Stop` và `PreToolUse` để phát giọng nói và thông báo qua Telegram khi agent làm xong việc hay hỏi ý kiến. Credentials lưu an toàn tại máy người dùng.
* **Zero Dependency:** Sử dụng thuần Python Standard Library và Native PowerShell/.NET.
* **Bảo mật:** Lưu trữ an toàn bằng Windows Credential Manager (`advapi32.dll`) trên Windows và Keyring trên Unix.

---

## 📄 License
MIT © [DK625](https://github.com/DK625)

