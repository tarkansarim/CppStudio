#include "{{PROJECT_NAME}}/viewport_session.hpp"

#include <algorithm>
#include <charconv>
#include <cstdint>
#include <fstream>
#include <sstream>
#include <stdexcept>

namespace {{CPP_NAMESPACE}} {
namespace {

std::string json_escape(std::string_view text) {
    std::string escaped;
    escaped.reserve(text.size() + 8);
    for (const char ch : text) {
        switch (ch) {
        case '\\':
            escaped += "\\\\";
            break;
        case '"':
            escaped += "\\\"";
            break;
        case '\n':
            escaped += "\\n";
            break;
        case '\r':
            escaped += "\\r";
            break;
        case '\t':
            escaped += "\\t";
            break;
        default:
            escaped += ch;
            break;
        }
    }
    return escaped;
}

std::string json_string(std::string_view key, std::string_view value) {
    return "\"" + std::string(key) + "\":\"" + json_escape(value) + "\"";
}

std::string json_number(std::string_view key, double value) {
    std::ostringstream out;
    out << "\"" << key << "\":" << value;
    return out.str();
}

std::string json_bool(std::string_view key, bool value) {
    return "\"" + std::string(key) + "\":" + (value ? "true" : "false");
}

std::string json_uint(std::string_view key, std::uint64_t value) {
    return "\"" + std::string(key) + "\":" + std::to_string(value);
}

std::string state_json(const ViewportSessionState& state) {
    std::ostringstream out;
    out << "{" << json_string("active_tool", state.active_tool) << ","
        << json_string("focus_surface", state.focus_surface) << ","
        << "\"viewport_width\":" << state.viewport_width << ","
        << "\"viewport_height\":" << state.viewport_height << ","
        << json_number("device_pixel_ratio", state.device_pixel_ratio) << ","
        << json_uint("scene_revision", state.scene_revision) << ","
        << json_uint("render_revision", state.render_revision);
    if (state.last_hit_point.has_value()) {
        out << ",\"last_hit_point\":{" << json_number("x", state.last_hit_point->x) << ","
            << json_number("y", state.last_hit_point->y) << ","
            << json_number("z", state.last_hit_point->z) << "}";
    }
    out << "}";
    return out.str();
}

std::string point_json(std::string_view key, const ViewportSessionPoint& point) {
    return "\"" + std::string(key) + "\":{" + json_number("x", point.x) + "," +
           json_number("y", point.y) + "," + json_number("z", point.z) + "}";
}

std::string find_json_string(std::string_view line, std::string_view key,
                             std::string_view fallback) {
    const std::string needle = "\"" + std::string(key) + "\":\"";
    const std::size_t start = line.find(needle);
    if (start == std::string_view::npos) {
        return std::string(fallback);
    }
    std::string value;
    bool escaped = false;
    for (std::size_t index = start + needle.size(); index < line.size(); ++index) {
        const char ch = line[index];
        if (escaped) {
            switch (ch) {
            case 'n':
                value.push_back('\n');
                break;
            case 'r':
                value.push_back('\r');
                break;
            case 't':
                value.push_back('\t');
                break;
            default:
                value.push_back(ch);
                break;
            }
            escaped = false;
            continue;
        }
        if (ch == '\\') {
            escaped = true;
            continue;
        }
        if (ch == '"') {
            return value;
        }
        value.push_back(ch);
    }
    return std::string(fallback);
}

double find_json_number(std::string_view line, std::string_view key, double fallback) {
    const std::string needle = "\"" + std::string(key) + "\":";
    const std::size_t start = line.find(needle);
    if (start == std::string_view::npos) {
        return fallback;
    }
    const std::size_t value_start = start + needle.size();
    std::size_t value_end = value_start;
    while (value_end < line.size()) {
        const char ch = line[value_end];
        if ((ch >= '0' && ch <= '9') || ch == '-' || ch == '+' || ch == '.' || ch == 'e' ||
            ch == 'E') {
            ++value_end;
            continue;
        }
        break;
    }
    double value = fallback;
    const auto first = line.data() + value_start;
    const auto last = line.data() + value_end;
    const auto parsed = std::from_chars(first, last, value);
    return parsed.ec == std::errc{} ? value : fallback;
}

bool find_json_bool(std::string_view line, std::string_view key, bool fallback) {
    const std::string needle = "\"" + std::string(key) + "\":";
    const std::size_t start = line.find(needle);
    if (start == std::string_view::npos) {
        return fallback;
    }
    const std::string_view value = line.substr(start + needle.size());
    if (value.starts_with("true")) {
        return true;
    }
    if (value.starts_with("false")) {
        return false;
    }
    return fallback;
}

ViewportSessionPoint find_json_point(std::string_view line, std::string_view key,
                                     const ViewportSessionPoint& fallback) {
    const std::string needle = "\"" + std::string(key) + "\":{";
    const std::size_t start = line.find(needle);
    if (start == std::string_view::npos) {
        return fallback;
    }
    const std::size_t end = line.find('}', start + needle.size());
    const std::string_view object =
        end == std::string_view::npos
            ? line.substr(start + needle.size())
            : line.substr(start + needle.size(), end - (start + needle.size()));
    return {
        find_json_number(object, "x", fallback.x),
        find_json_number(object, "y", fallback.y),
        find_json_number(object, "z", fallback.z),
    };
}

std::string event_json(const ViewportSessionEvent& event) {
    std::ostringstream out;
    out << "{" << json_number("time_ms", event.time_ms) << ","
        << json_string("type", to_string(event.type)) << ","
        << json_string("input_surface", event.input_surface) << ","
        << point_json("screen_point", event.screen_point) << ","
        << point_json("viewport_point", event.viewport_point) << ","
        << json_number("device_pixel_ratio", event.device_pixel_ratio) << ","
        << json_bool("primary_button_down", event.primary_button_down) << ","
        << json_bool("shift_down", event.shift_down) << ","
        << json_bool("ctrl_down", event.ctrl_down) << "," << json_bool("alt_down", event.alt_down)
        << "," << json_number("pressure", event.pressure) << ","
        << json_number("tilt_x", event.tilt_x) << "," << json_number("tilt_y", event.tilt_y) << ","
        << json_number("twist", event.twist) << "," << json_string("value", event.value) << ","
        << json_string("note", event.note) << "}";
    return out.str();
}

void write_text_file(const std::filesystem::path& path, std::string_view text) {
    if (!path.parent_path().empty()) {
        std::filesystem::create_directories(path.parent_path());
    }
    std::ofstream file(path);
    if (!file) {
        throw std::runtime_error("failed to write file: " + path.string());
    }
    file << text;
}

class FakeViewportSessionHost final : public ViewportSessionHost {
  public:
    ViewportSessionState read_state() const override { return state_; }

    ViewportSessionActionResult dispatch_event(const ViewportSessionEvent& event) override {
        ++state_.scene_revision;
        ++state_.render_revision;
        state_.device_pixel_ratio = event.device_pixel_ratio;
        if (event.type == ViewportSessionEventType::tool_change) {
            state_.active_tool = event.value.empty() ? "unknown" : event.value;
        }
        if (event.type == ViewportSessionEventType::mouse_press ||
            event.type == ViewportSessionEventType::mouse_move ||
            event.type == ViewportSessionEventType::mouse_release) {
            state_.focus_surface = event.input_surface;
            state_.last_hit_point = event.viewport_point;
        }
        if (event.type == ViewportSessionEventType::probe && event.value == "fail") {
            return {false, "fake host probe failed"};
        }
        return {true, "ok"};
    }

    ViewportSessionActionResult capture_viewport(const std::filesystem::path& path) override {
        std::filesystem::create_directories(path.parent_path());
        std::ofstream file(path, std::ios::binary);
        if (!file) {
            return {false, "failed to open capture path"};
        }
        file << "P3\n4 4\n255\n";
        for (int index = 0; index < 16; ++index) {
            const int blue = 32 + ((index + static_cast<int>(state_.render_revision)) % 12) * 16;
            file << "0 96 " << blue << "\n";
        }
        return {true, "ok"};
    }

    ViewportSessionActionResult run_probe(std::string_view probe_name) override {
        if (probe_name.empty()) {
            return {false, "probe name is empty"};
        }
        return {true, "ok"};
    }

  private:
    ViewportSessionState state_{
        .active_tool = "select",
        .focus_surface = "viewport",
        .viewport_width = 1280,
        .viewport_height = 720,
        .device_pixel_ratio = 1.0,
        .scene_revision = 1,
        .render_revision = 1,
        .last_hit_point = std::nullopt,
    };
};

} // namespace

std::string_view to_string(ViewportSessionEventType type) {
    switch (type) {
    case ViewportSessionEventType::wait:
        return "wait";
    case ViewportSessionEventType::mouse_move:
        return "mouse_move";
    case ViewportSessionEventType::mouse_press:
        return "mouse_press";
    case ViewportSessionEventType::mouse_release:
        return "mouse_release";
    case ViewportSessionEventType::key_press:
        return "key_press";
    case ViewportSessionEventType::tool_change:
        return "tool_change";
    case ViewportSessionEventType::camera_state:
        return "camera_state";
    case ViewportSessionEventType::snapshot:
        return "snapshot";
    case ViewportSessionEventType::probe:
        return "probe";
    case ViewportSessionEventType::assert_state:
        return "assert_state";
    }
    return "wait";
}

ViewportSessionEventType viewport_session_event_type_from_string(std::string_view text) {
    if (text == "mouse_move") {
        return ViewportSessionEventType::mouse_move;
    }
    if (text == "mouse_press") {
        return ViewportSessionEventType::mouse_press;
    }
    if (text == "mouse_release") {
        return ViewportSessionEventType::mouse_release;
    }
    if (text == "key_press") {
        return ViewportSessionEventType::key_press;
    }
    if (text == "tool_change") {
        return ViewportSessionEventType::tool_change;
    }
    if (text == "camera_state") {
        return ViewportSessionEventType::camera_state;
    }
    if (text == "snapshot") {
        return ViewportSessionEventType::snapshot;
    }
    if (text == "probe") {
        return ViewportSessionEventType::probe;
    }
    if (text == "assert_state") {
        return ViewportSessionEventType::assert_state;
    }
    return ViewportSessionEventType::wait;
}

std::vector<ViewportSessionEvent> default_viewport_session_smoke_events() {
    ViewportSessionEvent tool;
    tool.time_ms = 0.0;
    tool.type = ViewportSessionEventType::tool_change;
    tool.value = "primary_tool";

    ViewportSessionEvent press;
    press.time_ms = 8.0;
    press.type = ViewportSessionEventType::mouse_press;
    press.screen_point = {320.0, 240.0, 0.0};
    press.viewport_point = {0.0, 0.0, 0.0};
    press.primary_button_down = true;
    press.pressure = 0.75;
    press.note = "begin user-equivalent viewport edit";

    ViewportSessionEvent move;
    move.time_ms = 16.0;
    move.type = ViewportSessionEventType::mouse_move;
    move.screen_point = {360.0, 260.0, 0.0};
    move.viewport_point = {0.15, 0.05, 0.0};
    move.primary_button_down = true;
    move.pressure = 0.8;

    ViewportSessionEvent release;
    release.time_ms = 24.0;
    release.type = ViewportSessionEventType::mouse_release;
    release.screen_point = {380.0, 280.0, 0.0};
    release.viewport_point = {0.2, 0.1, 0.0};
    release.note = "end user-equivalent viewport edit";

    ViewportSessionEvent snapshot;
    snapshot.time_ms = 32.0;
    snapshot.type = ViewportSessionEventType::snapshot;
    snapshot.value = "final";

    return {tool, press, move, release, snapshot};
}

void write_viewport_session_events_jsonl(const std::filesystem::path& path,
                                         const std::vector<ViewportSessionEvent>& events) {
    std::filesystem::create_directories(path.parent_path());
    std::ofstream file(path);
    if (!file) {
        throw std::runtime_error("failed to write events: " + path.string());
    }
    for (const auto& event : events) {
        file << event_json(event) << '\n';
    }
}

std::vector<ViewportSessionEvent>
read_viewport_session_events_jsonl(const std::filesystem::path& path) {
    std::ifstream file(path);
    if (!file) {
        throw std::runtime_error("failed to read events: " + path.string());
    }
    std::vector<ViewportSessionEvent> events;
    std::string line;
    while (std::getline(file, line)) {
        if (line.empty()) {
            continue;
        }
        ViewportSessionEvent event;
        event.time_ms = find_json_number(line, "time_ms", 0.0);
        event.type =
            viewport_session_event_type_from_string(find_json_string(line, "type", "wait"));
        event.input_surface = find_json_string(line, "input_surface", "viewport");
        event.screen_point = find_json_point(line, "screen_point", {});
        event.viewport_point = find_json_point(line, "viewport_point", {});
        event.device_pixel_ratio = find_json_number(line, "device_pixel_ratio", 1.0);
        event.primary_button_down = find_json_bool(line, "primary_button_down", false);
        event.shift_down = find_json_bool(line, "shift_down", false);
        event.ctrl_down = find_json_bool(line, "ctrl_down", false);
        event.alt_down = find_json_bool(line, "alt_down", false);
        event.pressure = find_json_number(line, "pressure", 0.0);
        event.tilt_x = find_json_number(line, "tilt_x", 0.0);
        event.tilt_y = find_json_number(line, "tilt_y", 0.0);
        event.twist = find_json_number(line, "twist", 0.0);
        event.value = find_json_string(line, "value", "");
        event.note = find_json_string(line, "note", "");
        events.push_back(std::move(event));
    }
    std::sort(events.begin(), events.end(),
              [](const auto& lhs, const auto& rhs) { return lhs.time_ms < rhs.time_ms; });
    return events;
}

ViewportSessionReport replay_viewport_session(ViewportSessionHost& host, std::string scenario_id,
                                              const std::vector<ViewportSessionEvent>& events,
                                              const std::filesystem::path& artifact_dir) {
    std::filesystem::create_directories(artifact_dir);
    std::filesystem::create_directories(artifact_dir / "captures");

    ViewportSessionReport report;
    report.scenario_id = std::move(scenario_id);
    report.before = host.read_state();
    write_text_file(artifact_dir / "state_initial.json", state_json(report.before) + "\n");

    for (const auto& event : events) {
        if (event.type == ViewportSessionEventType::snapshot) {
            const auto capture_path = artifact_dir / "captures" /
                                      (event.value.empty() ? "snapshot.ppm" : event.value + ".ppm");
            const auto capture = host.capture_viewport(capture_path);
            if (!capture.ok) {
                report.message = capture.message;
                report.after = host.read_state();
                report.artifacts.push_back(capture_path);
                return report;
            }
            report.artifacts.push_back(capture_path);
        } else if (event.type == ViewportSessionEventType::probe) {
            const auto probe = host.run_probe(event.value);
            if (!probe.ok) {
                report.message = probe.message;
                report.after = host.read_state();
                return report;
            }
        } else {
            const auto result = host.dispatch_event(event);
            if (!result.ok) {
                report.message = result.message;
                report.after = host.read_state();
                return report;
            }
        }
        ++report.steps_executed;
    }

    report.after = host.read_state();
    write_text_file(artifact_dir / "state_final.json", state_json(report.after) + "\n");
    report.ok = report.after.render_revision > report.before.render_revision &&
                report.after.focus_surface == "viewport";
    report.message = report.ok ? "ok" : "session replay did not advance visible viewport state";
    return report;
}

void write_viewport_session_report(const std::filesystem::path& path,
                                   const ViewportSessionReport& report) {
    std::ostringstream out;
    out << "{\n"
        << "  \"ok\": " << (report.ok ? "true" : "false") << ",\n"
        << "  " << json_string("scenario_id", report.scenario_id) << ",\n"
        << "  " << json_string("message", report.message) << ",\n"
        << "  \"steps_executed\": " << report.steps_executed << ",\n"
        << "  \"before\": " << state_json(report.before) << ",\n"
        << "  \"after\": " << state_json(report.after) << ",\n"
        << "  \"artifacts\": [";
    for (std::size_t index = 0; index < report.artifacts.size(); ++index) {
        if (index != 0) {
            out << ", ";
        }
        out << "\"" << json_escape(report.artifacts[index].generic_string()) << "\"";
    }
    out << "]\n}\n";
    write_text_file(path, out.str());
}

ViewportSessionReport
run_viewport_session_fake_host_smoke(const std::filesystem::path& artifact_dir) {
    std::filesystem::create_directories(artifact_dir);
    const auto events = default_viewport_session_smoke_events();
    write_text_file(artifact_dir / "metadata.json", "{\n  \"schema_version\": 1,\n  \"producer\": "
                                                    "\"{{PROJECT_NAME_LOWER}}_viewport_session_smoke\",\n"
                                                    "  \"scenario_id\": \"fake-host-smoke\"\n}\n");
    write_viewport_session_events_jsonl(artifact_dir / "events.jsonl", events);

    FakeViewportSessionHost host;
    auto report = replay_viewport_session(host, "fake-host-smoke", events, artifact_dir);
    write_viewport_session_report(artifact_dir / "report.json", report);
    return report;
}

} // namespace {{CPP_NAMESPACE}}
