# Host Toolchain Setup

Use this reference only when a machine needs to build generated C++ projects, run sanitizer lanes, or
exercise Vulkan/CUDA lanes. Installing CppStudio as a Codex skill does not require these GPU
toolchains.

Primary vendor references:

- CUDA Linux: <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/>
- CUDA Windows: <https://docs.nvidia.com/cuda/cuda-installation-guide-microsoft-windows/>
- CUDA quick start: <https://docs.nvidia.com/cuda/cuda-quick-start-guide/>
- Vulkan SDK: <https://vulkan.lunarg.com/>
- Vulkan SDK overview: <https://www.lunarg.com/home/vulkan-sdk/>
- Clang AddressSanitizer: <https://clang.llvm.org/docs/AddressSanitizer.html>
- Clang UndefinedBehaviorSanitizer: <https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html>
- MSVC AddressSanitizer: <https://learn.microsoft.com/en-us/cpp/sanitizers/asan>

## Ubuntu 24.04 / WSL2

This block was tested in Docker against `ubuntu:24.04` on May 1, 2026 for package availability and
GCC/Clang ASan+UBSan smoke links. Docker cannot validate a real GPU driver, display server, or
hardware-backed Vulkan ICD, so run the verification commands on the real host too.

Install baseline C++ build, formatting, debugging, and CPU sanitizer tooling:

```bash
sudo apt update
sudo apt install -y --no-install-recommends \
  build-essential cmake ninja-build git rsync pkg-config \
  python3 python3-venv ca-certificates curl wget xz-utils \
  clang llvm lld clang-format clang-tidy libclang-rt-18-dev gdb
```

`libclang-rt-18-dev` is required on Ubuntu 24.04 for Clang AddressSanitizer and UBSan links. GCC
sanitizer smoke builds worked with the `build-essential` runtime set; Clang sanitizer smoke builds
failed without the Clang runtime package.

Install the LunarG Vulkan SDK for Vulkan 1.3 or newer headers, shader tools, validation layers, and SDK
environment variables:

```bash
sudo apt install -y --no-install-recommends \
  libvulkan1 libxcb1 libx11-6 libxrandr2 libwayland-client0

VULKAN_SDK_VERSION="$(curl -fsSL https://vulkan.lunarg.com/sdk/latest/linux.txt)"
curl -fL -o /tmp/vulkan-sdk.tar.xz \
  "https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}/linux/vulkan_sdk.tar.xz"

mkdir -p "${HOME}/vulkan"
tar -xf /tmp/vulkan-sdk.tar.xz -C "${HOME}/vulkan"

. "${HOME}/vulkan/${VULKAN_SDK_VERSION}/setup-env.sh"
VULKAN_SETUP_LINE="source \"${HOME}/vulkan/${VULKAN_SDK_VERSION}/setup-env.sh\""
grep -qxF "${VULKAN_SETUP_LINE}" "${HOME}/.bashrc" || echo "${VULKAN_SETUP_LINE}" >> "${HOME}/.bashrc"

glslc --version
spirv-val --version
vulkaninfo --summary
```

The latest Linux SDK endpoint resolved to `1.4.341.1` during the Docker check. Ubuntu 24.04 distro
packages such as `glslc`, `spirv-tools`, `vulkan-tools`, and `libvulkan-dev` installed successfully,
and their Vulkan header version was `275` from a Vulkan 1.3-era package set. The generated template
targets Vulkan 1.3, but the LunarG SDK above is still the preferred route when you want matching SDK
tools, validation layers, and current diagnostics.

Install CUDA Toolkit on a real Ubuntu 24.04 host:

```bash
sudo apt update
sudo apt install -y --no-install-recommends ca-certificates wget

wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb \
  -O /tmp/cuda-keyring_1.1-1_all.deb
sudo dpkg -i /tmp/cuda-keyring_1.1-1_all.deb

sudo apt update
sudo apt install -y cuda-toolkit

grep -qxF 'export PATH=/usr/local/cuda/bin:${PATH}' "${HOME}/.bashrc" || \
  echo 'export PATH=/usr/local/cuda/bin:${PATH}' >> "${HOME}/.bashrc"
grep -qxF 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' "${HOME}/.bashrc" || \
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> "${HOME}/.bashrc"

export PATH=/usr/local/cuda/bin:${PATH}
export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

nvcc --version
compute-sanitizer --version
```

The CUDA APT repository check was tested in Docker for Ubuntu 24.04; `cuda-toolkit` resolved to
`13.2.1-1` and `cuda-toolkit-13-0` was available for projects that need to pin a major toolkit line.
Install or update the NVIDIA display driver on the real host before CUDA validation. On WSL2, install
the Windows NVIDIA driver on Windows and do not install Linux display-driver packages inside WSL.

For a native Ubuntu host, choose one driver path deliberately:

```bash
# Ubuntu-managed driver path:
sudo apt install -y ubuntu-drivers-common
ubuntu-drivers devices
sudo ubuntu-drivers install
sudo reboot

# Or NVIDIA CUDA repository driver path, after installing cuda-keyring above:
# sudo apt install -y cuda-drivers
# sudo reboot
```

After reboot, verify the host:

```bash
nvidia-smi
nvcc --version
compute-sanitizer --version
```

## macOS

Install baseline native tooling with Homebrew:

```bash
xcode-select --install
brew install cmake ninja git rsync python llvm lld
```

Install the LunarG macOS Vulkan SDK:

```bash
VULKAN_SDK_VERSION="$(curl -fsSL https://vulkan.lunarg.com/sdk/latest/mac.txt)"
curl -fL -o "${HOME}/Downloads/vulkan-sdk-${VULKAN_SDK_VERSION}-macos.zip" \
  "https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}/mac/vulkan_sdk.zip"
open "${HOME}/Downloads/vulkan-sdk-${VULKAN_SDK_VERSION}-macos.zip"
```

Run the SDK installer from the opened archive, then open a new shell and verify:

```bash
glslc --version
spirv-val --version
vulkaninfo --summary
```

CUDA lanes are not a normal local target on modern macOS. Use Linux, Windows, WSL2, or a remote
NVIDIA machine for CUDA validation.

## Windows

This block was checked from Linux on May 1, 2026 by querying the current `microsoft/winget-pkgs`
manifests for package identifiers and by checking live LunarG and NVIDIA installer endpoints. It
still must be executed and verified on a real Windows host because this repo cannot run Windows
installers from Linux.

Install baseline native tooling from an elevated PowerShell session:

```powershell
winget source update

$WingetPackages = @(
  "Microsoft.VisualStudio.2022.BuildTools",
  "Kitware.CMake",
  "Ninja-build.Ninja",
  "Git.Git",
  "Python.Python.3.12",
  "LLVM.LLVM"
)

foreach ($PackageId in $WingetPackages) {
  winget show -e --id $PackageId --source winget
}

winget install -e --id Microsoft.VisualStudio.2022.BuildTools --source winget `
  --accept-source-agreements --accept-package-agreements `
  --override "--wait --quiet --norestart --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Component.VC.CMake.Project --includeRecommended"

winget install -e --id Kitware.CMake --source winget --accept-source-agreements --accept-package-agreements
winget install -e --id Ninja-build.Ninja --source winget --accept-source-agreements --accept-package-agreements
winget install -e --id Git.Git --source winget --accept-source-agreements --accept-package-agreements
winget install -e --id Python.Python.3.12 --source winget --accept-source-agreements --accept-package-agreements
winget install -e --id LLVM.LLVM --source winget --accept-source-agreements --accept-package-agreements
```

MSVC AddressSanitizer is the default Windows CPU sanitizer path. Use LLVM or WSL2 when you need
Clang/GCC-style sanitizer behavior.

Install the LunarG Windows Vulkan SDK:

```powershell
$VulkanSdkVersion = (Invoke-WebRequest -UseBasicParsing https://vulkan.lunarg.com/sdk/latest/windows.txt).Content.Trim()
$VulkanInstaller = Join-Path $env:TEMP "vulkan-sdk-$VulkanSdkVersion.exe"
Invoke-WebRequest -UseBasicParsing `
  -OutFile $VulkanInstaller `
  "https://sdk.lunarg.com/sdk/download/$VulkanSdkVersion/windows/vulkan_sdk.exe"
Start-Process -Wait $VulkanInstaller
```

Open a new Developer PowerShell and verify:

```powershell
glslc --version
spirv-val --version
vulkaninfo --summary
```

Install CUDA Toolkit and the NVIDIA driver:

```powershell
winget show -e --id Nvidia.CUDA --source winget
winget install -e --id Nvidia.CUDA --source winget --accept-source-agreements --accept-package-agreements
```

The `Nvidia.CUDA` winget manifest resolved to CUDA `13.2` with NVIDIA's
`cuda_13.2.1_windows.exe` local installer during the manifest check. The NVIDIA Windows guide also
supports the graphical CUDA installer and silent installer flags. After installation, open a new
Developer PowerShell and verify:

```powershell
nvidia-smi
nvcc --version
compute-sanitizer --version
```

## Verify Active Tools

After installing GPU tools, verify the active shell before troubleshooting a generated project:

```bash
cmake --version
ninja --version
c++ --version
glslc --version
spirv-val --version
vulkaninfo --summary
nvcc --version
compute-sanitizer --version
```

Run only the commands that apply to the active lane. For example, Vulkan-only projects do not need
`nvcc` or Compute Sanitizer. Generated projects also include `scripts/check_dev_tools.sh` for a
project-local tool availability report.
