#include "{{PROJECT_NAME}}/cuda_vector_add.hpp"

#include <cuda_runtime.h>

#include <array>

namespace {{CPP_NAMESPACE}} {
namespace {

__global__ void vector_add_kernel(const int* lhs, const int* rhs, int* output, int count) {
    const int index = blockIdx.x * blockDim.x + threadIdx.x;
    if (index < count) {
        output[index] = lhs[index] + rhs[index];
    }
}

bool cuda_ok(cudaError_t status) {
    return status == cudaSuccess;
}

} // namespace

bool cuda_vector_add_smoke() {
    constexpr int count = 4;
    const std::array<int, count> lhs = {1, 2, 3, 4};
    const std::array<int, count> rhs = {10, 20, 30, 40};
    std::array<int, count> output = {0, 0, 0, 0};

    int* device_lhs = nullptr;
    int* device_rhs = nullptr;
    int* device_output = nullptr;

    const auto bytes = static_cast<size_t>(count) * sizeof(int);
    bool ok = cuda_ok(cudaMalloc(&device_lhs, bytes)) && cuda_ok(cudaMalloc(&device_rhs, bytes)) &&
              cuda_ok(cudaMalloc(&device_output, bytes)) &&
              cuda_ok(cudaMemcpy(device_lhs, lhs.data(), bytes, cudaMemcpyHostToDevice)) &&
              cuda_ok(cudaMemcpy(device_rhs, rhs.data(), bytes, cudaMemcpyHostToDevice));

    if (ok) {
        vector_add_kernel<<<1, 32>>>(device_lhs, device_rhs, device_output, count);
        ok = cuda_ok(cudaGetLastError()) &&
             cuda_ok(cudaMemcpy(output.data(), device_output, bytes, cudaMemcpyDeviceToHost)) &&
             cuda_ok(cudaDeviceSynchronize());
    }

    cudaFree(device_lhs);
    cudaFree(device_rhs);
    cudaFree(device_output);

    return ok && output[0] == 11 && output[1] == 22 && output[2] == 33 && output[3] == 44;
}

} // namespace {{CPP_NAMESPACE}}
