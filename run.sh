docker run -ti --rm --name qwen-code-local --network=host -v $PWD/models:/home/developer/models -v $PWD/workspace:/home/developer/workspace qwen-code-local:llama.cpp
