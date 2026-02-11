# HƯỚNG DẪN CLONE GITLAB VÀ SETUP DỰ ÁN

**Mã học phần:** 252BIM500601  
**Đề tài:** Ứng dụng AI trong phân tích rủi ro nghỉ việc nhân sự  
**Ngày cập nhật:** 11/02/2026  

---

## ✅ BƯỚC 1: CLONE GITLAB VỚI ACCESS TOKEN

### 1.1 Thông tin truy cập GitLab

| Thông tin | Giá trị |
|-----------|--------|
| **GitLab URL** | https://gitlab.com/boygia757-netizen/hr-ai-project |
| **Branch chính** | `hr_domain_research` (dùng cho team) |
| **Branch production** | `main` (cấm push lên) |
| **Access Token (gia)** | `glpat-I1s2qe7-q09FgrR7nuXxtG86MQp10mtsYzZxCw` |
| **Token Role** | Owner (api, read_api, create_runner, write_repository) |

### 1.2 Thông tin User theo Role Developer

| Tên | Mã SV | Token | Role | Scope |
|-----|-------|-------|------|-------|
| Khải | K234060700 | `glpat-khai...` | Developer | api, read_api, create_runner, write_repository |
| Hân | K234060691 | `glpat-han...` | Developer | api, read_api, create_runner, write_repository |
| Ninh | K234060716 | `glpat-ninh...` | Developer | api, read_api, create_runner, write_repository |
| Uyên | K234060737 | `glpat-uyen...` | Developer | api, read_api, create_runner, write_repository |

### 1.3 Clone repo bằng 1 câu lệnh

**Sử dụng Access Token của mình:**

```bash
# Thay YOUR_TOKEN bằng token của bạn
git clone https://oauth2:YOUR_TOKEN@gitlab.com/boygia757-netizen/hr-ai-project.git
cd hr-ai-project

# Checkout branch chính (KHÔNG checkout main)
git checkout hr_domain_research
```

**Ví dụ cụ thể cho Khải:**

```bash
git clone https://oauth2:glpat-khaitoken123@gitlab.com/boygia757-netizen/hr-ai-project.git
cd hr-ai-project
git checkout hr_domain_research
```

### 1.4 Cấu hình Git global (lần đầu tiên)

```bash
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"

# Ví dụ:
git config --global user.name "Khải"
git config --global user.email "khai@example.com"
```

---

## ✅ BƯỚC 2: SETUP SQL SERVER VỀ LOCAL VỀ DOCKER

### 2.1 Restore HR_Analytics.bak vào Docker SQL Server

**Bước 1: Copy file HR_Analytics.bak vào Docker container**

```powershell
# Từ thư mục gốc dự án
cd C:\Users\[YourUsername]\HR Analytics text to sql agent\hr-ai-project

# Copy file .bak vào container (tìm container name từ docker ps)
docker cp HR_Analytics.bak hr-sql-server:/var/opt/mssql/backup/

# Verify file đã copy
docker exec hr-sql-server ls -la /var/opt/mssql/backup/
```

**Bước 2: Restore database từ backup**

```powershell
# Kết nối vào SQL Server container qua sqlcmd
docker exec -it hr-sql-server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YourSAPassword"

# Trong sqlcmd prompt, chạy lệnh restore:
RESTORE DATABASE HR_Analytics 
FROM DISK = '/var/opt/mssql/backup/HR_Analytics.bak'
WITH MOVE 'HR_Analytics' TO '/var/opt/mssql/data/HR_Analytics.mdf',
     MOVE 'HR_Analytics_log' TO '/var/opt/mssql/data/HR_Analytics_log.ldf'
GO

# Exit sqlcmd
EXIT
```

**Bước 3: Verify restore thành công**

```powershell
# Kiểm tra databases
docker exec -it hr-sql-server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YourSAPassword" -Q "SELECT name FROM sys.databases WHERE name='HR_Analytics'"

# Kết quả mong đợi:
# name
# HR_Analytics
```

### 2.2 Kết nối SQL Server Container với Docker Network

**SQL Server container đã tự động kết nối với network `wren`**

```powershell
# Kiểm tra network
docker network ls | findstr wren

# Verify container kết nối tới network
docker network inspect wren | findstr -A 50 "Containers"
```

**Connection String từ các service khác trong Docker:**

```
Server=hr-sql-server:1433;User Id=SA;Password=YourSAPassword;Database=HR_Analytics;
```

**Connection String từ máy local (Windows):**

```
Server=localhost,1433;User Id=SA;Password=YourSAPassword;Database=HR_Analytics;
```

---

## ✅ BƯỚC 3: KHỞI ĐỘNG DOCKER VÀ VERIFY

### 3.1 Khởi động Docker Compose

```powershell
cd C:\Users\[YourUsername]\HR Analytics text to sql agent\hr-ai-project\WrenAI\docker

# Khởi động tất cả containers
docker compose up -d

# Kiểm tra status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Kết quả mong đợi: 6 containers UP**

| Container | Status | Port |
|-----------|--------|------|
| wrenai-wren-ui-1 | Up | 0.0.0.0:3000->3000/tcp |
| wrenai-wren-ai-service-1 | Up | 0.0.0.0:5555->5555/tcp |
| wrenai-wren-engine-1 | Up | 7432/tcp, 8080/tcp |
| wrenai-qdrant-1 | Up | 6333-6334/tcp |
| wrenai-ibis-server-1 | Up | 8000/tcp |
| hr-sql-server | Up | 0.0.0.0:1433->1433/tcp |

### 3.2 Health Check

```powershell
# 1. Check AI Service health
Invoke-RestMethod -Uri "http://localhost:5555/health"

# Kết quả mong đợi: {"status":"ok"}

# 2. Mở UI trên trình duyệt
Start-Process "http://localhost:3000"

# 3. Kiểm tra Qdrant
Invoke-RestMethod -Uri "http://localhost:6333/health"

# 4. Verify SQL Server kết nối
docker exec -it hr-sql-server /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "YourSAPassword" -Q "SELECT COUNT(*) as EmployeeCount FROM HR_Analytics.dbo.MS_EMPLOYEE"
```

---

## ✅ BƯỚC 4: CẤU HÌNH 5 NGHIỆP VỤ HR TRÊN UI

### 4.1 Cách Cấu hình Từng Loại

#### A. Tạo Relationship (Khải, Hân)

**Ví dụ: Employee_Profile → Department**

```
1. Mở Wren AI UI → tab Modeling
2. Chọn model "Employee_Profile"
3. Click "Add Relationship"
4. Relationship Details:
   - Name: "employee_in_department"
   - With Model: "Department"
   - Join Type: MANY_TO_ONE
   - From: Employee_Profile.department_id
   - To: Department.department_id
5. Click "Save" → "Deploy" (góc phải)
```

#### B. Tạo Calculated Field (Khải, Hân)

**Ví dụ: Age_Group (Hân)**

```
1. Modeling → Model: Employee_Profile
2. Click "Add Calculated Field"
3. Name: Age_Group
4. Expression:
   CASE 
     WHEN age < 30 THEN 'Young'
     WHEN age < 45 THEN 'Mid-Career'
     ELSE 'Senior'
   END
5. Data Type: VARCHAR
6. Click "Save" → "Deploy"
```

#### C. Thêm SQL Pair (Ninh)

**Ví dụ: Top 5 nhân viên rủi ro**

```
1. Knowledge → Question SQL Pairs
2. Click "+ Add SQL Pair"
3. Question: "Top 5 nhân viên có nguy cơ nghỉ việc cao nhất?"
4. SQL:
   SELECT TOP 5
     e.employee_id,
     e.employee_name,
     af.attrition_prediction,
     af.probability_score,
     e.department
   FROM ms_employee e
   LEFT JOIN attrition_forecast af ON e.employee_id = af.employee_id
   WHERE af.probability_score > 0.6
   ORDER BY af.probability_score DESC
5. Click "Save" → tự động vector hóa + index vào Qdrant
```

#### D. Thêm Instruction (Ninh)

**Ví dụ: Lọc mặc định theo risk level**

```
1. Knowledge → Instructions
2. Click "+ Add Instruction"
3. Instruction: "Khi hỏi về rủi ro, mặc định chỉ hiển thị nhân viên có risk_level = 'High' hoặc 'Critical'"
4. Type: Global
5. Click "Save" → "Deploy"
```

### 4.2 Chi Tiết 5 Nghiệp Vụ cho Mỗi Người

#### KHẢI (Infrastructure) - 5 Nghiệp Vụ

| # | Nghiệp vụ | Loại | SQL/Expression | File Test |
|---|-----------|------|----------------|-----------|
| 1 | Tổng quỹ lương theo phòng ban | Calculated Field + Relationship | `SUM(monthly_income * 12) as annual_salary_budget` | Test bằng: "Tổng quỹ lương của từng phòng ban?" |
| 2 | Nhân viên > 10 năm chưa thăng chức | SQL Pair | `years_at_company > 10 AND years_since_last_promotion > 5` | Test: "Nhân viên nào có thời gian làm việc > 10 năm nhưng chưa thăng chức?" |
| 3 | So sánh nghỉ việc: làm thêm giờ vs không | SQL Pair | `GROUP BY OverTime, COUNT(attrition) as count` | Test: "So sánh tỷ lệ nghỉ việc giữa nhân viên làm thêm giờ và không?" |
| 4 | Nhân viên lương bất thường | Instruction | "Bất thường = |lương - trung bình phòng| > 1.5 * stddev" | Test: "Nhân viên nào có mức lương bất thường?" |
| 5 | Báo cáo tổng hợp | SQL Pair | `SELECT COUNT(*), SUM(IF(attrition_prediction='Yes',1,0)), COUNT(DISTINCT department)` | Test: "Báo cáo tổng hợp: tổng NV, số NV rủi ro, số phòng ban?" |

#### HÂN (Semantic Layer) - 5 Nghiệp Vụ

| # | Nghiệp vụ | Loại | Chi tiết | Test |
|---|-----------|------|----------|------|
| 1 | Phân nhóm tuổi | Calculated Field | `Age_Group = CASE WHEN age<30 THEN 'Young'...` | "Phân nhóm nhân viên theo độ tuổi?" |
| 2 | So sánh lương with dept avg | Relationship + Calculated | Join Employee→Dept, tính `salary_vs_avg` | "Ai có lương thấp hơn trung bình phòng?" |
| 3 | Nhân viên undervalued | Instruction | `total_working_years>10 AND job_level<=2` | "Nhân viên nào có kinh nghiệm cao nhưng level thấp?" |
| 4 | Work-life balance vs attrition | SQL Pair | Multi-table join GroupBy dept | "Phân tích work-life balance vs attrition?" |
| 5 | High Performer at Risk | SQL Pair | `performance>=3 AND risk_level IN ('High','Critical')` | "Nhân viên High Performer có rủi ro nào?" |

#### NINH (Agentic) - 5 Nghiệp Vụ

| # | Nghiệp vụ | Loại | Chi tiết | Test |
|---|-----------|------|----------|------|
| 1 | Top 5 rủi ro cao nhất | SQL Pair | CTE+ROW_NUMBER+risk_level | "Top 5 nhân viên rủi ro cao nhất?" |
| 2 | Điểm burnout nguy hiểm | SQL Pair+Instruction | Formula: `overtime*3 + travel*2 + tenure_gap*1.5` | "Nhân viên nào có burnout nguy hiểm?" |
| 3 | Lọc mặc định risk_level | Instruction (Global) | "Mặc định chỉ hiển thị High/Critical" | "Liệt kê nhân viên rủi ro" |
| 4 | So sánh by job_role | SQL Pair | Multi-group aggregation | "So sánh tỷ lệ rủi ro giữa các job role?" |
| 5 | Mặc định monthly_income | Instruction (Global) | "Luôn dùng monthly_income, không daily_rate" | "Tính lương trung bình?" |

---

## ✅ BƯỚC 5: GIT WORKFLOW - PUSH LÊN GITLAB

### 5.1 Quy Trình Standard Git

```bash
# 1. Kiểm tra branch hiện tại (phải là hr_domain_research)
git branch -a
# Output: * hr_domain_research

# 2. Xem tệp đã thay đổi
git status

# 3. Add tệp (cách 1: add cụ thể)
git add HUONG_DAN_TEAM_DEV.docx
git add khải/Q_deepdive.docx khải/use_cases_screenshots/
git add khải/architecture_diagram.png

# 3. Add tệp (cách 2: add tất cả)
git add .

# 4. Commit với message rõ ràng
git commit -m "Khải: Hoàn thiện 5 use cases + deep dive Q1-Q8 + architecture diagram"

# 5. Push lên GitLab
git push origin hr_domain_research

# Kết quả mong đợi:
# To https://gitlab.com/boygia757-netizen/hr-ai-project.git
#    47ad50e..abc1234  hr_domain_research -> hr_domain_research
```

### 5.2 Quy Tắc Commit Message

**Format:**

```
[Tên_người]: [Mô_tả_công_việc] + [Deliverable]
```

**Ví dụ:**

```bash
git commit -m "Khải: Deep dive Q1-Q8 + 5 use cases infrastructure + docker logs analysis"

git commit -m "Hân: Semantic layer questions Q1-Q9 + 5 calculated fields + Qdrant indexing diagram"

git commit -m "Ninh: SQL generation pipeline + 5 SQL pairs + 5 instructions + through-back Q&A"

git commit -m "Gia: Feature importance analysis + business insights report + ML explanations + slides"

git commit -m "Uyên: Project architecture + 3 diagrams (anatomy, dataflow, mlops) + 12 Q answers"
```

### 5.3 Cấu Trúc Folder Trên GitLab

```
hr-ai-project/
├── khải/
│   ├── Q1_Q8_deepdive.docx
│   ├── 5_use_cases_screenshots/
│   │   ├── use_case_1_total_salary.png
│   │   ├── use_case_2_10_years_no_promo.png
│   │   ├── use_case_3_overtime_attrition.png
│   │   ├── use_case_4_salary_abnormal.png
│   │   ├── use_case_5_summary_report.png
│   ├── architecture_diagram.png
│   ├── docker_logs_analysis.txt
│   └── README.md
│
├── hân/
│   ├── Q1_Q9_semantic_layer.docx
│   ├── 5_use_cases_screenshots/
│   ├── qdrant_collections_diagram.png
│   ├── indexing_flow_diagram.png
│   └── README.md
│
├── ninh/
│   ├── Q1_Q9_agentic_layer.docx
│   ├── 5_use_cases_screenshots/
│   ├── sql_generation_dag.png
│   ├── api_endpoints_table.xlsx
│   └── README.md
│
├── gia/
│   ├── ML_Analysis_Report.docx
│   ├── Feature_Importance_Chart.png
│   ├── Correlation_Heatmap.png
│   ├── Business_Insights_Slides.pptx
│   └── README.md
│
├── uyên/
│   ├── Architecture_Summary.docx
│   ├── Project_Anatomy_Diagram.png
│   ├── DataFlow_Diagram.png
│   ├── MLOps_Workflow_Diagram.png
│   ├── Slides_Overview.pptx
│   └── README.md
│
└── HUONG_DAN_TEAM_DEV.docx (tài liệu chung)
```

### 5.4 Hướng Dẫn Tạo README cho Mỗi Người

**File: khải/README.md**

```markdown
# Khải (K234060700) — Infrastructure & Connectivity Owner

## Deliverables

- ✅ Deep dive Q1-Q8 (docx)
- ✅ 5 use cases cấu hình thành công (screenshots)
- ✅ Architecture diagram (6 containers + luồng dữ liệu)
- ✅ Docker logs analysis
- ✅ Through-back Q1, Q4, Q5, Q6 (chuẩn bị)

## Setup Instructions

1. Clone repo: `git clone https://oauth2:[token]@gitlab.com/boygia757-netizen/hr-ai-project.git`
2. Restore HR_Analytics.bak (xem hướng dẫn chung)
3. Chạy: `docker compose up -d`
4. Verify: Tất cả 6 containers UP

## Test 5 Use Cases

```powershell
# Hỏi câu hỏi lần lượt, kiểm tra SQL + Chart
"Tổng quỹ lương của từng phòng ban?"
"Nhân viên nào có > 10 năm chưa thăng chức?"
"So sánh tỷ lệ nghỉ việc: làm thêm giờ vs không?"
"Nhân viên nào có lương bất thường?"
"Báo cáo tổng hợp (tổng NV, rủi ro, tỷ lệ churn)?"
```

## Files

- Q1_Q8_deepdive.docx: 8 câu hỏi chi tiết + trích dẫn source code
- 5_use_cases_screenshots/: Screenshots kết quả từ UI
- architecture_diagram.png: Sơ đồ 6 containers
- docker_logs_analysis.txt: Log khi hỏi câu hỏi
```

---

## ✅ BƯỚC 6: TEST TRÊN PUBLIC LINK

### 6.1 Public Link Demo

```
https://certification-lows-spy-tension.trycloudflare.com
```

### 6.2 Test Workflow cho Mỗi Người

**KHẢI Test:**

```
1. Mở https://certification-lows-spy-tension.trycloudflare.com
2. Click "+ New" → Chat
3. Hỏi: "Tổng quỹ lương của từng phòng ban?"
   → Kiểm tra: View SQL → Chart → Answer
4. Chụp screenshot 5 use cases
```

**HÂN Test:**

```
1. Mở https://certification-lows-spy-tension.trycloudflare.com
2. Tab "Modeling" → Verify 5 Calculated Fields
3. Tab "Setup" → Relationships → Verify Relationships
4. Chat: Hỏi các use cases
5. Chụp screenshots
```

**NINH Test:**

```
1. Tab "Knowledge" → SQL Pairs → Verify 5 pairs
2. Tab "Instructions" → Verify 5 instructions
3. Chat: Hỏi các use cases
4. Kiểm tra AI dùng Instruction đúng không
```

---

## ✅ BƯỚC 7: DEADLINE VÀ SUBMISSION

### 7.1 Timeline

| Ngày | Công việc | Checklist |
|------|-----------|-----------|
| 11/02 | Clone repo, restore SQL, chạy Docker | ☐ Repo UP, SQL connected |
| 12/02 | Đọc source code + ghi chú | ☐ Notes hoàn chỉnh |
| 13/02 | Cấu hình 5 use cases + test | ☐ 5 use cases active |
| 14/02 | Viết docx deep dive | ☐ Docx draft |
| 15/02 | Hoàn thiện + screenshot | ☐ All screenshots |
| 16/02 | Push GitLab + submit | ☐ Push successful |

### 7.2 Final Submission

```bash
# Cuối cùng, mỗi người push lên GitLab
git add .
git commit -m "[Tên]: Final submission - Q&A + Use Cases + Screenshots"
git push origin hr_domain_research

# Tạo folder cá nhân:
# - git add tên_người/
# - git add tên_người/Q_answers.docx
# - git add tên_người/*.png
```

---

## 📞 LIÊN HỆ HỖ TRỢ

- **GitLab:** https://gitlab.com/boygia757-netizen/hr-ai-project
- **Public Demo:** https://certification-lows-spy-tension.trycloudflare.com
- **Local UI:** http://localhost:3000
- **AI Service Health:** http://localhost:5555/health
- **Qdrant:** http://localhost:6333/dashboard
