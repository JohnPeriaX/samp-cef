# SAMP CEF

This project embeds CEF into SA:MP so you can build in-game interfaces with HTML / CSS / JavaScript.

This project is a framework or SDK, not a ready-to-use download. You should have basic JS / HTML / CSS knowledge before building on top of it.

## What You Can Do
- Create browser views from a gamemode or from client-side plugins through the C ABI.
- Place browsers on objects with spatial-like sound.
- Send and receive custom events between server and client.

## Crates
- `cef` - Rust wrappers around the CEF C API.
- `cef-api` - Rust wrappers used to build client plugins with CEF.
- `cef-interface` - Example Rust plugin.
- `cef-sys` - Bindings for the CEF C API.
- `client` - Client CEF plugin.
- `d3dx9` - Bindings for the DirectX SDK.
- `loader` - Small loader that makes it work and should be named `cef.asi`.
- `messages` - Protobuf messages used to communicate with the server.
- `network` - Quinn glue similar to laminar.
- `proto` - Raw proto files.
- `renderer` - Glue between the CEF renderer process and the main logic.
- `server` - Server-side plugin.

## Download
Latest builds from the master branch are available in GitHub Actions.

[GitHub Actions](https://github.com/ZOTTCE/samp-cef/actions)

Current builds are available for these operating systems:

- CentOS 7 (`cef-centos-7.so`)
- Debian 9, 10, 11 (`cef-debian-*.so`)
- Ubuntu 18.04, 20.04 (`cef-ubuntu-*.so`)
- Windows (`cef-windows.dll`)

Client-side artifacts such as `cef.asi`, `client.dll`, and `renderer.exe` are also included.

## Building
### Dependencies
- Install the Rust toolchain pinned in `rust-toolchain.toml` and add the `i686-pc-windows-msvc` target for Windows client builds.
- A prebuilt CEF distribution is required for some client-side features such as streams.
- Set the `CEF_PATH` environment variable to the directory that contains `libcef.lib` if you want to use your own copy.
- Client builds require the DirectX SDK (June 2010), or `DX_SDK` must point to its `Lib/x86` directory.

### Windows Quick Start (Verified)
The steps below were verified to build the current repository on Windows.

1. Install Rustup.

```powershell
winget install -e --id Rustlang.Rustup
```

2. Open a new PowerShell window after installation.

If the current shell still does not see `rustup`, refresh PATH once.

```powershell
$env:Path = ([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User'))
```

3. Install the 32-bit MSVC target.

```powershell
rustup target add i686-pc-windows-msvc
```

4. Install Visual Studio 2022 Build Tools or Visual Studio Community with the `Desktop development with C++` workload.

5. Install the additional native tools required by dependencies.

```powershell
winget install -e --id NASM.NASM
winget install -e --id 7zip.7zip
```

6. Run the build script from the repository root.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

The script performs these steps automatically:
- Downloads `libcef.lib` if `CEF_PATH` is not set.
- Downloads and extracts the DirectX SDK x86 libraries if `DX_SDK` is not set.
- Enables the Visual Studio x86 MSVC developer environment.
- Builds `client`, `renderer`, and `loader` for `i686-pc-windows-msvc`.

Build outputs:
- `target/i686-pc-windows-msvc/release/client.dll`
- `target/i686-pc-windows-msvc/release/loader.dll`
- `target/i686-pc-windows-msvc/release/renderer.exe`

Notes:
- The current repository uses the stable toolchain pinned in `rust-toolchain.toml`; the old `nightly-2022-11-06` toolchain is not required.
- If you already have `libcef.lib`, set `CEF_PATH` to that directory before running the script.
- If you already have the DirectX SDK x86 libraries, set `DX_SDK` to the `Lib/x86` directory.

### Notes
If you hit a linker error, you may need to adjust hard-coded paths in the source.

- `client/build.rs` - Default DirectX SDK path.

### Running Rust
Use this command to build only the server.

```sh
rustup target add i686-pc-windows-msvc
cargo build --release --package server
```

### Building The Windows Client On Windows
Use `scripts/build-client-win32.ps1` to build `client`, `renderer`, and `loader` on a Windows host.

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

### Cross-Compiling The Windows Client (macOS/Linux)
Use `scripts/build-client-win32.sh` to build `client`, `renderer`, and `loader` for `i686-pc-windows-msvc` on non-Windows hosts.

The script relies on `cargo-xwin` (`cargo install cargo-xwin --locked`), `7z` for extracting the DirectX SDK, and downloads `libcef.lib` if `CEF_PATH` is not set.

If you want to use OpenAL instead of `rodio` for audio, build `client` without default features.

```sh
cargo build --release --target i686-pc-windows-msvc --package client --no-default-features
```

Then place `openal.dll` as `sound.dll` inside the `cef` folder.

To build only a specific crate, add `--package <NAME>`.

Building all crates on Linux may fail, so pass `--package server` when you only want the server build.

## CEF Version
Current CEF and Chromium versions are:

`89.0.5+gc1f90d8+chromium-89.0.4389.40` `release branch 4389`

```text
Date:             February 26, 2021

CEF Version:      89.0.5+gc1f90d8+chromium-89.0.4389.40
CEF URL:          https://bitbucket.org/chromiumembedded/cef.git
                  @c1f90d8c933dce163b74971707dbd79f00f18219

Chromium Version: 89.0.4389.40
Chromium URL:     https://chromium.googlesource.com/chromium/src.git
                  @2c3400a2b467aa3cf67b4942740db29e60feecb8
```

## Docs
- [English docs](docs/main_en.md)
- [Build instructions](docs/build.md)
- GitHub wiki

## Video Examples
- https://www.youtube.com/watch?v=Jh9IBlOKoVM (full-screen character demo)
- https://www.youtube.com/watch?v=jU-O8_t1AfI (simple interfaces)
- https://www.youtube.com/watch?v=qs7n8LoVYs4 (custom GTA interface)
- https://www.youtube.com/watch?v=vcyTjn3RJhs (voice chat)
- https://www.youtube.com/watch?v=6OnCSHKcOGU (kitchen TV)

## BIG TODO: EXAMPLES
The overall idea is similar to implementations for FiveM or RAGE:MP.