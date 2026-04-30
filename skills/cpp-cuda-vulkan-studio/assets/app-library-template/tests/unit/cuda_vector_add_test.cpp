#include "{{PROJECT_NAME}}/cuda_vector_add.hpp"

#include <iostream>

int main() {
    if (!{{CPP_NAMESPACE}}::cuda_vector_add_smoke()) {
        std::cerr << "CUDA vector add smoke failed\n";
        return 1;
    }
    return 0;
}
