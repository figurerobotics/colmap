docker build -t="colmap:latest" --build-arg CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} .
# In some cases, you may have to explicitly specify the compute architecture:
#   docker build -t="colmap:latest" --build-arg CUDA_ARCHITECTURES=75 .
