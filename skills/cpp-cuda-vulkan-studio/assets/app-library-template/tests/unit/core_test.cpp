#include "{{PROJECT_NAME}}/version.hpp"

#include <iostream>

int main() {
    if ({{CPP_NAMESPACE}}::project_name().empty()) {
        std::cerr << "project_name must not be empty\n";
        return 1;
    }
    if ({{CPP_NAMESPACE}}::add(19, 23) != 42) {
        std::cerr << "add contract failed\n";
        return 1;
    }
    return 0;
}
