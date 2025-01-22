

source /opt/intel/oneapi/setvars.sh
./bin/llama-server --model granite-code:3b --model-url ollama://granite-code:3b --host 0.0.0.0
