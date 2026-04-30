#include "{{PROJECT_NAME}}/version.hpp"

namespace {{CPP_NAMESPACE}} {

std::string_view project_name() {
    return "{{PROJECT_NAME}}";
}

int add(int lhs, int rhs) {
    return lhs + rhs;
}

} // namespace {{CPP_NAMESPACE}}
