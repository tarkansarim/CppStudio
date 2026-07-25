# Tool Inventory

Machine inventory refreshed on 2026-03-20 from the local GPU profiling workstation.

## Installed

- `nsys`
  - path: `/usr/local/cuda/bin/nsys`
  - version: `NVIDIA Nsight Systems version 2025.3.2.367-253236224375v0`
- `ncu`
  - path: `/usr/local/cuda/bin/ncu`
  - version: `Version 2025.3.0.0 (build 36273991) (public-release)`
- `compute-sanitizer`
  - path: `/usr/local/cuda/bin/compute-sanitizer`
  - version: `Version 2025.3.0.0 (build 36260728) (public-release)`
- `cuda-gdb`
  - path: `/usr/local/cuda/bin/cuda-gdb`
  - version: `NVIDIA (R) cuda-gdb 13.0`
- `ngfx-ui-for-linux`
  - path: `/usr/bin/ngfx-ui-for-linux`
  - version: `NVIDIA Nsight Graphics 2026.1.0.0 (build 37556978) (public-release)`
- `ngfx-capture`
  - path: `/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-capture`
- `ngfx-replay`
  - path: `/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64/ngfx-replay`
- `renderdoccmd`
  - path: `${HOME}/.local/bin/renderdoccmd`
  - version: `renderdoccmd x64 v1.43 built from 286e07140d96bf3acda4059e085e8f5eb0e92608`
- `qrenderdoc`
  - path: `${HOME}/.local/bin/qrenderdoc`
  - version: `QRenderDoc v1.43 (286e07140d96bf3acda4059e085e8f5eb0e92608)`
- `nvidia-smi`
  - path: `/usr/bin/nvidia-smi`
  - gpu/driver: `NVIDIA RTX PRO 6000 Blackwell Workstation Edition, 580.126.09`
- `perf`
  - path: `/usr/bin/perf`
  - version: `perf version 5.15.178`
- `glxinfo`
  - path: `/usr/bin/glxinfo`

## Missing from PATH

- `nsight-cu`
- `nvprof`
- `vulkaninfo`

## PATH notes

CUDA tools are available through:

- `/usr/local/cuda/bin`
- `/usr/local/cuda-12.2/bin`

Graphics debugger tools are available through:

- `${HOME}/.local/bin`
- `/opt/nvidia/nsight-graphics-for-linux/nsight-graphics-for-linux-2026.1.0.0/host/linux-desktop-nomad-x64`
