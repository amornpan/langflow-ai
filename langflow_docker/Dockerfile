# Multi-stage Dockerfile for Langflow with uv
# Fixed for webrtcvad build requirements

# Stage 1: Builder stage with build tools
FROM ghcr.io/astral-sh/uv:python3.12-bookworm AS builder

# Install build dependencies for packages that need compilation
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    libc6-dev \
    make \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for uv optimization
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_PREFERENCE=only-system
ENV UV_CACHE_DIR=/tmp/.uv-cache

# Create app directory
WORKDIR /app

# Copy pyproject.toml first for better caching
COPY pyproject.toml ./

# Generate uv.lock file and install dependencies with cache mount
RUN --mount=type=cache,target=/tmp/.uv-cache \
    uv lock && \
    uv sync --locked --no-install-project

# Stage 2: Runtime stage (slim without build tools)
FROM python:3.12-slim-bookworm AS runtime

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd --gid 1000 langflow && \
    useradd --uid 1000 --gid langflow --shell /bin/bash --create-home langflow

# Copy the virtual environment from builder stage
COPY --from=builder --chown=langflow:langflow /app/.venv /app/.venv

# Set up the virtual environment path
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"
ENV PYTHONPATH="/app/.venv/lib/python3.12/site-packages"

# Switch to non-root user
USER langflow

# Create necessary directories for Langflow
RUN mkdir -p /home/langflow/.langflow/logs \
    && mkdir -p /home/langflow/.langflow/storage \
    && mkdir -p /home/langflow/.langflow/cache \
    && mkdir -p /home/langflow/.langflow/secret_keys

# Set working directory
WORKDIR /home/langflow

# Copy any custom flows (if any)
# COPY --chown=langflow:langflow flows/ /home/langflow/flows/

# Expose Langflow port
EXPOSE 7860

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:7860/health || exit 1

# Default command to run Langflow
CMD ["langflow", "run", "--host", "0.0.0.0", "--port", "7860"]
