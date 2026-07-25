<div align="center">
  <img src="figures/logo-100.png" alt="KUik Logo" width="100" />
  <h1>KUik</h1>
  <p><strong>A high-performance, native desktop application for streaming movies directly to your screen. Built natively with C++20, Qt 6.7+, and CMake.</strong></p>
  
  <p>
    <img src="https://img.shields.io/badge/C++-00599C?style=for-the-badge&logo=cplusplus&logoColor=white" alt="C++" />
    <img src="https://img.shields.io/badge/Qt-41CD52?style=for-the-badge&logo=qt&logoColor=white" alt="Qt" />
    <img src="https://img.shields.io/badge/CMake-064F8C?style=for-the-badge&logo=cmake&logoColor=white" alt="CMake" />
    <img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License" />
  </p>
</div>

<br />

## Preview

<div align="center">
  <img src="figures/home_page.png" alt="Home Screen Preview" width="100%" />
</div>

<br />

## Features

### Core Streaming & Playback
- **Direct Network Streaming:** Native HTTP/HTTPS playback of HLS adaptive bitrate streams straight from the Internet Archive.
- **Hardware Acceleration:** Buttery smooth video rendering using Qt Multimedia, entirely bypassing the need for a web browser engine.
- **Advanced Controls:** Complete control suite including timeline seeking, volume management, and a seamless full-screen mode.

### Catalogue & User Experience
- **Live TMDB Integration:** Instantly fetches high-quality poster artwork, release metadata, and movie synopses in real-time.
- **Dynamic Search Engine:** Instantly filter the expansive movie database by title, keyword, or genre.
- **Local Account Management:** Securely creates and stores user profiles on the local machine.
- **Persistent Watch History:** Automatically tracks and saves your viewing history across application restarts.

<br />

## Requirements

The following dependencies are required to build the project from source:

- **Qt 6.7+** (Ensure Widgets, QML, Multimedia, and Network modules are checked)
- **CMake 3.25+**
- **Git**
- **vcpkg** (For C++ dependency management)
- **Visual Studio 2022+** or **MinGW**

<br />

## Team

| Member | GitHub |
| :--- | :--- |
| **Mandeep Dahal** | [@mandeep-03-git](https://github.com/mandeep-03-git) |
| **Roshan Ghimire** | [@roshan9-git](https://github.com/roshan9-git) |
| **Aryan Humagain** | [@LinuxRyn](https://github.com/LinuxRyn) |
| **Saksham Kandel** | [@S1ksh1m](https://github.com/S1ksh1m) |
| **Kaushtuv Khadka** | [@kaushtuvkhadka](https://github.com/kaushtuvkhadka) |

<br />

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/kaushtuvkhadka/kuik.git
   cd kuik
   ```

2. **Configure and build using CMake**
   ```bash
   cmake -S . -B build -DCMAKE_TOOLCHAIN_FILE=[path/to/vcpkg]/scripts/buildsystems/vcpkg.cmake
   cmake --build build
   ```

3. **Launch the application**
   ```bash
   ./build/bin/Debug/KUik.exe
   ```

> *Alternatively, open `CMakeLists.txt` directly in Qt Creator, let it automatically configure the project with your selected desktop kit, and click Run.*

<br />

## Documentation

- **[System Architecture](figures/system_architecture.jpg)** : High-level separation of the QML Frontend, C++ Backend, and External APIs.
- **[UML Use Cases](figures/use_case_diagram.jpg)** : Core interactions between Users, the Application, and External Services.
- **Project Report** : The comprehensive academic report detailing requirements, methodology, and results is available in the final release bundle.

<br />

## License

<details>
<summary>Click to view the full MIT License</summary>
<br>

MIT License

Copyright (c) 2026 KUik Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

</details>
