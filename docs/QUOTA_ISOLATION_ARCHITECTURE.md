# Quota Isolation & Multi-Session Architecture (Kiến trúc Cách ly Quota Đa Phiên)

## 1. Vấn đề Cross-Process Pollution (Nhiễm chéo Quota giữa các Account)
Trong môi trường làm việc đa terminal / đa tài khoản:
- Giả sử Terminal 1 đang chạy Antigravity CLI (`agi`) với tài khoản `supermanvnx001@gmail.com`.
- Người dùng mở Terminal 2 và thực hiện chuyển sang tài khoản mới `layaccantinao@gmail.com` (tài khoản này chưa verify và gặp lỗi `Eligibility Check Failed`).
- Khi lệnh switch diễn ra, OS Credential Vault (`gemini:antigravity`) được cập nhật sang `layaccantinao@gmail.com`.
- Lúc này, Terminal 1 đang chạy `supermanvnx001` kích hoạt hook `statusline`. Nếu `statusline` đọc thông tin account từ OS Credential Vault (singleton dùng chung toàn hệ thống), nó sẽ thấy account là `layaccantinao` và **ghi đè toàn bộ quota sống của `supermanvnx001` vào file của `layaccantinao`**.
- Kết quả: Tài khoản `layaccantinao` (đang bị lỗi verify) bị hiển thị sai lệch thành có quota giống hệt `supermanvnx001`, xóa mất cờ báo lỗi `"Verify Required"`.

---

## 2. Nguyên lý Fix: Strict Process-Bound Per-Account Keyed Caching

Để đảm bảo **100% tài khoản nào hiển thị đúng quota/lỗi của tài khoản đó**, hệ thống áp dụng 3 quy tắc bất biến:

### Quy tắc 1: Định danh theo Process Environment (`AGI_ACTIVE_ACCOUNT`)
- Mỗi phiên Antigravity (`agi`) khi khởi chạy (`agi-auth switch`, `agi-auth login`, hoặc hàm `agi` trên PowerShell/Bash) **bắt buộc phải snapshot và bind email tài khoản vào biến môi trường process-local: `AGI_ACTIVE_ACCOUNT`**.
- Biến môi trường này gắn liền với vòng đời của tiến trình `agi` và các tiến trình con (`statusline.py`), hoàn toàn độc lập và không bao giờ bị ảnh hưởng bởi việc các terminal khác thay đổi Credential Vault.

### Quy tắc 2: Tuyệt đối không fallback về Global Vault trong `statusline`
- Trong `statusline.py`, hàm `get_target_account_file()` **CHỈ** tìm file tài khoản tương ứng khi `os.environ.get("AGI_ACTIVE_ACCOUNT")` tồn tại.
- Nếu một tiến trình chạy mà không có `AGI_ACTIVE_ACCOUNT`, `statusline.py` sẽ chỉ render hiển thị lên màn hình mà **TUYỆT ĐỐI KHÔNG GHI/SỬA bất kỳ file tài khoản nào** trong `~/.gemini/accounts/` để tránh ghi nhầm dữ liệu.

### Quy tắc 3: Xóa sạch Quota (Purge) khi Antigravity không trả về Quota
- Khi một tài khoản được kích hoạt nhưng Antigravity báo lỗi `Eligibility Check Failed` hoặc chưa verify:
  - Antigravity sẽ gửi payload `data["quota"]` rỗng (`{}`).
  - Khi đó, `statusline.py` sẽ **ngay lập tức xóa bỏ trường `"quota"`** (`acc_data.pop("quota", None)`) và ghi cờ `"error": "Verify Required"`.
  - Không bao giờ để tài khoản bị lỗi giữ lại quota rác từ các phiên trước.

---

## 3. Cấu trúc lưu trữ độc lập (`~/.gemini/accounts/<email>.json`)
Mỗi tài khoản được lưu độc lập thành 1 file json với schema rõ ràng:
```json
{
  "email": "layaccantinao@gmail.com",
  "auth_method": "consumer",
  "token": {
    "access_token": "...",
    "refresh_token": "...",
    "expiry": "..."
  },
  "plan_tier": "Google AI Pro",
  "quota": {
    "gemini-5h": { "remaining_fraction": 1.0 },
    "gemini-weekly": { "remaining_fraction": 1.0 }
  },
  "error": "Verify Required"
}
```

Bảng `agi-auth list` đọc trực tiếp từ từng file riêng biệt theo khóa định danh, đảm bảo không có bất kỳ sự nhầm lẫn hay dùng chung dữ liệu nào.
