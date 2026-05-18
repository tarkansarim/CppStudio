#include "{{PROJECT_NAME}}/viewport_session.hpp"

#include <filesystem>
#include <iostream>

int main() {
    const auto output_dir =
        std::filesystem::temp_directory_path() / "{{PROJECT_NAME_LOWER}}_viewport_session_test";
    std::filesystem::remove_all(output_dir);

    const auto report = {{CPP_NAMESPACE}}::run_viewport_session_fake_host_smoke(output_dir);
    if (!report.ok) {
        std::cerr << "viewport session smoke failed: " << report.message << '\n';
        return 1;
    }
    if (report.steps_executed != {{CPP_NAMESPACE}}::default_viewport_session_smoke_events().size()) {
        std::cerr << "unexpected viewport session step count\n";
        return 2;
    }

    const auto events_path = output_dir / "events.jsonl";
    const auto report_path = output_dir / "report.json";
    const auto capture_path = output_dir / "captures" / "final.ppm";
    if (!std::filesystem::is_regular_file(events_path) ||
        !std::filesystem::is_regular_file(report_path) ||
        !std::filesystem::is_regular_file(capture_path)) {
        std::cerr << "viewport session artifacts missing\n";
        return 3;
    }

    const auto events = {{CPP_NAMESPACE}}::read_viewport_session_events_jsonl(events_path);
    if (events.empty() ||
        events.front().type != {{CPP_NAMESPACE}}::ViewportSessionEventType::tool_change) {
        std::cerr << "viewport session events did not round-trip\n";
        return 4;
    }
    if (report.after.active_tool != "primary_tool" || !report.after.last_hit_point.has_value()) {
        std::cerr << "viewport session did not commit visible tool state\n";
        return 5;
    }

    return 0;
}
