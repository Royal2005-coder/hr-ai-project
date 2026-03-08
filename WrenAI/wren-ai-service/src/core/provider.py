from abc import ABCMeta, abstractmethod

from haystack.document_stores.types import DocumentStore


# === NHÀ CUNG CẤP LLM - Abstract class định nghĩa giao diện giao tiếp với mô hình ngôn ngữ lớn (OpenAI, Gemini, v.v.) ===
class LLMProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_generator(self, *args, **kwargs):
        ...

    def get_model(self):
        return self._model

    def get_model_kwargs(self):
        return self._model_kwargs

    def get_context_window_size(self):
        return self._context_window_size


# === NHÀ CUNG CẤP EMBEDDER - Abstract class để chuyển đổi văn bản thành vector số học (embedding) ===
class EmbedderProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_text_embedder(self, *args, **kwargs):
        ...

    @abstractmethod
    def get_document_embedder(self, *args, **kwargs):
        ...

    def get_model(self):
        return self._embedding_model


# === NHÀ CUNG CẤP KHO TÀI LIỆU - Abstract class quản lý lưu trữ và truy xuất vector trong Qdrant DB ===
class DocumentStoreProvider(metaclass=ABCMeta):
    @abstractmethod
    def get_store(self, *args, **kwargs) -> DocumentStore:
        ...

    @abstractmethod
    def get_retriever(self, *args, **kwargs):
        ...
