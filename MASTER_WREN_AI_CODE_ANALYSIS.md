# 📖 MASTER GUIDE — Đọc hiểu toàn bộ Code Python trong Wren AI Service
## Phân tích chi tiết FULL tất cả file .py — Chức năng, Luồng, Class, Import, Pipeline

> **Mục đích**: Tài liệu này giải thích **100% file .py** trong `wren-ai-service/src/`, giúp đọc hiểu code từ tổng quát đến chi tiết. Mỗi file được phân tích: mục đích, import, class, function, decorator, prompt template, cơ chế vận hành, và liên kết với các file khác trong hệ thống.
>
> **Tổng cộng**: **~90 file Python** được phân tích trong tài liệu này.

---

## 📑 MỤC LỤC

- [I. Tổng quan kiến trúc toàn hệ thống](#i-tổng-quan-kiến-trúc-toàn-hệ-thống)
- [II. SRC ROOT — Entry Point & Cấu hình](#ii-src-root--entry-point--cấu-hình)
  - [2.1 `__main__.py`](#21-__main__py--điểm-khởi-chạy-ứng-dụng)
  - [2.2 `config.py`](#22-configpy--cấu-hình-hệ-thống)
  - [2.3 `globals.py`](#23-globalspy--kết-nối-toàn-bộ-pipeline)
  - [2.4 `utils.py`](#24-utilspy--tiện-ích-hệ-thống)
  - [2.5 `force_deploy.py`](#25-force_deploypy--triển-khai-bắt-buộc)
  - [2.6 `force_update_config.py`](#26-force_update_configpy--cập-nhật-cấu-hình)
- [III. CORE — Xương sống hệ thống](#iii-core--xương-sống-hệ-thống)
  - [3.1 `core/pipeline.py`](#31-corepipelinepy--lớp-cơ-sở-pipeline)
  - [3.2 `core/provider.py`](#32-coreproviderpy--abstract-provider-interfaces)
  - [3.3 `core/engine.py`](#33-coreenginepy--abstract-engine--tiện-ích-sql)
- [IV. PROVIDERS — Tích hợp dịch vụ bên ngoài](#iv-providers--tích-hợp-dịch-vụ-bên-ngoài)
  - [4.1 `providers/__init__.py`](#41-providers__init__py--factory-tạo-component)
  - [4.2 `providers/loader.py`](#42-providersloaderpy--registry-pattern)
  - [4.3 `providers/document_store/qdrant.py`](#43-providersdocument_storeqdrantpy--vector-database)
  - [4.4 `providers/embedder/litellm.py`](#44-providersembedderlitellmpy--text-to-vector)
  - [4.5 `providers/llm/litellm.py`](#45-providersllmlitellmpy--gọi-llm)
  - [4.6 `providers/engine/wren.py`](#46-providersenginewrenpy--sql-execution)
- [V. PIPELINES/COMMON — Hàm dùng chung](#v-pipelinescommon--hàm-dùng-chung)
- [VI. PIPELINES/INDEXING — Chuẩn bị tri thức](#vi-pipelinesindexing--chuẩn-bị-tri-thức)
  - [6.1 `indexing/__init__.py`](#61-indexing__init__py--component-dùng-chung)
  - [6.2 `indexing/db_schema.py`](#62-indexingdb_schemapy--ddl-chunking--indexing)
  - [6.3 `indexing/table_description.py`](#63-indexingtable_descriptionpy--mô-tả-bảng)
  - [6.4 `indexing/historical_question.py`](#64-indexinghistorical_questionpy--câu-hỏi-lịch-sử)
  - [6.5 `indexing/sql_pairs.py`](#65-indexingsql_pairspy--cặp-câu-hỏi-sql)
  - [6.6 `indexing/instructions.py`](#66-indexinginstructionspy--hướng-dẫn-nghiệp-vụ)
  - [6.7 `indexing/project_meta.py`](#67-indexingproject_metapy--metadata-dự-án)
  - [6.8 `indexing/utils/helper.py`](#68-indexingutilshelperpy--tiền-xử-lý-dữ-liệu)
- [VII. PIPELINES/RETRIEVAL — Truy xuất ngữ cảnh](#vii-pipelinesretrieval--truy-xuất-ngữ-cảnh)
  - [7.1 `retrieval/db_schema_retrieval.py`](#71-retrievaldb_schema_retrievalpy--tìm-schema-liên-quan)
  - [7.2 `retrieval/sql_pairs_retrieval.py`](#72-retrievalsql_pairs_retrievalpy--tìm-sql-mẫu)
  - [7.3 `retrieval/historical_question_retrieval.py`](#73-retrievalhistorical_question_retrievalpy--tìm-câu-hỏi-cũ)
  - [7.4 `retrieval/instructions.py`](#74-retrievalinstructionspy--tìm-hướng-dẫn)
  - [7.5 `retrieval/sql_executor.py`](#75-retrievalsql_executorpy--thực-thi-sql)
  - [7.6 `retrieval/sql_functions.py`](#76-retrievalsql_functionspy--hàm-sql-hỗ-trợ)
  - [7.7 `retrieval/sql_knowledge.py`](#77-retrievalsql_knowledgepy--tri-thức-sql)
  - [7.8 `retrieval/preprocess_sql_data.py`](#78-retrievalpreprocess_sql_datapy--tiền-xử-lý-dữ-liệu)
- [VIII. PIPELINES/GENERATION — Sinh nội dung](#viii-pipelinesgeneration--sinh-nội-dung)
  - [8.1 `generation/intent_classification.py`](#81-generationintent_classificationpy--phân-loại-ý-định)
  - [8.2 `generation/sql_generation_reasoning.py`](#82-generationsql_generation_reasoningpy--chain-of-thought)
  - [8.3 `generation/sql_generation.py`](#83-generationsql_generationpy--sinh-sql-chính)
  - [8.4 `generation/sql_correction.py`](#84-generationsql_correctionpy--sửa-sql-lỗi)
  - [8.5 `generation/sql_regeneration.py`](#85-generationsql_regenerationpy--tái-sinh-sql)
  - [8.6 `generation/followup_sql_generation.py`](#86-generationfollowup_sql_generationpy--sql-câu-hỏi-nối-tiếp)
  - [8.7 `generation/followup_sql_generation_reasoning.py`](#87-generationfollowup_sql_generation_reasoningpy--suy-luận-nối-tiếp)
  - [8.8 `generation/sql_answer.py`](#88-generationsql_answerpy--chuyển-sql-thành-text)
  - [8.9 `generation/sql_question.py`](#89-generationsql_questionpy--chuyển-sql-thành-câu-hỏi)
  - [8.10 `generation/sql_diagnosis.py`](#810-generationsql_diagnosispy--chẩn-đoán-lỗi-sql)
  - [8.11 `generation/sql_tables_extraction.py`](#811-generationsql_tables_extractionpy--trích-xuất-tên-bảng)
  - [8.12 `generation/question_recommendation.py`](#812-generationquestion_recommendationpy--gợi-ý-câu-hỏi)
  - [8.13 `generation/chart_generation.py`](#813-generationchart_generationpy--sinh-biểu-đồ)
  - [8.14 `generation/chart_adjustment.py`](#814-generationchart_adjustmentpy--tinh-chỉnh-biểu-đồ)
  - [8.15 `generation/data_assistance.py`](#815-generationdata_assistancepy--hỗ-trợ-dữ-liệu)
  - [8.16 `generation/misleading_assistance.py`](#816-generationmisleading_assistancepy--xử-lý-câu-hỏi-sai)
  - [8.17 `generation/user_guide_assistance.py`](#817-generationuser_guide_assistancepy--hướng-dẫn-sử-dụng)
  - [8.18 `generation/relationship_recommendation.py`](#818-generationrelationship_recommendationpy--gợi-ý-quan-hệ)
  - [8.19 `generation/semantics_description.py`](#819-generationsemantics_descriptionpy--mô-tả-ngữ-nghĩa)
  - [8.20 `generation/utils/sql.py`](#820-generationutilssqlpy--tiện-ích-sql)
  - [8.21 `generation/utils/chart.py`](#821-generationutilschartpy--tiện-ích-biểu-đồ)
- [IX. WEB LAYER — API Endpoints & Services](#ix-web-layer--api-endpoints--services)
  - [9.1 Tổng quan Router & Service](#91-tổng-quan-router--service)
  - [9.2 Ask (Hỏi đáp chính)](#92-ask--hỏi-đáp-chính)
  - [9.3 Ask Feedback (Phản hồi tinh chỉnh)](#93-ask-feedback--phản-hồi-tinh-chỉnh)
  - [9.4 Semantics Preparation (Nhập MDL)](#94-semantics-preparation--nhập-mdl)
  - [9.5 SQL Pairs (Quản lý tri thức SQL)](#95-sql-pairs--quản-lý-tri-thức-sql)
  - [9.6 Instructions (Quản lý hướng dẫn)](#96-instructions--quản-lý-hướng-dẫn)
  - [9.7 SQL Answers (Trả lời bằng text)](#97-sql-answers--trả-lời-bằng-text)
  - [9.8 SQL Corrections (Sửa SQL)](#98-sql-corrections--sửa-sql)
  - [9.9 SQL Questions (SQL → Câu hỏi)](#99-sql-questions--sql--câu-hỏi)
  - [9.10 Charts (Biểu đồ)](#910-charts--biểu-đồ)
  - [9.11 Chart Adjustments (Tinh chỉnh biểu đồ)](#911-chart-adjustments--tinh-chỉnh-biểu-đồ)
  - [9.12 Question Recommendations (Gợi ý câu hỏi)](#912-question-recommendations--gợi-ý-câu-hỏi)
  - [9.13 Relationship Recommendations (Gợi ý quan hệ)](#913-relationship-recommendations--gợi-ý-quan-hệ)
  - [9.14 Semantics Descriptions (Mô tả ngữ nghĩa)](#914-semantics-descriptions--mô-tả-ngữ-nghĩa)
  - [9.15 Development API (Debug)](#915-development-api--debug)
  - [9.16 `services/__init__.py`](#916-services__init__py--base-classes)
- [X. Tổng hợp luồng End-to-End](#x-tổng-hợp-luồng-end-to-end)
- [XI. Bảng tổng hợp FULL file .py](#xi-bảng-tổng-hợp-full-file-py)

---

## I. Tổng quan kiến trúc toàn hệ thống

### Sơ đồ module tổng quan

```
wren-ai-service/src/
├── __main__.py          ← KHỞI CHẠY FastAPI app
├── config.py            ← CẤU HÌNH toàn hệ thống (Settings)
├── globals.py           ← KẾT NỐI tất cả pipeline → ServiceContainer
├── utils.py             ← TIỆN ÍCH: logging, Langfuse, tracing
├── force_deploy.py      ← TRIỂN KHAI bắt buộc qua GraphQL
├── force_update_config.py ← CẬP NHẬT YAML config
│
├── core/                ← XƯƠNG SỐNG: Abstract classes
│   ├── pipeline.py      ←   BasicPipeline, PipelineComponent
│   ├── provider.py      ←   LLMProvider, EmbedderProvider, DocumentStoreProvider
│   └── engine.py        ←   Engine (abstract), clean_generation_result()
│
├── providers/           ← TÍCH HỢP dịch vụ bên ngoài
│   ├── __init__.py      ←   Factory: generate_components() từ YAML config
│   ├── loader.py        ←   Registry: @provider decorator, PROVIDERS dict
│   ├── document_store/
│   │   └── qdrant.py    ←   AsyncQdrantDocumentStore, QdrantProvider
│   ├── embedder/
│   │   └── litellm.py   ←   AsyncTextEmbedder, AsyncDocumentEmbedder
│   ├── llm/
│   │   └── litellm.py   ←   LitellmLLMProvider (acompletion, Router fallback)
│   └── engine/
│       └── wren.py      ←   WrenUI, WrenIbis, WrenEngine
│
├── pipelines/           ← XỬ LÝ CHÍNH: Indexing → Retrieval → Generation
│   ├── common.py        ←   build_table_ddl(), ScoreFilter, clean_up_new_lines()
│   ├── indexing/        ←   Chuẩn bị tri thức (MDL → Vector DB)
│   │   ├── __init__.py  ←     MDLValidator, DocumentCleaner, AsyncDocumentWriter
│   │   ├── db_schema.py ←     DDLChunker, DBSchema pipeline
│   │   ├── table_description.py ← TableDescriptionChunker
│   │   ├── historical_question.py ← ViewChunker, HistoricalQuestion
│   │   ├── sql_pairs.py ←     SqlPairsConverter, SqlPairs pipeline
│   │   ├── instructions.py ←  InstructionsConverter, Instructions pipeline
│   │   ├── project_meta.py ←  ProjectMeta pipeline (metadata)
│   │   └── utils/helper.py ←  COLUMN_PREPROCESSORS, COLUMN_COMMENT_HELPERS
│   │
│   ├── retrieval/       ←   Truy xuất ngữ cảnh từ Vector DB
│   │   ├── db_schema_retrieval.py ← DbSchemaRetrieval (tìm schema)
│   │   ├── sql_pairs_retrieval.py ← SqlPairsRetrieval (tìm SQL mẫu)
│   │   ├── historical_question_retrieval.py ← HistoricalQuestionRetrieval
│   │   ├── instructions.py ← Instructions retrieval (tìm hướng dẫn)
│   │   ├── sql_executor.py ← SQLExecutor, DataFetcher
│   │   ├── sql_functions.py ← SqlFunction, SqlFunctions (hàm SQL)
│   │   ├── sql_knowledge.py ← SqlKnowledge, SqlKnowledges (tri thức SQL)
│   │   └── preprocess_sql_data.py ← PreprocessSqlData (cắt data theo token)
│   │
│   └── generation/      ←   Sinh nội dung (SQL, text, chart, ...)
│       ├── intent_classification.py ← IntentClassification
│       ├── sql_generation_reasoning.py ← SQLGenerationReasoning (CoT)
│       ├── sql_generation.py ← SQLGeneration
│       ├── sql_correction.py ← SQLCorrection
│       ├── sql_regeneration.py ← SQLRegeneration (feedback)
│       ├── followup_sql_generation.py ← FollowUpSQLGeneration
│       ├── followup_sql_generation_reasoning.py ← FollowUpSQLGenerationReasoning
│       ├── sql_answer.py ← SQLAnswer (SQL → text, streaming)
│       ├── sql_question.py ← SQLQuestion (SQL → câu hỏi)
│       ├── sql_diagnosis.py ← SQLDiagnosis (chẩn đoán lỗi)
│       ├── sql_tables_extraction.py ← SQLTablesExtraction
│       ├── question_recommendation.py ← QuestionRecommendation
│       ├── chart_generation.py ← ChartGeneration (Vega-Lite)
│       ├── chart_adjustment.py ← ChartAdjustment
│       ├── data_assistance.py ← DataAssistance (hỗ trợ schema, streaming)
│       ├── misleading_assistance.py ← MisleadingAssistance (streaming)
│       ├── user_guide_assistance.py ← UserGuideAssistance (streaming)
│       ├── relationship_recommendation.py ← RelationshipRecommendation
│       ├── semantics_description.py ← SemanticsDescription
│       └── utils/
│           ├── sql.py   ←   SQLGenPostProcessor, SQL rules, validation
│           └── chart.py ←   ChartDataPreprocessor, Vega-Lite validation
│
└── web/                 ← API LAYER: FastAPI routers + services
    ├── development.py   ←   Debug API: list/run pipelines trực tiếp
    └── v1/
        ├── routers/     ←   13 router files (REST endpoints)
        │   ├── __init__.py ← Đăng ký tất cả router
        │   ├── ask.py, ask_feedbacks.py, chart.py, chart_adjustment.py
        │   ├── instructions.py, question_recommendation.py
        │   ├── relationship_recommendation.py, semantics_description.py
        │   ├── semantics_preparation.py, sql_answers.py
        │   ├── sql_corrections.py, sql_pairs.py, sql_question.py
        │   └── (Tổng: 13 routers = 41 endpoints)
        └── services/    ←   13 service files (business logic)
            ├── __init__.py ← BaseRequest, Configuration, SSEEvent, MetadataTraceable
            ├── ask.py, ask_feedback.py, chart.py, chart_adjustment.py
            ├── instructions.py, question_recommendation.py
            ├── relationship_recommendation.py, semantics_description.py
            ├── semantics_preparation.py, sql_answer.py
            ├── sql_corrections.py, sql_pairs.py, sql_question.py
            └── (Tổng: 13 services)
```

### Luồng dữ liệu tổng quát

```
USER REQUEST
     │
     ▼
┌─────────────┐     ┌──────────────┐     ┌────────────────┐     ┌───────────────┐
│   ROUTERS   │────▶│   SERVICES   │────▶│   PIPELINES    │────▶│   PROVIDERS   │
│ (FastAPI)   │     │ (Orchestrate)│     │ (Hamilton DAG) │     │ (External API)│
│ 13 routers  │     │ 13 services  │     │ Indexing (7)   │     │ Qdrant (VDB)  │
│ 41 endpoints│     │ TTLCache     │     │ Retrieval (8)  │     │ LiteLLM (LLM) │
│             │◀────│ Background   │◀────│ Generation (19)│◀────│ LiteLLM (Emb) │
│ JSON resp   │     │ Tasks        │     │ Utils (2)      │     │ Wren Engine   │
└─────────────┘     └──────────────┘     └────────────────┘     └───────────────┘
```

### Các framework và thư viện chính

| Thư viện | Vai trò | File sử dụng chính |
|---|---|---|
| **FastAPI** | Web framework, background tasks, SSE | `web/v1/routers/*.py`, `__main__.py` |
| **Hamilton** | DAG-based pipeline execution | Tất cả `pipelines/**/*.py` |
| **Haystack** | AI component framework (`@component`, `Document`, `PromptBuilder`) | `pipelines/**/*.py`, `providers/*.py` |
| **LiteLLM** | Unified LLM & Embedding API (OpenAI/Anthropic/Gemini) | `providers/llm/litellm.py`, `providers/embedder/litellm.py` |
| **Qdrant** | Vector database (cosine similarity search) | `providers/document_store/qdrant.py` |
| **Langfuse** | Observability, tracing (`@observe`) | Tất cả pipeline & service files |
| **Pydantic** | Data validation, JSON schema | Tất cả service & router files |
| **tiktoken** | Token counting (context window management) | `retrieval/preprocess_sql_data.py`, `retrieval/db_schema_retrieval.py` |
| **orjson** | JSON parsing nhanh | Nhiều generation files |
| **aiohttp** | HTTP client bất đồng bộ | `providers/engine/wren.py`, `retrieval/sql_executor.py` |
| **backoff** | Retry exponential backoff | `providers/llm/litellm.py`, `providers/embedder/litellm.py` |
| **cachetools** | TTL cache | `web/v1/services/*.py`, `retrieval/sql_functions.py` |
| **pandas** | Xử lý data cho chart | `generation/utils/chart.py` |
| **jsonschema** | Validate Vega-Lite schema | `generation/utils/chart.py` |

---

## II. SRC ROOT — Entry Point & Cấu hình

### 2.1 `__main__.py` — Điểm khởi chạy ứng dụng

📄 **File**: [src/\_\_main\_\_.py](WrenAI/wren-ai-service/src/__main__.py)

**Mục đích**: Khởi tạo FastAPI app, tạo tất cả provider và pipeline, đăng ký routes

```python
# IMPORT CHÍNH
from fastapi import FastAPI
from src.config import settings                     # Cấu hình hệ thống
from src.globals import create_service_container    # Factory tạo tất cả service
from src.providers import generate_components       # Factory tạo tất cả provider
from src.web.v1 import routers                      # Tất cả API endpoints
from src.web import development                     # Debug endpoints

# LUỒNG KHỞI CHẠY (trong hàm lifespan):
# 1. generate_components(settings.components) → Tạo LLMProvider, EmbedderProvider, 
#                                                DocumentStoreProvider, Engine cho mỗi pipeline
# 2. create_service_container(pipe_components, settings) → Kết nối providers + pipelines → services
# 3. app.include_router(routers.router, prefix="/v1") → Đăng ký 41 endpoints
# 4. app.include_router(development.router, prefix="/dev") → Đăng ký debug API
```

**Cơ chế lifespan**: FastAPI lifespan context manager đảm bảo tất cả component được khởi tạo trước khi nhận request đầu tiên.

---

### 2.2 `config.py` — Cấu hình hệ thống

📄 **File**: [src/config.py](WrenAI/wren-ai-service/src/config.py)

**Mục đích**: Tập trung toàn bộ cài đặt hệ thống bằng Pydantic Settings

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # CẤU HÌNH INDEXING
    column_indexing_batch_size: int = 50       # Số cột tối đa trong 1 chunk DDL
    
    # CẤU HÌNH RETRIEVAL
    table_retrieval_size: int = 10             # Top-k bảng tìm được
    table_column_retrieval_size: int = 1000    # Top-k chunk cột
    
    # NGƯỠNG SIMILARITY
    sql_pairs_similarity_threshold: float = 0.7   # Ngưỡng cho SQL pairs (70%)
    instructions_similarity_threshold: float = 0.7 # Ngưỡng cho instructions (70%)
    historical_question_retrieval_similarity_threshold: float = 0.9  # Ngưỡng cho câu hỏi cũ (90%)
    
    # SQL CORRECTION
    max_sql_correction_retries: int = 3        # Số lần thử sửa SQL tối đa
    
    # YAML CONFIG
    components: list = []                       # Danh sách config YAML cho providers
```

**Lưu ý**: Biến môi trường sẽ override giá trị mặc định (nhờ Pydantic Settings). Ví dụ: `TABLE_RETRIEVAL_SIZE=20` sẽ đổi top-k từ 10 lên 20.

---

### 2.3 `globals.py` — Kết nối toàn bộ pipeline

📄 **File**: [src/globals.py](WrenAI/wren-ai-service/src/globals.py)

**Mục đích**: Factory function tạo `ServiceContainer` — nơi kết nối **TẤT CẢ** pipeline thành các service

```python
def create_service_container(pipe_components, settings) -> ServiceContainer:
    # BƯỚC 1: Tạo từng pipeline instance từ PipelineComponent
    
    # Indexing pipelines (7 loại)
    _db_schema = indexing.DBSchema(...)            # DDL indexing
    _table_description = indexing.TableDescription(...)  # Mô tả bảng
    _historical_question = indexing.HistoricalQuestion(...) # Câu hỏi cũ
    _sql_pairs = indexing.SqlPairs(...)             # SQL pairs
    _instructions = indexing.Instructions(...)       # Hướng dẫn
    _project_meta = indexing.ProjectMeta(...)        # Metadata
    
    # Retrieval pipelines (8 loại)
    _db_schema_retrieval = retrieval.DbSchemaRetrieval(...)
    _sql_pairs_retrieval = retrieval.SqlPairsRetrieval(...)
    _instructions_retrieval = retrieval.Instructions(...)
    _historical_question_retrieval = retrieval.HistoricalQuestionRetrieval(...)
    _sql_executor = retrieval.SQLExecutor(...)
    _sql_functions = retrieval.SqlFunctions(...)
    _sql_knowledge = retrieval.SqlKnowledges(...)
    _preprocess_sql_data = retrieval.PreprocessSqlData(...)
    
    # Generation pipelines (19 loại)
    _intent_classification = generation.IntentClassification(...)
    _sql_generation_reasoning = generation.SQLGenerationReasoning(...)
    _sql_generation = generation.SQLGeneration(...)
    _sql_correction = generation.SQLCorrection(...)
    _sql_regeneration = generation.SQLRegeneration(...)
    _followup_sql_generation = generation.FollowUpSQLGeneration(...)
    _followup_sql_generation_reasoning = generation.FollowUpSQLGenerationReasoning(...)
    _sql_answer = generation.SQLAnswer(...)
    _sql_question = generation.SQLQuestion(...)
    _sql_diagnosis = generation.SQLDiagnosis(...)
    _sql_tables_extraction = generation.SQLTablesExtraction(...)
    _question_recommendation = generation.QuestionRecommendation(...)
    _chart_generation = generation.ChartGeneration(...)
    _chart_adjustment = generation.ChartAdjustment(...)
    _data_assistance = generation.DataAssistance(...)
    _misleading_assistance = generation.MisleadingAssistance(...)
    _user_guide_assistance = generation.UserGuideAssistance(...)
    _relationship_recommendation = generation.RelationshipRecommendation(...)
    _semantics_description = generation.SemanticsDescription(...)
    
    # BƯỚC 2: Ghép pipeline thành services (mỗi service nhận dict of pipelines)
    return ServiceContainer(
        ask_service=AskService(pipelines={...}),
        ask_feedback_service=AskFeedbackService(pipelines={...}),
        chart_service=ChartService(pipelines={...}),
        semantics_preparation_service=SemanticsPreparationService(pipelines={...}),
        # ... 13 services tổng cộng
    )
```

**Kiến trúc**: `PipelineComponent` → `Pipeline` → `Service` → `ServiceContainer` → Gắn vào `app.state`

---

### 2.4 `utils.py` — Tiện ích hệ thống

📄 **File**: [src/utils.py](WrenAI/wren-ai-service/src/utils.py)

**Mục đích**: Logging, Langfuse monitoring, tracing decorators, tiện ích chung

| Hàm/Class | Chức năng |
|---|---|
| `setup_custom_logger()` | Cấu hình logging với timestamp, level, format |
| `init_langfuse()` | Kết nối Langfuse monitoring platform |
| `@trace_metadata` | **Decorator**: Ghi project_id, thread_id vào Langfuse trace |
| `@trace_cost` | **Decorator**: Ghi chi phí LLM (model usage, tokens) vào Langfuse |
| `fetch_wren_ai_docs()` | Tải tài liệu hướng dẫn Wren AI (cho UserGuideAssistance) |
| `extract_braces_content(text)` | Trích xuất JSON từ text LLM trả về (tìm `{...}`) |

**Decorator `@trace_metadata`** — Cách hoạt động:

```python
@trace_metadata
async def ask(self, ask_request):
    # Decorator tự động:
    # 1. Lấy project_id, thread_id từ request
    # 2. Cập nhật Langfuse trace với metadata
    # 3. Ghi session_id = project_id
    ...
```

---

### 2.5 `force_deploy.py` — Triển khai bắt buộc

📄 **File**: [src/force_deploy.py](WrenAI/wren-ai-service/src/force_deploy.py)

**Mục đích**: Gửi GraphQL mutation `Deploy(force: true)` tới Wren UI khi thay đổi LLM/embedding model, buộc tái tạo Qdrant collections

```python
@backoff.on_exception(backoff.expo, aiohttp.ClientError, max_time=60, max_tries=3)
async def force_deploy():
    # Gửi POST /api/graphql → mutation Deploy { deploy(force: true) }
    # WREN_UI_ENDPOINT mặc định: http://wren-ui:3000
    # Chỉ chạy khi ENGINE == "wren_ui"
```

---

### 2.6 `force_update_config.py` — Cập nhật cấu hình

📄 **File**: [src/force_update_config.py](WrenAI/wren-ai-service/src/force_update_config.py)

**Mục đích**: Script cập nhật `config.yaml` cho local development — set đúng engine cho từng pipeline

```python
def update_config():
    # Đọc config.yaml (multi-document YAML)
    # Với mỗi pipe:
    #   - Nếu tên chứa "sql_functions" hoặc "sql_knowledge" → engine = "wren_ibis"
    #   - Còn lại → engine = "wren_ui"
```

---

## III. CORE — Xương sống hệ thống

### 3.1 `core/pipeline.py` — Lớp cơ sở Pipeline

📄 **File**: [src/core/pipeline.py](WrenAI/wren-ai-service/src/core/pipeline.py)

**Mục đích**: Định nghĩa abstract class mà **TẤT CẢ 34 pipeline** kế thừa

```python
# IMPORT
from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from collections.abc import Mapping
from hamilton.async_driver import AsyncDriver   # ← Framework DAG bất đồng bộ
from hamilton.driver import Driver              # ← Framework DAG đồng bộ
from haystack import Pipeline                   # ← Framework AI pipeline

class BasicPipeline(metaclass=ABCMeta):
    """
    MỌI pipeline đều kế thừa class này.
    Lưu trữ 1 trong 3 loại pipe: Hamilton AsyncDriver | Hamilton Driver | Haystack Pipeline
    """
    def __init__(self, pipe: Pipeline | AsyncDriver | Driver):
        self._pipe = pipe               # ← Executor engine (Hamilton hoặc Haystack)
    
    @abstractmethod
    def run(self, *args, **kwargs):     # ← Mỗi pipeline phải implement hàm này
        ...

@dataclass
class PipelineComponent(Mapping):
    """
    Container chứa tất cả provider cần cho 1 pipeline.
    Dùng như dict: pipe_components["llm_provider"] → trả LLMProvider instance
    """
    llm_provider: LLMProvider = None
    embedder_provider: EmbedderProvider = None
    document_store_provider: DocumentStoreProvider = None
    engine: Engine = None
```

**Cơ chế Hamilton AsyncDriver**: Mỗi pipeline module định nghĩa các hàm Python thuần (decorated với `@observe`). Hamilton tự phân tích dependencies giữa các hàm (qua parameter name matching) và xây dựng DAG (Directed Acyclic Graph). Khi gọi `driver.execute(["output_node"])`, Hamilton tự động chạy đúng thứ tự.

---

### 3.2 `core/provider.py` — Abstract Provider Interfaces

📄 **File**: [src/core/provider.py](WrenAI/wren-ai-service/src/core/provider.py)

**Mục đích**: Định nghĩa interface cho mọi dịch vụ bên ngoài — cho phép thay đổi provider mà không ảnh hưởng pipeline

```python
class LLMProvider(metaclass=ABCMeta):
    """Interface cho nhà cung cấp LLM (OpenAI, Anthropic, Gemini, ...)"""
    @abstractmethod
    def get_generator(self, *args, **kwargs):
        ...  # Trả về hàm async gọi LLM
    
    def get_model(self): return self._model              # Tên model (gpt-4o, gemini-pro)
    def get_context_window_size(self): return self._context_window_size  # Kích thước context

class EmbedderProvider(metaclass=ABCMeta):
    """Interface cho nhà cung cấp Embedding"""
    @abstractmethod
    def get_text_embedder(self, ...):    ...  # Embed 1 text (cho query)
    @abstractmethod
    def get_document_embedder(self, ...): ...  # Embed nhiều Document (cho indexing)

class DocumentStoreProvider(metaclass=ABCMeta):
    """Interface cho Vector Database"""
    @abstractmethod
    def get_store(self, ...) -> DocumentStore:  ...  # Lấy kho vector
    @abstractmethod
    def get_retriever(self, ...):               ...  # Lấy bộ tìm kiếm
```

**Tại sao dùng Abstract**: Cho phép swap provider dễ dàng — ví dụ đổi từ Qdrant sang Pinecone chỉ cần implement 1 class mới, không sửa pipeline nào.

---

### 3.3 `core/engine.py` — Abstract Engine & Tiện ích SQL

📄 **File**: [src/core/engine.py](WrenAI/wren-ai-service/src/core/engine.py)

**Mục đích**: Interface cho SQL execution engine + hàm dọn dẹp SQL output từ LLM

```python
class Engine(metaclass=ABCMeta):
    @abstractmethod
    async def execute_sql(self, sql, session, dry_run=True, ...):
        """
        Thực thi hoặc xác thực SQL.
        dry_run=True: Chỉ kiểm tra cú pháp, không thực thi thật
        dry_run=False: Thực thi thật và trả dữ liệu
        """
        ...

def clean_generation_result(result: str) -> str:
    """Dọn dẹp output LLM: loại bỏ markdown code blocks, dấu ;, khoảng trắng thừa"""
    return result.replace("```sql", "").replace("```", "").replace(";", "").strip()

def remove_limit_statement(sql: str) -> str:
    """Xóa LIMIT clause khỏi SQL (dùng khi cần lấy toàn bộ dữ liệu)"""
    return re.sub(r"\bLIMIT\s+\d+\b", "", sql, flags=re.IGNORECASE).strip()
```

---

## IV. PROVIDERS — Tích hợp dịch vụ bên ngoài

### 4.1 `providers/__init__.py` — Factory tạo Component

📄 **File**: [src/providers/\_\_init\_\_.py](WrenAI/wren-ai-service/src/providers/__init__.py)

**Mục đích**: Đọc YAML config → Tạo tất cả provider instances → Ghép thành `PipelineComponent` cho mỗi pipeline

```python
def generate_components(configs: list[dict]) -> dict[str, PipelineComponent]:
    """
    ENTRY POINT: Được gọi từ __main__.py
    1. loader.import_mods() → Auto-import tất cả provider modules
    2. transform(configs) → Parse YAML thành Configuration(providers, pipelines)
    3. Instantiate providers → LLMProvider, EmbedderProvider, etc.
    4. Tạo PipelineComponent cho mỗi pipeline từ config
    """

def provider_factory(config: dict):
    """Dùng loader.get_provider(name) để tạo instance từ registry"""

def llm_processor(entry: dict) -> dict:
    """Xử lý config LLM: model name, fallback chain, api_key, timeout"""
    # Hỗ trợ fallback: nếu model chính fail → tự chuyển sang model dự phòng

def pipeline_processor(entry: dict) -> dict:
    """Map tên pipeline → tên provider (llm, embedder, document_store, engine)"""
```

**Luồng tạo component**:

```
config.yaml → transform() → Configuration → provider_factory() → Provider instances
                                           → pipeline_processor() → PipelineComponent per pipeline
```

---

### 4.2 `providers/loader.py` — Registry Pattern

📄 **File**: [src/providers/loader.py](WrenAI/wren-ai-service/src/providers/loader.py)

**Mục đích**: Plugin system — tự động phát hiện và đăng ký provider qua decorator

```python
PROVIDERS = {}  # ← Registry global

def provider(name: str):
    """
    DECORATOR đăng ký provider vào registry.
    Khi import module, class sẽ tự động được đăng ký.
    """
    def wrapper(cls):
        PROVIDERS[name] = cls
        return cls
    return wrapper

def import_mods(package="src.providers"):
    """Auto-import tất cả submodule trong src/providers/ → trigger decorator"""

def get_provider(name: str):
    """Lấy provider class từ registry theo tên"""
    return PROVIDERS[name]
```

**Cách sử dụng**:

```python
# Trong qdrant.py:
@provider("qdrant")
class QdrantProvider(DocumentStoreProvider): ...

# Trong litellm.py (llm):
@provider("litellm_llm")
class LitellmLLMProvider(LLMProvider): ...

# Khi cần tạo instance:
cls = get_provider("qdrant")  # → QdrantProvider
instance = cls(**config)
```

---

### 4.3 `providers/document_store/qdrant.py` — Vector Database

📄 **File**: [src/providers/document_store/qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py)

**Mục đích**: Quản lý 6 Qdrant vector collections — lưu trữ, tìm kiếm, xóa documents

| Class | Kế thừa | Chức năng |
|---|---|---|
| `AsyncQdrantDocumentStore` | `QdrantDocumentStore` | Kho vector bất đồng bộ — tất cả operations dùng `async_client` |
| `AsyncQdrantEmbeddingRetriever` | — | Haystack `@component` — bọc store để dùng trong pipeline |
| `QdrantProvider` | `DocumentStoreProvider` | Factory quản lý 6 collections |

**6 Collections trong Qdrant**:

```python
class QdrantProvider(DocumentStoreProvider):
    def _reset_document_store(self, recreate_index):
        self.get_store()                                  # 1. "Document" → DDL Schema chunks
        self.get_store(dataset_name="table_descriptions") # 2. Mô tả bảng (cho table retrieval)
        self.get_store(dataset_name="view_questions")     # 3. Câu hỏi lịch sử (views)
        self.get_store(dataset_name="sql_pairs")          # 4. Cặp câu hỏi-SQL (few-shot)
        self.get_store(dataset_name="instructions")       # 5. Hướng dẫn nghiệp vụ
        self.get_store(dataset_name="project_meta")       # 6. Metadata dự án (data source)
```

**Cơ chế tìm kiếm Cosine Similarity**:

```python
async def _query_by_embedding(self, query_embedding, filters, top_k=10):
    # 1. Gửi vector câu hỏi tới Qdrant
    points = await self.async_client.search(
        collection_name=self.index,
        query_vector=rest.NamedVector(name="", vector=query_embedding),
        limit=top_k,
    )
    # 2. Chuẩn hóa điểm cosine: [-1,1] → [0,1]
    score = (score + 1) / 2
```

**Cơ chế ghi documents**:

```python
async def write_documents(self, documents, policy=DuplicatePolicy.OVERWRITE):
    # Chia documents thành batch → Upsert vào Qdrant
    points = [
        rest.PointStruct(
            id=doc.id,                    # UUID
            vector=doc.embedding,          # Vector embedding
            payload={"content": doc.content, "meta": doc.meta}  # Nội dung + metadata
        )
        for doc in documents
    ]
    await self.async_client.upsert(collection_name=..., points=points)
```

---

### 4.4 `providers/embedder/litellm.py` — Text to Vector

📄 **File**: [src/providers/embedder/litellm.py](WrenAI/wren-ai-service/src/providers/embedder/litellm.py)

**Mục đích**: Chuyển text thành vector số — dùng 2 class cho 2 use case khác nhau

| Class | Decorator | Chức năng | Khi nào dùng |
|---|---|---|---|
| `AsyncTextEmbedder` | `@component` | Embed **1 text** → 1 vector | Khi user đặt câu hỏi (query) |
| `AsyncDocumentEmbedder` | `@component` | Embed **nhiều Document** → nhiều vector | Khi indexing (lưu tri thức) |
| `LitellmEmbedderProvider` | `@provider("litellm_embedder")` | Factory tạo 2 class trên |  |

```python
# AsyncTextEmbedder — Embed 1 câu hỏi
@component
class AsyncTextEmbedder:
    @backoff.on_exception(backoff.expo, openai.RateLimitError, max_time=60, max_tries=3)
    async def run(self, text: str):
        text = text.replace("\n", " ")                    # Tiền xử lý
        response = await aembedding(                       # Gọi API embedding
            model=self._model, input=[text], api_key=...
        )
        return {"embedding": response.data[0]["embedding"]}  # Trả vector

# AsyncDocumentEmbedder — Embed hàng loạt
@component
class AsyncDocumentEmbedder:
    async def _embed_batch(self, texts, batch_size=32):
        # Chia text thành batch 32 → Gọi API song song → Gộp kết quả
        batches = [texts[i:i+batch_size] for i in range(0, len(texts), batch_size)]
        responses = await asyncio.gather(*[embed_single_batch(b) for b in batches])
    
    async def run(self, documents: list[Document]):
        # 1. Lấy content từ mỗi Document
        # 2. Embed batch
        # 3. Gắn vector vào doc.embedding
        for doc, emb in zip(documents, embeddings):
            doc.embedding = emb
```

---

### 4.5 `providers/llm/litellm.py` — Gọi LLM

📄 **File**: [src/providers/llm/litellm.py](WrenAI/wren-ai-service/src/providers/llm/litellm.py)

**Mục đích**: Giao tiếp với LLM (OpenAI/Anthropic/Gemini) qua LiteLLM — hỗ trợ streaming, fallback, JSON schema response

```python
@provider("litellm_llm")
class LitellmLLMProvider(LLMProvider):
    def __init__(self, model, ..., fallback_model_list=None):
        self._model = model                                    # Model chính: gpt-4o, gemini-pro, ...
        if fallback_model_list:
            self._router = Router(                             # Router cho fallback
                model_list=fallback_model_list,
                fallbacks=[{model: [fallback_models]}]         # Model fail → auto chuyển sang dự phòng
            )
    
    def get_generator(self, model_kwargs=None, streaming_callback=None):
        """Trả về hàm async gọi LLM — có 2 chế độ: streaming và non-streaming"""
        
        @backoff.on_exception(backoff.expo, openai.RateLimitError, max_time=60, max_tries=3)
        async def _run(prompt, ...):
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": prompt},
            ]
            
            if streaming_callback:
                # STREAMING: Nhận từng chunk text real-time
                completion = await acompletion(
                    model=self._model, messages=messages, stream=True, ...
                )
                async for chunk in completion:
                    delta = chunk.choices[0].delta.content
                    if delta:
                        streaming_callback(chunk)  # Gửi chunk về pipeline
                        collected_content += delta
            else:
                # NON-STREAMING: Nhận toàn bộ response cùng lúc
                if self._has_fallbacks:
                    completion = await self._router.acompletion(...)
                else:
                    completion = await acompletion(...)
            
            return {"replies": [collected_content], "meta": [usage_info]}
        
        return _run
```

**Cơ chế Fallback**: Khi model chính gặp lỗi (rate limit, timeout), `Router` tự động gọi model dự phòng trong danh sách. Chuỗi fallback được config trong YAML.

**Cơ chế JSON Schema Response**: Một số pipeline yêu cầu output JSON có cấu trúc cố định. LiteLLM chuyển Pydantic schema thành `response_format` parameter cho API call:

```python
model_kwargs = {
    "response_format": {
        "type": "json_schema",
        "json_schema": MyPydanticModel.model_json_schema()
    }
}
```

---

### 4.6 `providers/engine/wren.py` — SQL Execution

📄 **File**: [src/providers/engine/wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py)

**Mục đích**: 3 engine khác nhau để thực thi và xác thực SQL

| Class | Decorator | Giao tiếp | Chức năng |
|---|---|---|---|
| `WrenUI` | `@provider("wren_ui")` | GraphQL → Wren UI server | Execute SQL qua `previewSql` mutation |
| `WrenIbis` | `@provider("wren_ibis")` | REST API → Ibis connector | Execute SQL + `dry_plan()` + `get_func_list()` + `get_sql_knowledge()` |
| `WrenEngine` | `@provider("wren_engine")` | REST API → Engine trực tiếp | Execute SQL đơn giản |

```python
# WrenUI — Xác thực SQL qua GraphQL
@provider("wren_ui")
class WrenUI(Engine):
    async def execute_sql(self, sql, session, dry_run=True, ...):
        async with session.post(
            f"{self._endpoint}/api/graphql",
            json={
                "query": """mutation PreviewSql($data: PreviewSQLDataInput) {
                    previewSql(data: $data)
                }""",
                "variables": {"data": {"sql": sql, "dryRun": dry_run, "limit": 1}},
            }
        ) as response:
            result = await response.json()
            if "errors" in result:
                return False, None, {"error_message": error_text}  # SQL lỗi
            return True, result["data"], None                       # SQL hợp lệ

# WrenIbis — Có thêm dry_plan, func_list, sql_knowledge
@provider("wren_ibis")
class WrenIbis(Engine):
    async def dry_plan(self, sql, session):
        """Tạo execution plan mà không thực thi — dùng để validate nhanh"""
        
    async def get_func_list(self, data_source, session) -> list[dict]:
        """Lấy danh sách SQL functions hỗ trợ cho data source cụ thể"""
        
    async def get_sql_knowledge(self, data_source, session) -> dict:
        """Lấy bộ rules Text-to-SQL chuyên biệt cho data source"""
```

---

## V. PIPELINES/COMMON — Hàm dùng chung

📄 **File**: [src/pipelines/common.py](WrenAI/wren-ai-service/src/pipelines/common.py)

**Mục đích**: Các hàm và component được CHIA SẺ giữa nhiều pipeline

| Hàm/Class | Chức năng | Nơi sử dụng |
|---|---|---|
| `build_table_ddl(schema_dict)` | Tái cấu trúc dict → DDL text (`CREATE TABLE ...`) | `db_schema_retrieval.py` |
| `ScoreFilter` | `@component`: Lọc Documents theo ngưỡng score | `sql_pairs_retrieval.py`, `historical_question_retrieval.py` |
| `clean_up_new_lines(text)` | Dọn `\n` thừa, thay nhiều dấu cách → 1 | Hầu hết generation pipeline |
| `retrieve_metadata(retriever)` | Lấy metadata dự án từ `project_meta` store | `sql_functions.py`, `sql_knowledge.py`, `followup_sql_generation.py` |
| `get_engine_supported_data_type()` | Map kiểu data giữa các engine | `db_schema.py` |

```python
@component
class ScoreFilter:
    """Lọc documents theo ngưỡng cosine similarity"""
    @component.output_types(documents=List[Document])
    def run(self, documents: List[Document], score: float = 0.9, max_size: int = 10):
        return {
            "documents": sorted(
                filter(lambda d: d.score >= score, documents),  # Chỉ giữ doc ≥ ngưỡng
                key=lambda d: d.score, reverse=True              # Xếp giảm dần
            )[:max_size]                                         # Giới hạn max_size
        }
```

---

## VI. PIPELINES/INDEXING — Chuẩn bị tri thức

> **Vai trò**: Chuyển đổi MDL (Model Definition Language) thành Documents → Embed thành Vector → Lưu vào Qdrant

### Luồng chung mọi Indexing pipeline

```
MDL JSON string → Validate → Chunk (chia nhỏ) → Embed (text→vector) → Clean (xóa cũ) → Write (lưu Qdrant)
```

### 6.1 `indexing/__init__.py` — Component dùng chung

📄 **File**: [src/pipelines/indexing/\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/indexing/__init__.py)

| Component | Decorator | Chức năng |
|---|---|---|
| `DocumentCleaner` | `@component` | Xóa documents cũ theo `project_id` trước khi index mới |
| `MDLValidator` | `@component` | Validate JSON MDL hợp lệ (parse + kiểm tra cấu trúc) |
| `AsyncDocumentWriter` | `@component` | Ghi documents vào Qdrant bất đồng bộ (bọc Haystack `DocumentWriter`) |
| `clean_display_name(name)` | Hàm | Chuẩn hóa tên hiển thị (bỏ dấu `"`, thay `_` bằng khoảng trắng) |

---

### 6.2 `indexing/db_schema.py` — DDL Chunking & Indexing

📄 **File**: [src/pipelines/indexing/db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py)

**Mục đích**: Chia nhỏ cấu trúc database (bảng, cột, quan hệ) thành chunks → embed → lưu vào collection `"Document"`

| Class/Hàm | Chức năng |
|---|---|
| `DDLChunker` (`@component`) | **CỐT LÕI**: Chia MDL thành chunks DDL |
| `DBSchema(BasicPipeline)` | Pipeline hoàn chỉnh: validate → chunk → embed → clean → write |

**Cơ chế Chunking chi tiết trong `DDLChunker`**:

```python
@component
class DDLChunker:
    def run(self, mdl, column_batch_size=50):
        chunks = []
        for model in mdl["models"]:
            # CHUNK TYPE 1: TABLE metadata (tên, mô tả, alias)
            chunks.append(_model_command(model))        # type="TABLE"
            
            # CHUNK TYPE 2: TABLE_COLUMNS (batch cột tối đa 50 mỗi chunk)
            column_batches = self._column_batch(model, ..., column_batch_size)
            chunks.extend(column_batches)                # type="TABLE_COLUMNS"
            
            # CHUNK TYPE 3: FOREIGN_KEY relationships
            for rel in model.get("relationships", []):
                chunks.append(_relationship_command(rel))  # type="FOREIGN_KEY"
        
        for view in mdl.get("views", []):
            # CHUNK TYPE 4: VIEW
            chunks.append(_view_command(view))            # type="VIEW"
        
        for metric in mdl.get("metrics", []):
            # CHUNK TYPE 5: METRIC
            chunks.append(_metric_command(metric))        # type="METRIC"
        
        # Chuyển mỗi chunk thành Haystack Document
        return {"documents": [Document(content=c["payload"], meta={"name": c["name"]}}) for c in chunks]}
```

**Ví dụ**: Bảng `Employees` có 120 cột tạo ra:
- 1 chunk TABLE (metadata)
- 3 chunk TABLE_COLUMNS (50 + 50 + 20 cột)
- N chunk FOREIGN_KEY (mỗi quan hệ 1 chunk)

**Hamilton DAG nodes**: `validate_mdl` → `chunk` → `embedding` → `clean` → `write`

---

### 6.3 `indexing/table_description.py` — Mô tả bảng

📄 **File**: [src/pipelines/indexing/table_description.py](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py)

**Mục đích**: Tạo 1 Document mô tả cho mỗi bảng/metric/view → lưu vào collection `"table_descriptions"`

```python
@component
class TableDescriptionChunker:
    """Mỗi bảng → 1 Document chứa: tên bảng + mô tả + danh sách cột"""
    def run(self, mdl):
        descriptions = []
        for model in mdl["models"]:
            descriptions.append(Document(
                content=f"{model['name']}: {model.get('description', '')}. Columns: {', '.join(col_names)}",
                meta={"name": model["name"], "type": "MODEL"}
            ))
        # Tương tự cho metrics và views
```

**Tại sao cần collection riêng**: Khi user hỏi, hệ thống tìm **bảng liên quan** trước (dùng `table_descriptions`) → rồi mới lấy **chi tiết DDL** từ collection `Document`. Đây là retrieval 2 bước.

---

### 6.4 `indexing/historical_question.py` — Câu hỏi lịch sử

📄 **File**: [src/pipelines/indexing/historical_question.py](WrenAI/wren-ai-service/src/pipelines/indexing/historical_question.py)

**Mục đích**: Lưu các câu hỏi đã được trả lời (từ views) → collection `"view_questions"` — cho phép tái sử dụng câu trả lời cũ

```python
@component
class ViewChunker:
    """Mỗi view → 1 Document chứa: câu hỏi gốc + tóm tắt + các câu hỏi lịch sử"""
    def run(self, mdl):
        for view in mdl.get("views", []):
            historical_queries = view.get("properties", {}).get("historical_queries", [])
            content = f"Question: {view.get('question', '')}. Summary: {view.get('summary', '')}. "
            content += " ".join([q["question"] for q in historical_queries])
            # Document.meta chứa viewId → dùng để redirect thẳng tới view có sẵn
```

**Ngưỡng**: Chỉ khi similarity ≥ 0.9 (90%) mới được coi là "câu hỏi đã trả lời"

---

### 6.5 `indexing/sql_pairs.py` — Cặp câu hỏi-SQL

📄 **File**: [src/pipelines/indexing/sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py)

**Mục đích**: Lưu cặp câu hỏi + SQL (từ user tinh chỉnh) → collection `"sql_pairs"` — dùng cho few-shot learning

```python
class SqlPair(BaseModel):
    """Cấu trúc 1 SQL pair"""
    id: str
    sql: str           # Câu lệnh SQL
    question: str      # Câu hỏi tự nhiên

@component
class SqlPairsConverter:
    """Mỗi SqlPair → 1 Document: content=question (được embed), meta.sql=SQL"""
    def run(self, sql_pairs: list[SqlPair]):
        return {
            "documents": [
                Document(
                    content=pair.question,  # ← TEXT ĐƯỢC EMBED: câu hỏi tự nhiên
                    meta={
                        "sql_pair_id": pair.id,
                        "sql": pair.sql,    # ← SQL lưu trong metadata (không embed)
                    }
                )
                for pair in sql_pairs
            ]
        }
```

**Cơ chế**: Khi user hỏi câu mới, hệ thống tìm câu hỏi tương tự trong `sql_pairs` → lấy SQL mẫu → đưa vào prompt như few-shot example cho LLM.

---

### 6.6 `indexing/instructions.py` — Hướng dẫn nghiệp vụ

📄 **File**: [src/pipelines/indexing/instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py)

**Mục đích**: Lưu hướng dẫn nghiệp vụ → collection `"instructions"` — bổ sung context cho LLM khi sinh SQL

```python
class Instruction(BaseModel):
    id: str
    instruction: str      # Nội dung hướng dẫn (VD: "Doanh thu = quantity * unit_price")
    question: str          # Câu hỏi mẫu (VD: "Tổng doanh thu theo tháng?")
    is_default: bool       # True = luôn áp dụng, False = chỉ khi câu hỏi tương đồng
    scope: str            # "sql" | "answer" | "chart" — phạm vi áp dụng

@component
class InstructionsConverter:
    def run(self, instructions):
        return {
            "documents": [
                Document(
                    content="this is a global instruction..." if inst.is_default
                            else inst.question,          # Default → text cố định, Custom → câu hỏi
                    meta={
                        "instruction": inst.instruction,  # Nội dung hướng dẫn thực tế
                        "is_default": inst.is_default,
                        "scope": inst.scope,
                    }
                )
                for inst in instructions
            ]
        }
```

**2 loại instruction**:
- `is_default=True` (mặc định): **Luôn được retrieve** — áp dụng cho mọi câu hỏi
- `is_default=False` (tùy chỉnh): Chỉ retrieve khi câu hỏi user tương đồng (similarity ≥ 0.7)

---

### 6.7 `indexing/project_meta.py` — Metadata dự án

📄 **File**: [src/pipelines/indexing/project_meta.py](WrenAI/wren-ai-service/src/pipelines/indexing/project_meta.py)

**Mục đích**: Lưu thông tin data source (loại DB) → collection `"project_meta"` — các pipeline khác dùng để biết loại DB đang kết nối

```python
class ProjectMeta(BasicPipeline):
    """
    Tạo 1 Document duy nhất chứa loại data source.
    VD: meta.data_source = "bigquery" | "postgresql" | "mysql" | "local_file"
    Lưu ý: "duckdb" tự động chuyển thành "local_file"
    """
```

**Sử dụng bởi**: `sql_functions.py`, `sql_knowledge.py` (cần biết data source để lấy đúng SQL functions/rules)

---

### 6.8 `indexing/utils/helper.py` — Tiền xử lý dữ liệu

📄 **File**: [src/pipelines/indexing/utils/helper.py](WrenAI/wren-ai-service/src/pipelines/indexing/utils/helper.py)

**Mục đích**: Helpers xử lý properties, relationships, calculated fields, JSON fields khi tạo DDL chunks

| Hằng số | Chức năng |
|---|---|
| `COLUMN_PREPROCESSORS` | Dict các Helper xử lý cột trước khi tạo DDL: properties, relationship, expression, isCalculated |
| `COLUMN_COMMENT_HELPERS` | Dict các Helper tạo comment cho cột: properties (tạo JSON comment alias/desc/nested), isCalculated (tạo comment expression) |
| `MODEL_PREPROCESSORS` | Dict các Helper xử lý model-level (mutable, nạp từ submodules) |

```python
# Ví dụ: Cột "MonthlyIncome" có properties {description: "Lương tháng", alias: "monthly_income"}
# → COLUMN_COMMENT_HELPERS["properties"] tạo:
#   -- {"alias": "monthly_income", "description": "Lương tháng"}
# → Dòng comment này được gắn vào DDL chunk cùng cột
```

---

## VII. PIPELINES/RETRIEVAL — Truy xuất ngữ cảnh

> **Vai trò**: Tìm kiếm thông tin liên quan từ Vector DB để bổ sung context cho LLM

### 7.1 `retrieval/db_schema_retrieval.py` — Tìm schema liên quan

📄 **File**: [src/pipelines/retrieval/db_schema_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py)

**Mục đích**: Pipeline retrieval chính — tìm các bảng liên quan nhất và tái cấu trúc DDL context

**Luồng 2 bước (Two-stage Retrieval)**:

```
Bước 1: Tìm bảng liên quan         Bước 2: Lấy chi tiết DDL
┌──────────────────────┐           ┌──────────────────────┐
│ embedding(query)     │           │ dbschema_retrieval()  │
│   ↓                  │           │   ↓                  │
│ table_retrieval()    │──────────▶│ (filter by tên bảng) │
│ (top_k=10 từ         │           │ (lấy tất cả chunks   │
│  "table_descriptions"│           │  TABLE + TABLE_COLUMNS│
│  collection)         │           │  + FOREIGN_KEY        │
└──────────────────────┘           │  từ "Document"        │
                                   │  collection)          │
                                   └──────────┬───────────┘
                                              │
                                   ┌──────────▼───────────┐
                                   │ construct_db_schemas()│
                                   │ (ghép chunks → DDL   │
                                   │  hoàn chỉnh per bảng)│
                                   └──────────┬───────────┘
                                              │
                                   ┌──────────▼───────────┐
                                   │ Column Pruning?       │
                                   │ (nếu DDL quá dài     │
                                   │  > context_window     │
                                   │  → gọi LLM cắt bớt  │
                                   │  cột không liên quan) │
                                   └──────────────────────┘
```

**Hamilton DAG nodes**: `embedding` → `table_retrieval` → `dbschema_retrieval` → `construct_db_schemas` → `check_using_db_schemas_without_pruning` → (optional) `column_pruning` → `construct_retrieval_results`

**Column Pruning**: Khi tổng DDL vượt `context_window_size` token (đo bằng tiktoken), hệ thống gọi LLM yêu cầu loại bỏ cột không liên quan tới câu hỏi.

---

### 7.2 `retrieval/sql_pairs_retrieval.py` — Tìm SQL mẫu

📄 **File**: [src/pipelines/retrieval/sql_pairs_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_pairs_retrieval.py)

**Mục đích**: Tìm SQL mẫu tương tự từ collection `"sql_pairs"` — dùng cho few-shot prompting

```python
class SqlPairsRetrieval(BasicPipeline):
    # Luồng: embedding(query) → retrieval(top_k=10) → ScoreFilter(score≥0.7) → format output
    # Kết quả: list[{question, sql}] — câu hỏi + SQL mẫu tương đồng nhất
```

**Ngưỡng**: `score ≥ 0.7` (70%) — chỉ SQL pairs có similarity cao mới được chọn

---

### 7.3 `retrieval/historical_question_retrieval.py` — Tìm câu hỏi cũ

📄 **File**: [src/pipelines/retrieval/historical_question_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/historical_question_retrieval.py)

**Mục đích**: Tìm câu hỏi đã trả lời (có view sẵn) → nếu tìm thấy, trả view ngay không cần sinh SQL mới

```python
class HistoricalQuestionRetrieval(BasicPipeline):
    # Luồng: embedding(query) → retrieval(top_k) → ScoreFilter(score≥0.9) → extract viewId
    # Nếu tìm thấy viewId → redirect tới view có sẵn (không cần sinh SQL)
```

**Ngưỡng**: `score ≥ 0.9` (90%) — rất nghiêm ngặt, chỉ khi câu hỏi gần như giống hệt mới tái sử dụng

---

### 7.4 `retrieval/instructions.py` — Tìm hướng dẫn

📄 **File**: [src/pipelines/retrieval/instructions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/instructions.py)

**Mục đích**: Retrieve hướng dẫn nghiệp vụ phù hợp — kết hợp default + custom instructions

```python
class Instructions(BasicPipeline):
    # Luồng:
    # 1. embedding(query) → Embed câu hỏi
    # 2. retrieval() → Tìm instructions tương đồng
    # 3. ScopeFilter(scope="sql"|"answer"|"chart") → Lọc theo phạm vi
    # 4. ScoreFilter(score≥0.7) → Lọc theo ngưỡng
    # 5. default_instructions() → Luôn lấy instructions có is_default=True
    # 6. merge() → Ghép default + filtered custom instructions
```

**Cơ chế ScopeFilter**: Mỗi instruction có `scope` ("sql", "answer", "chart"). Pipeline sẽ lọc theo scope phù hợp với tác vụ hiện tại.

---

### 7.5 `retrieval/sql_executor.py` — Thực thi SQL

📄 **File**: [src/pipelines/retrieval/sql_executor.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_executor.py)

**Mục đích**: Thực thi SQL thật trên Wren Engine và lấy dữ liệu trả về

```python
@component
class DataFetcher:
    """Haystack component gọi engine.execute_sql() qua aiohttp session"""
    def run(self, sql, project_id, limit=500):
        # Gửi SQL tới engine → nhận kết quả (columns + data rows)
        # limit=500: Giới hạn số hàng trả về
        success, data, error = await self._engine.execute_sql(sql, session, dry_run=False)
        return {"results": {"columns": ..., "data": ...}, "error_message": error}

class SQLExecutor(BasicPipeline):
    """Bọc DataFetcher trong Hamilton pipeline"""
```

**Sử dụng bởi**: `ChartService`, `ChartAdjustmentService`, `SqlAnswerService` — khi cần data thật để tạo biểu đồ hoặc text answer

---

### 7.6 `retrieval/sql_functions.py` — Hàm SQL hỗ trợ

📄 **File**: [src/pipelines/retrieval/sql_functions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_functions.py)

**Mục đích**: Lấy danh sách SQL functions được data source hỗ trợ (VD: DATE_TRUNC, ARRAY_AGG, ...)

```python
class SqlFunction:
    """Bọc 1 SQL function definition — chuyển thành expression dạng text cho prompt"""
    _expr: str  # VD: "DATE_TRUNC(part, date) → timestamp"

class SqlFunctions(BasicPipeline):
    """
    Pipeline + TTL Cache (24 giờ):
    1. retrieve_metadata() → Biết data_source là gì (bigquery, postgresql, ...)
    2. engine.get_func_list(data_source) → Lấy function list từ WrenIbis
    3. cache() → Cache 24h (không gọi lại API)
    """
```

**Lưu ý**: Chỉ hoạt động với `WrenIbis` engine (không phải `WrenUI`)

---

### 7.7 `retrieval/sql_knowledge.py` — Tri thức SQL

📄 **File**: [src/pipelines/retrieval/sql_knowledge.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_knowledge.py)

**Mục đích**: Lấy bộ rules Text-to-SQL chuyên biệt cho data source — bổ sung bộ rules mặc định

```python
class SqlKnowledge:
    """Container cho tri thức SQL engine-specific"""
    text_to_sql_rule: str                      # Rules cho SQL generation
    instructions: str                           # Instructions bổ sung
    calculated_field_instructions: str          # Hướng dẫn calculated fields
    metric_instructions: str                    # Hướng dẫn metrics
    json_field_instructions: str                # Hướng dẫn JSON fields

class SqlKnowledges(BasicPipeline):
    """Pipeline + TTL Cache (24h) — Lấy knowledge từ WrenIbis"""
```

---

### 7.8 `retrieval/preprocess_sql_data.py` — Tiền xử lý dữ liệu

📄 **File**: [src/pipelines/retrieval/preprocess_sql_data.py](WrenAI/wren-ai-service/src/pipelines/retrieval/preprocess_sql_data.py)

**Mục đích**: Cắt bớt rows dữ liệu SQL sao cho vừa context window LLM

```python
class PreprocessSqlData(BasicPipeline):
    def __init__(self, llm_provider):
        # Chọn tokenizer phù hợp:
        # - "o200k_base" cho gpt-4o variants
        # - "cl100k_base" cho các model khác
        self._encoding = tiktoken.get_encoding(encoding_name)
        self._context_window_size = llm_provider.get_context_window_size()
    
    # Luồng: đếm token → nếu quá lớn → giảm dần 50 rows mỗi lần → lặp cho đến khi vừa
```

**Cơ chế**: Giảm dần (`reduction_step=50` rows) cho đến khi tổng token < context_window_size

---

## VIII. PIPELINES/GENERATION — Sinh nội dung

> **Vai trò**: Sử dụng LLM để sinh SQL, text, chart, và các nội dung khác từ context đã retrieve
>
> **Pattern chung**: Mỗi pipeline = Hamilton DAG: `prompt()` → `generate()` → `post_process()`

### Pattern chung cho TẤT CẢ Generation pipeline

```python
# 1. PROMPT: Ghép template Jinja2 với context
@observe(capture_input=False)
def prompt(query, documents, prompt_builder, ...):
    return prompt_builder.run(query=query, documents=documents, ...)

# 2. GENERATE: Gọi LLM
@observe(as_type="generation", capture_input=False)
@trace_cost
async def generate(prompt, generator, generator_name, ...):
    return await generator(prompt=prompt["prompt"], ...)

# 3. POST-PROCESS: Parse output, validate, clean
@observe(capture_input=False)
async def post_process(generate, ...):
    # Parse JSON, validate SQL, extract fields, ...

# 4. CLASS: Bọc DAG thành pipeline
class MyPipeline(BasicPipeline):
    def __init__(self, llm_provider, ...):
        self._configs = {
            "generator": llm_provider.get_generator(model_kwargs=...),
            "generator_name": llm_provider.get_model(),
            "prompt_builder": PromptBuilder(template=user_prompt_template),
            ...
        }
        self._pipe = AsyncDriver(self._configs, sys.modules[__name__], result_builder=base.DictResult())
    
    @observe(name="My Pipeline")
    async def run(self, ...):
        return await self._pipe.execute(["post_process"], inputs={...})
```

### 5 Pipeline có Streaming support

| Pipeline | Queue | Sentinel | Dùng cho |
|---|---|---|---|
| `SQLGenerationReasoning` | `asyncio.Queue()` per query_id | `"<DONE>"` | Chain of Thought planning |
| `FollowUpSQLGenerationReasoning` | `asyncio.Queue()` per query_id | `"<DONE>"` | Follow-up reasoning |
| `DataAssistance` | `asyncio.Queue()` per query_id | `"<DONE>"` | Trả lời về schema |
| `MisleadingAssistance` | `asyncio.Queue()` per query_id | `"<DONE>"` | Xử lý câu hỏi sai |
| `UserGuideAssistance` | `asyncio.Queue()` per query_id | `"<DONE>"` | Hướng dẫn sử dụng |
| `SQLAnswer` | `asyncio.Queue()` per query_id | `"<DONE>"` | SQL → text answer |

```python
# Pattern streaming chung
class StreamingPipeline(BasicPipeline):
    def __init__(self, ...):
        self._user_queues = {}
    
    def _streaming_callback(self, chunk, query_id):
        asyncio.create_task(self._user_queues[query_id].put(chunk.content))
    
    async def get_streaming_results(self, query_id):
        while True:
            result = await asyncio.wait_for(self._user_queues[query_id].get(), timeout=120)
            if result == "<DONE>":
                break
            yield result
```

---

### 8.1 `generation/intent_classification.py` — Phân loại ý định

📄 **File**: [src/pipelines/generation/intent_classification.py](WrenAI/wren-ai-service/src/pipelines/generation/intent_classification.py)

**Mục đích**: Phân loại câu hỏi user thành 4 loại ý định → quyết định pipeline tiếp theo

| Ý định | Giải thích | Pipeline tiếp |
|---|---|---|
| `TEXT_TO_SQL` | Câu hỏi cần sinh SQL | → SQLGenerationReasoning → SQLGeneration |
| `GENERAL` | Câu hỏi chung về dữ liệu | → DataAssistance (streaming) |
| `MISLEADING_QUERY` | Câu hỏi không liên quan tới DB | → MisleadingAssistance (streaming) |
| `USER_GUIDE` | Câu hỏi về cách dùng Wren AI | → UserGuideAssistance (streaming) |

```python
# DAG: embedding → table_retrieval → dbschema_retrieval → construct_db_schemas → prompt → classify → post_process
# Output: {intent: "TEXT_TO_SQL", rephrased_question: "...", db_schemas: [...]}
```

**Lưu ý**: Pipeline này cũng thực hiện **rephrasing** — viết lại câu hỏi user rõ ràng hơn cho các bước tiếp theo.

---

### 8.2 `generation/sql_generation_reasoning.py` — Chain of Thought

📄 **File**: [src/pipelines/generation/sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py)

**Mục đích**: Tạo kế hoạch suy luận từng bước trước khi sinh SQL — cải thiện chất lượng SQL đáng kể

```python
# System prompt yêu cầu LLM lập kế hoạch:
# "Phân tích câu hỏi → Xác định bảng/cột cần → Lập bước truy vấn → Ghi ngôn ngữ user"
# STREAMING: Gửi từng chunk suy luận real-time về UI qua SSE

# DAG: prompt(query, documents, sql_samples, instructions, configuration)
#       → generate(streaming) → post_process
# Input configuration: language, timezone → để LLM biết ngôn ngữ và múi giờ
```

**Streaming**: LLM stream từng token suy luận → put vào `asyncio.Queue` → Service đọc và gửi SSE event → UI hiển thị real-time

---

### 8.3 `generation/sql_generation.py` — Sinh SQL chính

📄 **File**: [src/pipelines/generation/sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py)

**Mục đích**: Sinh câu SQL từ câu hỏi + context (schema, SQL mẫu, instructions, reasoning plan)

```python
# PROMPT TEMPLATE chứa:
# 1. DATABASE SCHEMA → DDL các bảng liên quan (từ retrieval)
# 2. SQL FUNCTIONS → Danh sách hàm SQL hỗ trợ (từ sql_functions)
# 3. SQL SAMPLES → SQL mẫu tương đồng (từ sql_pairs)
# 4. USER INSTRUCTIONS → Hướng dẫn nghiệp vụ (từ instructions)
# 5. QUESTION → Câu hỏi user
# 6. REASONING PLAN → Kế hoạch suy luận (từ reasoning pipeline)

# DAG: prompt → generate_sql → post_process(SQLGenPostProcessor)
# Post-process: clean SQL → execute dry_run → classify valid/invalid
```

---

### 8.4 `generation/sql_correction.py` — Sửa SQL lỗi

📄 **File**: [src/pipelines/generation/sql_correction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_correction.py)

**Mục đích**: Nhận SQL lỗi + error message → gọi LLM sửa → validate lại

```python
# PROMPT TEMPLATE chứa:
# 1. DATABASE SCHEMA → DDL context
# 2. INVALID SQL → SQL bị lỗi
# 3. ERROR MESSAGE → Thông báo lỗi từ engine
# 4. SQL FUNCTIONS → Hàm SQL hỗ trợ

# DAG: prompt → generate_sql_correction → post_process(validate lại)
# Retry: Tối đa 3 lần (max_sql_correction_retries=3 trong config)
```

---

### 8.5 `generation/sql_regeneration.py` — Tái sinh SQL

📄 **File**: [src/pipelines/generation/sql_regeneration.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_regeneration.py)

**Mục đích**: Tái sinh SQL khi user feedback (chỉnh sửa bước suy luận) — dùng trong Ask Feedback flow

```python
# Input: sql_generation_reasoning (đã chỉnh sửa) + SQL gốc + schema
# Output: SQL mới dựa trên reasoning đã chỉnh

# Hàm đặc biệt: get_sql_regeneration_system_prompt(sql_knowledge)
# → Tạo system prompt kết hợp rules mặc định + rules từ engine-specific knowledge
```

---

### 8.6 `generation/followup_sql_generation.py` — SQL câu hỏi nối tiếp

📄 **File**: [src/pipelines/generation/followup_sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/followup_sql_generation.py)

**Mục đích**: Sinh SQL cho câu hỏi nối tiếp (follow-up) — sử dụng lịch sử hội thoại (histories)

```python
# Khác biệt so với sql_generation.py:
# 1. Nhận histories: list[AskHistory] → danh sách câu hỏi + SQL trước đó
# 2. Prompt template chứa conversation history
# 3. LLM hiểu ngữ cảnh cuộc hội thoại để sinh SQL chính xác hơn

# generate_sql_in_followup() nhận histories → chuyển thành messages cho LLM
# Sử dụng construct_ask_history_messages() để format histories
```

---

### 8.7 `generation/followup_sql_generation_reasoning.py` — Suy luận nối tiếp

📄 **File**: [src/pipelines/generation/followup_sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/followup_sql_generation_reasoning.py)

**Mục đích**: Chain of Thought cho follow-up questions — streaming, có lịch sử hội thoại

```python
# Tương tự sql_generation_reasoning.py nhưng:
# - Prompt template chứa histories (câu hỏi + SQL trước đó)
# - Streaming support
# - Configuration: language, timezone
```

---

### 8.8 `generation/sql_answer.py` — Chuyển SQL thành text

📄 **File**: [src/pipelines/generation/sql_answer.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_answer.py)

**Mục đích**: Chuyển kết quả SQL thành câu trả lời tự nhiên bằng Markdown — streaming

```python
# System prompt: "Bạn là nhà phân tích dữ liệu, giải thích cho người không chuyên"
# Input: query, sql, sql_data (columns + rows), language, current_time
# Output: Markdown text dễ hiểu, không chứa SQL/thuật ngữ kỹ thuật
# custom_instruction: Instructions scope="answer" được thêm vào prompt

# Streaming: Gửi từng chunk text real-time về UI
```

---

### 8.9 `generation/sql_question.py` — Chuyển SQL thành câu hỏi

📄 **File**: [src/pipelines/generation/sql_question.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_question.py)

**Mục đích**: Reverse-engineer — từ SQL tạo câu hỏi tự nhiên bằng ngôn ngữ user

```python
# Input: SQL query + Configuration (language)
# Output: JSON {question: "..."} — 1 câu hỏi tự nhiên mô tả SQL
# Pydantic model: SQLQuestionResult(BaseModel) — question: str
```

---

### 8.10 `generation/sql_diagnosis.py` — Chẩn đoán lỗi SQL

📄 **File**: [src/pipelines/generation/sql_diagnosis.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_diagnosis.py)

**Mục đích**: So sánh SQL gốc vs SQL lỗi → giải thích nguyên nhân lỗi ngắn gọn (≤50 từ)

```python
# Input: original_sql, invalid_sql, error_message, database schema
# Output: JSON {reasoning: "..."} — giải thích lỗi
# Quy trình 4 bước:
# 1. Phân tích SQL gốc
# 2. So sánh với SQL lỗi
# 3. Kiểm tra error message
# 4. Kết luận nguyên nhân
```

---

### 8.11 `generation/sql_tables_extraction.py` — Trích xuất tên bảng

📄 **File**: [src/pipelines/generation/sql_tables_extraction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_tables_extraction.py)

**Mục đích**: Trích xuất danh sách tên bảng từ SQL query — dùng khi cần biết SQL tham chiếu bảng nào

```python
# Input: SQL query
# Output: JSON {tables: ["table1", "table2", ...]}
# Ví dụ: "SELECT * FROM orders JOIN customers" → ["orders", "customers"]
# Pydantic model: SQLTablesExtractionResult(BaseModel) — tables: list[str]
```

---

### 8.12 `generation/question_recommendation.py` — Gợi ý câu hỏi

📄 **File**: [src/pipelines/generation/question_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/question_recommendation.py)

**Mục đích**: Gợi ý câu hỏi phân tích dựa trên MDL — chia theo 4 danh mục

```python
# 4 danh mục gợi ý:
# 1. Descriptive — Mô tả (VD: "Tổng doanh thu theo tháng")
# 2. Segmentation — Phân đoạn (VD: "Top 5 phòng ban theo hiệu suất")
# 3. Comparative — So sánh (VD: "So sánh Q1 vs Q2")
# 4. Data Quality — Chất lượng dữ liệu (VD: "Có bao nhiêu giá trị null?")

# Mỗi câu hỏi gợi ý sẽ được VALIDATE bằng cách chạy full SQL generation pipeline
# → Chỉ giữ câu hỏi tạo ra SQL hợp lệ
```

---

### 8.13 `generation/chart_generation.py` — Sinh biểu đồ

📄 **File**: [src/pipelines/generation/chart_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_generation.py)

**Mục đích**: Sinh Vega-Lite chart schema từ câu hỏi + SQL + dữ liệu mẫu

```python
# Input: query, sql, data (sample_data → qua ChartDataPreprocessor)
# Output: JSON {reasoning, chart_type, chart_schema}

# 7 loại biểu đồ hỗ trợ:
# line, bar, pie, grouped_bar, stacked_bar, area, multi_line

# Validation: chart_schema được validate bằng jsonschema vs Vega-Lite v5 spec
# Data preprocessing: pandas sample 15 rows, 5 unique column values
```

---

### 8.14 `generation/chart_adjustment.py` — Tinh chỉnh biểu đồ

📄 **File**: [src/pipelines/generation/chart_adjustment.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_adjustment.py)

**Mục đích**: Chỉnh sửa biểu đồ hiện tại theo yêu cầu user (đổi loại, trục, màu)

```python
# ChartAdjustmentOption: 
#   chart_type: str         # Đổi loại biểu đồ
#   x_axis: str             # Đổi trục X
#   y_axis: str             # Đổi trục Y
#   x_offset: str           # Thêm offset X
#   color: str              # Đổi encoding màu
#   theta: str              # Cho biểu đồ tròn

# Input: query, sql, chart_schema (hiện tại), adjustment_option, sample_data
# Output: chart_schema mới đã chỉnh sửa
```

---

### 8.15 `generation/data_assistance.py` — Hỗ trợ dữ liệu

📄 **File**: [src/pipelines/generation/data_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/data_assistance.py)

**Mục đích**: Trả lời câu hỏi chung về database schema — KHÔNG sinh SQL, chỉ text Markdown

```python
# Dùng khi intent = "GENERAL"
# System prompt: "Data analyst, friendly, max 150 words CJK / 110 words other"
# Input: db_schemas (DDL context), query, language
# Output: Streaming Markdown text giải thích schema
# custom_instruction: Instructions scope="answer"
```

---

### 8.16 `generation/misleading_assistance.py` — Xử lý câu hỏi sai

📄 **File**: [src/pipelines/generation/misleading_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/misleading_assistance.py)

**Mục đích**: Trả lời câu hỏi không liên quan — gợi ý câu hỏi tốt hơn dựa trên schema

```python
# Dùng khi intent = "MISLEADING_QUERY"
# System prompt: "Max 100 words, no SQL, suggest better questions based on DB schema"
# Input: db_schemas, query, language
# Output: Streaming text giải thích + gợi ý câu hỏi phù hợp
```

---

### 8.17 `generation/user_guide_assistance.py` — Hướng dẫn sử dụng

📄 **File**: [src/pipelines/generation/user_guide_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/user_guide_assistance.py)

**Mục đích**: Trả lời câu hỏi về Wren AI tool từ tài liệu hướng dẫn — kèm citations

```python
# Dùng khi intent = "USER_GUIDE"
# System prompt: "Follow user guide strictly, add citations (document URL), Markdown output"
# Input: query, language, wren_ai_docs (fetched from fetch_wren_ai_docs())
# wren_ai_docs: list[{path, content}] — tài liệu hướng dẫn
# Output: Streaming Markdown text với links tham chiếu
```

---

### 8.18 `generation/relationship_recommendation.py` — Gợi ý quan hệ

📄 **File**: [src/pipelines/generation/relationship_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/relationship_recommendation.py)

**Mục đích**: Phân tích MDL và gợi ý relationships (FK) giữa các bảng

```python
# Input: mdl (JSON models), language
# Output: JSON {relationships: [{name, fromModel, fromColumn, type, toModel, toColumn, reason}]}

# 3 loại quan hệ: MANY_TO_ONE, ONE_TO_MANY, ONE_TO_ONE

# DAG: cleaned_models → prompt → generate → normalized → validated
# validated(): Kiểm tra tên model/column thực sự tồn tại trong MDL

# Pydantic: RelationType(Enum), ModelRelationship(BaseModel), RelationshipResult(BaseModel)
```

---

### 8.19 `generation/semantics_description.py` — Mô tả ngữ nghĩa

📄 **File**: [src/pipelines/generation/semantics_description.py](WrenAI/wren-ai-service/src/pipelines/generation/semantics_description.py)

**Mục đích**: Auto-generate mô tả (description) cho models và columns

```python
# Input: user_prompt, selected_models, mdl, language
# Output: dict[model_name→{columns: [{name, description}], description: str}]

# DAG: picked_models → prompt → generate → normalize → output
# normalize(): Parse JSON, group by model name
# output(): Filter enriched columns, merge descriptions

# Service chunking: Models lớn (>50 cột) được chia thành chunks
```

---

### 8.20 `generation/utils/sql.py` — Tiện ích SQL

📄 **File**: [src/pipelines/generation/utils/sql.py](WrenAI/wren-ai-service/src/pipelines/generation/utils/sql.py)

**Mục đích**: Component chia sẻ cho mọi SQL generation pipeline — validation, rules, post-processing

| Class/Hàm | Chức năng |
|---|---|
| `SQLGenPostProcessor` (`@component`) | **CỐT LÕI**: Validate SQL qua engine.execute_sql(dry_run) hoặc engine.dry_plan() |
| `_DEFAULT_TEXT_TO_SQL_RULES` | Bộ rules mặc định cho Text-to-SQL (>20 rules) |
| `get_text_to_sql_rules(sql_knowledge)` | Merge rules mặc định + rules từ engine |
| `get_sql_generation_system_prompt(sql_knowledge)` | Tạo system prompt cho SQL generation |
| `construct_instructions(instructions, has_...)` | Ghép instructions + calculated field/metric/JSON instructions |
| `construct_ask_history_messages(histories)` | Chuyển histories thành messages cho follow-up |
| `SQL_GENERATION_MODEL_KWARGS` | JSON schema response format cho SQL output |

```python
@component
class SQLGenPostProcessor:
    async def _classify_generation_result(self, generation_result, ...):
        """
        CƠ CHẾ VALIDATION 2 LỚP:
        1. Ưu tiên: engine.dry_plan(sql) → nếu thành công → SQL hợp lệ
        2. Fallback: engine.execute_sql(sql, dry_run=True) → preview SQL
        Nếu cả 2 fail → trả invalid_generation_result kèm error message
        """
```

**Bộ rules `_DEFAULT_TEXT_TO_SQL_RULES`** gồm:
- Dùng table alias thay vì tên đầy đủ
- Ưu tiên ANSI SQL chuẩn
- Không dùng reserved words làm alias
- Sử dụng GROUP BY khi có aggregate function
- Xử lý NULL values đúng cách
- Không sửa đổi user filter values
- ... và 15+ rules khác

---

### 8.21 `generation/utils/chart.py` — Tiện ích biểu đồ

📄 **File**: [src/pipelines/generation/utils/chart.py](WrenAI/wren-ai-service/src/pipelines/generation/utils/chart.py)

**Mục đích**: Data preprocessing, Vega-Lite validation, Pydantic schema cho 7 loại biểu đồ

| Class/Hàm | Decorator | Chức năng |
|---|---|---|
| `ChartDataPreprocessor` | `@component` | Dùng pandas sample 15 rows + 5 unique column values |
| `ChartGenerationPostProcessor` | `@component` | Parse JSON, validate vs Vega-Lite v5 schema |
| `ChartGenerationResults(BaseModel)` | — | Pydantic: reasoning + chart_type + chart_schema |
| `chart_generation_instructions` | — | ~200 dòng hướng dẫn + 7 chart examples |

**7 Pydantic chart schemas**:

```python
# Mỗi loại biểu đồ có schema Pydantic riêng:
LineChartSchema          # Biểu đồ đường
MultiLineChartSchema     # Nhiều đường (dùng fold transform)
BarChartSchema           # Biểu đồ cột
GroupedBarChartSchema    # Cột nhóm (xOffset encoding)
StackedBarChartSchema    # Cột chồng (stack: "zero")
PieChartSchema           # Biểu đồ tròn (mark: "arc", theta encoding)
AreaChartSchema          # Biểu đồ diện tích
```

**Validation**: `jsonschema.validate(chart_schema, vega_lite_v5_schema)` — đảm bảo output đúng spec Vega-Lite

---

## IX. WEB LAYER — API Endpoints & Services

> **Vai trò**: Giao tiếp với client (Wren UI) qua REST API — nhận request, chạy background task, trả kết quả qua polling hoặc SSE

### 9.1 Tổng quan Router & Service

📄 **Đăng ký routers**: [src/web/v1/routers/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/routers/__init__.py)
📄 **Re-export services**: [src/web/v1/services/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/services/__init__.py)

**Pattern chung cho mọi Router + Service**:

```
Client                     Router                       Service                    Pipelines
  │                         │                             │                          │
  │ POST /v1/asks          │                             │                          │
  │────────────────────────▶│ Tạo query_id               │                          │
  │                         │ BackgroundTasks.add_task()──▶│ ask()                   │
  │◀── {query_id} ─────────│                             │──────────────────────────▶│
  │                         │                             │     indexing/retrieval/   │
  │ GET /v1/asks/{id}/result│                             │     generation           │
  │────────────────────────▶│ Đọc cache ─────────────────▶│ get_result()             │
  │◀── {status, response} ─│                             │     TTLCache             │
```

**Tổng cộng 41 API endpoints**:

| Nhóm | POST | GET | PATCH | DELETE | Streaming |
|---|---|---|---|---|---|
| Ask | 1 | 2 | 1 | 0 | 1 (SSE) |
| Ask Feedback | 1 | 1 | 1 | 0 | 0 |
| SQL Pairs | 1 | 1 | 0 | 1 | 0 |
| Instructions | 1 | 1 | 0 | 1 | 0 |
| SQL Answers | 1 | 1 | 0 | 0 | 1 (SSE) |
| SQL Corrections | 1 | 1 | 0 | 0 | 0 |
| SQL Questions | 1 | 1 | 0 | 0 | 0 |
| Charts | 1 | 1 | 1 | 0 | 0 |
| Chart Adjustments | 1 | 1 | 1 | 0 | 0 |
| Question Rec. | 1 | 1 | 0 | 0 | 0 |
| Relationship Rec. | 1 | 1 | 0 | 0 | 0 |
| Semantics Desc. | 1 | 1 | 0 | 0 | 0 |
| Semantics Prep. | 1 | 1 | 0 | 1 | 0 |

---

### 9.2 Ask — Hỏi đáp chính

📄 **Router**: [src/web/v1/routers/ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py)
📄 **Service**: [src/web/v1/services/ask.py](WrenAI/wren-ai-service/src/web/v1/services/ask.py)

**Endpoints**:
- `POST /v1/asks` → Tạo query, chạy background
- `GET /v1/asks/{id}/result` → Poll kết quả
- `GET /v1/asks/{id}/streaming-result` → SSE stream suy luận
- `PATCH /v1/asks/{id}` → Dừng xử lý

**AskService.ask() — Luồng xử lý chính (CỐT LÕI CỦA HỆ THỐNG)**:

```python
async def ask(self, ask_request):
    # PHASE 1: UNDERSTANDING
    status = "understanding"
    # → historical_question_retrieval (tìm câu đã hỏi, nếu score≥0.9 trả ngay)
    # → sql_pairs_retrieval + instructions_retrieval (chạy song song)
    # → intent_classification (phân loại: TEXT_TO_SQL/GENERAL/MISLEADING/USER_GUIDE)
    
    # Nếu intent != TEXT_TO_SQL → chuyển sang pipeline streaming tương ứng → return
    
    # PHASE 2: SEARCHING
    status = "searching"
    # → db_schema_retrieval (tìm top-10 bảng, lấy DDL context)
    # → sql_functions + sql_knowledge (lấy SQL functions & rules)
    
    # PHASE 3: PLANNING (streaming)
    status = "planning"
    # → sql_generation_reasoning (Chain of Thought, streaming SSE)
    
    # PHASE 4: GENERATING
    status = "generating"
    # → sql_generation (sinh SQL + validate dry_run)
    
    # PHASE 5: CORRECTING (nếu SQL lỗi)
    status = "correcting"
    # → sql_correction (tối đa 3 lần)
    # → sql_diagnosis (chẩn đoán lỗi nếu cho phép)
    
    # PHASE 6: FINISHED
    status = "finished"
    # → Trả AskResult(sql=..., type="llm"|"view")
```

**Pydantic models quan trọng**:
- `AskRequest(BaseRequest)`: query, histories, sql_samples, instructions
- `AskResult`: sql, type, viewId
- `AskResultResponse`: status, response, sql_generation_reasoning, rephrased_question

---

### 9.3 Ask Feedback — Phản hồi tinh chỉnh

📄 **Router**: [src/web/v1/routers/ask_feedbacks.py](WrenAI/wren-ai-service/src/web/v1/routers/ask_feedbacks.py)
📄 **Service**: [src/web/v1/services/ask_feedback.py](WrenAI/wren-ai-service/src/web/v1/services/ask_feedback.py)

**Endpoints**: `POST /v1/ask-feedbacks`, `GET /v1/ask-feedbacks/{id}`, `PATCH /v1/ask-feedbacks/{id}`

**Luồng**: User chỉnh sửa bước suy luận → hệ thống tái sinh SQL dựa trên reasoning mới

```python
# AskFeedbackService.ask_feedback() workflow:
# 1. searching → db_schema_retrieval + sql_pairs + instructions (song song)
# 2. sql_functions + sql_knowledge
# 3. generating → sql_regeneration(reasoning ĐÃ CHỈNH, SQL gốc)
# 4. correcting → sql_correction (nếu lỗi) + sql_diagnosis (nếu cho phép)
# 5. finished → trả SQL mới
```

---

### 9.4 Semantics Preparation — Nhập MDL

📄 **Router**: [src/web/v1/routers/semantics_preparation.py](WrenAI/wren-ai-service/src/web/v1/routers/semantics_preparation.py)
📄 **Service**: [src/web/v1/services/semantics_preparation.py](WrenAI/wren-ai-service/src/web/v1/services/semantics_preparation.py)

**Endpoints**:
- `POST /v1/semantics-preparations` → Trigger full indexing
- `GET /v1/semantics-preparations/{mdl_hash}/status` → Check status
- `DELETE /v1/semantics` → Xóa tất cả data

**Đây là entry point cho INDEXING** — khi user deploy MDL:

```python
# SemanticsPreparationService.prepare_semantics() workflow:
# Chạy SONG SONG 5 indexing pipeline:
await asyncio.gather(
    self._pipelines["db_schema"].run(mdl_str, project_id),           # DDL chunks
    self._pipelines["historical_question"].run(mdl_str, project_id), # View questions
    self._pipelines["table_description"].run(mdl_str, project_id),   # Table descriptions
    self._pipelines["sql_pairs"].run(mdl_str, project_id),           # Existing SQL pairs
    self._pipelines["project_meta"].run(mdl_str, project_id),        # Metadata
)
```

**Delete**: Xóa tất cả 6 collections (db_schema, historical_question, table_description, project_meta, sql_pairs, instructions)

---

### 9.5 SQL Pairs — Quản lý tri thức SQL

📄 **Router**: [src/web/v1/routers/sql_pairs.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_pairs.py)
📄 **Service**: [src/web/v1/services/sql_pairs.py](WrenAI/wren-ai-service/src/web/v1/services/sql_pairs.py)

**Endpoints**: `POST /v1/sql-pairs`, `DELETE /v1/sql-pairs`, `GET /v1/sql-pairs/{id}`

```python
# SqlPairsService.index(): Tạo MDL boilerplate → gọi sql_pairs indexing pipeline
# SqlPairsService.delete(): Xóa SQL pairs theo ID list
```

---

### 9.6 Instructions — Quản lý hướng dẫn

📄 **Router**: [src/web/v1/routers/instructions.py](WrenAI/wren-ai-service/src/web/v1/routers/instructions.py)
📄 **Service**: [src/web/v1/services/instructions.py](WrenAI/wren-ai-service/src/web/v1/services/instructions.py)

**Endpoints**: `POST /v1/instructions`, `DELETE /v1/instructions`, `GET /v1/instructions/{id}`

```python
# InstructionsService.index():
# 1. Expand instructions: mỗi instruction có thể có nhiều questions
#    → Mỗi question tạo 1 Instruction object riêng
# 2. Default instructions + Custom instructions → gọi instructions indexing pipeline
```

---

### 9.7 SQL Answers — Trả lời bằng text

📄 **Router**: [src/web/v1/routers/sql_answers.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_answers.py)
📄 **Service**: [src/web/v1/services/sql_answer.py](WrenAI/wren-ai-service/src/web/v1/services/sql_answer.py)

**Endpoints**: `POST /v1/sql-answers`, `GET /v1/sql-answers/{id}`, `GET /v1/sql-answers/{id}/streaming`

```python
# SqlAnswerService.sql_answer():
# 1. preprocess_sql_data → Cắt data để vừa context window
# 2. sql_answer pipeline → Streaming text answer
# 3. Client nhận SSE events qua GET /streaming
```

---

### 9.8 SQL Corrections — Sửa SQL

📄 **Router**: [src/web/v1/routers/sql_corrections.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_corrections.py)
📄 **Service**: [src/web/v1/services/sql_corrections.py](WrenAI/wren-ai-service/src/web/v1/services/sql_corrections.py)

**Endpoints**: `POST /v1/sql-corrections`, `GET /v1/sql-corrections/{id}`

```python
# SqlCorrectionService.correct():
# 1. Trích xuất tên bảng từ SQL (nếu chưa có)
# 2. Lấy sql_knowledge
# 3. db_schema_retrieval (tìm DDL cho các bảng)
# 4. sql_correction pipeline → SQL đã sửa
```

---

### 9.9 SQL Questions — SQL → Câu hỏi

📄 **Router**: [src/web/v1/routers/sql_question.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_question.py)
📄 **Service**: [src/web/v1/services/sql_question.py](WrenAI/wren-ai-service/src/web/v1/services/sql_question.py)

**Endpoints**: `POST /v1/sql-questions`, `GET /v1/sql-questions/{id}`

```python
# SqlQuestionService.sql_question():
# Chạy song song sql_question pipeline cho mỗi SQL trong list
# → asyncio.gather(*[pipeline.run(sql) for sql in request.sqls])
```

---

### 9.10 Charts — Biểu đồ

📄 **Router**: [src/web/v1/routers/chart.py](WrenAI/wren-ai-service/src/web/v1/routers/chart.py)
📄 **Service**: [src/web/v1/services/chart.py](WrenAI/wren-ai-service/src/web/v1/services/chart.py)

**Endpoints**: `POST /v1/charts`, `GET /v1/charts/{id}`, `PATCH /v1/charts/{id}`

```python
# ChartService.chart():
# 1. Nếu không có data → sql_executor(sql) → lấy data
# 2. chart_generation pipeline → Vega-Lite schema
# 3. remove_data_from_chart_schema → Loại data khỏi schema (optional)
```

---

### 9.11 Chart Adjustments — Tinh chỉnh biểu đồ

📄 **Router**: [src/web/v1/routers/chart_adjustment.py](WrenAI/wren-ai-service/src/web/v1/routers/chart_adjustment.py)
📄 **Service**: [src/web/v1/services/chart_adjustment.py](WrenAI/wren-ai-service/src/web/v1/services/chart_adjustment.py)

**Endpoints**: `POST /v1/chart-adjustments`, `GET /v1/chart-adjustments/{id}`, `PATCH /v1/chart-adjustments/{id}`

```python
# ChartAdjustmentOption: chart_type, x_axis, y_axis, x_offset, color, theta
# ChartAdjustmentService.chart_adjustment():
# 1. sql_executor(sql) → lấy data
# 2. chart_adjustment pipeline(query, sql, adjustment_option, chart_schema, data)
```

---

### 9.12 Question Recommendations — Gợi ý câu hỏi

📄 **Router**: [src/web/v1/routers/question_recommendation.py](WrenAI/wren-ai-service/src/web/v1/routers/question_recommendation.py)
📄 **Service**: [src/web/v1/services/question_recommendation.py](WrenAI/wren-ai-service/src/web/v1/services/question_recommendation.py)

**Endpoints**: `POST /v1/question-recommendations`, `GET /v1/question-recommendations/{id}`

```python
# QuestionRecommendation.recommend():
# 1. Parse MDL
# 2. db_schema_retrieval → Lấy DDL context
# 3. question_recommendation pipeline → Sinh câu hỏi gợi ý theo 4 categories
# 4. _validate_question() → Cho mỗi câu hỏi, chạy FULL SQL generation pipeline
#    (db_schema + sql_pairs + instructions + sql_functions + sql_knowledge + sql_generation)
# 5. Chỉ giữ câu hỏi tạo ra SQL HỢP LỆ
# 6. regenerate: Nếu category nào thiếu câu hỏi → gọi lại
```

---

### 9.13 Relationship Recommendations — Gợi ý quan hệ

📄 **Router**: [src/web/v1/routers/relationship_recommendation.py](WrenAI/wren-ai-service/src/web/v1/routers/relationship_recommendation.py)
📄 **Service**: [src/web/v1/services/relationship_recommendation.py](WrenAI/wren-ai-service/src/web/v1/services/relationship_recommendation.py)

**Endpoints**: `POST /v1/relationship-recommendations`, `GET /v1/relationship-recommendations/{id}`

---

### 9.14 Semantics Descriptions — Mô tả ngữ nghĩa

📄 **Router**: [src/web/v1/routers/semantics_description.py](WrenAI/wren-ai-service/src/web/v1/routers/semantics_description.py)
📄 **Service**: [src/web/v1/services/semantics_description.py](WrenAI/wren-ai-service/src/web/v1/services/semantics_description.py)

**Endpoints**: `POST /v1/semantics-descriptions`, `GET /v1/semantics-descriptions/{id}`

```python
# SemanticsDescription.generate():
# 1. _chunking() → Chia models lớn (>50 cột) thành chunks
# 2. asyncio.gather(*[_generate_task(chunk) for chunk in chunks]) → Song song
# 3. Merge kết quả → Trả description cho từng model/column
```

---

### 9.15 Development API — Debug

📄 **File**: [src/web/development.py](WrenAI/wren-ai-service/src/web/development.py)

**Mục đích**: API chỉ dùng khi dev — liệt kê và chạy pipeline trực tiếp bằng tên

**Endpoints**:
- `GET /dev/pipelines` → Liệt kê tất cả pipeline + parameters
- `POST /dev/pipelines/{name}` → Chạy pipeline bất kỳ với JSON body

```python
# _extract_run_method_params(): Dùng inspect.signature + get_type_hints
# → Liệt kê tất cả parameter của pipeline.run() kèm type hint
```

---

### 9.16 `services/__init__.py` — Base Classes

📄 **File**: [src/web/v1/services/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/services/__init__.py)

**Mục đích**: Base classes cho mọi Service — Request/Response models, Configuration, SSE, Tracing

| Class | Chức năng |
|---|---|
| `BaseRequest(BaseModel)` | Request base: query_id, project_id, thread_id, configurations, request_from |
| `Configuration(BaseModel)` | Ngôn ngữ + Timezone → `show_current_time()` trả `"2024-10-23 Wednesday 12:00:00"` |
| `SSEEvent(BaseModel)` | Server-Sent Event: `serialize()` → `"data: {JSON}\n\n"` |
| `MetadataTraceable` | Mixin: `with_metadata()` trả dict kèm error metadata cho Langfuse |

**Re-export**: File này cũng import + re-export tất cả 13 Service classes

---

## X. Tổng hợp luồng End-to-End

### Luồng 1: Deploy MDL (Chuẩn bị tri thức)

```
Wren UI → POST /v1/semantics-preparations {mdl, mdl_hash}
    │
    ▼
SemanticsPreparationService.prepare_semantics()
    │
    ├──▶ DBSchema.run(mdl)           → DDL chunks → Embed → Qdrant "Document"
    ├──▶ TableDescription.run(mdl)   → Mô tả bảng → Embed → Qdrant "table_descriptions"
    ├──▶ HistoricalQuestion.run(mdl) → Câu hỏi cũ → Embed → Qdrant "view_questions"
    ├──▶ SqlPairs.run(mdl)           → SQL pairs → Embed → Qdrant "sql_pairs"
    └──▶ ProjectMeta.run(mdl)        → Metadata → Qdrant "project_meta"
    
    (5 pipeline chạy SONG SONG)
```

### Luồng 2: Đặt câu hỏi (Text-to-SQL)

```
User → POST /v1/asks {query: "Tỷ lệ nghỉ việc?"}
    │
    ▼ [status: understanding]
    ├──▶ HistoricalQuestionRetrieval → Kiểm tra câu hỏi cũ (score≥0.9?)
    ├──▶ SqlPairsRetrieval → Tìm SQL mẫu (score≥0.7)
    ├──▶ InstructionsRetrieval → Tìm hướng dẫn (score≥0.7) + defaults
    └──▶ IntentClassification → "TEXT_TO_SQL" + rephrased_question
    │
    ▼ [status: searching]
    ├──▶ DbSchemaRetrieval → Top-10 bảng → Full DDL context
    ├──▶ SqlFunctions → Hàm SQL hỗ trợ (cache 24h)
    └──▶ SqlKnowledges → Rules Text-to-SQL (cache 24h)
    │
    ▼ [status: planning]
    └──▶ SQLGenerationReasoning → Chain of Thought (STREAMING via SSE)
    │
    ▼ [status: generating]
    └──▶ SQLGeneration → SQL + dry_run validation
    │
    ▼ [status: correcting] (nếu SQL lỗi, tối đa 3 lần)
    └──▶ SQLCorrection → Sửa SQL + validate lại
    │
    ▼ [status: finished]
    └──▶ AskResult {sql: "SELECT ...", type: "llm"}
```

### Luồng 3: Tinh chỉnh (Feedback Loop)

```
User → POST /v1/ask-feedbacks {question, sql, reasoning_đã_chỉnh}
    │
    ▼ [searching]
    ├──▶ DbSchemaRetrieval + SqlPairsRetrieval + InstructionsRetrieval (song song)
    │
    ▼ [generating]
    └──▶ SQLRegeneration(reasoning_mới, sql_gốc) → SQL mới
    │
    ▼ [correcting] (nếu lỗi)
    └──▶ SQLCorrection + SQLDiagnosis
    │
    ▼ [finished]
    └──▶ SQL đã tinh chỉnh

User → POST /v1/sql-pairs {question, sql}  → Lưu vào knowledge base "sql_pairs"
User → POST /v1/instructions {instructions} → Lưu vào knowledge base "instructions"
```

### Luồng 4: Sinh biểu đồ

```
User → POST /v1/charts {query, sql, data?}
    │
    ▼
    ├──▶ SQLExecutor (nếu chưa có data) → Thực thi SQL → Lấy data
    └──▶ ChartGeneration → ChartDataPreprocessor → LLM → Vega-Lite schema
    │
    ▼
    └──▶ Validate vs Vega-Lite v5 spec → ChartResult {chart_type, chart_schema}
```

---

## XI. Bảng tổng hợp FULL file .py

### SRC ROOT (6 files)

| # | File | Class/Hàm chính | Thư viện chính | Chức năng |
|---|---|---|---|---|
| 1 | [src/\_\_init\_\_.py](WrenAI/wren-ai-service/src/__init__.py) | — | — | Package init (trống) |
| 2 | [src/\_\_main\_\_.py](WrenAI/wren-ai-service/src/__main__.py) | `lifespan()`, FastAPI app | `fastapi` | Khởi chạy ứng dụng |
| 3 | [src/config.py](WrenAI/wren-ai-service/src/config.py) | `Settings(BaseSettings)` | `pydantic_settings` | Cấu hình hệ thống |
| 4 | [src/globals.py](WrenAI/wren-ai-service/src/globals.py) | `create_service_container()` | `src.pipelines.*` | Kết nối pipeline→service |
| 5 | [src/utils.py](WrenAI/wren-ai-service/src/utils.py) | `@trace_metadata`, `@trace_cost` | `langfuse`, `dotenv` | Tiện ích & tracing |
| 6 | [src/force_deploy.py](WrenAI/wren-ai-service/src/force_deploy.py) | `force_deploy()` | `aiohttp`, `backoff` | Deploy bắt buộc |
| 7 | [src/force_update_config.py](WrenAI/wren-ai-service/src/force_update_config.py) | `update_config()` | `yaml` | Cập nhật config |

### CORE (3 files)

| # | File | Class chính | Kế thừa | Chức năng |
|---|---|---|---|---|
| 8 | [src/core/pipeline.py](WrenAI/wren-ai-service/src/core/pipeline.py) | `BasicPipeline`, `PipelineComponent` | `ABCMeta`, `Mapping` | Abstract pipeline base |
| 9 | [src/core/provider.py](WrenAI/wren-ai-service/src/core/provider.py) | `LLMProvider`, `EmbedderProvider`, `DocumentStoreProvider` | `ABCMeta` | Abstract provider interfaces |
| 10 | [src/core/engine.py](WrenAI/wren-ai-service/src/core/engine.py) | `Engine` + `clean_generation_result()` | `ABCMeta` | Abstract engine + SQL cleaner |

### PROVIDERS (6 files)

| # | File | Class chính | Decorator | Chức năng |
|---|---|---|---|---|
| 11 | [src/providers/\_\_init\_\_.py](WrenAI/wren-ai-service/src/providers/__init__.py) | `Configuration`, `generate_components()` | — | Factory tạo providers |
| 12 | [src/providers/loader.py](WrenAI/wren-ai-service/src/providers/loader.py) | `PROVIDERS` dict, `@provider()` | — | Plugin registry |
| 13 | [src/providers/document_store/qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py) | `AsyncQdrantDocumentStore`, `QdrantProvider` | `@provider("qdrant")` | Vector database (6 collections) |
| 14 | [src/providers/embedder/litellm.py](WrenAI/wren-ai-service/src/providers/embedder/litellm.py) | `AsyncTextEmbedder`, `AsyncDocumentEmbedder` | `@provider("litellm_embedder")`, `@component` | Text→Vector conversion |
| 15 | [src/providers/llm/litellm.py](WrenAI/wren-ai-service/src/providers/llm/litellm.py) | `LitellmLLMProvider` | `@provider("litellm_llm")` | LLM API (streaming + fallback) |
| 16 | [src/providers/engine/wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py) | `WrenUI`, `WrenIbis`, `WrenEngine` | `@provider("wren_ui")`, etc. | SQL execution (3 engines) |

### PIPELINES/INDEXING (7 files)

| # | File | Class chính | Collection Qdrant | Cơ chế Chunking |
|---|---|---|---|---|
| 17 | [indexing/\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/indexing/__init__.py) | `MDLValidator`, `DocumentCleaner`, `AsyncDocumentWriter` | — | Shared components |
| 18 | [indexing/db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py) | `DDLChunker`, `DBSchema` | `Document` | Batch cột (50/chunk) |
| 19 | [indexing/table_description.py](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py) | `TableDescriptionChunker`, `TableDescription` | `table_descriptions` | 1 bảng = 1 doc |
| 20 | [indexing/historical_question.py](WrenAI/wren-ai-service/src/pipelines/indexing/historical_question.py) | `ViewChunker`, `HistoricalQuestion` | `view_questions` | 1 view = 1 doc |
| 21 | [indexing/sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py) | `SqlPairsConverter`, `SqlPairs` | `sql_pairs` | 1 pair = 1 doc |
| 22 | [indexing/instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py) | `InstructionsConverter`, `Instructions` | `instructions` | 1 instruction = 1 doc |
| 23 | [indexing/project_meta.py](WrenAI/wren-ai-service/src/pipelines/indexing/project_meta.py) | `ProjectMeta` | `project_meta` | 1 project = 1 doc |
| 24 | [indexing/utils/helper.py](WrenAI/wren-ai-service/src/pipelines/indexing/utils/helper.py) | `Helper`, `COLUMN_PREPROCESSORS` | — | DDL preprocessing |

### PIPELINES/RETRIEVAL (8 files)

| # | File | Class chính | Nguồn tìm | Ngưỡng |
|---|---|---|---|---|
| 25 | [retrieval/db_schema_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py) | `DbSchemaRetrieval` | `table_descriptions`→`Document` | top_k=10 |
| 26 | [retrieval/sql_pairs_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_pairs_retrieval.py) | `SqlPairsRetrieval` | `sql_pairs` | score≥0.7 |
| 27 | [retrieval/historical_question_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/historical_question_retrieval.py) | `HistoricalQuestionRetrieval` | `view_questions` | score≥0.9 |
| 28 | [retrieval/instructions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/instructions.py) | `Instructions` | `instructions` | score≥0.7 + defaults |
| 29 | [retrieval/sql_executor.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_executor.py) | `DataFetcher`, `SQLExecutor` | Wren Engine | limit=500 rows |
| 30 | [retrieval/sql_functions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_functions.py) | `SqlFunction`, `SqlFunctions` | WrenIbis API | TTL cache 24h |
| 31 | [retrieval/sql_knowledge.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_knowledge.py) | `SqlKnowledge`, `SqlKnowledges` | WrenIbis API | TTL cache 24h |
| 32 | [retrieval/preprocess_sql_data.py](WrenAI/wren-ai-service/src/pipelines/retrieval/preprocess_sql_data.py) | `PreprocessSqlData` | — | tiktoken token counting |

### PIPELINES/GENERATION (19 files + 2 utils)

| # | File | Class chính | Streaming | Output |
|---|---|---|---|---|
| 33 | [generation/intent_classification.py](WrenAI/wren-ai-service/src/pipelines/generation/intent_classification.py) | `IntentClassification` | ❌ | intent + rephrased_question |
| 34 | [generation/sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py) | `SQLGenerationReasoning` | ✅ SSE | Kế hoạch suy luận text |
| 35 | [generation/sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py) | `SQLGeneration` | ❌ | valid_sql / invalid_sql |
| 36 | [generation/sql_correction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_correction.py) | `SQLCorrection` | ❌ | corrected_sql |
| 37 | [generation/sql_regeneration.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_regeneration.py) | `SQLRegeneration` | ❌ | regenerated_sql |
| 38 | [generation/followup_sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/followup_sql_generation.py) | `FollowUpSQLGeneration` | ❌ | SQL (follow-up context) |
| 39 | [generation/followup_sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/followup_sql_generation_reasoning.py) | `FollowUpSQLGenerationReasoning` | ✅ SSE | Reasoning (follow-up) |
| 40 | [generation/sql_answer.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_answer.py) | `SQLAnswer` | ✅ SSE | Markdown text answer |
| 41 | [generation/sql_question.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_question.py) | `SQLQuestion` | ❌ | {question: "..."} |
| 42 | [generation/sql_diagnosis.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_diagnosis.py) | `SQLDiagnosis` | ❌ | {reasoning: "..."} |
| 43 | [generation/sql_tables_extraction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_tables_extraction.py) | `SQLTablesExtraction` | ❌ | {tables: [...]} |
| 44 | [generation/question_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/question_recommendation.py) | `QuestionRecommendation` | ❌ | {questions by category} |
| 45 | [generation/chart_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_generation.py) | `ChartGeneration` | ❌ | Vega-Lite chart_schema |
| 46 | [generation/chart_adjustment.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_adjustment.py) | `ChartAdjustment` | ❌ | Adjusted chart_schema |
| 47 | [generation/data_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/data_assistance.py) | `DataAssistance` | ✅ SSE | Markdown (no SQL) |
| 48 | [generation/misleading_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/misleading_assistance.py) | `MisleadingAssistance` | ✅ SSE | Markdown + gợi ý |
| 49 | [generation/user_guide_assistance.py](WrenAI/wren-ai-service/src/pipelines/generation/user_guide_assistance.py) | `UserGuideAssistance` | ✅ SSE | Markdown + citations |
| 50 | [generation/relationship_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/relationship_recommendation.py) | `RelationshipRecommendation` | ❌ | {relationships: [...]} |
| 51 | [generation/semantics_description.py](WrenAI/wren-ai-service/src/pipelines/generation/semantics_description.py) | `SemanticsDescription` | ❌ | {model→descriptions} |
| 52 | [generation/utils/sql.py](WrenAI/wren-ai-service/src/pipelines/generation/utils/sql.py) | `SQLGenPostProcessor` | — | SQL validation + rules |
| 53 | [generation/utils/chart.py](WrenAI/wren-ai-service/src/pipelines/generation/utils/chart.py) | `ChartDataPreprocessor`, `ChartGenerationPostProcessor` | — | Chart preprocessing + validation |

### WEB LAYER (27 files)

| # | File | Endpoints / Class | Chức năng |
|---|---|---|---|
| 54 | [web/development.py](WrenAI/wren-ai-service/src/web/development.py) | `GET /dev/pipelines`, `POST /dev/pipelines/{name}` | Debug API |
| 55 | [web/v1/routers/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/routers/__init__.py) | `router = APIRouter()` | Đăng ký 13 routers |
| 56 | [web/v1/routers/ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py) | `POST /asks`, `GET /asks/{id}/result`, streaming | Ask endpoints |
| 57 | [web/v1/routers/ask_feedbacks.py](WrenAI/wren-ai-service/src/web/v1/routers/ask_feedbacks.py) | `POST /ask-feedbacks`, `GET`, `PATCH` | Feedback endpoints |
| 58 | [web/v1/routers/chart.py](WrenAI/wren-ai-service/src/web/v1/routers/chart.py) | `POST /charts`, `GET`, `PATCH` | Chart endpoints |
| 59 | [web/v1/routers/chart_adjustment.py](WrenAI/wren-ai-service/src/web/v1/routers/chart_adjustment.py) | `POST /chart-adjustments`, `GET`, `PATCH` | Chart adjust endpoints |
| 60 | [web/v1/routers/instructions.py](WrenAI/wren-ai-service/src/web/v1/routers/instructions.py) | `POST`, `DELETE`, `GET /instructions` | Instructions mgmt |
| 61 | [web/v1/routers/question_recommendation.py](WrenAI/wren-ai-service/src/web/v1/routers/question_recommendation.py) | `POST`, `GET /question-recommendations` | Q&A recommendations |
| 62 | [web/v1/routers/relationship_recommendation.py](WrenAI/wren-ai-service/src/web/v1/routers/relationship_recommendation.py) | `POST`, `GET /relationship-recommendations` | Relationship recs |
| 63 | [web/v1/routers/semantics_description.py](WrenAI/wren-ai-service/src/web/v1/routers/semantics_description.py) | `POST`, `GET /semantics-descriptions` | Semantics desc |
| 64 | [web/v1/routers/semantics_preparation.py](WrenAI/wren-ai-service/src/web/v1/routers/semantics_preparation.py) | `POST`, `GET`, `DELETE /semantics` | MDL indexing |
| 65 | [web/v1/routers/sql_answers.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_answers.py) | `POST`, `GET`, streaming `/sql-answers` | SQL→text |
| 66 | [web/v1/routers/sql_corrections.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_corrections.py) | `POST`, `GET /sql-corrections` | SQL fix |
| 67 | [web/v1/routers/sql_pairs.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_pairs.py) | `POST`, `DELETE`, `GET /sql-pairs` | SQL pairs mgmt |
| 68 | [web/v1/routers/sql_question.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_question.py) | `POST`, `GET /sql-questions` | SQL→question |
| 69 | [web/v1/services/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/services/__init__.py) | `BaseRequest`, `Configuration`, `SSEEvent` | Base classes |
| 70 | [web/v1/services/ask.py](WrenAI/wren-ai-service/src/web/v1/services/ask.py) | `AskService` | **CỐT LÕI**: Orchestrate ask flow |
| 71 | [web/v1/services/ask_feedback.py](WrenAI/wren-ai-service/src/web/v1/services/ask_feedback.py) | `AskFeedbackService` | Feedback + regeneration |
| 72 | [web/v1/services/chart.py](WrenAI/wren-ai-service/src/web/v1/services/chart.py) | `ChartService` | Sinh biểu đồ |
| 73 | [web/v1/services/chart_adjustment.py](WrenAI/wren-ai-service/src/web/v1/services/chart_adjustment.py) | `ChartAdjustmentService` | Chỉnh biểu đồ |
| 74 | [web/v1/services/instructions.py](WrenAI/wren-ai-service/src/web/v1/services/instructions.py) | `InstructionsService` | Quản lý instructions |
| 75 | [web/v1/services/question_recommendation.py](WrenAI/wren-ai-service/src/web/v1/services/question_recommendation.py) | `QuestionRecommendation` | Gợi ý + validate câu hỏi |
| 76 | [web/v1/services/relationship_recommendation.py](WrenAI/wren-ai-service/src/web/v1/services/relationship_recommendation.py) | `RelationshipRecommendation` | Gợi ý quan hệ |
| 77 | [web/v1/services/semantics_description.py](WrenAI/wren-ai-service/src/web/v1/services/semantics_description.py) | `SemanticsDescription` | Auto-generate descriptions |
| 78 | [web/v1/services/semantics_preparation.py](WrenAI/wren-ai-service/src/web/v1/services/semantics_preparation.py) | `SemanticsPreparationService` | **INDEXING ENTRY**: 5 parallel pipelines |
| 79 | [web/v1/services/sql_answer.py](WrenAI/wren-ai-service/src/web/v1/services/sql_answer.py) | `SqlAnswerService` | SQL→text streaming |
| 80 | [web/v1/services/sql_corrections.py](WrenAI/wren-ai-service/src/web/v1/services/sql_corrections.py) | `SqlCorrectionService` | Sửa SQL + schema retrieval |
| 81 | [web/v1/services/sql_pairs.py](WrenAI/wren-ai-service/src/web/v1/services/sql_pairs.py) | `SqlPairsService` | Quản lý SQL pairs |
| 82 | [web/v1/services/sql_question.py](WrenAI/wren-ai-service/src/web/v1/services/sql_question.py) | `SqlQuestionService` | SQL→question (parallel) |

### PIPELINES/COMMON (1 file)

| # | File | Chức năng |
|---|---|---|
| 83 | [src/pipelines/common.py](WrenAI/wren-ai-service/src/pipelines/common.py) | `build_table_ddl()`, `ScoreFilter`, `clean_up_new_lines()`, `retrieve_metadata()` |

### PACKAGE INIT FILES (~7 files)

| # | File | Nội dung |
|---|---|---|
| 84 | [src/pipelines/\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/__init__.py) | Trống |
| 85 | [src/pipelines/generation/\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/generation/__init__.py) | Re-export 19 generation classes |
| 86 | [src/pipelines/retrieval/\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/retrieval/__init__.py) | Re-export 8 retrieval classes |
| 87-90 | `providers/*/\_\_init\_\_.py`, `web/\_\_init\_\_.py`, `web/v1/\_\_init\_\_.py` | Package init (trống) |

---

> **Tổng cộng**: ~90 file Python phân tích đầy đủ — mỗi file được note mục đích, class, function, decorator, thư viện, cơ chế vận hành, và liên kết tới file khác trong hệ thống. Tất cả link dẫn tới file code thực tế trong repo.
