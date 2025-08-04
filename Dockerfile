FROM ghcr.io/ggml-org/llama.cpp:server-cuda

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN apt-get update \
    && apt-get install -y vim git curl tmux python3 python3-pip sudo \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

# Install huggingface_hub
RUN python3 -m pip install --no-cache-dir -U huggingface_hub hf_transfer

# Install Claude Code
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g @qwen-code/qwen-code@latest tiktoken \
    && apt autoremove -y \
    && apt clean -y \
    && rm -rf /tmp/* /var/tmp/* \
    && find /var/cache/apt/archives /var/lib/apt/lists -not -name lock -type f -delete \
    && find /var/cache -type f -delete

# Create group and user developer
RUN groupadd -g $GROUP_ID developer \
    && useradd -u $USER_ID -g $GROUP_ID -m developer \
    && echo developer ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/developer \
    && chmod 0440 /etc/sudoers.d/developer \
    && usermod -a -G video developer

# Download fixed tool calling chat template for Qwen3-Code-30B-A3B-Instruct
ENV HF_CHAT_TEMPLATE='/app/Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.jinja'
ADD --chown=developer:developer https://huggingface.co/unsloth/Qwen3-Coder-30B-A3B-Instruct/raw/main/chat_template.jinja $HF_CHAT_TEMPLATE

# Switch to user developer
USER developer

# Config for hugginface_hub
ENV HF_HUB_ENABLE_HF_TRANSFER=1
ENV HF_REPO_ID="unsloth/Qwen3-Coder-30B-A3B-Instruct-GGUF"
ENV HF_MODEL="Qwen3-Coder-30B-A3B-Instruct-UD-Q4_K_XL.gguf"

# Config for llama.cpp
ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_PORT=4000
ENV LLAMA_ARG_N_PARALLEL=1
ENV LLAMA_API_KEY=sk-1234-miaw
ENV LLAMA_ARG_JINJA=1
ENV LLAMA_ARG_THREADS=-1
ENV LLAMA_LOG_COLORS=1
ENV LLAMA_LOG_PREFIX=1

# Config for loaded llama.cpp model
ENV LLAMA_ARG_MODEL="/home/developer/models/$HF_REPO_ID/$HF_MODEL"
ENV LLAMA_ARG_CTX_SIZE=98274
ENV LLAMA_ARG_N_PREDICT=-1
ENV LLAMA_ARG_N_GPU_LAYERS=49
ENV LLAMA_ARG_NO_CONTEXT_SHIFT=1
ENV LLAMA_ARG_FLASH_ATTN=1
ENV LLAMA_ARG_CACHE_TYPE_K=q8_0
ENV LLAMA_ARG_CACHE_TYPE_V=q8_0
ENV LLAMA_ARG_SPLIT_MODE=row
ENV LLAMA_SAMPLING_TEMPERATURE=0.7
ENV LLAMA_SAMPLING_MIN_P=0
ENV LLAMA_SAMPLING_TOP_P=0.80
ENV LLAMA_SAMPLING_TOP_K=20
ENV LLAMA_SAMPLING_REPETITION_PENALTY=1.05

# Config for Qwen Code
ENV OPENAI_API_KEY="$LLAMA_API_KEY"
ENV OPENAI_BASE_URL="http://${LLAMA_ARG_HOST}:${LLAMA_ARG_PORT}"
ENV OPENAI_MODEL="$HF_MODEL"

COPY --chown=developer:developer entrypoint.sh /home/developer/entrypoint.sh
COPY --chown=developer:developer hf_download.py /home/developer/hf_download.py
COPY --chown=developer:developer test_openai.sh /home/developer/test_openai.sh

# Required to make tiktoken tokenizer to work offline
ARG TIKTOKEN_URL="https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken"
ENV TIKTOKEN_CACHE_DIR="/home/developer/.tiktoken/"
ADD --chown=developer:developer $TIKTOKEN_URL $TIKTOKEN_CACHE_DIR/9b5ad71b2ce5302211f9c61530b329a4922fc6a4

# Disables google telemetry
COPY --chown=developer:developer settings.json /home/developer/.qwen/

ENTRYPOINT [ "/home/developer/entrypoint.sh" ]
