# Tai lieu ky thuat du an HR Analytics -- He thong du bao nghi viec va truy van insight nhan su

Ma so de tai: 252BIM500601
Phien ban: 1.0 -- Ngay cap nhat: 09/02/2026


## Muc luc

1. Tong quan du an va muc tieu nghiep vu
2. Kien truc he thong tong the
3. Cay du an va chuc nang tung thanh phan
4. Co so du lieu HR Analytics -- Schema va ERD
5. Cau hinh Wren AI cho bai toan HR Analytics
6. Semantic Layer -- co che hoat dong cot loi
7. Cau hinh LLM va Embedder (Gemini API)
8. SQL Pairs va Instructions -- tri thuc nghiep vu
9. Pipeline xu ly truy van Text-to-SQL
10. Chart Generation -- truc quan hoa du lieu
11. Cau hinh tieng Viet cho nguoi dung Viet Nam
12. Bao mat thong tin nhan vien khi truy van qua LLM
13. Deep dive -- tai sao chon Wren AI thay vi LangChain
14. Huong dan khoi dong va van hanh he thong
15. Ket qua dat duoc va danh gia


---


## 1. Tong quan du an va muc tieu nghiep vu

Du an HR Analytics duoc xay dung nham giai quyet hai van de cot loi trong quan tri nhan su hien dai. Thu nhat, doanh nghiep thieu kha nang du bao som nguy co nghi viec cua nhan vien, chi biet khi ho nop don. Thu hai, viec truy xuat insight nhan su doi hoi ky nang SQL chuyen sau hoac phu thuoc bo phan IT/Data, gay cham tre trong ra quyet dinh.

He thong giai quyet hai van de nay bang cach ket hop hai nang luc AI:

Predictive AI: Mo hinh Random Forest duoc huan luyen tren tap du lieu IBM HR Analytics (1470 nhan vien, 35 dac trung) de cham diem rui ro nghi viec cho tung nhan vien. Ket qua du bao duoc luu tru trong bang tr_attrition_result voi cac truong probability_score (xac suat nghi viec tu 0 den 1), risk_level (Low, Medium, High, Critical), va prediction_label (0 hoac 1).

Generative AI (Text-to-SQL): Tro ly ao cho phep nguoi dung HR hoi dap du lieu bang ngon ngu tu nhien tieng Viet. He thong tu dong chuyen cau hoi thanh truy van SQL, thuc thi tren co so du lieu, va tra ve ket qua kem giai thich. Day la thanh phan duoc trien khai bang Wren AI, la trong tam ky thuat cua du an.

Muc tieu cuoi cung la cung cap cho HR Manager mot cong cu tu phuc vu, khong can biet SQL, co the tu dat cau hoi nhu "10 nhan vien co nguy co nghi viec cao nhat va cac feature bat thuong so voi nhom an toan" va nhan duoc cau tra loi co du lieu cu the, bieu do truc quan, trong vong vai chuc giay.


## 2. Kien truc he thong tong the

He thong duoc trien khai hoan toan bang Docker Compose gom 6 container chay dong thoi, giao tiep qua mang noi bo Docker. Kien truc tuan theo mo hinh phan lop cua Wren AI gom 4 lop:

Data Layer: Ket noi truc tiep toi co so du lieu MSSQL Server (container hr-sql-server) chua toan bo du lieu nhan su. Wren Engine va Ibis Server dong vai tro trung gian, doc metadata va thuc thi truy van SQL tren data source.

Semantic Layer: La lop truu tuong hoa du lieu, dinh nghia cac model, relationship, calculated field va mo ta nghiep vu (description) cho tung bang, tung cot. Semantic Layer duoc luu tru trong Wren Engine duoi dang MDL (Model Definition Language) va duoc index vao Qdrant Vector Database de phuc vu retrieval.

Agentic Layer: Wren AI Service (Python, Haystack framework) xu ly toan bo logic AI gom intent classification, schema retrieval, SQL generation, SQL correction, chart generation. Moi chuc nang duoc to chuc thanh mot pipeline rieng biet. LLM (Gemini 2.5 Flash) va Embedder (Gemini Embedding 001) duoc goi qua LiteLLM voi Gemini API key (Google AI Studio).

Representation Layer: Wren UI (Next.js) la giao dien web cho nguoi dung, cung cap trang hoi dap (Home), quan ly Modeling, va hien thi ket qua gom bang du lieu, giai thich van ban, va bieu do Vega-Lite.

So do cac container va cong giao tiep:

```
wren-ui (port 3000)  <-->  wren-ai-service (port 5555)  <-->  Gemini API
      |                           |
      v                           v
wren-engine (port 8080)      qdrant (port 6333)
      |
      v
ibis-server (port 8000)  <-->  hr-sql-server (port 1433)
```


## 3. Cay du an va chuc nang tung thanh phan

```
hr-ai-project/
|
|-- legacy/                              Scripts SQL khoi tao co so du lieu
|   |-- init-db.sql                      Tao bang MS_EMPLOYEE, TR_PERFORMANCE, ...
|   |-- create_actionable_views.sql      Tao views tong hop: v_hr_worker_risk, ...
|   |-- setup_db_mail_template.sql       Cau hinh canh bao email (mo rong)
|
|-- notebooks/                           Jupyter Notebook huan luyen mo hinh ML
|   |-- HR_Analytics_Project_Final.ipynb  Pipeline EDA, Feature Engineering,
|   |                                     Random Forest, XGBoost, du bao, xuat ket qua
|   |-- WA_Fn-UseC_-HR-Employee-Attrition.csv   Du lieu goc IBM HR Analytics
|   |-- HR_Critical_Risk_Report.xlsx     Bao cao nhan vien rui ro cao
|   |-- README.md                        Huong dan su dung notebook
|
|-- WrenAI/                              Repository Wren AI (customized)
    |-- docker/                          Cau hinh trien khai Docker Compose
    |   |-- docker-compose.yaml          Dinh nghia 6 services
    |   |-- config.yaml                  Cau hinh LLM, Embedder, Pipelines
    |   |-- .env                         Bien moi truong (API keys, versions)
    |   |-- bootstrap/                   Script khoi tao du lieu ban dau
    |
    |-- wren-ai-service/                 Backend AI (Python, Haystack)
    |   |-- src/
    |   |   |-- config.py                Doc va parse config.yaml
    |   |   |-- globals.py               Khoi tao tat ca pipeline instances
    |   |   |-- pipelines/
    |   |   |   |-- generation/          Cac pipeline sinh SQL, chart, ...
    |   |   |   |   |-- sql_generation.py          Text-to-SQL chinh
    |   |   |   |   |-- sql_correction.py          Tu dong sua SQL loi
    |   |   |   |   |-- intent_classification.py   Phan loai y dinh cau hoi
    |   |   |   |   |-- chart_generation.py        Sinh Vega-Lite chart
    |   |   |   |   |-- sql_answer.py              Giai thich ket qua SQL
    |   |   |   |   |-- question_recommendation.py Goi y cau hoi
    |   |   |   |   |-- misleading_assistance.py   Xu ly cau hoi ngoai pham vi
    |   |   |   |-- indexing/            Pipeline index du lieu vao vector DB
    |   |   |   |   |-- db_schema.py               Index schema cua database
    |   |   |   |   |-- sql_pairs.py               Index SQL Pairs mau
    |   |   |   |   |-- instructions.py            Index Instructions
    |   |   |   |-- retrieval/           Pipeline truy xuat tu vector DB
    |   |   |       |-- db_schema_retrieval.py     Tim bang/cot lien quan
    |   |   |       |-- sql_pairs_retrieval.py     Tim SQL Pairs tuong tu
    |   |   |       |-- sql_executor.py            Thuc thi SQL tren engine
    |   |   |-- providers/
    |   |   |   |-- llm/litellm.py       Wrapper goi LLM qua LiteLLM (Gemini API)
    |   |   |   |-- embedder/litellm.py  Wrapper goi Embedder qua LiteLLM (Gemini API)
    |   |   |   |-- engine/wren.py       Ket noi Wren Engine va Ibis
    |   |   |   |-- document_store/qdrant.py  Ket noi Qdrant vector DB
    |   |   |-- web/v1/                  FastAPI routes va services
    |   |       |-- routers/             API endpoints (asks, charts, ...)
    |   |       |-- services/            Business logic cho tung feature
    |
    |-- wren-ui/                         Frontend (Next.js, TypeScript)
        |-- src/
            |-- apollo/server/           GraphQL server-side
            |   |-- schema.ts            GraphQL type definitions
            |   |-- resolvers/           Xu ly mutations va queries
            |   |-- adaptors/            Giao tiep voi wren-ai-service
            |   |-- models/adaptor.ts    Enum ngon ngu, interfaces
            |-- components/              React components
            |   |-- chart/               Render bieu do Vega-Lite
            |-- pages/                   Next.js pages
                |-- home/                Trang hoi dap chinh
                |-- api/v1/              REST API endpoints
```


## 4. Co so du lieu HR Analytics -- Schema va ERD

Co so du lieu HR_Analytics chay tren MSSQL Server 2022, chua 7 bang chinh va 2 view. Quan he giua cac bang tuan theo mo hinh Master-Transaction.

### 4.1. Cac bang chinh

MS_EMPLOYEE (1470 dong): Bang master chua thong tin co ban nhan vien.
- employee_id (NVARCHAR, PK): Ma nhan vien, la khoa chinh cua toan bo he thong.
- full_name, age, gender, marital_status: Thong tin ca nhan.
- dept_id (FK -> MS_DEPARTMENT): Phong ban.
- job_role_id (FK -> MS_JOB_ROLE): Vai tro cong viec.
- distance_from_home, total_working_years, num_companies_worked: Thong tin bo sung.

MS_DEPARTMENT (3 dong): Human Resources, Research and Development, Sales.
- dept_id (INT, PK), dept_name.

MS_JOB_ROLE (9 dong): Sales Executive, Research Scientist, Laboratory Technician, ...
- role_id (INT, PK), role_name, dept_id (FK).

TR_PERFORMANCE (1470 dong): Du lieu hieu suat va luong thuong.
- employee_id (FK -> MS_EMPLOYEE): Lien ket 1-1 voi nhan vien.
- monthly_income, job_satisfaction (1-4), work_life_balance (1-4).
- environment_satisfaction (1-4), relationship_satisfaction (1-4).
- performance_rating (1-4), job_involvement (1-4).
- over_time (NVARCHAR: 'Yes'/'No'), years_at_company, years_since_last_promotion.
- stock_option_level, training_times_last_year, percent_salary_hike.

tr_attrition_result (2940 dong, 1470 nhan vien x 2 batch): Ket qua du bao tu mo hinh ML.
- employee_number (INT): Ma nhan vien (kieu INT, can CAST khi JOIN voi employee_id).
- probability_score (FLOAT): Xac suat nghi viec tu 0.0 den 1.0.
- attrition_prob (FLOAT): Tuong tu probability_score, giu de tuong thich.
- risk_level (NVARCHAR): 'Low' (< 0.30), 'Medium' (0.30-0.50), 'High' (0.50-0.75), 'Critical' (> 0.75).
- prediction_label (INT): 0 = khong nghi, 1 = du bao nghi viec.
- prediction_date, batch_date: Ngay du bao va ngay batch.

tr_feature_importance (60 dong): Muc do quan trong cua tung feature trong mo hinh.
- feature_name, importance_score, model_version ('RF_v2.0_OOF').

HR_Training_Data (1470 dong): Du lieu goc dung de huan luyen mo hinh, giu lai de tham chieu.
- employee_id (INT), attrition (INT: 0/1), over_time (INT: 0/1).
- Cac cot tuong tu TR_PERFORMANCE nhung kieu du lieu khac (INT thay vi NVARCHAR).

### 4.2. Cac view

v_hr_worker_risk: Tong hop thong tin nhan vien voi du bao rui ro va diem burnout. JOIN MS_EMPLOYEE, TR_PERFORMANCE, MS_DEPARTMENT, MS_JOB_ROLE, va tr_attrition_result (lay ket qua du bao moi nhat bang ROW_NUMBER). Tinh burnout_score theo cong thuc: OverTime='Yes' (30 diem) + WorkLifeBalance<=2 (25 diem) + JobSatisfaction<=2 (25 diem) + EnvironmentSatisfaction<=2 (20 diem).

v_Employee_Actionable_Insights: Tong hop HR_Training_Data voi tr_attrition_result, xac dinh top_risk_factors tu dong bang CASE WHEN (OverTime, LowJobSatisfaction, LowIncome, ShortTenure).

### 4.3. Quan he JOIN dac biet

Diem luu y quan trong nhat ve schema la kieu du lieu khong dong nhat giua MS_EMPLOYEE.employee_id (NVARCHAR) va tr_attrition_result.employee_number (INT). Moi truy van JOIN giua hai bang nay bat buoc phai dung phep CAST:

```sql
CAST(e."employee_id" AS INT) = a."employee_number"
```

Day la dac diem duoc cau hinh trong Instructions cua Wren AI de LLM tu dong ap dung khi sinh SQL.


## 5. Cau hinh Wren AI cho bai toan HR Analytics

### 5.1. Docker Compose (docker-compose.yaml)

He thong gom 6 services duoc dinh nghia trong docker-compose.yaml:

- bootstrap: Khoi tao du lieu ban dau (volumes, configs). Chay mot lan roi thoat.
- wren-engine: Core engine xu ly MDL (Semantic Layer), expose port 8080.
- ibis-server: Adapter ket noi toi data source (MSSQL), expose port 8000. Day la thanh phan thuc thi SQL thuc te tren co so du lieu.
- wren-ai-service: Backend AI xu ly toan bo logic Text-to-SQL, chart, recommendations. Expose port 5555. Doc config tu /app/config.yaml (mount tu host).
- qdrant: Vector database luu tru embeddings cua schema, SQL Pairs, Instructions. Su dung anh qdrant/qdrant:v1.11.0.
- wren-ui: Giao dien web (Next.js), expose port 3000. Ket noi toi wren-engine, wren-ai-service, va ibis-server.

Container MSSQL Server (hr-sql-server) duoc trien khai rieng, khong nam trong docker-compose cua Wren AI nhung ket noi qua Docker network.

### 5.2. Bien moi truong (.env)

```
GEMINI_API_KEY=AIzaSy...(nhung san cho team)
GENERATION_MODEL=gemini/gemini-2.5-flash
WREN_PRODUCT_VERSION=0.29.1
WREN_AI_SERVICE_VERSION=0.29.0
WREN_UI_VERSION=0.32.2
IBIS_SERVER_VERSION=0.22.0
HOST_PORT=3000
AI_SERVICE_FORWARD_PORT=5555
SHOULD_FORCE_DEPLOY=1
TELEMETRY_ENABLED=false
```

> **Luu y:** He thong su dung Gemini API key (Google AI Studio) nhung san trong file .env. Team chi can pull code ve va chay docker compose up -d. Khong can cai gcloud hay tao API key rieng.

SHOULD_FORCE_DEPLOY=1 dam bao moi lan khoi dong, he thong tu dong deploy lai MDL va re-index toan bo documents vao Qdrant.

### 5.3. Cau hinh AI Service (config.yaml)

File config.yaml la trung tam cau hinh cua wren-ai-service, dinh nghia 4 thanh phan chinh:

LLM: Su dung Gemini 2.5 Flash qua LiteLLM voi prefix gemini/ (gemini/gemini-2.5-flash), context window 1,048,576 tokens, max output 8192 tokens, temperature 0 (deterministic). Xac thuc qua GEMINI_API_KEY trong file .env.

Embedder: Su dung gemini/gemini-embedding-001 voi output 768 chieu. Xac thuc cung qua GEMINI_API_KEY. Tham so quan trong la dimensions (so nhieu, khong phai dimension so it) vi LiteLLM truyen truc tiep tham so nay toi API.

Document Store: Qdrant tai dia chi http://qdrant:6333, embedding_model_dim: 768 (phai khop voi output cua embedder), recreate_index: false (giu nguyen index khi restart, chi true khi can reset).

Pipelines: 30 pipeline duoc dinh nghia, moi pipeline chi dinh su dung LLM, Embedder, Engine, va/hoac Document Store nao. Chi tiet cac pipeline quan trong se duoc trinh bay o muc 9.


## 6. Semantic Layer -- co che hoat dong cot loi

Semantic Layer la thanh phan cot loi phan biet Wren AI voi cac giai phap Text-to-SQL thong thuong. Thay vi de LLM truc tiep doc raw schema cua database (ten bang, ten cot goc), Semantic Layer tao ra mot lop truu tuong hoa gom:

### 6.1. Model (Mo hinh du lieu)

Moi bang trong database duoc anh xa thanh mot Model trong MDL. Model dinh nghia:
- Ten hien thi (vi du: "Employee_Profile" thay vi "dbo_MS_EMPLOYEE").
- Mo ta nghiep vu (vi du: "Bang chua thong tin co ban cua nhan vien").
- Cac cot voi ten, kieu du lieu, va mo ta (vi du: cot job_satisfaction duoc mo ta "Muc do hai long voi cong viec, thang diem 1-4").

### 6.2. Relationship (Quan he)

Cac relationship giua cac Model duoc dinh nghia tuong minh, vi du:
- MS_EMPLOYEE 1-1 TR_PERFORMANCE qua employee_id.
- MS_EMPLOYEE N-1 MS_DEPARTMENT qua dept_id.
- MS_EMPLOYEE 1-N tr_attrition_result qua CAST(employee_id AS INT) = employee_number.

Khi LLM sinh SQL, no su dung cac relationship nay de tu dong viet JOIN dung, khong can doan.

### 6.3. Calculated Fields va Metrics

MDL cho phep dinh nghia cac truong tinh toan san, vi du burnout_score, attrition_rate, de LLM co the truc tiep su dung ma khong can viet cong thuc phuc tap.

### 6.4. Quy trinh hoat dong

Khi nguoi dung deploy, Semantic Layer duoc xuat thanh van ban (MDL string), sau do duoc embedder chuyen thanh vector 768 chieu va luu vao Qdrant. Khi nguoi dung dat cau hoi, he thong:
1. Embed cau hoi thanh vector.
2. Tim kiem cac Model/Column/Relationship tuong tu nhat trong Qdrant (cosine similarity).
3. Dua context (schema + relationship + description) nay vao prompt cho LLM.
4. LLM sinh SQL dua tren context cu the, khong phai toan bo database.

Phuong phap nay giam thieu hallucination vi LLM chi "thay" cac bang va cot thuc su lien quan, kem theo mo ta nghiep vu ro rang.


## 7. Cau hinh LLM va Embedder (Gemini API)

### 7.1. LLM -- Gemini 2.5 Flash (via Gemini API)

Model: gemini/gemini-2.5-flash (qua LiteLLM).
Context window: 1,048,576 tokens -- du lon de chua toan bo schema, instructions, SQL pairs, va lich su hoi dap.
Temperature: 0 -- dam bao ket qua SQL on dinh, khong ngau nhien.
Max tokens: 8192 -- du cho cac truy van SQL phuc tap nhieu buoc.

Xac thuc bang GEMINI_API_KEY trong file .env. API key dung chung cho team, nhung san trong du an (GitLab private repo). Khong can cai Google Cloud SDK hay dang nhap gcloud.

LiteLLM dong vai tro abstraction layer, cho phep chuyen doi giua cac provider (OpenAI, Gemini, Anthropic, ...) chi bang thay doi config ma khong can sua code. Trong file wren-ai-service/src/providers/llm/litellm.py, lop LitellmLLMProvider nhan cau hinh tu config.yaml va tao ra generator function tuong ung.

### 7.2. Embedder -- Gemini Embedding 001 (via Gemini API)

Model: gemini/gemini-embedding-001.
Output: 768 chieu (dimensions).

Luu y ky thuat quan trong: LiteLLM truyen tham so embedding qua litellm.aembedding(model=..., dimensions=...). Ten tham so la "dimensions" (so nhieu), khong phai "dimension" (so it). Neu cau hinh sai ten, API tra ve loi "Unknown name 'dimension'". Day la van de da duoc xu ly trong qua trinh cau hinh.

Xac thuc cung thong qua GEMINI_API_KEY, giong nhu LLM. Khong can API key rieng cho embedder.

Trong file wren-ai-service/src/providers/embedder/litellm.py, lop LitellmEmbedderProvider truyen tat ca kwargs tu config truc tiep vao litellm.aembedding(), do do ten truong trong config.yaml phai chinh xac theo API cua LiteLLM.

### 7.3. Vector Database -- Qdrant

Qdrant luu tru embeddings cua 3 loai document:
- db_schema: Schema cua tung bang, tung cot, tung relationship.
- sql_pairs: Cac cap cau hoi - SQL mau.
- instructions: Cac huong dan nghiep vu cho LLM.

Moi document duoc embed thanh vector 768 chieu va luu tru trong collection rieng. Khi truy van, Qdrant tra ve top-k documents co cosine similarity cao nhat voi cau hoi cua nguoi dung.

Tham so recreate_index: true trong config.yaml dam bao moi lan deploy, tat ca collections duoc tao lai tu dau, tranh tinh trang du lieu cu bi loi.


## 8. SQL Pairs va Instructions -- tri thuc nghiep vu

### 8.1. SQL Pairs

SQL Pairs la cac cap (cau hoi, SQL) mau duoc cung cap cho he thong de hoc cach tra loi cac loai cau hoi cu the. He thong hien co 18 SQL Pairs (ID 12 den 29) bao phu cac tinh huong:

- Truy van don gian: "Top 10 nhan vien nguy co nghi viec cao nhat" -- SELECT tu view voi ORDER BY.
- Truy van phan tich: "Nhan vien nao co luong bat thuong so voi trung binh phong ban" -- CTE tinh z-score.
- Truy van so sanh: "So sanh nhom lam them gio va khong lam them gio" -- GROUP BY va aggregate.
- Truy van burnout: "Top 5 nhan vien burnout nguy hiem nhat" -- Cong thuc burnout_score.
- Truy van anomaly: "Nhan vien co nhieu feature bat thuong nhat so voi baseline an toan" -- CTE avg_safe, dem so anomalies.
- Truy van tong hop: "Tong quan HR: tong nhan vien, so nghi viec du bao, ty le churn theo phong ban" -- Aggregate toan cuc.

SQL Pairs duoc quan ly qua GraphQL API (mutation createSqlPair) va REST API (/api/v1/knowledge/sql-pairs). Khi deploy, cac SQL Pairs duoc embed va index vao Qdrant collection sql_pairs. Khi nguoi dung dat cau hoi tuong tu, he thong truy xuat SQL Pair gan nhat lam tham chieu cho LLM.

### 8.2. Instructions

Instructions la cac chi dan nghiep vu giup LLM hieu cach thuc dung khi sinh SQL. He thong hien co 13 Instructions chia thanh 2 loai:

Instructions toan cuc (isGlobal: true), ap dung cho moi truy van:
- Quy tac JOIN: Bat buoc CAST(employee_id AS INT) = employee_number khi lien ket MS_EMPLOYEE voi tr_attrition_result.
- Schema overview: Mo ta cac bang, so dong, va bang nao co du lieu thuc.
- Risk level definitions: Dinh nghia Low/Medium/High/Critical va nguong probability_score tuong ung.
- Terminology mapping: Anh xa thuat ngu tieng Viet va tieng Anh ("nghi viec" = attrition, "chay mau chat xam" = brain drain, ...).
- SQL generation rules: Quy tac ve dbo schema prefix, double-quote identifiers, batch_date filter.

Instructions theo cau hoi (isGlobal: false), chi ap dung khi cau hoi khop pattern:
- Feature bat thuong: Huong dan tinh trung binh nhom an toan roi so sanh.
- Burnout: Cong thuc tinh diem burnout va nguong nguy hiem.
- Attrition: Giai thich cac gia tri risk_level va cach dung ROW_NUMBER de lay du bao moi nhat.
- Salary anomaly: Phuong phap tinh z-score.

Instructions duoc quan ly qua REST API (/api/v1/knowledge/instructions) va cung duoc embed, index vao Qdrant.


## 9. Pipeline xu ly truy van Text-to-SQL

Khi nguoi dung dat cau hoi, he thong xu ly qua chuoi pipeline sau:

### 9.1. Intent Classification (intent_classification.py)

Pipeline dau tien xac dinh y dinh cua cau hoi: TEXT_TO_SQL (truy van du lieu), hoac cac loai khac (general question, misleading, ...). Pipeline nay su dung ca LLM va Embedder de phan tich cau hoi. Neu xac dinh la TEXT_TO_SQL, cau hoi duoc chuyen tiep sang pipeline sinh SQL.

### 9.2. Schema Retrieval (db_schema_retrieval.py)

Cau hoi duoc embed thanh vector 768 chieu, sau do truy van Qdrant de tim cac bang, cot, va relationship lien quan nhat. Ket qua la mot tap context gom schema, description, va relationship duoc chon loc -- khong phai toan bo database.

### 9.3. SQL Pairs Retrieval (sql_pairs_retrieval.py)

Dong thoi, he thong tim trong Qdrant cac SQL Pairs co cau hoi tuong tu nhat. Neu tim thay SQL Pair co do tuong dong cao, SQL mau se duoc dua vao prompt lam vi du (few-shot learning).

### 9.4. Instructions Retrieval (instructions.py)

Cac Instructions toan cuc luon duoc dua vao. Cac Instructions theo cau hoi chi duoc dua vao khi cau hoi cua nguoi dung khop voi pattern cua instruction do (thong qua vector similarity).

### 9.5. SQL Generation (sql_generation.py)

Day la pipeline cot loi. LLM nhan duoc prompt gom:
- System prompt dinh nghia vai tro va quy tac.
- Schema context tu retrieval.
- SQL Pairs mau (neu co).
- Instructions lien quan.
- Cau hoi cua nguoi dung.

LLM sinh ra SQL query. SQL nay la SQL logic theo MDL (su dung ten model thay vi ten bang goc).

### 9.6. SQL Correction (sql_correction.py)

SQL duoc goi vao Wren Engine de dry-run (kiem tra cu phap ma khong thuc thi). Neu co loi, pipeline sql_correction gui lai SQL cung thong bao loi cho LLM de tu dong sua. Quy trinh nay co the lap lai nhieu lan cho den khi SQL hop le.

### 9.7. SQL Execution (sql_executor.py)

Sau khi SQL hop le, Wren Engine chuyen SQL tu MDL sang SQL native cua MSSQL, gui qua Ibis Server de thuc thi tren co so du lieu thuc. Ket qua (cac dong du lieu) duoc tra ve cho UI.

### 9.8. SQL Answer (sql_answer.py)

LLM nhan du lieu ket qua va cau hoi goc, sinh ra cau tra loi bang ngon ngu tu nhien (tieng Viet) giai thich y nghia cua ket qua.


## 10. Chart Generation -- truc quan hoa du lieu

### 10.1. Co che hoat dong

Chart generation duoc kich hoat khi nguoi dung bam vao tab "Chart" trong giao dien ket qua. Quy trinh gom:
1. UI goi GraphQL mutation generateThreadResponseChart.
2. Backend gui request toi wren-ai-service endpoint POST /v1/charts voi cau hoi, SQL, va ngon ngu.
3. AI service thuc thi SQL de lay du lieu mau (qua sql_executor pipeline).
4. Pipeline chart_generation goi LLM voi du lieu mau, cau hoi, va SQL de sinh Vega-Lite schema.
5. LLM tra ve JSON gom reasoning (giai thich), chart_type (bar, line, pie, ...), va chart_schema (dac ta Vega-Lite).
6. UI render chart bang thu vien vega-embed.

### 10.2. Cac loai chart ho tro

He thong ho tro 7 loai bieu do: Bar chart, Line chart, Multi-line chart, Area chart, Pie chart, Stacked bar chart, va Grouped bar chart. LLM tu dong chon loai phu hop dua tren cau truc du lieu.

### 10.3. Cau hinh pipeline

Trong config.yaml, hai pipeline chart_generation va chart_adjustment deu su dung litellm_llm.default (Gemini 2.5 Flash). Chart adjustment cho phep nguoi dung yeu cau dieu chinh chart (doi loai chart, doi truc, doi mau).

File chart_generation.py su dung system prompt yeu cau LLM sinh Vega-Lite v5 schema dung chuan. File utils/chart.py dinh nghia cac Pydantic model cho tung loai chart (BarChartSchema, LineChartSchema, ...) de validate output cua LLM.


## 11. Cau hinh tieng Viet cho nguoi dung Viet Nam

### 11.1. Co che ngon ngu trong Wren AI

Ngon ngu trong Wren AI duoc quan ly theo project. Moi du an co mot truong language trong database, duoc gui kem moi request tu UI toi AI service. Gia tri language la mot chuoi nhu "Vietnamese", "English", duoc dua vao prompt cua moi pipeline de LLM biet sinh noi dung bang ngon ngu do.

### 11.2. Cau hinh cho du an nay

Du an nay da duoc cau hinh su dung tieng Viet thong qua viec cap nhat truong language cua project trong database cua wren-ui (SQLite). Gia tri "VI" duoc anh xa thanh chuoi "Vietnamese" khi gui toi AI service.

Tat ca cac pipeline sau deu ton trong ngon ngu nay:
- intent_classification: Phan tich cau hoi tieng Viet.
- sql_answer: Tra loi bang tieng Viet.
- question_recommendation: Goi y cau hoi bang tieng Viet.
- misleading_assistance: Goi y cau hoi thay the bang tieng Viet.
- chart_generation: Tieu de chart va mo ta bang tieng Viet.
- data_assistance: Ho tro du lieu bang tieng Viet.

### 11.3. Thuat ngu ky thuat

Cac thuat ngu ky thuat chuyen nganh nhu attrition, burnout, risk level, probability score, feature importance van giu nguyen tieng Anh vi day la thuat ngu chuan cua linh vuc HR Analytics va Machine Learning, khong nen dich de tranh hieu nham.


## 12. Bao mat thong tin nhan vien khi truy van qua LLM

### 12.1. Kien truc bao mat

Van de bao mat la moi quan tam chinh dang khi su dung LLM voi du lieu nhan su nhay cam. Kien truc Wren AI giai quyet van de nay bang cach tach biet hoan toan 2 luong du lieu:

Luong 1 -- Metadata (gui toi LLM): Chi co schema (ten bang, ten cot, kieu du lieu), descriptions (mo ta nghiep vu), relationships (quan he giua cac bang), SQL Pairs (cau hoi va SQL mau), va Instructions. Day la thong tin cau truc, khong chua bat ky du lieu ca nhan nao cua nhan vien.

Luong 2 -- Data (khong gui toi LLM): Du lieu thuc (ten nhan vien, luong, diem danh gia, ...) chi duoc truy van truc tiep tu MSSQL Server qua Ibis Server. Du lieu nay khong bao gio roi khoi mang noi bo Docker.

### 12.2. Quy trinh cu the

1. Nguoi dung dat cau hoi: "Nhan vien nao luong thap nhat?"
2. LLM chi nhan duoc schema va sinh SQL: SELECT employee_id, monthly_income FROM ...
3. SQL duoc thuc thi truc tiep tren MSSQL Server (khong qua LLM).
4. Ket qua du lieu tra ve truc tiep cho UI.
5. LLM chi nhan duoc ket qua tong hop (neu can giai thich) voi gioi han so dong (mac dinh 500 dong).

Nhu vay, LLM khong bao gio truc tiep truy cap database va du lieu nhan vien cu the chi di theo duong MSSQL -> Ibis Server -> Wren Engine -> UI, khong qua Google Gemini API.

### 12.3. Bien phap bo sung

- Telemetry disabled: TELEMETRY_ENABLED=false trong .env, khong gui bat ky du lieu nao ra ngoai.
- Gemini API key: API key dung chung cho team, nhung san trong file .env (GitLab private repo). Khong su dung Application Default Credentials (ADC), don gian hoa onboarding.
- Docker network isolation: Tat ca container giao tiep qua mang noi bo Docker (network: wren), chi expose port 3000 (UI) ra host.


## 13. Deep dive -- tai sao chon Wren AI thay vi LangChain

### 13.1. Van de cua LangChain cho bai toan Text-to-SQL

LangChain cung cap cong cu Text-to-SQL (SQLDatabaseChain, create_sql_agent), nhung khi ap dung cho bai toan HR Analytics quy mo enterprise, gap nhieu han che:

Thieu Semantic Layer: LangChain doc raw schema truc tiep tu database. Voi database co nhieu bang, ten cot viet tat hoac mo ho (vi du: dept_id, role_id), LLM de bi "hallucinate" -- sinh SQL sai bang, sai cot, hoac JOIN sai. Khong co co che dinh nghia mo ta nghiep vu cho tung cot, LLM khong hieu "job_satisfaction" la thang diem 1-4 hay la phan tram.

Khong co SQL validation tich hop: LangChain sinh SQL roi thuc thi truc tiep. Neu SQL sai cu phap, loi duoc tra ve cho nguoi dung ma khong co co che tu dong sua. Wren AI co pipeline sql_correction tu dong gui lai loi cho LLM de sua va thu lai.

Khong co SQL Pairs va Instructions: LangChain khong co khai niem "tri thuc nghiep vu" duoc index va retrieval tu dong. Developer phai tu viet prompt engineering phuc tap, hardcode cac vi du vao system prompt.

Khong co giao dien san: LangChain la thu vien Python, can tu xay UI. Wren AI cung cap giao dien web hoan chinh voi quan ly model, hoi dap, chart, va quan ly tri thuc (SQL Pairs, Instructions).

### 13.2. Uu diem cua Wren AI

Semantic Layer native: MDL (Model Definition Language) cho phep dinh nghia mo ta nghiep vu, quan he, va calculated fields. LLM lam viec voi ngon ngu nghiep vu thay vi raw schema.

RAG-based retrieval: Schema, SQL Pairs, va Instructions duoc embed va luu trong Qdrant. Chi nhung phan lien quan nhat moi duoc dua vao prompt, giam thieu token va tang do chinh xac.

Pipeline architecture: Moi chuc nang (retrieval, generation, correction, chart) la mot pipeline doc lap, de bao tri va mo rong. Su dung Haystack framework, ho tro nhieu LLM provider qua LiteLLM.

SQL validation loop: SQL duoc dry-run tren Wren Engine truoc khi thuc thi, neu loi se tu dong sua (sql_correction pipeline). Giam thieu loi SQL den muc toi thieu.

Enterprise-ready: Ho tro nhieu data source (MSSQL, PostgreSQL, MySQL, BigQuery, ...), co chart generation, question recommendation, va giao dien web san.

### 13.3. Khi nao nen dung LangChain

LangChain van phu hop cho cac du an prototype nho, hoac khi can tuy chinh sau logic AI (vi du: multi-agent, tool calling phuc tap). Wren AI phu hop hon cho bai toan Text-to-SQL quy mo enterprise voi data source phuc tap, can Semantic Layer, va can giao dien web san.


## 14. Huong dan khoi dong va van hanh he thong

### 14.1. Yeu cau he thong

- Docker Desktop (Windows/Mac) hoac Docker Engine (Linux).
- RAM toi thieu 8 GB (khuyen nghi 16 GB).
- GEMINI_API_KEY: Da nhung san trong file .env, team chi can pull code tu GitLab ve.
- MSSQL Server voi co so du lieu HR_Analytics da duoc khoi tao.

### 14.2. Cac buoc khoi dong

Buoc 1: Chuan bi MSSQL Server. Trien khai container hr-sql-server voi co so du lieu HR_Analytics. Chay cac script SQL trong thu muc legacy/ de tao bang va nap du lieu. Chay notebook HR_Analytics_Project_Final.ipynb de huan luyen mo hinh va ghi ket qua du bao vao bang tr_attrition_result.

Buoc 2: Cau hinh Wren AI. Vao thu muc hr-ai-project/WrenAI/docker/. File .env va config.yaml da duoc cau hinh san khi pull tu GitLab. Kiem tra: GEMINI_API_KEY co gia tri, GENERATION_MODEL=gemini/gemini-2.5-flash. Config.yaml: LLM dung model gemini/gemini-2.5-flash, embedder dung model gemini/gemini-embedding-001, dimensions: 768.

Buoc 3: Khoi dong he thong.
```
cd hr-ai-project/WrenAI/docker
docker compose up -d
```

Buoc 4: Ket noi data source. Truy cap http://localhost:3000. Thuc hien setup wizard: chon MSSQL Server, nhap connection string (host: hr-sql-server, port: 1433, database: HR_Analytics, user: SA, password: DataWarehouse@2024). Chon cac bang can su dung trong Modeling.

Buoc 5: Cau hinh Semantic Layer. Trong giao dien Modeling, dinh nghia relationships giua cac bang. Them descriptions cho tung bang va tung cot. Deploy model (mutation deploy(force: true)).

Buoc 6: Them tri thuc nghiep vu. Su dung REST API /api/v1/knowledge/sql-pairs de them SQL Pairs. Su dung REST API /api/v1/knowledge/instructions de them Instructions. Deploy lai de re-index.

Buoc 7: Cau hinh tieng Viet. Cap nhat ngon ngu du an thanh Vietnamese thong qua GraphQL mutation updateCurrentProject hoac truc tiep trong database.

Buoc 8: Kiem tra. Truy cap http://localhost:3000, dat cau hoi thu nghiem bang tieng Viet. Kiem tra ket qua SQL, giai thich, va chart.

### 14.3. Cac lenh van hanh

```
docker compose up -d          # Khoi dong tat ca services
docker compose down            # Dung tat ca services
docker compose restart wren-ai-service   # Khoi dong lai AI service
docker compose logs wren-ai-service -f   # Xem log AI service
```


## 15. Ket qua dat duoc va danh gia

### 15.1. Cac loai cau hoi da kiem chung thanh cong

He thong da duoc kiem chung voi cac loai cau hoi tu don gian den phuc tap:

Cau hoi truc tiep: "Top 10 nhan vien nguy co nghi viec cao nhat" -- Thoi gian tra loi khoang 15-20 giay, SQL chinh xac, ket qua dung.

Cau hoi tong hop: "Tong quan HR: tong nhan vien, so nghi viec du bao, ty le churn theo phong ban" -- Su dung CTE va aggregate, thoi gian khoang 18 giay.

Cau hoi phan tich phuc tap: "10 nhan vien co ty le nghi viec cao nhat va cac feature bat thuong so voi nhan vien khong co kha nang nghi viec" -- Su dung CTE avg_safe, CROSS JOIN, nhieu CASE WHEN, thoi gian khoang 39 giay.

Cau hoi burnout: "Top 5 nhan vien burnout nguy hiem nhat, giai thich ly do" -- Ap dung cong thuc burnout_score, thoi gian khoang 33 giay.

Cau hoi chay mau chat xam: "Nhan vien tai nang nao co nguy co nghi viec? Chay mau chat xam" -- LLM hieu thuat ngu tieng Viet va filter dung performance_rating >= 4.

### 15.2. Cac van de da xu ly trong qua trinh cau hinh

Embedder error "Unknown name 'dimension'": Do config.yaml su dung "dimension" (so it) thay vi "dimensions" (so nhieu). LiteLLM truyen truc tiep tham so nay toi Gemini API nen ten phai chinh xac.

Model text-embedding-004 deprecated: Chuyen sang gemini/gemini-embedding-001 voi xac thuc Gemini API key.

View tra ve NULL: Do bang HR_Predictions trong (0 dong). Da sua cac view de su dung tr_attrition_result (2940 dong co du lieu thuc).

Kieu du lieu khong dong nhat: over_time trong TR_PERFORMANCE la 'Yes'/'No' (NVARCHAR), trong HR_Training_Data la 1/0 (INT). Da xu ly bang CASE WHEN phu hop trong tung view.

Ngon ngu hien thi: He thong mac dinh tieng Anh. Da cau hinh chuyen sang tieng Viet de phu hop nguoi dung Viet Nam.

### 15.3. Danh gia tong the

He thong dat duoc muc tieu de ra: cung cap kha nang truy van du lieu HR bang ngon ngu tu nhien tieng Viet, tu dong sinh SQL chinh xac, hien thi ket qua bang du lieu va bieu do, giai thich ket qua ro rang. Thoi gian tra loi trung binh tu 15 den 40 giay tuy do phuc tap cua cau hoi. Semantic Layer dam bao do chinh xac cao bang cach cung cap context ro rang cho LLM. SQL Pairs va Instructions bo sung tri thuc nghiep vu giup he thong xu ly dung cac tinh huong dac thu cua bai toan HR Analytics.

---

Tai lieu nay la ban ghi chep ky thuat day du cua toan bo qua trinh cau hinh va trien khai du an HR Analytics. Moi thong tin da duoc kiem chung tren he thong thuc te dang hoat dong tai http://localhost:3000.
