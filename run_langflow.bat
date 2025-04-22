@echo off
set LANGFLOW_FILE_SIZE_LIMIT=100
set LANGFLOW_ALLOWED_FILE_TYPES=".txt,.pdf,.csv,.xlsx,.json,.md,.docx"
langflow run --host 0.0.0.0 --port 7860
