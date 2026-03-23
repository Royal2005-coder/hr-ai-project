# HR AI Project

Dự án phân tích nhân sự (HR Analytics) kết hợp Text-to-SQL với WrenAI để truy vấn dữ liệu tự nhiên và trình bày insight phục vụ báo cáo.

## Thành phần chính

- `WrenAI/`: mã nguồn và hạ tầng chạy WrenAI (Docker, AI service, UI).
- `notebooks/`: notebook phân tích và demo luồng nghiệp vụ HR.
- `legacy/`: script SQL khởi tạo/phục vụ tham chiếu dữ liệu cũ.

## Yêu cầu môi trường

- Docker Desktop
- Git
- Python 3.10+ (cho notebook/script hỗ trợ)

## Thiết lập nhanh

1. Clone repository.
2. Tạo file cấu hình môi trường từ mẫu:
   - Sao chép `WrenAI/docker/.env.example` thành `WrenAI/docker/.env`
3. Mở `WrenAI/docker/.env` và điền `GEMINI_API_KEY` của bạn.
4. Chạy hệ thống:

```bash
cd WrenAI/docker
docker compose up -d
```

## Bảo mật

- Không commit `.env` hoặc bất kỳ API key/secret nào.
- Chỉ commit file mẫu cấu hình (`.env.example`) với giá trị placeholder.

## Cấu trúc nộp bài

Repository đã được chuẩn hóa theo hướng tối giản tài liệu ở root và giữ README tổng quát làm điểm vào chính.
