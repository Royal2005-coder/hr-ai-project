# 📋 MASTER TECHNICAL ANALYSIS — Wren AI RAG System
## Phân tích kỹ thuật toàn diện: Từ Slide trình bày đến Codebase thực tế

> **Mục đích**: Tài liệu này đối chiếu (mapping) chi tiết **100%** nội dung đã trình bày trên 3 slide với mã nguồn thực tế trong dự án Wren AI. Mọi khái niệm, luồng xử lý, và cơ chế đều được gắn **link trực tiếp** tới file code, dòng code cụ thể, class, thư viện import tương ứng.
>
> **Quy ước đọc**: Click vào bất kỳ link nào (`→ Xem code`) sẽ mở đúng file và dòng code thực hiện chức năng đó. Các file code đã được note tiếng Việt có dấu tại dòng code quan trọng.

---

## 📑 MỤC LỤC

- [I. Kiến trúc tổng quan 3 tầng](#i-kiến-trúc-tổng-quan-3-tầng-slide-1)
- [II. Quy trình RAG Pipeline 5 bước](#ii-quy-trình-rag-pipeline-5-bước-slide-2)
- [III. Luồng vận hành thực tế & Tính năng tinh chỉnh](#iii-luồng-vận-hành-thực-tế--tính-năng-tinh-chỉnh-slide-3)
- [IV. Phân tích chi tiết từng tầng code](#iv-phân-tích-chi-tiết-từng-tầng-code)
  - [4.1 Tầng Core (Xương sống)](#41-tầng-core-xương-sống-hệ-thống)
  - [4.2 Tầng Web (Giao tiếp API)](#42-tầng-web-giao-tiếp-api)
  - [4.3 Tầng Indexing (Chuẩn bị tri thức)](#43-tầng-indexing-chuẩn-bị-tri-thức)
  - [4.4 Tầng Retrieval (Truy xuất ngữ cảnh)](#44-tầng-retrieval-truy-xuất-ngữ-cảnh)
  - [4.5 Tầng Generation (Sinh mã SQL)](#45-tầng-generation-sinh-mã-sql)
  - [4.6 Tầng Providers (Tích hợp dịch vụ)](#46-tầng-providers-tích-hợp-dịch-vụ-bên-ngoài)
  - [4.7 Utils & Common](#47-utils--common)
- [V. Cơ chế Chunking chi tiết](#v-cơ-chế-chunking-chi-tiết-ddl-vs-sql-pairs-vs-instructions)
- [VI. Luồng End-to-End hoàn chỉnh](#vi-luồng-end-to-end-hoàn-chỉnh)
- [VII. Bảng tổng hợp File ↔ Chức năng](#vii-bảng-tổng-hợp-file--chức-năng)

---

## I. Kiến trúc tổng quan 3 tầng (Slide 1)

### Sơ đồ 3 thành phần chính

```
┌────────────────────┐    ┌─────────────────────────────────────┐    ┌──────────────────────┐
│     WREN UI        │    │        WREN AI SERVICE              │    │    WREN ENGINE       │
│  (Giao diện)       │───▶│                                     │───▶│                      │
│                    │    │  ┌─────────┐  ┌──────────────────┐  │    │  ┌────────────────┐  │
│  • Home (Question) │    │  │Retrieval│  │  Vector Database  │  │    │  │   Metastore    │  │
│  • Modeling        │    │  │         │──│    (Qdrant)       │  │    │  │                │  │
│  • Connect         │    │  └────┬────┘  └──────────────────┘  │    │  ├────────────────┤  │
│                    │    │       │                              │    │  │     Core       │  │
│                    │    │  ┌────▼────┐  ┌──────────────────┐  │    │  │                │  │
│                    │    │  │  Prompt │──│  LLM (OpenAI)    │  │    │  ├────────────────┤  │
│                    │◀───│  │         │  │                  │  │◀───│  │  Connectors    │  │
│                    │    │  └────┬────┘  └──────────────────┘  │    │  │                │  │
│                    │    │  ┌────▼────────────────────────┐    │    │  └────────────────┘  │
│                    │    │  │  Output Processing          │    │    │                      │
│                    │    │  │  (Validate SQL Execution)   │    │    │     Data Sources     │
│                    │    │  └─────────────────────────────┘    │    └──────────────────────┘
└────────────────────┘    └─────────────────────────────────────┘
```

### Mapping Code cho 3 thành phần

| Thành phần | Mô tả Slide | File Code | Chi tiết |
|---|---|---|---|
| **Wren UI** | Giao diện Home, Modeling, Connect | [wren-ui/src/](WrenAI/wren-ui/src/) | Next.js frontend, GraphQL API |
| **Wren AI Service** | Retrieval, Vector DB, Prompt, Output Processing | [wren-ai-service/src/](WrenAI/wren-ai-service/src/) | FastAPI backend, RAG Pipeline |
| **Wren Engine** | Metastore, Core, Data Source Connectors | [wren-engine/](WrenAI/wren-engine/) | SQL execution & validation |

### Điểm khởi chạy hệ thống (Application Entry Point)

Toàn bộ Wren AI Service khởi chạy tại [\_\_main\_\_.py](WrenAI/wren-ai-service/src/__main__.py#L1):

```python
# Import thư viện
from fastapi import FastAPI                    # Framework web API
from src.config import settings                # Cấu hình hệ thống
from src.globals import create_service_container  # Khởi tạo tất cả pipeline
from src.providers import generate_components  # Tạo các provider (LLM, Embedder, DB)
from src.web.v1 import routers                 # Đăng ký API endpoints

# Khi ứng dụng khởi chạy:
pipe_components = generate_components(settings.components)  # Dòng 33: Tạo tất cả provider
app.state.service_container = create_service_container(pipe_components, settings)  # Dòng 34: Kết nối tất cả pipeline
app.include_router(routers.router, prefix="/v1")  # Dòng 57: Đăng ký các route API
```

→ [Xem entry point](WrenAI/wren-ai-service/src/__main__.py#L30-L35)

### Kết nối các pipeline trong `globals.py`

File [globals.py](WrenAI/wren-ai-service/src/globals.py) là nơi **ghép nối tất cả** pipeline lại thành `ServiceContainer`:

```python
# Khởi tạo tất cả pipeline indexing, retrieval, generation
return ServiceContainer(
    ask_service=services.AskService(
        pipelines={
            "intent_classification": generation.IntentClassification(...),  # Phân loại ý định
            "db_schema_retrieval": _db_schema_retrieval_pipeline,           # Truy xuất schema
            "sql_generation": generation.SQLGeneration(...),                # Sinh SQL
            "sql_generation_reasoning": generation.SQLGenerationReasoning(...),  # Chain of Thought
            "sql_correction": _sql_correction_pipeline,                    # Sửa SQL lỗi
            ...
        }
    ),
    semantics_preparation_service=services.SemanticsPreparationService(
        pipelines={
            "db_schema": indexing.DBSchema(...),           # Indexing schema
            "sql_pairs": _sql_pair_indexing_pipeline,      # Indexing SQL pairs
            "instructions": _instructions_indexing_pipeline, # Indexing hướng dẫn
            ...
        }
    ),
)
```

→ [Xem toàn bộ khởi tạo pipeline](WrenAI/wren-ai-service/src/globals.py#L43-L270)

---

## II. Quy trình RAG Pipeline 5 bước (Slide 2)

### Bước 1: Chunking — Chia nhỏ mô hình dữ liệu (MDL)

> **Slide**: Toàn bộ MDL được cắt nhỏ thành Chunk 1, Chunk 2, Chunk 3 (DDL chunks)

**Có 4 loại chunking khác nhau** trong hệ thống, mỗi loại dùng cơ chế khác nhau:

| Loại dữ liệu | Cơ chế Chunking | File Code | Vị trí lưu (Collection) |
|---|---|---|---|
| **DDL Schema** (bảng, cột, quan hệ) | Chia theo batch cột (`column_batch_size=50`) | [db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L32) | `Document` (default) |
| **Table Description** | Chia theo từng bảng (1 bảng = 1 Document) | [table_description.py](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py#L24) | `table_descriptions` |
| **SQL Pairs** | Chia theo từng câu hỏi (1 câu hỏi+SQL = 1 Document) | [sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py#L30) | `sql_pairs` |
| **Instructions** | Chia theo từng instruction (1 chỉ dẫn = 1 Document) | [instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py#L30) | `instructions` |

**DDL Chunking** chi tiết — Class `DDLChunker`:

```python
# File: wren-ai-service/src/pipelines/indexing/db_schema.py
@component
class DDLChunker:
    # Hàm cắt cột thành batch
    def _column_batch(self, model, primary_keys_map):
        commands = [_column_command(column, model) for column in model["columns"]]
        filtered = [cmd for cmd in commands if cmd is not None]
        
        # CƠ CHẾ CHUNKING: Cắt danh sách cột thành từng nhóm 50 cột
        return [
            {
                "name": model["name"],
                "payload": str({
                    "type": "TABLE_COLUMNS",
                    "columns": filtered[i : i + column_batch_size],  # ← DÒNG CHUNKING CHÍNH
                }),
            }
            for i in range(0, len(filtered), column_batch_size)
        ]
```

→ [Xem class DDLChunker](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L32-L237)
→ [Xem dòng chunking cột](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L193)

### Bước 2: Embedding — Mã hóa thành Vector

> **Slide**: Data object → Embedding Model → Vector Embedding → Vector Database

**Thư viện**: `litellm` (hàm `aembedding()`), `openai`

**Class chính**: `AsyncDocumentEmbedder` — nhúng hàng loạt Document

```python
# File: wren-ai-service/src/providers/embedder/litellm.py
@component
class AsyncDocumentEmbedder:
    async def _embed_batch(self, texts_to_embed, batch_size):
        async def embed_single_batch(batch):
            return await aembedding(           # ← GỌI API EMBEDDING
                model=self._model,             #    Model: text-embedding-3-large
                input=batch,                   #    Input: danh sách text
                api_key=self._api_key,
            )
        
        # Chia text thành batch và embedding song song
        batches = [texts_to_embed[i : i + batch_size] for i in range(0, len(texts_to_embed), batch_size)]
        responses = await asyncio.gather(*[embed_single_batch(b) for b in batches])
        
        # Gắn vector vào từng Document
        for doc, emb in zip(documents, embeddings):
            doc.embedding = emb  # ← GẮN VECTOR VÀO DOCUMENT
```

→ [Xem AsyncDocumentEmbedder](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L87-L155)
→ [Xem hàm aembedding()](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L104)

**Class phụ**: `AsyncTextEmbedder` — nhúng 1 câu hỏi duy nhất (dùng khi retrieval)

→ [Xem AsyncTextEmbedder](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L36-L85)

### Bước 3: Vector Search — Tìm kiếm Cosine Similarity

> **Slide**: Cosine Similarity = A·B / (|A|·|B|), tìm vector tương đồng nhất

**Class**: `AsyncQdrantDocumentStore._query_by_embedding()`

```python
# File: wren-ai-service/src/providers/document_store/qdrant.py
class AsyncQdrantDocumentStore(QdrantDocumentStore):
    async def _query_by_embedding(self, query_embedding, filters, top_k=10):
        # TÌM KIẾM VECTOR trong Qdrant DB
        points = await self.async_client.search(
            collection_name=self.index,
            query_vector=rest.NamedVector(
                name=DENSE_VECTORS_NAME if self.use_sparse_embeddings else "",
                vector=query_embedding,          # ← Vector câu hỏi người dùng
            ),
            query_filter=qdrant_filters,
            limit=top_k,                         # ← Lấy top-k kết quả
        )
        
        # CHUẨN HÓA ĐIỂM COSINE SIMILARITY
        if scale_score:
            for document in results:
                score = document.score
                if self.similarity == "cosine":
                    score = (score + 1) / 2      # ← Chuyển từ [-1,1] sang [0,1]
                document.score = score
```

→ [Xem hàm _query_by_embedding](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L157-L203)
→ [Xem dòng cosine normalization](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L198)

### Bước 4: Prompt Template (Query + Context)

> **Slide**: Prompt chứa QUERY, DOCUMENTS, SQL_GENERATION_REASONING, DATABASE SCHEMA

**Template thực tế** trong [sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py#L30-L79):

```python
sql_generation_user_prompt_template = """
### DATABASE SCHEMA ###
{% for document in documents %}
    {{ document }}                           ← Context từ Vector Search (các DDL bảng)
{% endfor %}

{% if sql_samples %}
### SQL SAMPLES ###                          ← Các cặp câu hỏi-SQL mẫu (từ sql_pairs)
{% for sample in sql_samples %}
Question: {{sample.question}}
SQL: {{sample.sql}}
{% endfor %}
{% endif %}

{% if instructions %}
### USER INSTRUCTIONS ###                    ← Hướng dẫn nghiệp vụ (từ instructions)
{% for instruction in instructions %}
{{ loop.index }}. {{ instruction }}
{% endfor %}
{% endif %}

### QUESTION ###
User's Question: {{ query }}                 ← Câu hỏi người dùng

{% if sql_generation_reasoning %}
### REASONING PLAN ###                       ← Kế hoạch suy luận Chain of Thought
{{ sql_generation_reasoning }}
{% endif %}

Let's think step by step.
"""
```

→ [Xem template đầy đủ](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py#L30-L79)

**Hàm ghép prompt**:

```python
# File: wren-ai-service/src/pipelines/generation/sql_generation.py
@observe(capture_input=False)
def prompt(query, documents, prompt_builder, ...):
    _prompt = prompt_builder.run(
        query=query,                  # Câu hỏi người dùng
        documents=documents,          # DDL schema từ retrieval
        sql_generation_reasoning=..., # Kế hoạch suy luận
        instructions=...,            # Hướng dẫn nghiệp vụ
        sql_samples=...,             # SQL mẫu
    )
    return {"prompt": clean_up_new_lines(_prompt.get("prompt"))}
```

→ [Xem hàm prompt()](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py#L83-L115)

### Bước 5: LLM SQL Generation và Validation

> **Slide**: LLM sinh SQL → Validation tại Wren Engine → Nếu lỗi → Correction

**Sinh SQL** — gọi LLM:

```python
# File: wren-ai-service/src/pipelines/generation/sql_generation.py
@observe(as_type="generation", capture_input=False)
async def generate_sql(prompt, generator, generator_name, ...):
    return await generator(                    # ← GỌI LLM (OpenAI/Gemini)
        prompt=prompt.get("prompt"),           #    Với prompt đã ghép ở bước trên
        current_system_prompt=get_sql_generation_system_prompt(sql_knowledge)
    ), generator_name
```

→ [Xem hàm generate_sql()](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py#L118-L127)

**Validation** — gửi SQL tới Wren Engine kiểm tra:

```python
# File: wren-ai-service/src/pipelines/generation/utils/sql.py
@component
class SQLGenPostProcessor:
    async def _classify_generation_result(self, generation_result, ...):
        async with aiohttp.ClientSession() as session:
            success, _, addition = await self._engine.execute_sql(
                generation_result,       # ← SQL vừa sinh
                session,
                dry_run=True,            # ← CHỈ KIỂM TRA, KHÔNG THỰC THI THẬT
            )
            if success:
                valid_generation_result = {"sql": generation_result}
            else:
                invalid_generation_result = {"sql": ..., "error": ...}
```

→ [Xem SQLGenPostProcessor](WrenAI/wren-ai-service/src/pipelines/generation/utils/sql.py#L20-L70)
→ [Xem validation logic](WrenAI/wren-ai-service/src/pipelines/generation/utils/sql.py#L110-L130)

**Correction** — khi SQL lỗi, gọi LLM sửa:

```python
# File: wren-ai-service/src/pipelines/generation/sql_correction.py
class SQLCorrection(BasicPipeline):
    # Nhận SQL lỗi + error message → Gọi LLM sửa → Validate lại
    async def run(self, contexts, invalid_generation_result, ...):
        return await self._pipe.execute(["post_process"], inputs={
            "invalid_generation_result": invalid_generation_result,
            "documents": contexts,
            ...
        })
```

→ [Xem SQLCorrection pipeline](WrenAI/wren-ai-service/src/pipelines/generation/sql_correction.py#L130-L185)

---

## III. Luồng vận hành thực tế & Tính năng tinh chỉnh (Slide 3)

### Bước 1: Đặt câu hỏi bằng ngôn ngữ tự nhiên

> **Slide**: Người dùng nhập "Công ty có đang chảy máu chất xám không?"

**Endpoint tiếp nhận**: `POST /v1/asks`

```python
# File: wren-ai-service/src/web/v1/routers/ask.py
@router.post("/asks")
async def ask(ask_request: AskRequest, background_tasks: BackgroundTasks, ...):
    query_id = str(uuid.uuid4())       # Tạo ID duy nhất cho câu hỏi
    ask_request.query_id = query_id
    
    # Khởi tạo trạng thái ban đầu: "understanding"
    service_container.ask_service._ask_results[query_id] = AskResultResponse(
        status="understanding",
    )
    
    # Chạy pipeline xử lý NỀN (không block response)
    background_tasks.add_task(
        service_container.ask_service.ask, ask_request, ...
    )
    return AskResponse(query_id=query_id)  # Trả ngay query_id cho client
```

→ [Xem endpoint /asks](WrenAI/wren-ai-service/src/web/v1/routers/ask.py#L24-L43)

### Bước 2: RAG query context trong Vector Database

> **Slide**: Hệ thống chọn top 10 bảng ứng viên

**Trong AskService.ask()** — trạng thái `"searching"`:

```python
# File: wren-ai-service/src/web/v1/services/ask.py
self._ask_results[query_id] = AskResultResponse(status="searching", ...)

# Gọi pipeline retrieval
retrieval_result = await self._pipelines["db_schema_retrieval"].run(
    query=user_query,
    histories=histories,
    project_id=ask_request.project_id,
)
documents = _retrieval_result.get("retrieval_results", [])
table_names = [doc.get("table_name") for doc in documents]  # Top 10 bảng ứng viên
table_ddls = [doc.get("table_ddl") for doc in documents]    # DDL tương ứng
```

→ [Xem bước searching](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L254-L288)

**Pipeline retrieval bên trong** ([db_schema_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py)):

1. **Embedding câu hỏi** → [embedding()](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py#L114-L128)
2. **Tìm bảng tương đồng** (TABLE_DESCRIPTION) → [table_retrieval()](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py#L131-L155)
3. **Lấy schema chi tiết** (TABLE_SCHEMA) → [dbschema_retrieval()](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py#L158-L192)
4. **Tái cấu trúc DDL** → [construct_db_schemas()](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py#L196-L224)

### Bước 3: Chain of Thought (Chuỗi suy luận)

> **Slide**: LLM lập kế hoạch: Filter date → Identify Top Talent → Calculate Rate → Conclude

**Trong AskService.ask()** — trạng thái `"planning"`:

```python
# File: wren-ai-service/src/web/v1/services/ask.py
self._ask_results[query_id] = AskResultResponse(status="planning", ...)

# Gọi pipeline suy luận
sql_generation_reasoning = (
    await self._pipelines["sql_generation_reasoning"].run(
        query=user_query,
        contexts=table_ddls,           # DDL schema làm context
        sql_samples=sql_samples,       # SQL mẫu
        instructions=instructions,     # Hướng dẫn nghiệp vụ
        configuration=ask_request.configurations,
        query_id=query_id,             # Dùng cho streaming
    )
).get("post_process", {})
```

→ [Xem bước planning](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L303-L340)

**Pipeline SQLGenerationReasoning** sử dụng **streaming callback** để gửi từng chunk suy luận real-time tới UI:

```python
# File: wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py
class SQLGenerationReasoning(BasicPipeline):
    def _streaming_callback(self, chunk, query_id):
        asyncio.create_task(self._user_queues[query_id].put(chunk.content))
    
    async def get_streaming_results(self, query_id):
        while True:
            self._streaming_results = await asyncio.wait_for(
                _get_streaming_results(query_id), timeout=120
            )
            if self._streaming_results == "<DONE>":
                break
            yield self._streaming_results  # ← STREAM TỪNG CHUNK SUY LUẬN
```

→ [Xem streaming logic](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py#L114-L145)

### Bước 4: Nhận kết quả

> **Slide**: Tỷ lệ chảy máu chất xám = 0.163... + Tạo view + Gợi ý câu hỏi

**Trong AskService.ask()** — trạng thái `"generating"` → `"finished"`:

```python
# Gọi pipeline sinh SQL
text_to_sql_generation_results = await self._pipelines["sql_generation"].run(
    query=user_query,
    contexts=table_ddls,
    sql_generation_reasoning=sql_generation_reasoning,
    ...
)

# Kiểm tra kết quả
if sql_valid_result := text_to_sql_generation_results["post_process"]["valid_generation_result"]:
    api_results = [AskResult(sql=sql_valid_result.get("sql"), type="llm")]
    
    # CẬP NHẬT TRẠNG THÁI: HOÀN THÀNH
    self._ask_results[query_id] = AskResultResponse(
        status="finished",
        response=api_results,
        sql_generation_reasoning=sql_generation_reasoning,
        ...
    )
```

→ [Xem bước generating](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L352-L425)
→ [Xem trả kết quả](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L500-L530)

**Feature: Gợi ý câu hỏi** — Class `QuestionRecommendation`:

→ [Xem pipeline question recommendation](WrenAI/wren-ai-service/src/pipelines/generation/question_recommendation.py)

### Bước tinh chỉnh: Adjust Steps, Adjust SQL, Save to Knowledge

> **Slide**: Khi không hài lòng → Chỉnh bước suy luận → Sửa SQL → Lưu tri thức

**1. Adjust Steps (AskFeedback):**

```python
# File: wren-ai-service/src/web/v1/services/ask_feedback.py
# Service xử lý feedback: nhận bước suy luận đã chỉnh sửa, tái sinh SQL
```

→ [Xem router ask_feedbacks](WrenAI/wren-ai-service/src/web/v1/routers/ask_feedbacks.py)

**2. Save to Knowledge — Lưu SQL Pairs:**

```python
# File: wren-ai-service/src/pipelines/indexing/sql_pairs.py
class SqlPairs(BasicPipeline):
    def __init__(self, ...):
        store = document_store_provider.get_store(dataset_name="sql_pairs")
        # Lưu vào collection riêng "sql_pairs" trong Qdrant
```

→ [Xem pipeline SQL Pairs indexing](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py#L163-L195)

**3. Save to Knowledge — Lưu Instructions:**

```python
# File: wren-ai-service/src/pipelines/indexing/instructions.py
class Instructions(BasicPipeline):
    def __init__(self, ...):
        store = document_store_provider.get_store(dataset_name="instructions")
        # Lưu vào collection riêng "instructions" trong Qdrant
```

→ [Xem pipeline Instructions indexing](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py#L120-L155)

**4. Các Collection Vector DB cho Knowledge Base:**

```python
# File: wren-ai-service/src/providers/document_store/qdrant.py
class QdrantProvider(DocumentStoreProvider):
    def _reset_document_store(self, recreate_index):
        self.get_store()                                    # DDL Schema chính
        self.get_store(dataset_name="table_descriptions")   # Mô tả bảng
        self.get_store(dataset_name="view_questions")       # Câu hỏi lịch sử
        self.get_store(dataset_name="sql_pairs")            # CẶP CÂU HỎI-SQL ĐÃ TINH CHỈNH
        self.get_store(dataset_name="instructions")         # HƯỚNG DẪN NGHIỆP VỤ BỔ SUNG
        self.get_store(dataset_name="project_meta")         # Metadata dự án
```

→ [Xem _reset_document_store()](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L308-L314)

---

## IV. Phân tích chi tiết từng tầng code

### 4.1 Tầng Core (Xương sống hệ thống)

📁 **Vị trí**: [wren-ai-service/src/core/](WrenAI/wren-ai-service/src/core/)

#### `pipeline.py` — Lớp cơ sở cho tất cả Pipeline

```python
# Import
from hamilton.async_driver import AsyncDriver   # Framework DAG execution
from haystack import Pipeline                   # Framework AI pipeline
from src.core.provider import DocumentStoreProvider, EmbedderProvider, LLMProvider

class BasicPipeline(metaclass=ABCMeta):
    """Mọi pipeline (Indexing, Retrieval, Generation) đều kế thừa từ class này"""
    def __init__(self, pipe: Pipeline | AsyncDriver | Driver):
        self._pipe = pipe
    
    @abstractmethod
    def run(self, *args, **kwargs):  # Mỗi pipeline phải implement hàm run()
        ...

@dataclass
class PipelineComponent(Mapping):
    """Container chứa tất cả provider cần cho 1 pipeline"""
    llm_provider: LLMProvider = None
    embedder_provider: EmbedderProvider = None
    document_store_provider: DocumentStoreProvider = None
    engine: Engine = None
```

→ [Xem pipeline.py](WrenAI/wren-ai-service/src/core/pipeline.py#L1-L40)

#### `provider.py` — Abstract class cho các nhà cung cấp dịch vụ

```python
class LLMProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_generator(self, *args, **kwargs): ...  # Trả về hàm gọi LLM
    def get_model(self): return self._model         # Tên model (gpt-4o, gemini, ...)
    def get_context_window_size(self): ...           # Kích thước context window

class EmbedderProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_text_embedder(self, ...): ...            # Embedder cho 1 text
    @abstractmethod
    def get_document_embedder(self, ...): ...        # Embedder cho nhiều documents

class DocumentStoreProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_store(self, ...) -> DocumentStore: ...   # Trả về kho vector
    @abstractmethod
    def get_retriever(self, ...): ...                # Trả về bộ truy xuất
```

→ [Xem provider.py](WrenAI/wren-ai-service/src/core/provider.py#L1-L46)

#### `engine.py` — Abstract Engine và hàm tiện ích

```python
class Engine(metaclass=ABCMeta):
    @abstractmethod
    async def execute_sql(self, sql, session, dry_run=True, ...):
        """Thực thi hoặc xác thực SQL trên data engine"""
        ...

def clean_generation_result(result: str) -> str:
    """Loại bỏ markdown, ký tự thừa từ output LLM"""
    return result.replace("```sql", "").replace("```", "").replace(";", "")
```

→ [Xem engine.py](WrenAI/wren-ai-service/src/core/engine.py#L1-L56)

---

### 4.2 Tầng Web (Giao tiếp API)

📁 **Vị trí**: [wren-ai-service/src/web/v1/](WrenAI/wren-ai-service/src/web/v1/)

#### Cấu trúc Router

File [routers/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/routers/__init__.py) đăng ký tất cả endpoint:

| Router | Endpoint | Chức năng |
|---|---|---|
| [ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py) | `POST /v1/asks` | Đặt câu hỏi |
| [ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py#L61) | `GET /v1/asks/{id}/result` | Lấy kết quả |
| [ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py#L69) | `GET /v1/asks/{id}/streaming-result` | Stream kết quả suy luận |
| [ask_feedbacks.py](WrenAI/wren-ai-service/src/web/v1/routers/ask_feedbacks.py) | `POST /v1/ask-feedbacks` | Gửi phản hồi tinh chỉnh |
| [sql_pairs.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_pairs.py) | `POST /v1/sql-pairs` | Lưu cặp câu hỏi-SQL |
| [instructions.py](WrenAI/wren-ai-service/src/web/v1/routers/instructions.py) | `POST /v1/instructions` | Lưu hướng dẫn nghiệp vụ |
| [question_recommendation.py](WrenAI/wren-ai-service/src/web/v1/routers/question_recommendation.py) | `POST /v1/question-recommendations` | Gợi ý câu hỏi |
| [semantics_preparation.py](WrenAI/wren-ai-service/src/web/v1/routers/semantics_preparation.py) | `POST /v1/semantics-preparations` | Deploy/index MDL |
| [sql_corrections.py](WrenAI/wren-ai-service/src/web/v1/routers/sql_corrections.py) | `POST /v1/sql-corrections` | Sửa SQL lỗi |

#### AskService — Service xử lý chính

```python
# File: wren-ai-service/src/web/v1/services/ask.py
class AskService:
    def __init__(self, pipelines: Dict[str, BasicPipeline], ...):
        self._pipelines = pipelines  # Chứa TẤT CẢ pipeline cần thiết
    
    async def ask(self, ask_request):
        # LUỒNG XỬ LÝ CHÍNH:
        # 1. status="understanding" → Intent Classification
        # 2. status="searching"     → DB Schema Retrieval  
        # 3. status="planning"      → SQL Generation Reasoning (Chain of Thought)
        # 4. status="generating"    → SQL Generation
        # 5. status="correcting"    → SQL Correction (nếu lỗi)
        # 6. status="finished"      → Trả kết quả
```

→ [Xem AskService](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L95-L180)
→ [Xem luồng ask() đầy đủ](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L125-L630)

**Các trạng thái xử lý** (`status`):

```
understanding → searching → planning → generating → [correcting] → finished
                                                                  → failed
                                                    → stopped
```

---

### 4.3 Tầng Indexing (Chuẩn bị tri thức)

📁 **Vị trí**: [wren-ai-service/src/pipelines/indexing/](WrenAI/wren-ai-service/src/pipelines/indexing/)

#### Sơ đồ luồng Indexing

```
MDL JSON ──▶ Validate ──▶ Chunk ──▶ Embed ──▶ Clean old docs ──▶ Write to Qdrant
```

#### Các pipeline Indexing

| Pipeline | File | Chức năng | Collection Qdrant |
|---|---|---|---|
| `DBSchema` | [db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L248-L292) | Index cấu trúc bảng, cột, FK | `Document` |
| `TableDescription` | [table_description.py](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py#L91-L145) | Index mô tả bảng | `table_descriptions` |
| `HistoricalQuestion` | [historical_question.py](WrenAI/wren-ai-service/src/pipelines/indexing/historical_question.py#L116-L160) | Index câu hỏi lịch sử (views) | `view_questions` |
| `SqlPairs` | [sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py#L163-L228) | Index cặp câu hỏi-SQL tinh chỉnh | `sql_pairs` |
| `Instructions` | [instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py#L120-L175) | Index hướng dẫn nghiệp vụ | `instructions` |

#### Component dùng chung

| Component | File | Chức năng |
|---|---|---|
| `MDLValidator` | [\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/indexing/__init__.py#L57-L75) | Validate JSON MDL |
| `DocumentCleaner` | [\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/indexing/__init__.py#L14-L54) | Xóa documents cũ trước khi index mới |
| `AsyncDocumentWriter` | [\_\_init\_\_.py](WrenAI/wren-ai-service/src/pipelines/indexing/__init__.py#L78-L90) | Ghi documents vào Qdrant bất đồng bộ |

---

### 4.4 Tầng Retrieval (Truy xuất ngữ cảnh)

📁 **Vị trí**: [wren-ai-service/src/pipelines/retrieval/](WrenAI/wren-ai-service/src/pipelines/retrieval/)

#### Sơ đồ luồng DB Schema Retrieval

```
User Query ──▶ Embed Query ──▶ Search table_descriptions ──▶ Get full DDL schema
                                (top_k=10 bảng)              ──▶ Column Pruning (nếu cần)
                                                              ──▶ Return DDL context
```

#### Các pipeline Retrieval

| Pipeline | File | Chức năng | Threshold |
|---|---|---|---|
| `DbSchemaRetrieval` | [db_schema_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py#L449-L520) | Tìm DDL bảng liên quan | top_k=10 |
| `SqlPairsRetrieval` | [sql_pairs_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_pairs_retrieval.py#L114-L155) | Tìm SQL mẫu tương đồng | score ≥ 0.7 |
| `HistoricalQuestionRetrieval` | [historical_question_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/historical_question_retrieval.py#L128-L163) | Tìm câu hỏi đã trả lời | score ≥ 0.9 |
| `Instructions` | [instructions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/instructions.py#L178-L229) | Tìm hướng dẫn liên quan | score ≥ 0.7 |

#### ScoreFilter — Lọc kết quả theo ngưỡng

```python
# File: wren-ai-service/src/pipelines/common.py
@component
class ScoreFilter:
    def run(self, documents, score=0.9, max_size=10):
        return {
            "documents": sorted(
                filter(lambda doc: doc.score >= score, documents),  # Lọc theo ngưỡng
                key=lambda doc: doc.score, reverse=True            # Sắp xếp giảm dần
            )[:max_size]                                           # Giới hạn số lượng
        }
```

→ [Xem ScoreFilter](WrenAI/wren-ai-service/src/pipelines/common.py#L90-L106)

---

### 4.5 Tầng Generation (Sinh mã SQL)

📁 **Vị trí**: [wren-ai-service/src/pipelines/generation/](WrenAI/wren-ai-service/src/pipelines/generation/)

#### Các pipeline Generation chính

| Pipeline | File | Chức năng |
|---|---|---|
| `IntentClassification` | [intent_classification.py](WrenAI/wren-ai-service/src/pipelines/generation/intent_classification.py) | Phân loại ý định: TEXT_TO_SQL, GENERAL, MISLEADING, USER_GUIDE |
| `SQLGenerationReasoning` | [sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py) | Chain of Thought — lập kế hoạch suy luận |
| `SQLGeneration` | [sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py) | Sinh câu SQL từ prompt |
| `SQLCorrection` | [sql_correction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_correction.py) | Sửa SQL có lỗi |
| `SQLRegeneration` | [sql_regeneration.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_regeneration.py) | Tái sinh SQL khi user feedback |
| `QuestionRecommendation` | [question_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/question_recommendation.py) | Gợi ý câu hỏi mới |
| `SQLAnswer` | [sql_answer.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_answer.py) | Chuyển kết quả SQL thành text |
| `ChartGeneration` | [chart_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_generation.py) | Sinh biểu đồ từ dữ liệu |

#### Luồng chung của mỗi Generation pipeline

```
Prompt Template ──▶ Fill variables ──▶ Call LLM ──▶ Post-process ──▶ Validate
    (Jinja2)         (PromptBuilder)   (generator)   (clean SQL)    (dry_run)
```

#### Intent Classification — 4 loại ý định

```python
# File: wren-ai-service/src/pipelines/generation/intent_classification.py
# Hệ thống phân loại câu hỏi thành:
# - TEXT_TO_SQL:     Câu hỏi cần sinh SQL
# - GENERAL:         Câu hỏi chung về data
# - MISLEADING_QUERY: Câu hỏi không liên quan
# - USER_GUIDE:      Câu hỏi về tính năng Wren AI
```

→ [Xem intent classification prompt](WrenAI/wren-ai-service/src/pipelines/generation/intent_classification.py#L27-L152)

---

### 4.6 Tầng Providers (Tích hợp dịch vụ bên ngoài)

📁 **Vị trí**: [wren-ai-service/src/providers/](WrenAI/wren-ai-service/src/providers/)

#### Cơ chế Provider Registry

```python
# File: wren-ai-service/src/providers/loader.py
PROVIDERS = {}

def provider(name: str):
    """Decorator đăng ký provider vào registry"""
    def wrapper(cls):
        PROVIDERS[name] = cls
        return cls
    return wrapper

# Sử dụng:
@provider("litellm_llm")      # Đăng ký LLM provider
class LitellmLLMProvider: ...

@provider("litellm_embedder")  # Đăng ký Embedder provider
class LitellmEmbedderProvider: ...

@provider("qdrant")            # Đăng ký Document Store provider
class QdrantProvider: ...
```

→ [Xem loader.py](WrenAI/wren-ai-service/src/providers/loader.py#L1-L89)

#### Document Store — Qdrant

| Class | File | Chức năng |
|---|---|---|
| `AsyncQdrantDocumentStore` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L65-L277) | Kho vector bất đồng bộ |
| `AsyncQdrantEmbeddingRetriever` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L280-L322) | Bộ truy xuất vector |
| `QdrantProvider` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L325-L384) | Factory tạo store & retriever |

**Các phương thức quan trọng**:

| Phương thức | Dòng code | Chức năng |
|---|---|---|
| `write_documents()` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L241-L277) | Lưu vector vào Qdrant |
| `_query_by_embedding()` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L157-L203) | Tìm kiếm Cosine Similarity |
| `delete_documents()` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L215-L229) | Xóa documents |
| `count_documents()` | [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py#L231-L241) | Đếm documents |

**Import thư viện chính**:
```python
import qdrant_client                        # Client giao tiếp Qdrant
from haystack_integrations.document_stores.qdrant import QdrantDocumentStore  # Haystack adapter
from qdrant_client.http import models as rest  # REST models (PointStruct, NamedVector, ...)
```

#### Embedder — LiteLLM

| Class | File | Chức năng |
|---|---|---|
| `AsyncTextEmbedder` | [litellm.py (embedder)](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L36-L85) | Embed 1 text (câu hỏi user) |
| `AsyncDocumentEmbedder` | [litellm.py (embedder)](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L87-L155) | Embed nhiều Documents (chunks) |
| `LitellmEmbedderProvider` | [litellm.py (embedder)](WrenAI/wren-ai-service/src/providers/embedder/litellm.py#L158-L196) | Factory provider |

**Import thư viện chính**:
```python
from litellm import aembedding   # Hàm gọi API embedding bất đồng bộ
import openai                    # Xử lý retry khi API lỗi
import backoff                   # Exponential backoff retry
```

#### LLM — LiteLLM

| Class | File | Chức năng |
|---|---|---|
| `LitellmLLMProvider` | [litellm.py (llm)](WrenAI/wren-ai-service/src/providers/llm/litellm.py#L22-L155) | Giao tiếp LLM |

**Import thư viện chính**:
```python
from litellm import Router, acompletion  # Router cho fallback, acompletion cho gọi LLM
import openai                            # API errors handling
import backoff                           # Retry mechanism
```

**Cơ chế Fallback**: Nếu model chính fail, tự động chuyển sang model dự phòng:
```python
# Dòng 62-68: Khởi tạo Router với fallback
self._router = Router(
    model_list=fallback_model_list or [],
    fallbacks=[{self._model: [m["model_name"] for m in fallback_model_list[1:]]}]
)

# Dòng 104-110: Gọi với fallback
if self._has_fallbacks:
    completion = await self._router.acompletion(model=self._model, messages=..., ...)
else:
    completion = await acompletion(model=self._model, messages=..., ...)
```

→ [Xem fallback mechanism](WrenAI/wren-ai-service/src/providers/llm/litellm.py#L58-L110)

#### Engine — Wren

| Class | File | Chức năng |
|---|---|---|
| `WrenUI` | [wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py#L17-L129) | Execute SQL qua UI GraphQL API |
| `WrenIbis` | [wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py#L132-L300) | Execute SQL qua Ibis connector |
| `WrenEngine` | [wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py#L302-L351) | Execute SQL qua Engine trực tiếp |

**WrenUI validate SQL** qua GraphQL:
```python
# File: wren-ai-service/src/providers/engine/wren.py
async def execute_sql(self, sql, session, dry_run=True, ...):
    async with session.post(
        f"{self._endpoint}/api/graphql",
        json={
            "query": "mutation PreviewSql($data: PreviewSQLDataInput) { previewSql(data: $data) }",
            "variables": {"data": {"sql": sql, "dryRun": True, "limit": 1}},
        },
    ) as response:
        # Nếu thành công → SQL hợp lệ, nếu lỗi → trả error message
```

→ [Xem WrenUI.execute_sql()](WrenAI/wren-ai-service/src/providers/engine/wren.py#L26-L129)

---

### 4.7 Utils & Common

#### `utils.py` — Tiện ích hệ thống

| Hàm/Class | Dòng | Chức năng |
|---|---|---|
| `setup_custom_logger()` | [utils.py](WrenAI/wren-ai-service/src/utils.py#L51-L66) | Cấu hình logging |
| `init_langfuse()` | [utils.py](WrenAI/wren-ai-service/src/utils.py#L77-L85) | Khởi tạo monitoring Langfuse |
| `trace_metadata()` | [utils.py](WrenAI/wren-ai-service/src/utils.py#L88-L155) | Decorator ghi metadata theo dõi |
| `trace_cost()` | [utils.py](WrenAI/wren-ai-service/src/utils.py#L158-L176) | Decorator đo chi phí LLM |
| `fetch_wren_ai_docs()` | [utils.py](WrenAI/wren-ai-service/src/utils.py#L179-L200) | Lấy tài liệu hướng dẫn Wren AI |

→ [Xem utils.py](WrenAI/wren-ai-service/src/utils.py#L1-L221)

#### `common.py` — Hàm dùng chung cho pipelines

| Hàm/Class | Dòng | Chức năng |
|---|---|---|
| `build_table_ddl()` | [common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L30-L73) | Xây dựng DDL từ schema dict |
| `ScoreFilter` | [common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L90-L106) | Lọc documents theo ngưỡng score |
| `clean_up_new_lines()` | [common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L112-L113) | Dọn dẹp xuống dòng thừa |
| `retrieve_metadata()` | [common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L76-L89) | Lấy metadata dự án |
| `get_engine_supported_data_type()` | [common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L7-L27) | Map kiểu dữ liệu |

→ [Xem common.py](WrenAI/wren-ai-service/src/pipelines/common.py#L1-L113)

---

## V. Cơ chế Chunking chi tiết (DDL vs SQL Pairs vs Instructions)

### So sánh 3 cơ chế chunking

| Tiêu chí | DDL Schema Chunking | SQL Pairs Chunking | Instructions Chunking |
|---|---|---|---|
| **Đơn vị chunk** | Batch cột (50 cột/chunk) + 1 chunk metadata bảng | 1 câu hỏi = 1 chunk | 1 instruction = 1 chunk |
| **Cơ chế** | **Batch-based** (chia theo số lượng cố định) | **Sentence-level** (mỗi cặp Q&A là 1 đơn vị) | **Sentence-level** (mỗi chỉ dẫn là 1 đơn vị) |
| **Content được embed** | DDL command dạng text (`CREATE TABLE ...`) | Câu hỏi (`question`) | Câu hỏi (`question`) hoặc "global instruction" |
| **Metadata lưu kèm** | `type`, `name`, `project_id` | `sql_pair_id`, `sql`, `project_id` | `instruction_id`, `instruction`, `is_default`, `scope` |
| **File code** | [db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py) | [sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py) | [instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py) |

### DDL Schema Chunking — Chi tiết kỹ thuật

Mỗi bảng trong MDL tạo ra **nhiều chunks**:

```
Bảng "Employees" (120 cột, 3 FK) sẽ tạo:
├── Chunk 1: TABLE metadata (tên, mô tả, alias)
├── Chunk 2: TABLE_COLUMNS batch 1 (cột 1-50 + FK liên quan)
├── Chunk 3: TABLE_COLUMNS batch 2 (cột 51-100)
└── Chunk 4: TABLE_COLUMNS batch 3 (cột 101-120)
```

**Code tạo chunk cho bảng**:
```python
# File: db_schema.py, hàm _model_command()
def _model_command(model):
    payload = {
        "type": "TABLE",           # Loại chunk: metadata bảng
        "comment": f"\n/* {model_properties} */\n",
        "name": table_name,
    }
    return {"name": table_name, "payload": str(payload)}
```

**Code tạo chunk cho batch cột**:
```python
# File: db_schema.py, hàm _column_batch()
return [
    {
        "name": model["name"],
        "payload": str({
            "type": "TABLE_COLUMNS",   # Loại chunk: danh sách cột
            "columns": filtered[i : i + column_batch_size],  # Batch 50 cột
        }),
    }
    for i in range(0, len(filtered), column_batch_size)
]
```

→ [Xem _model_command()](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L122-L137)
→ [Xem _column_batch()](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py#L179-L199)

### SQL Pairs Chunking — Chi tiết kỹ thuật

Mỗi cặp câu hỏi + SQL = **1 Document duy nhất**:

```python
# File: sql_pairs.py, class SqlPairsConverter
@component
class SqlPairsConverter:
    def run(self, sql_pairs, project_id=""):
        return {
            "documents": [
                Document(
                    id=str(uuid.uuid4()),
                    meta={
                        "sql_pair_id": sql_pair.id,
                        "sql": sql_pair.sql,        # SQL được lưu trong metadata
                    },
                    content=sql_pair.question,      # CÂU HỎI được embed (content)
                )
                for sql_pair in sql_pairs
            ]
        }
```

**Cơ chế**: Content được embed là **câu hỏi tiếng tự nhiên** → khi user hỏi câu tương tự, vector search sẽ tìm được câu hỏi-SQL mẫu gần nhất → cung cấp làm few-shot example cho LLM.

→ [Xem SqlPairsConverter](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py#L30-L53)

### Instructions Chunking — Chi tiết kỹ thuật

Mỗi instruction = **1 Document duy nhất**, có phân biệt `is_default` và `scope`:

```python
# File: instructions.py, class InstructionsConverter
@component
class InstructionsConverter:
    def run(self, instructions, project_id=""):
        return {
            "documents": [
                Document(
                    id=str(uuid.uuid4()),
                    meta={
                        "instruction_id": instruction.id,
                        "instruction": instruction.instruction,   # Nội dung hướng dẫn
                        "is_default": instruction.is_default,     # Mặc định hay tùy chỉnh
                        "scope": instruction.scope,               # Phạm vi: "sql", "answer", "chart"
                    },
                    content="this is a global instruction..."     # Content nếu là default
                        if instruction.is_default
                        else instruction.question,                # CÂU HỎI nếu là custom
                )
                for instruction in instructions
            ]
        }
```

**Logic**: Default instructions luôn được truy xuất (không cần similarity), custom instructions được tìm kiếm theo question tương đồng.

→ [Xem InstructionsConverter](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py#L30-L61)
→ [Xem retrieval default_instructions](WrenAI/wren-ai-service/src/pipelines/retrieval/instructions.py#L125-L155)

### Table Description Chunking — Chi tiết kỹ thuật

Mỗi bảng/metric/view = **1 Document mô tả**, chứa tên + description + danh sách cột:

```python
# File: table_description.py, class TableDescriptionChunker
def _get_table_descriptions(self, mdl):
    resources = (
        [_structure_data("MODEL", model) for model in mdl["models"]]
        + [_structure_data("METRIC", metric) for metric in mdl["metrics"]]
        + [_structure_data("VIEW", view) for view in mdl["views"]]
    )
    return [
        {
            "name": resource["name"],
            "description": resource["properties"].get("description", ""),
            "columns": ", ".join(resource["columns"]),
        }
        for resource in resources
    ]
```

→ [Xem TableDescriptionChunker](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py#L24-L72)

---

## VI. Luồng End-to-End hoàn chỉnh

### Ví dụ: User hỏi "Công ty có đang chảy máu chất xám không?"

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 1: WEB LAYER — Tiếp nhận câu hỏi                                     │
│                                                                             │
│ [routers/ask.py] POST /v1/asks                                             │
│   → Tạo query_id = uuid4()                                                │
│   → Đặt status = "understanding"                                           │
│   → Chạy service.ask() trong background                                    │
│   → Trả query_id cho client ngay lập tức                                  │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 2: INTENT CLASSIFICATION — Phân loại ý định                           │
│                                                                             │
│ [services/ask.py] → Đầu tiên kiểm tra historical_question (câu hỏi cũ)    │
│ [generation/intent_classification.py]                                        │
│   → Embed câu hỏi qua AsyncTextEmbedder [embedder/litellm.py]             │
│   → Retrieval table_descriptions từ Qdrant                                 │
│   → Ghép prompt: câu hỏi + schema + SQL samples + instructions            │
│   → Gọi LLM phân loại → Kết quả: "TEXT_TO_SQL"                            │
│   → Rephrase: "Tỷ lệ nhân viên giỏi nghỉ việc trong công ty?"            │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 3: RETRIEVAL — Truy xuất ngữ cảnh (status="searching")                │
│                                                                             │
│ [retrieval/db_schema_retrieval.py]                                          │
│   → embedding(): Embed câu hỏi thành vector [embedder/litellm.py]         │
│   → table_retrieval(): Tìm top-10 bảng trong "table_descriptions"         │
│      [document_store/qdrant.py] AsyncQdrantEmbeddingRetriever.run()        │
│   → dbschema_retrieval(): Lấy full DDL từ "Document" collection           │
│   → construct_db_schemas(): Tái cấu trúc thành DDL hoàn chỉnh            │
│   → Kết quả: ["dbo_V_ML_TEST", "dbo_HR_Training_Data", ...]              │
│                                                                             │
│ Song song: [retrieval/sql_pairs_retrieval.py] → Tìm SQL mẫu tương đồng    │
│            [retrieval/instructions.py] → Tìm hướng dẫn liên quan           │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 4: REASONING — Chain of Thought (status="planning")                    │
│                                                                             │
│ [generation/sql_generation_reasoning.py]                                     │
│   → Ghép prompt: câu hỏi + DDL schema + SQL mẫu + instructions            │
│   → Gọi LLM với STREAMING                                                  │
│      [llm/litellm.py] acompletion(stream=True)                             │
│   → LLM suy luận từng bước:                                               │
│      1. Filter relevant batch date                                          │
│      2. Identify Top Talent                                                 │
│      3. Identify Brain Drain Employees                                      │
│      4. Calculate Brain Drain Rate                                          │
│      5. Determine Brain Drain Significance                                  │
│   → Stream từng chunk suy luận về UI qua SSE                              │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 5: GENERATION — Sinh SQL (status="generating")                         │
│                                                                             │
│ [generation/sql_generation.py]                                               │
│   → prompt(): Ghép template Jinja2 với tất cả context                      │
│   → generate_sql(): Gọi LLM sinh SQL                                      │
│      [llm/litellm.py] acompletion() hoặc router.acompletion()              │
│   → post_process(): [generation/utils/sql.py]                              │
│      → clean_generation_result(): Loại bỏ markdown, ký tự thừa            │
│      → engine.execute_sql(dry_run=True): Validate SQL tại Wren Engine      │
│      [engine/wren.py] WrenUI.execute_sql() qua GraphQL                     │
│                                                                             │
│ Nếu SQL hợp lệ → Trả kết quả                                             │
│ Nếu SQL lỗi → BƯỚC 5b: SQL CORRECTION                                     │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │ (nếu lỗi)
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 5b: CORRECTION — Sửa SQL lỗi (status="correcting")                   │
│                                                                             │
│ [generation/sql_correction.py]                                               │
│   → Nhận: SQL lỗi + Error message + DDL schema                            │
│   → Ghép prompt correction template                                         │
│   → Gọi LLM sửa SQL                                                       │
│   → Validate lại                                                            │
│   → Retry tối đa 3 lần (max_sql_correction_retries=3)                     │
│                                                                             │
│ [services/ask.py] Vòng lặp sửa lỗi:                                       │
│   while current_retries < max_retries:                                      │
│       sql_correction_results = await pipelines["sql_correction"].run(...)   │
│       if valid: break                                                       │
└─────────────┬───────────────────────────────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ BƯỚC 6: RESPONSE — Trả kết quả (status="finished")                         │
│                                                                             │
│ [services/ask.py]                                                           │
│   → Cập nhật: status="finished", response=[AskResult(sql=...)]            │
│   → Client poll: GET /v1/asks/{query_id}/result                            │
│   → Streaming: GET /v1/asks/{query_id}/streaming-result (SSE)              │
│                                                                             │
│ [routers/ask.py]                                                            │
│   → get_ask_result(): Trả AskResultResponse                               │
│   → get_ask_streaming_result(): StreamingResponse                          │
│                                                                             │
│ Kết quả chứa: SQL, reasoning, table_names, rephrased_question             │
└─────────────────────────────────────────────────────────────────────────────┘
```

→ [Xem toàn bộ luồng trong AskService.ask()](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L125-L630)

---

## VII. Bảng tổng hợp File ↔ Chức năng

### Core

| File | Chức năng chính | Thư viện import quan trọng |
|---|---|---|
| [src/core/pipeline.py](WrenAI/wren-ai-service/src/core/pipeline.py) | `BasicPipeline`, `PipelineComponent` | `hamilton.async_driver`, `haystack.Pipeline` |
| [src/core/provider.py](WrenAI/wren-ai-service/src/core/provider.py) | `LLMProvider`, `EmbedderProvider`, `DocumentStoreProvider` | `abc.ABCMeta`, `haystack.document_stores` |
| [src/core/engine.py](WrenAI/wren-ai-service/src/core/engine.py) | `Engine`, `clean_generation_result()` | `aiohttp`, `re`, `pydantic` |

### Web Layer

| File | Chức năng chính | Thư viện import quan trọng |
|---|---|---|
| [src/web/v1/routers/ask.py](WrenAI/wren-ai-service/src/web/v1/routers/ask.py) | Endpoint `/asks`, `/asks/{id}/result` | `fastapi.APIRouter`, `BackgroundTasks` |
| [src/web/v1/services/ask.py](WrenAI/wren-ai-service/src/web/v1/services/ask.py) | `AskService.ask()` orchestration | `cachetools.TTLCache`, `pydantic`, `asyncio` |
| [src/web/v1/services/\_\_init\_\_.py](WrenAI/wren-ai-service/src/web/v1/services/__init__.py) | `Configuration`, `BaseRequest`, `SSEEvent` | `pydantic`, `orjson`, `pytz` |

### Indexing Pipelines

| File | Class chính | Cơ chế Chunking | Collection |
|---|---|---|---|
| [src/pipelines/indexing/db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py) | `DDLChunker`, `DBSchema` | Batch cột (50/chunk) | `Document` |
| [src/pipelines/indexing/table_description.py](WrenAI/wren-ai-service/src/pipelines/indexing/table_description.py) | `TableDescriptionChunker`, `TableDescription` | 1 bảng = 1 chunk | `table_descriptions` |
| [src/pipelines/indexing/historical_question.py](WrenAI/wren-ai-service/src/pipelines/indexing/historical_question.py) | `ViewChunker`, `HistoricalQuestion` | 1 view = 1 chunk | `view_questions` |
| [src/pipelines/indexing/sql_pairs.py](WrenAI/wren-ai-service/src/pipelines/indexing/sql_pairs.py) | `SqlPairsConverter`, `SqlPairs` | 1 câu hỏi = 1 chunk | `sql_pairs` |
| [src/pipelines/indexing/instructions.py](WrenAI/wren-ai-service/src/pipelines/indexing/instructions.py) | `InstructionsConverter`, `Instructions` | 1 instruction = 1 chunk | `instructions` |

### Retrieval Pipelines

| File | Class chính | Nguồn tìm kiếm | Threshold |
|---|---|---|---|
| [src/pipelines/retrieval/db_schema_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/db_schema_retrieval.py) | `DbSchemaRetrieval` | `table_descriptions` → `Document` | top_k=10 |
| [src/pipelines/retrieval/sql_pairs_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/sql_pairs_retrieval.py) | `SqlPairsRetrieval` | `sql_pairs` | score ≥ 0.7 |
| [src/pipelines/retrieval/historical_question_retrieval.py](WrenAI/wren-ai-service/src/pipelines/retrieval/historical_question_retrieval.py) | `HistoricalQuestionRetrieval` | `view_questions` | score ≥ 0.9 |
| [src/pipelines/retrieval/instructions.py](WrenAI/wren-ai-service/src/pipelines/retrieval/instructions.py) | `Instructions` | `instructions` | score ≥ 0.7 |

### Generation Pipelines

| File | Class chính | Chức năng |
|---|---|---|
| [src/pipelines/generation/intent_classification.py](WrenAI/wren-ai-service/src/pipelines/generation/intent_classification.py) | `IntentClassification` | Phân loại ý định |
| [src/pipelines/generation/sql_generation_reasoning.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation_reasoning.py) | `SQLGenerationReasoning` | Chain of Thought + streaming |
| [src/pipelines/generation/sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py) | `SQLGeneration` | Sinh SQL chính |
| [src/pipelines/generation/sql_correction.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_correction.py) | `SQLCorrection` | Sửa SQL lỗi |
| [src/pipelines/generation/sql_regeneration.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_regeneration.py) | `SQLRegeneration` | Tái sinh SQL (feedback) |
| [src/pipelines/generation/question_recommendation.py](WrenAI/wren-ai-service/src/pipelines/generation/question_recommendation.py) | `QuestionRecommendation` | Gợi ý câu hỏi |
| [src/pipelines/generation/sql_answer.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_answer.py) | `SQLAnswer` | Chuyển SQL → text trả lời |
| [src/pipelines/generation/chart_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/chart_generation.py) | `ChartGeneration` | Sinh biểu đồ |

### Providers

| File | Class chính | Thư viện | Vai trò |
|---|---|---|---|
| [src/providers/document_store/qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py) | `QdrantProvider`, `AsyncQdrantDocumentStore` | `qdrant_client`, `haystack_integrations` | Vector DB |
| [src/providers/embedder/litellm.py](WrenAI/wren-ai-service/src/providers/embedder/litellm.py) | `LitellmEmbedderProvider`, `AsyncTextEmbedder` | `litellm.aembedding` | Text → Vector |
| [src/providers/llm/litellm.py](WrenAI/wren-ai-service/src/providers/llm/litellm.py) | `LitellmLLMProvider` | `litellm.acompletion`, `litellm.Router` | LLM API |
| [src/providers/engine/wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py) | `WrenUI`, `WrenIbis`, `WrenEngine` | `aiohttp` | SQL Execution |
| [src/providers/loader.py](WrenAI/wren-ai-service/src/providers/loader.py) | `provider()` decorator, `PROVIDERS` registry | `importlib` | Plugin system |

### Utils & Config

| File | Chức năng | Thư viện |
|---|---|---|
| [src/utils.py](WrenAI/wren-ai-service/src/utils.py) | Logging, Langfuse, tracing | `langfuse`, `dotenv`, `requests` |
| [src/pipelines/common.py](WrenAI/wren-ai-service/src/pipelines/common.py) | DDL builder, ScoreFilter, helpers | `haystack.Document`, `re` |
| [src/config.py](WrenAI/wren-ai-service/src/config.py) | Settings (cấu hình toàn bộ) | `pydantic_settings`, `yaml` |
| [src/globals.py](WrenAI/wren-ai-service/src/globals.py) | ServiceContainer, wiring pipelines | `src.pipelines.*`, `src.web.v1.services.*` |
| [src/pipelines/generation/utils/sql.py](WrenAI/wren-ai-service/src/pipelines/generation/utils/sql.py) | `SQLGenPostProcessor`, SQL rules | `aiohttp`, `orjson`, `haystack` |

---

## Kết luận

Toàn bộ nội dung đã trình bày trên 3 slide được **thực hiện hóa hoàn chỉnh** trong codebase Wren AI thông qua kiến trúc pipeline modular:

1. **Slide 1 (Kiến trúc tổng quan)**: 3 thành phần Wren UI → AI Service → Engine được kết nối qua HTTP/GraphQL API, orchestrate tại [globals.py](WrenAI/wren-ai-service/src/globals.py) và [\_\_main\_\_.py](WrenAI/wren-ai-service/src/__main__.py)

2. **Slide 2 (RAG Pipeline 5 bước)**: Chunking → Embedding → Vector Search → Prompt → Generation + Validation được thực thi qua pipeline chain: [db_schema.py](WrenAI/wren-ai-service/src/pipelines/indexing/db_schema.py) → [litellm.py (embedder)](WrenAI/wren-ai-service/src/providers/embedder/litellm.py) → [qdrant.py](WrenAI/wren-ai-service/src/providers/document_store/qdrant.py) → [sql_generation.py](WrenAI/wren-ai-service/src/pipelines/generation/sql_generation.py) → [wren.py](WrenAI/wren-ai-service/src/providers/engine/wren.py)

3. **Slide 3 (Vận hành thực tế)**: Toàn bộ luồng từ đặt câu hỏi → phân loại → truy xuất → suy luận → sinh SQL → sửa lỗi → trả kết quả → tinh chỉnh được orchestrate trong [AskService.ask()](WrenAI/wren-ai-service/src/web/v1/services/ask.py#L125-L630) với streaming qua SSE

**Framework cốt lõi**: Haystack (`@component`, `Document`), Hamilton (`AsyncDriver` cho DAG execution), LiteLLM (unified LLM/Embedding API), Qdrant (Vector Database), FastAPI (Web framework)

---

> 📌 **Lưu ý**: Mọi file code đã được note tiếng Việt có dấu tại các dòng code quan trọng. Click vào link sẽ mở đúng file và vị trí tương ứng.
