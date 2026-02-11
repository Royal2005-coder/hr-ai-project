# HƯỚNG DẪN THỰC HIỆN NHIỆM VỤ — Team Dev HR Analytics AI

**Mã học phần:** 252BIM500601  
**Đề tài:** Ứng dụng AI trong phân tích rủi ro nghỉ việc nhân sự và hỗ trợ ra quyết định  
**GVHD:** TS. Trịnh Quang Việt  
**Ngày phát hành:** 11/02/2026  
**Deadline:** 16/02/2026  

---

## MỤC LỤC

1. [Tổng quan dự án và mục tiêu](#1-tổng-quan-dự-án-và-mục-tiêu)
2. [Link demo public và hệ thống](#2-link-demo-public-và-hệ-thống)
3. [Hướng dẫn clone và chạy dự án từ GitLab](#3-hướng-dẫn-clone-và-chạy-dự-án-từ-gitlab)
4. [Phân công chi tiết theo người](#4-phân-công-chi-tiết-theo-người)
5. [Hướng dẫn cấu hình 5 nghiệp vụ HR trên Wren AI UI](#5-hướng-dẫn-cấu-hình-5-nghiệp-vụ-hr-trên-wren-ai-ui)
6. [Hướng dẫn verify và test demo performance](#6-hướng-dẫn-verify-và-test-demo-performance)
7. [Hướng dẫn deep dive research source code](#7-hướng-dẫn-deep-dive-research-source-code)
8. [Yêu cầu đầu ra (Deliverables)](#8-yêu-cầu-đầu-ra-deliverables)
9. [Timeline và checklist](#9-timeline-và-checklist)

---

## 1. Tổng quan dự án và mục tiêu

### 1.1 Kiến trúc hệ thống

```
┌─────────────────────────────────────────────────────────────────────┐
│                    HR Analytics AI System                           │
│                                                                     │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │  wren-ui  │→ │wren-ai-service│→ │  wren-engine │→ │ibis-server│ │
│  │  :3000    │  │    :5555      │  │    :8080     │  │   :8000   │ │
│  │ Next.js   │  │  FastAPI      │  │ MDL Engine   │  │  Ibis     │ │
│  │ Apollo GQL│  │ 29 Pipelines  │  │ SQL Compiler │  │ Translator│ │
│  └───────────┘  └──────┬───────┘  └──────────────┘  └─────┬─────┘ │
│                        │                                    │       │
│                  ┌─────▼─────┐                        ┌────▼─────┐ │
│                  │  qdrant   │                        │  MSSQL   │ │
│                  │   :6333   │                        │  :1433   │ │
│                  │ Vector DB │                        │ HR Data  │ │
│                  └───────────┘                        └──────────┘ │
│                                                                     │
│  LLM: gemini/gemini-2.5-flash | Embedder: gemini-embedding-001     │
│  API Key: AIzaSyDVw0VwiGkFc3kdbIeIOs_4qICd_Y9rSm4                 │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 4 Layer Architecture

| Layer | Thư mục | Mô tả |
|-------|---------|-------|
| **Data Layer** | `legacy/` | SQL Scripts khởi tạo DB, Views, Database Mail |
| **Analytics Layer** | `notebooks/` | ML model Random Forest, SMOTE, OOF, Feature Importance |
| **Agentic Layer** | `WrenAI/` | AI Chatbot Text-to-SQL: 6 containers, 29 pipelines |
| **Representation Layer** | `WrenAI/wren-ui/` | Next.js UI: Modeling, Knowledge, Chat |

---

## 2. Link demo public và hệ thống

### 2.1 Public Link (Cloudflare Tunnel)

> **Link demo hiện tại (sẽ thay đổi khi restart):**
> 
> **https://certification-lows-spy-tension.trycloudflare.com**
> 
> Link này kết nối trực tiếp tới backend hệ thống đang chạy, bao gồm:
> - Wren AI UI (Chat, Modeling, Knowledge)
> - Wren AI Service (29 AI pipelines + Gemini API)
> - Wren Engine + Ibis Server (SQL compilation + execution)
> - MSSQL Server (HR Analytics database)
> - Qdrant (Vector DB: 52 schema docs + 17 table descriptions)

### 2.2 Cách tạo lại public link (khi máy restart)

```powershell
# Bước 1: Khởi động Docker containers
cd hr-ai-project/WrenAI/docker
docker compose up -d

# Bước 2: Chờ tất cả containers healthy (~30 giây)
docker ps --format "table {{.Names}}\t{{.Status}}"

# Bước 3: Tạo public tunnel
cloudflared tunnel --url http://localhost:3000

# Link mới sẽ hiện trong terminal, dạng:
# https://xxx-yyy-zzz.trycloudflare.com
```

### 2.3 Local URLs (khi chạy trên máy cá nhân)

| Service | URL | Mô tả |
|---------|-----|-------|
| Wren AI UI | http://localhost:3000 | Giao diện chính |
| Wren AI Service | http://localhost:5555 | API AI (health: /health) |
| Qdrant Dashboard | http://localhost:6333/dashboard | Xem vector collections |

---

## 3. Hướng dẫn clone và chạy dự án từ GitLab

### 3.1 Yêu cầu hệ thống

- **Windows 10/11** với Docker Desktop
- **Docker Desktop** (bật WSL2 integration)
- **SQL Server 2019+** hoặc dùng container MSSQL
- **Python 3.10+** (cho notebook)
- **Git** để clone repo

### 3.2 Clone repo

```bash
git clone https://gitlab.com/boygia757-netizen/hr-ai-project.git
cd hr-ai-project
git checkout hr_domain_research
```

### 3.3 Cấu hình SQL Server

```powershell
# Option A: Dùng SQL Server container đã có
docker ps --filter "name=hr-sql-server"
# Nếu chưa có, restore từ file backup:
# 1. Copy HR_Analytics.bak vào SQL Server
# 2. Restore database HR_Analytics từ backup

# Option B: Dùng SQL Server trên máy
# Connection string: mssql://SA:YourPassword@host.docker.internal:1433/HR_Analytics
```

### 3.4 Cấu hình và chạy Wren AI

```powershell
cd WrenAI/docker

# Kiểm tra file .env đã có các biến:
# GEMINI_API_KEY=AIzaSyDVw0VwiGkFc3kdbIeIOs_4qICd_Y9rSm4
# GENERATION_MODEL=gemini/gemini-2.5-flash
# LLM_PROVIDER=litellm_llm

# Kiểm tra config.yaml đã cấu hình:
# type: litellm_llm
# models: [{ model: "gemini/gemini-2.5-flash", ... }]
# embedder: { type: litellm_embedder, ... model: "gemini/gemini-embedding-001" }

# Khởi động tất cả containers
docker compose up -d

# Kiểm tra 6 containers chạy
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Kết quả mong đợi: 5 containers UP + 1 bootstrap (exited ok)
# wrenai-wren-ui-1          Up    0.0.0.0:3000->3000/tcp
# wrenai-wren-ai-service-1  Up    0.0.0.0:5555->5555/tcp
# wrenai-wren-engine-1      Up    7432/tcp, 8080/tcp
# wrenai-qdrant-1           Up    6333-6334/tcp
# wrenai-ibis-server-1      Up    8000/tcp, 8888/tcp
```

### 3.5 Verify hệ thống hoạt động

```powershell
# 1. Health check AI service
Invoke-RestMethod -Uri "http://localhost:5555/health"
# Kết quả: { "status": "ok" }

# 2. Mở UI trên trình duyệt
Start-Process "http://localhost:3000"

# 3. Kiểm tra threads đã lưu
$body = '{"query":"{ threads { id } }"}'
Invoke-RestMethod -Uri "http://localhost:3000/api/graphql" -Method POST -ContentType "application/json" -Body $body
```

---

## 4. Phân công chi tiết theo người

### 4.1 Khải (K234060700) — Infrastructure & Connectivity Owner

**Trọng tâm:** 6 containers, Ibis Server, Docker network, .env, luồng dữ liệu

**Source code bắt buộc đọc:**

| File | Đường dẫn | Dòng | Nội dung chính |
|------|-----------|------|----------------|
| docker-compose.yaml | `WrenAI/docker/docker-compose.yaml` | ~120 | 6 services definition |
| .env | `WrenAI/docker/.env` | ~30 | GEMINI_API_KEY, ports |
| config.yaml | `WrenAI/docker/config.yaml` | 160 | 29 pipelines, LLM, Embedder |
| ibisAdaptor.ts | `wren-ui/src/apollo/server/adaptors/ibisAdaptor.ts` | 658 | IbisAdaptor: query, dryPlan, metadata |
| wren.py | `wren-ai-service/src/providers/engine/wren.py` | 351 | WrenEngineProvider: GraphQL PreviewSql |
| __main__.py | `wren-ai-service/src/__main__.py` | 101 | FastAPI bootstrap |
| globals.py | `wren-ai-service/src/globals.py` | 341 | ServiceContainer factory |
| init.sh | `WrenAI/docker/bootstrap/init.sh` | - | Bootstrap init script |

**Deep dive questions (trả lời trong docx):**

1. Q1: Giải thích chi tiết luồng dữ liệu đi qua 6 container từ lúc user nhập câu hỏi đến lúc nhận kết quả?
2. Q2: Tại sao cần Ibis Server? Ibis đóng vai trò gì giữa MDL và Native SQL của MSSQL?
3. Q3: File `ibisAdaptor.ts` thực hiện những method nào để giao tiếp với Ibis container (query, dryPlan, metadata)?
4. Q4: File `wren.py` trong providers/engine thực hiện kết nối tới Wren Engine bằng cách nào (GraphQL mutation PreviewSql)?
5. Q5: Cấu hình `.env` gồm những biến môi trường nào? GEMINI_API_KEY được truyền vào container nào?
6. Q6: Bootstrap container làm gì? Tại sao nó chỉ chạy 1 lần rồi dừng?
7. Q7: Network 'wren' trong docker-compose hoạt động thế nào để các container giao tiếp với nhau?
8. Q8: Khi ibis-server gặp lỗi kết nối đến MSSQL, log hiển thị ở đâu và cách debug?

**5 nghiệp vụ HR cần cấu hình trên Wren AI UI:**

| # | Nghiệp vụ | Loại cấu hình | Chi tiết |
|---|-----------|---------------|----------|
| 1 | Tính tổng quỹ lương theo phòng ban | Modeling + Relationship | Tạo calculated field `total_salary_dept`, Relationship: Employee_Profile → Department |
| 2 | Nhân viên > 10 năm chưa thăng chức | SQL Pair + Instruction | SQL Pair phức tạp với `years_at_company > 10 AND years_since_last_promotion > 5` |
| 3 | So sánh tỷ lệ nghỉ việc: làm thêm giờ vs không | SQL Pair | GROUP BY OverTime, HAVING Attrition prediction |
| 4 | Nhân viên lương bất thường so với phòng ban | Instruction | Định nghĩa "bất thường" = chênh lệch > 1.5 độ lệch chuẩn |
| 5 | Báo cáo tổng hợp: tổng NV, số nghỉ việc dự báo, tỷ lệ churn | SQL Pair tổng hợp | Multi-table aggregation |

**Deliverables:**
- Docx deep dive trả lời Q1-Q8 (có dẫn chứng file, số dòng)
- Sơ đồ kiến trúc 6 containers (draw.io hoặc Mermaid)
- 5 nghiệp vụ HR cấu hình thành công, chụp screenshot kết quả
- Demo live: show docker logs luồng xử lý 1 câu hỏi

---

### 4.2 Hân (K234060691) — Semantic Layer & Vector Store Specialist

**Trọng tâm:** MDL, Relationships, Qdrant indexing/retrieval, Embedder

**Source code bắt buộc đọc:**

| File | Đường dẫn | Dòng | Nội dung chính |
|------|-----------|------|----------------|
| db_schema.py | `wren-ai-service/src/pipelines/indexing/db_schema.py` | 393 | DBSchemaIndexing: MDL → DDL → embedding → Qdrant |
| db_schema_retrieval.py | `wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py` | 520 | 2-phase: Table retrieval + Column selection |
| qdrant.py | `wren-ai-service/src/providers/document_store/qdrant.py` | 441 | AsyncQdrantDocumentStore, dim=768 |
| litellm.py (embedder) | `wren-ai-service/src/providers/embedder/litellm.py` | 202 | LiteLLMTextEmbedder, gemini-embedding-001 |
| mdl.schema.json | `WrenAI/wren-mdl/mdl.schema.json` | 472 | MDL schema: model, column, relationship |
| modelingHelper.ts | `wren-ui/src/utils/modelingHelper.ts` | 80 | UI helper cho modeling |
| modeling.tsx | `wren-ui/src/pages/modeling.tsx` | - | Trang Modeling trong UI |
| relationships.tsx | `wren-ui/src/pages/setup/relationships.tsx` | - | Trang thiết lập Relationship |

**Deep dive questions (trả lời trong docx):**

1. Q1: Semantic Layer giải quyết bài toán gì cho Text-to-SQL mà Raw Schema không làm được?
2. Q2: MDL (Model Definition Language) gồm những concepts nào (model, column, relationship, metric, view)? Mô tả từng concept.
3. Q3: File `db_schema.py` trong pipelines/indexing thực hiện vector hóa schema bằng cách nào? Mỗi document chứa những gì?
4. Q4: File `db_schema_retrieval.py` thực hiện retrieval 2 pha như thế nào (Table retrieval + Column selection)?
5. Q5: Qdrant lưu trữ những collection nào? Mỗi collection có bao nhiêu documents?
   - `Document` (db_schema) = **52** documents
   - `table_descriptions` = **17** documents
   - `sql_pairs` = 0 (chưa thêm — nhiệm vụ của team)
   - `instructions` = 0 (chưa thêm — nhiệm vụ của team)
6. Q6: Cosine similarity được sử dụng như thế nào để tìm bảng liên quan nhất khi user hỏi câu hỏi?
7. Q7: Làm sao AI biết 'Attrition = Yes' nghĩa là 'Nghỉ việc'? Vai trò của Description và Alias trong Semantic Layer?
8. Q8: Khi nào cần `recreate_index = true` và khi nào đặt false?
9. Q9: Context nào cần cung cấp cho AI để nó hiểu quy trình nghiệp vụ HR?

**5 nghiệp vụ HR cần cấu hình trên Wren AI UI:**

| # | Nghiệp vụ | Loại cấu hình | Chi tiết |
|---|-----------|---------------|----------|
| 1 | Phân nhóm nhân viên theo độ tuổi | Calculated Field | `Age_Group = CASE WHEN age < 30 THEN 'Young' WHEN age < 45 THEN 'Mid' ELSE 'Senior' END` |
| 2 | So sánh lương với trung bình phòng ban | Relationship + Calculated Field | Relationship: Employee → Department + Calculated: `Salary_vs_DeptAvg` |
| 3 | Nhân viên undervalued (kinh nghiệm cao, level thấp) | Instruction | Định nghĩa: `total_working_years > 10 AND job_level <= 2` |
| 4 | Work-life balance vs attrition theo phòng ban | SQL Pair | Multi-table join + GROUP BY |
| 5 | High Performer at Risk | SQL Pair | `performance_rating >= 3 AND risk_level IN ('High','Critical')` |

**Deliverables:**
- Docx deep dive trả lời Q1-Q9 (có dẫn chứng file, số dòng, giải thích code cốt lõi)
- Sơ đồ indexing flow: MDL → Embedding → Qdrant (draw.io)
- Bảng so sánh các Qdrant collections (tên, số documents, vai trò)
- 5 nghiệp vụ HR cấu hình thành công, chụp screenshot

---

### 4.3 Ninh (K234060716) — Agentic Layer & Knowledge Engineer

**Trọng tâm:** SQL Generation, SQL Correction, Intent Classification, SQL Pairs, Instructions

**Source code bắt buộc đọc:**

| File | Đường dẫn | Dòng | Nội dung chính |
|------|-----------|------|----------------|
| sql_generation.py | `wren-ai-service/src/pipelines/generation/sql_generation.py` | 234 | Hamilton DAG: prompt → generate → post_process |
| sql_correction.py | `wren-ai-service/src/pipelines/generation/sql_correction.py` | 201 | Self-Correction loop |
| intent_classification.py | `wren-ai-service/src/pipelines/generation/intent_classification.py` | 401 | 4 intents: TEXT_TO_SQL, GENERAL, USER_GUIDE, MISLEADING_QUERY |
| chart_generation.py | `wren-ai-service/src/pipelines/generation/chart_generation.py` | ~200 | Vega-Lite spec từ SQL results |
| sql_answer.py | `wren-ai-service/src/pipelines/generation/sql_answer.py` | - | NL answer từ SQL result |
| litellm.py (llm) | `wren-ai-service/src/providers/llm/litellm.py` | 167 | LiteLLM abstraction, fallback, retry |
| config.yaml | `WrenAI/docker/config.yaml` | 160 | temperature, max_tokens, 29 pipelines |
| config.py | `wren-ai-service/src/config.py` | 122 | Settings, retry config |
| ask.py | `wren-ai-service/src/web/v1/routers/ask.py` | 80 | POST /asks endpoint |
| question-sql-pairs.tsx | `wren-ui/src/pages/knowledge/question-sql-pairs.tsx` | - | UI quản lý SQL Pairs |
| instructions.tsx | `wren-ui/src/pages/knowledge/instructions.tsx` | - | UI quản lý Instructions |

**Deep dive questions (trả lời trong docx):**

1. Q1: File `sql_generation.py` tổ chức Hamilton DAG gồm những node nào? Mô tả chức năng từng node.
2. Q2: Prompt gửi sang Gemini được cấu tạo từ những thành phần nào (System Prompt + Schema Context + Few-shot SQL Pairs + Instructions + User Question)?
3. Q3: Cơ chế tự sửa lỗi (Self-Correction) trong `sql_correction.py` hoạt động như thế nào? Retry tối đa bao nhiêu lần?
4. Q4: Intent Classification phân loại câu hỏi thành những loại nào (4 loại)?
5. Q5: SQL Pairs được quản lý qua API nào? Quy trình từ lúc thêm đến lúc ảnh hưởng kết quả?
6. Q6: Instructions chia thành 2 loại nào (isGlobal: true/false)? Cho ví dụ cụ thể.
7. Q7: LiteLLM đóng vai trò gì? Tại sao dùng prefix `gemini/` thay vì gọi trực tiếp Gemini API?
8. Q8: Chart generation pipeline tạo biểu đồ Vega-Lite như thế nào?
9. Q9: Làm sao bảo mật thông tin nhân viên khi query qua LLM (chỉ gửi Metadata, không gửi Raw Data)?

**5 nghiệp vụ HR cần cấu hình trên Wren AI UI:**

| # | Nghiệp vụ | Loại cấu hình | Chi tiết |
|---|-----------|---------------|----------|
| 1 | Top 5 nhân viên có nguy cơ nghỉ việc cao nhất | SQL Pair | CTE + ROW_NUMBER + risk_level |
| 2 | Nhân viên có điểm burnout nguy hiểm | SQL Pair + Instruction | Công thức: `overtime*3 + business_travel*2 + years_since_last_promotion*1.5` |
| 3 | Lọc mặc định theo risk_level High/Critical | Instruction (Global) | "Khi hỏi về rủi ro, mặc định chỉ hiển thị High hoặc Critical" |
| 4 | So sánh tỷ lệ nghỉ việc dự báo giữa các job_role | SQL Pair | Multi-group aggregation |
| 5 | Mặc định sử dụng monthly_income cho câu hỏi về lương | Instruction (Global) | "Luôn dùng monthly_income, không dùng daily_rate" |

**Deliverables:**
- Docx deep dive trả lời Q1-Q9 (có dẫn chứng file, số dòng, trích dẫn code)
- Sơ đồ pipeline Text-to-SQL end-to-end
- Bảng liệt kê 13 API endpoints của wren-ai-service
- 5 nghiệp vụ HR thêm thành công, chụp screenshot

---

### 4.4 Gia (K234060689) — Business Insights Analyst

**Trọng tâm:** Notebook ML pipeline, feature importance, business insights

**Source code bắt buộc đọc:**
- `notebooks/HR_Analytics_Project_Final.ipynb` (18 cells: giải thích từng cell)
- `notebooks/WA_Fn-UseC_-HR-Employee-Attrition.csv` (dataset gốc, 35 features, 1470 rows)
- `legacy/init-db.sql` (178 dòng — bảng hr_training_data, 35 columns)
- `legacy/create_actionable_views.sql` (33 dòng — VIEW v_employee_actionable_insights)

**Deep dive questions (trả lời trong docx):**

1. Q1: Insight từ feature importance giúp gì cho HR Director ra quyết định chiến lược?
2. Q2: Chi phí thay thế 1 nhân sự là bao nhiêu? (Tìm số liệu SHRM, Gallup, Deloitte)
3. Q3: Data Leakage là gì? Tại sao tách Train/Test bình thường lại sai?
4. Q4: OOF (Out-of-Fold) giúp mô phỏng Production như thế nào?
5. Q5: Chỉ số Recall quan trọng hơn Precision không? Tại sao?
6. Q6: SMOTE hoạt động thế nào? Tại sao cần xử lý mất cân bằng dữ liệu?
7. Q7: Random Forest Classifier được chọn vì lý do gì? So sánh với Logistic Regression và XGBoost.
8. Q8: Các hyperparameters (n_estimators=300, max_depth=15, class_weight='balanced') có ý nghĩa gì?
9. Q9: Thang đo rủi ro (Low < 30%, Medium 30-50%, High 50-75%, Critical > 75%) xây dựng dựa trên cơ sở nào?

**Deliverables:**
- Docx Report trả lời Q1-Q9 (có biểu đồ, số liệu, dẫn chứng)
- Giải thích từng cell notebook (cell 1-18)
- Biểu đồ feature importance (bar chart), correlation heatmap
- Bảng phân tích Risk theo Department
- Slide trình bày Business Insights (5-7 slides)

---

### 4.5 Uyên (K234060737) — MLOps Engineer & Project Architect

**Trọng tâm:** Cây dự án, Data Pipeline end-to-end, MLOps Workflow, mục tiêu cốt lõi

**Source code bắt buộc đọc:**
- Toàn bộ cấu trúc thư mục repo
- `legacy/init-db.sql` (178 dòng)
- `legacy/create_actionable_views.sql` (33 dòng)
- `legacy/setup_db_mail_template.sql` (74 dòng — Database Mail, Gmail SMTP)
- `notebooks/HR_Analytics_Project_Final.ipynb` (luồng ETL + ML)
- `WrenAI/docker/docker-compose.yaml` (6 services overview)
- `WrenAI/docker/config.yaml` (LLM, Embedder, Qdrant)
- `HR_Analytics.bak` (SQL Server backup)

**Deep dive questions (trả lời trong docx):**

1. Q1: Mục tiêu cốt lõi của dự án? Chuyển đổi HR Thụ động → Chủ động?
2. Q2: Dân chủ hóa dữ liệu (Data Democratization) nghĩa là gì?
3. Q3: Tại sao bảo mật quan trọng? Chỉ gửi Metadata cho LLM?
4. Q4: Luồng ETL hoạt động cụ thể như thế nào?
5. Q5: Model Drift là gì? Khi nào cần Retrain?
6. Q6: Data Validation chống 'Garbage in, Garbage out'?
7. Q7: Trigger logic: Tại sao chạy theo tháng?
8. Q8: Giám sát phân phối dữ liệu (Monitoring)?
9. Q9: Human-in-the-loop: AI hỗ trợ hay thay thế HR Director?
10. Q10: Production Tools: Notebook → Apache Airflow / SQL Server Agent Job?
11. Q11: Tại sao nên dùng Local LLM (Ollama) thay vì Cloud API?
12. Q12: Giá trị Email Insight và HTML Report?

**Deliverables:**
- Docx trả lời Q1-Q12 (có sơ đồ minh họa)
- Sơ đồ Cây Dự Án (Project Anatomy) — 3 layers
- Sơ đồ Data Flow end-to-end
- Sơ đồ MLOps Workflow
- Slide trình bày tổng quan dự án (7-10 slides)
- Bảng PCCV hoàn chỉnh

---

## 5. Hướng dẫn cấu hình 5 nghiệp vụ HR trên Wren AI UI

### 5.1 Cách tạo Relationship (cho Khải, Hân)

1. Mở Wren AI UI → **Modeling** tab
2. Click vào model cần tạo relationship (VD: `Employee_Profile`)
3. Click **Add Relationship**
4. Chọn model liên kết (VD: `Department`)
5. Chọn Join Type: `MANY_TO_ONE`
6. Chọn Join Column:
   - From: `Employee_Profile.department` → To: `Department.department_name`
7. Click **Save**
8. **Quan trọng:** Sau khi thêm, click **Deploy** ở góc trên phải để sync vào AI

### 5.2 Cách tạo Calculated Field (cho Khải, Hân)

1. Mở **Modeling** → Chọn model (VD: `Employee_Profile`)
2. Click **Add Calculated Field**
3. Nhập tên: VD `Age_Group`
4. Nhập biểu thức SQL:
   ```sql
   CASE 
     WHEN age < 30 THEN 'Young'
     WHEN age < 45 THEN 'Mid-Career'
     ELSE 'Senior'
   END
   ```
5. Chọn data type: `VARCHAR`
6. Click **Save** → **Deploy**

### 5.3 Cách thêm SQL Pair (cho Ninh)

1. Mở **Knowledge** tab → **Question SQL Pairs**
2. Click **+ Add SQL Pair**
3. Nhập:
   - **Question:** "Top 5 nhân viên có nguy cơ nghỉ việc cao nhất tháng này"
   - **SQL:**
     ```sql
     SELECT TOP 5 
       e.employee_id,
       e.employee_name,
       a.probability_score,
       a.risk_level,
       e.department
     FROM Attrition_Forecast a
     JOIN Employee_Profile e ON a.employee_id = e.employee_id
     WHERE a.risk_level IN ('High', 'Critical')
     ORDER BY a.probability_score DESC
     ```
4. Click **Save** → Hệ thống tự động vector hóa và lưu vào Qdrant

### 5.4 Cách thêm Instruction (cho Ninh)

1. Mở **Knowledge** tab → **Instructions**
2. Click **+ Add Instruction**
3. Nhập:
   - **Instruction:** "Khi hỏi về rủi ro nghỉ việc, mặc định chỉ hiển thị nhân viên có risk_level là 'High' hoặc 'Critical', trừ khi người dùng yêu cầu khác."
   - **Type:** Global (áp dụng cho mọi câu hỏi)
4. Click **Save** → **Deploy**

### 5.5 Quy trình Deploy sau khi cấu hình

```
Thêm Modeling/Relationship/Calculated Field
    ↓
Click "Deploy" (góc trên phải UI)
    ↓
Wren AI tự động:
  1. Cập nhật MDL trong Wren Engine
  2. Re-index schema vào Qdrant (db_schema collection)
  3. Sẵn sàng nhận câu hỏi mới
    ↓
Thêm SQL Pairs / Instructions
    ↓
Tự động vector hóa và lưu vào Qdrant
    ↓
Test bằng cách hỏi câu hỏi trên Chat UI
```

---

## 6. Hướng dẫn verify và test demo performance

### 6.1 Test trên Public Link

1. Mở link: **https://certification-lows-spy-tension.trycloudflare.com**
2. Click **+ New** để tạo thread mới
3. Nhập câu hỏi test cho từng nghiệp vụ:

**Test Khải:**
```
- "Tổng quỹ lương của từng phòng ban là bao nhiêu?"
- "Nhân viên nào có thời gian làm việc > 10 năm nhưng chưa được thăng chức?"
- "So sánh tỷ lệ nghỉ việc giữa nhân viên làm thêm giờ và không làm thêm giờ"
```

**Test Hân:**
```
- "Phân nhóm nhân viên theo độ tuổi và tỷ lệ nghỉ việc của từng nhóm?"
- "Nhân viên nào có lương thấp hơn trung bình phòng ban?"
- "Danh sách High Performer at Risk?"
```

**Test Ninh:**
```
- "Top 5 nhân viên có nguy cơ nghỉ việc cao nhất?"
- "Nhân viên nào có điểm burnout nguy hiểm?"
- "So sánh tỷ lệ nghỉ việc dự báo giữa các job role?"
```

### 6.2 Kiểm tra performance

Khi AI trả lời, kiểm tra:

1. **View SQL** tab: SQL sinh ra có đúng logic không?
2. **Chart** tab: Biểu đồ có hiển thị đúng dữ liệu không?
3. **Answer** tab: Câu trả lời có chính xác, có insights không?
4. **Answer preparation steps**: Kiểm tra AI đi qua bao nhiêu bước (thường 3 steps)

### 6.3 Chụp screenshot cho docx

Khi test xong mỗi nghiệp vụ, chụp:
- Screenshot câu hỏi + câu trả lời (Answer tab)
- Screenshot SQL được sinh ra (View SQL tab)
- Screenshot Chart nếu có (Chart tab)
- Screenshot Answer preparation steps

---

## 7. Hướng dẫn deep dive research source code

### 7.1 Cách đọc source code hiệu quả

```powershell
# Clone repo về máy
git clone https://gitlab.com/boygia757-netizen/hr-ai-project.git
cd hr-ai-project

# Mở bằng VS Code
code .

# Tìm file theo tên
# Ctrl+P → gõ tên file (VD: "sql_generation.py")

# Tìm theo nội dung
# Ctrl+Shift+F → gõ keyword (VD: "Hamilton", "DAG", "pipeline")
```

### 7.2 Cách đọc luồng xử lý (dành cho cả 3 người AI)

**Luồng Text-to-SQL end-to-end:**

```
User nhập câu hỏi trên UI
    ↓
[wren-ui] POST /api/graphql → mutation createThread
    ↓
[wren-ui] Gọi wren-ai-service POST /v1/asks
    ↓
[wren-ai-service] Intent Classification Pipeline
  → Phân loại: TEXT_TO_SQL / GENERAL / USER_GUIDE / MISLEADING_QUERY
    ↓
[wren-ai-service] DB Schema Retrieval Pipeline
  → Qdrant cosine similarity search → Top-K relevant tables
  → LLM column selection → Filtered schema context
    ↓
[wren-ai-service] SQL Generation Pipeline
  → Hamilton DAG: prompt → generate (Gemini API) → post_process
    ↓
[wren-engine] Validate SQL syntax (dry-run)
    ↓
Nếu lỗi → SQL Correction Pipeline (retry tối đa 3 lần)
    ↓
[ibis-server] Translate MDL SQL → T-SQL (MSSQL native)
    ↓
[MSSQL] Execute SQL → Return results
    ↓
[wren-ai-service] SQL Answer Pipeline → Natural language answer
    ↓
[wren-ai-service] Chart Generation Pipeline → Vega-Lite spec
    ↓
[wren-ui] Hiển thị Answer + SQL + Chart cho user
```

### 7.3 Cách xem Docker logs để hiểu luồng

```powershell
# Xem log realtime của AI service khi hỏi câu hỏi
docker logs -f wrenai-wren-ai-service-1

# Xem log của Wren Engine
docker logs -f wrenai-wren-engine-1

# Xem log của Ibis Server (SQL translation)
docker logs -f wrenai-ibis-server-1

# Xem log của tất cả containers cùng lúc
docker compose logs -f
```

### 7.4 Cách kiểm tra Qdrant collections

```powershell
# Qua wren-ai-service container
docker exec wrenai-wren-ai-service-1 python -c "
import urllib.request
r = urllib.request.urlopen('http://qdrant:6333/collections')
print(r.read().decode())
"

# Kiểm tra số documents trong mỗi collection
# Document (db_schema) = 52 → schema vectors
# table_descriptions = 17 → table description vectors
# sql_pairs = 0 → sẽ tăng khi team thêm SQL Pairs
# instructions = 0 → sẽ tăng khi team thêm Instructions
```

---

## 8. Yêu cầu đầu ra (Deliverables)

### 8.1 Khải, Hân, Ninh (AI Engineering)

| Deliverable | Mô tả | Định dạng |
|-------------|--------|-----------|
| **Docx Deep Dive** | Trả lời tất cả deep dive questions, dẫn chứng source code, số dòng | .docx |
| **5 nghiệp vụ HR** | Cấu hình trên Wren AI UI, chụp screenshot kết quả | Screenshots trong docx |
| **Sơ đồ kỹ thuật** | Kiến trúc, pipeline, indexing flow | draw.io / Mermaid |
| **Demo live** | Hỏi câu hỏi trên public link, show kết quả | Live / Recording |
| **Through-back Q&A** | Chuẩn bị trả lời 8 câu hỏi vấn đáp showcase | Trong docx chung |

### 8.2 Gia (Data Analytics)

| Deliverable | Mô tả | Định dạng |
|-------------|--------|-----------|
| **Docx Report** | Trả lời Q1-Q9, biểu đồ, số liệu | .docx |
| **Giải thích Notebook** | Cell 1-18: mục đích, input, output, thư viện | Trong docx |
| **Biểu đồ** | Feature importance, correlation heatmap, Risk by Department | Ảnh/chart |
| **Slide** | Business Insights (5-7 slides) | .pptx |

### 8.3 Uyên (MLOps & Architecture)

| Deliverable | Mô tả | Định dạng |
|-------------|--------|-----------|
| **Docx Tổng quan** | Trả lời Q1-Q12, dẫn chứng file repo | .docx |
| **3 Sơ đồ** | Cây dự án, Data Flow, MLOps Workflow | draw.io / Mermaid |
| **Slide** | Tổng quan dự án (7-10 slides) | .pptx |
| **Bảng PCCV** | File Excel PCCV_HR_Analytics_v3.xlsx | .xlsx |

---

## 9. Timeline và checklist

| Ngày | Hoạt động | Ai | Checklist |
|------|-----------|-----|-----------|
| **11/02 (T3)** | Nhận tài liệu, clone repo, chạy dự án | Tất cả | ☐ Repo chạy thành công |
| **12/02 (T4)** | Đọc source code theo phân công | Tất cả | ☐ Ghi chú cá nhân |
| **13/02 (T5)** | Cấu hình 5 nghiệp vụ HR, test trên UI | Khải, Hân, Ninh | ☐ 5 nghiệp vụ active |
| **13/02 (T5)** | Giải thích notebook, tạo biểu đồ | Gia | ☐ Draft report + biểu đồ |
| **13/02 (T5)** | Vẽ sơ đồ, viết phần tổng quan | Uyên | ☐ Draft 3 sơ đồ |
| **14/02 (T6)** | Viết Docx deep dive | Tất cả | ☐ Draft Docx |
| **15/02 (T7)** | Hoàn thiện Docx, tạo Slide, review chéo | Tất cả | ☐ Docx + Slide final |
| **16/02 (CN)** | Push deliverables lên GitLab, dry run | Tất cả | ☐ Tất cả trên GitLab |

---

## PHỤ LỤC

### A. Thông tin kỹ thuật hệ thống

| Thông số | Giá trị |
|----------|---------|
| LLM Model | `gemini/gemini-2.5-flash` (1M token context) |
| Embedder | `gemini-embedding-001` (768 dimensions) |
| Vector DB | Qdrant v1.11.0 (6 collections, 70+ documents) |
| Database | SQL Server 2019 (HR_Analytics DB) |
| Framework | Wren AI v0.29.0+ |
| Containers | 6 services (docker-compose) |
| Pipelines | 29 total (19 generation + 6 indexing + 4 retrieval) |

### B. Liên hệ

- **GitLab:** https://gitlab.com/boygia757-netizen/hr-ai-project
- **Branch:** `hr_domain_research`
- **Public Demo:** https://certification-lows-spy-tension.trycloudflare.com
- **Tài liệu thêm:** `TAI_LIEU_DU_AN_HR_ANALYTICS.md`, `ONBOARDING_GUIDE.md`
