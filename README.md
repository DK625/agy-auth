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
* **Mở trực tiếp trình duyệt** để xác thực Google OAuth PKCE.
* Tự động nhận diện Email Google (`@gmail.com`), lưu profile và **mở ngay Antigravity CLI (`agi`)** để bắt đầu làm việc.

### 2. Xem danh sách tài khoản & Quota
```bash
agi-auth list
```
Hiển thị tức thì danh sách tài khoản, Plan, Quota còn lại và lần hoạt động gần nhất:
```text
     ACCOUNT                      PLAN           5H REMAIN       WEEKLY REMAIN        LAST ACTIVITY
---------------------------------------------------------------------------------------------------
  01 claude25602@gmail.com        Standard       -               -                    47m ago      
* 02 minhha10c8@gmail.com         Google AI Pro  38% (06:47)     9% (16:28, 01 Sep)   Now          
  03 supermanvnx001@gmail.com     Standard       85% (08:15)     95% (03:00, 08 Sep)  35m ago      
```

#### 💡 Cơ chế cập nhật Quota (Quota Mechanism)
* **Vì sao không gọi API get quota độc lập?** Google Antigravity **không cung cấp public REST endpoint độc lập** để tra cứu số dư Quota cho tài khoản cá nhân (Consumer / Google AI Pro). Thông tin quota chỉ được trả về trong luồng session nội bộ của Antigravity CLI khi người dùng mở phiên làm việc.
* **Cơ chế Hooking thông minh:**
  1. Khi bạn chạy `agi-auth login` hoặc `agi-auth switch`, `agi-auth` tự động khởi chạy `agi` dưới danh tính của tài khoản đó.
  2. Ngay khi `agi` mở lên (hoặc trong mỗi lượt chat), `statusline` sẽ bắt ngay thông số Quota thực tế (`5h` / `Weekly`), Plan (`Google AI Pro` / `Standard`) và thông tin lỗi (nếu có), lưu cô lập riêng vào profile của tài khoản đó.
  3. Khi chạy `agi-auth list`, dữ liệu Quota gần nhất sẽ được hiển thị ngay lập tức.
  4. **Tự động phục hồi Real-Time (Dynamic Reset):** Khi đồng hồ thực tế vượt qua mốc giờ reset (`reset_time`), bảng `list` sẽ **tự động tính toán phục hồi về `100%`** mà không cần bạn phải mở lại `agi`.
  5. Với tài khoản mới thêm chưa mở `agi` lần nào, bảng sẽ hiển thị dấu `-` cho đến phiên đăng nhập đầu tiên. Tài khoản gặp lỗi xác minh tài khoản sẽ hiển thị `Verify Req`.

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

### 5. Cấu hình Telegram Notification & Task Speech Hook
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

