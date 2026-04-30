#include "{{PROJECT_NAME}}/version.hpp"

#include <chrono>
#include <iostream>

int main() {
    constexpr int iterations = 1'000'000;
    volatile int sink = 0;
    const auto start = std::chrono::steady_clock::now();
    for (int index = 0; index < iterations; ++index) {
        sink += {{CPP_NAMESPACE}}::add(index, 1);
    }
    const auto stop = std::chrono::steady_clock::now();
    const auto elapsed_us =
        std::chrono::duration_cast<std::chrono::microseconds>(stop - start).count();
    std::cout << "benchmark_smoke iterations=" << iterations << " elapsed_us=" << elapsed_us
              << " sink=" << sink << '\n';
    return 0;
}
