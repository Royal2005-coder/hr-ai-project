# HR Analytics AI Agent (Open Source)

Dự án phân tích nhân sự (HR Analytics) kết hợp mô hình học máy (Machine Learning) và Text-to-SQL với WrenAI để truy cập và phân tích dữ liệu bằng ngôn ngữ tự nhiên.

## Đặc điểm nổi bật
- **Open Source:** Dự án mã nguồn mở, bạn có thể tự do sao chép và phát triển thêm.
- **Bảo vệ Dữ liệu:** Thiết kế an toàn, không gửi Raw Data cho AI, chỉ dùng Semantic Layer (Metadata) qua API.
- **Tùy biến LLM:** Có thể thay thế mô hình Gemini bằng các mô hình LLM khác thông qua LiteLLM.

## Thành phần chính

- `WrenAI/`: mã nguồn và hạ tầng chạy WrenAI (Docker, AI service, UI, Qdrant).
- `notebooks/`: notebook phân tích và demo luồng nghiệp vụ HR.
- `legacy/`: script SQL khởi tạo/phục vụ tham chiếu dữ liệu cũ.

## Yêu cầu môi trường

- Docker Desktop (Bật WSL2 hoặc Hyper-V)
- Git
- Python 3.10+ (cho notebook/script hỗ trợ)
- **Tài khoản Google AI Studio để lấy Gemini API Key miễn phí.**

## 🚀 Hướng dẫn cài đặt nhanh (Quick Start)

1. Clone repository:
```bash
git clone https://github.com/Royal2005-coder/hr-ai-project.git
cd hr-ai-project
```

2. Tạo file cấu hình môi trường từ mẫu:
   - Truy cập vào thư mục `WrenAI/docker/`
   - Sao chép file `WrenAI/docker/.env.example` thành file mới tên là `WrenAI/docker/.env`

3. Cấu hình AI:
   - Mở file `.env` bằng text editor (VSCode, Notepad,...).
   - Điền API Key của bạn lấy từ [Google AI Studio](https://aistudio.google.com/) vào biến `GEMINI_API_KEY`.
   - Ví dụ: `GEMINI_API_KEY=AIzaSyxxxxxxxx...`

4. Khởi động hệ thống:
```bash
cd WrenAI/docker
docker compose up -d
```

5. Chờ vài phút cho đến khi tất cả các dịch vụ (container) khởi động. Sau đó mở trình duyệt và truy cập: [http://localhost:3000](http://localhost:3000)

## 🔒 Quy tắc Bảo mật Bắt buộc

- **KHÔNG BAO GIỜ** chia sẻ GEMINI_API_KEY của bạn cho người khác.
- **TUYỆT ĐỐI KHÔNG** commit file `.env` chứa API Key thật lên GitHub. File `.env` đã được đưa vào `.gitignore` để tránh rủi ro.
- Nếu bạn lỡ làm lộ API Key, hãy truy cập Google AI Studio để revoke (xóa) key cũ ngay lập tức và tạo key mới.

## Giấy phép (License)
Dự án được phát hành dưới dạng Open Source phục vụ mục đích nghiên cứu và giáo dục.
