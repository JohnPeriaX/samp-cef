# Build Notes

## Building the Windows client on Windows
From a clean Windows machine, this sequence is enough to build successfully:

1. Install Rustup:

```powershell
winget install -e --id Rustlang.Rustup
```

2. Open a new PowerShell window.

If `rustup` is still not recognized in the current shell, refresh PATH once:

```powershell
$env:Path = ([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User'))
```

3. Install the 32-bit Rust target:

```powershell
rustup target add i686-pc-windows-msvc
```

4. Install Visual Studio 2022 Build Tools or Visual Studio Community with the `Desktop development with C++` workload.

5. Install native build tools required by dependencies:

```powershell
winget install -e --id NASM.NASM
winget install -e --id 7zip.7zip
```

6. Run the build script from the repository root:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

The PowerShell script:
- downloads `libcef.lib` if `CEF_PATH` is not set
- downloads/extracts the DirectX SDK x86 libraries if `DX_SDK` is not set
- enters the Visual Studio x86 developer shell
- builds `client`, `renderer`, and `loader` for `i686-pc-windows-msvc`

Outputs:
- `target/i686-pc-windows-msvc/release/client.dll`
- `target/i686-pc-windows-msvc/release/loader.dll`
- `target/i686-pc-windows-msvc/release/renderer.exe`

Notes:
- Use the stable toolchain pinned by `rust-toolchain.toml`.
- You do not need the old `nightly-2022-11-06` toolchain for the current repository state.
- If you already have CEF libraries, set `CEF_PATH` to the folder that contains `libcef.lib`.
- If you already have DirectX SDK June 2010 x86 libraries, set `DX_SDK` to the `Lib/x86` directory.

## Cross-compiling the Windows client (macOS/Linux)
- Install `cargo-xwin`: `cargo install cargo-xwin --locked`.
- Ensure `XWIN_ACCEPT_LICENSE=1` is set (the script defaults it).
- Install `7z` (used to extract the DirectX SDK archive), `nasm`, and LLVM (for `llvm-lib`).
- Optionally set `DX_SDK` to an existing DirectX SDK `Lib/x86` directory; otherwise the script downloads and extracts it.
- Run `scripts/build-client-win32.sh`.

The script downloads `libcef.lib` if `CEF_PATH` is not set and builds `client`, `renderer`, and `loader` for `i686-pc-windows-msvc`. Outputs land in `target/i686-pc-windows-msvc/release/`.
