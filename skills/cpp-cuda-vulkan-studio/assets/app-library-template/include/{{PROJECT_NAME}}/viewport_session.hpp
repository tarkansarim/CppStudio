#pragma once

#include <cstdint>
#include <filesystem>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace {{CPP_NAMESPACE}} {

enum class ViewportSessionEventType {
    wait,
    mouse_move,
    mouse_press,
    mouse_release,
    key_press,
    tool_change,
    camera_state,
    snapshot,
    probe,
    assert_state,
};

struct ViewportSessionPoint {
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;
};

struct ViewportSessionEvent {
    double time_ms = 0.0;
    ViewportSessionEventType type = ViewportSessionEventType::wait;
    std::string input_surface = "viewport";
    ViewportSessionPoint screen_point;
    ViewportSessionPoint viewport_point;
    double device_pixel_ratio = 1.0;
    bool primary_button_down = false;
    bool shift_down = false;
    bool ctrl_down = false;
    bool alt_down = false;
    double pressure = 0.0;
    double tilt_x = 0.0;
    double tilt_y = 0.0;
    double twist = 0.0;
    std::string value;
    std::string note;
};

struct ViewportSessionState {
    std::string active_tool = "none";
    std::string focus_surface = "none";
    int viewport_width = 0;
    int viewport_height = 0;
    double device_pixel_ratio = 1.0;
    std::uint64_t scene_revision = 0;
    std::uint64_t render_revision = 0;
    std::optional<ViewportSessionPoint> last_hit_point;
};

struct ViewportSessionActionResult {
    bool ok = true;
    std::string message = "ok";
};

struct ViewportSessionReport {
    bool ok = false;
    std::string scenario_id;
    std::string message;
    std::size_t steps_executed = 0;
    ViewportSessionState before;
    ViewportSessionState after;
    std::vector<std::filesystem::path> artifacts;
};

class ViewportSessionHost {
  public:
    virtual ~ViewportSessionHost() = default;

    virtual ViewportSessionState read_state() const = 0;
    virtual ViewportSessionActionResult dispatch_event(const ViewportSessionEvent& event) = 0;
    virtual ViewportSessionActionResult capture_viewport(const std::filesystem::path& path) = 0;
    virtual ViewportSessionActionResult run_probe(std::string_view probe_name) = 0;
};

std::string_view to_string(ViewportSessionEventType type);
ViewportSessionEventType viewport_session_event_type_from_string(std::string_view text);

std::vector<ViewportSessionEvent> default_viewport_session_smoke_events();
void write_viewport_session_events_jsonl(const std::filesystem::path& path,
                                         const std::vector<ViewportSessionEvent>& events);
std::vector<ViewportSessionEvent>
read_viewport_session_events_jsonl(const std::filesystem::path& path);

ViewportSessionReport replay_viewport_session(ViewportSessionHost& host, std::string scenario_id,
                                              const std::vector<ViewportSessionEvent>& events,
                                              const std::filesystem::path& artifact_dir);

void write_viewport_session_report(const std::filesystem::path& path,
                                   const ViewportSessionReport& report);

ViewportSessionReport
run_viewport_session_fake_host_smoke(const std::filesystem::path& artifact_dir);

} // namespace {{CPP_NAMESPACE}}
