# Qwen Code Local Development Environment

This project provides a Docker-based local development environment for running Qwen Code models using llama.cpp.

## Overview

The Qwen Code Local Development Environment runs the Qwen3-Coder-30B-A3B-Instruct model using Docker. It provides an OpenAI-compatible API for code generation tasks and can be run completely offline after initial setup.

## Key Features

- **Local Execution**: Run code generation models entirely locally without internet access after initial download
- **Docker-based**: Consistent environment across different systems
- **OpenAI API Compatible**: Works with tools expecting an OpenAI-compatible API
- **Offline Support**: Once model is downloaded, can run completely offline

## Requirements

- Docker Engine (version 20.10 or higher)
- At least 18GB of free disk space for the model
- For GPU acceleration: NVIDIA GPU with CUDA support and nvidia-docker2
- Internet connection for initial model download (subsequent runs can be offline)

> Note: The current settings are targeted for a GPU with 24GB VRAM or more. The code was tested on an RTX 3090. If you have less VRAM available, you'll need to adjust the following settings in the Dockerfile:
> - `LLAMA_ARG_N_GPU_LAYERS`
> - `LLAMA_ARG_CTX_SIZE`
> - `LLAMA_ARG_N_PREDICT`

## Components

### Docker Image

The Docker image is built from `Dockerfile` and includes:

- llama.cpp server
- Node.js and npm for Qwen Code
- Python dependencies for Hugging Face Hub access
- Developer user with appropriate permissions

### Model

Uses the Qwen3-Coder-30B-A3B-Instruct model (quantized to Q4_K_XL) from Hugging Face.

### Scripts

1. `build.sh` - Builds the Docker image
2. `run.sh` - Runs the container with host networking
3. `run_offline.sh` - Runs the container with no network access
4. `test_openai.sh` - Tests that the API is working correctly
5. `view_llama_server.sh` - Opens a terminal session to the running llama.cpp server container
   To detach from the tmux session, press `Ctrl-b` followed by `d`

## Usage

### Building the Image

```bash
./build.sh
```

### Running the Container

For host networking (required to download model on first run):
```bash
./run.sh
```

For offline mode (no network access):
```bash
./run_offline.sh
```

### Testing

After running the container, test that it's working:
```bash
./test_openai.sh
```

## Configuration

The Dockerfile sets various environment variables for optimal performance:

- Model parameters (context size, prediction count, GPU layers)
- Sampling parameters (temperature, top-p, top-k, presence penalty)
- API endpoint configuration

## Directory Structure

- `/models` - Where the model files are stored
- `/workspace` - Working directory for development

## Notes

- The first run will download the model from Hugging Face (requires internet connection)
- Subsequent runs will use the cached model
- The container will automatically shut down when you exit the terminal

## Troubleshooting

If you encounter issues:
1. Ensure Docker is installed and running
2. Check that you have sufficient disk space for the model (~18GB)
3. Verify network connectivity during initial model download
4. Make sure you're running with appropriate permissions
