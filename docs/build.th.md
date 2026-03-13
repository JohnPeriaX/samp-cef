# Build Notes

## การบิ้ว Windows client บน Windows
ถ้าเริ่มจากเครื่อง Windows เปล่า ๆ ขั้นตอนด้านล่างนี้เพียงพอสำหรับการบิ้วให้ผ่าน:

1. ติดตั้ง Rustup:

```powershell
winget install -e --id Rustlang.Rustup
```

2. เปิด PowerShell หน้าต่างใหม่

ถ้า shell ปัจจุบันยังไม่รู้จัก `rustup` ให้รีเฟรช PATH หนึ่งครั้ง:

```powershell
$env:Path = ([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User'))
```

3. ติดตั้ง Rust target แบบ 32-bit:

```powershell
rustup target add i686-pc-windows-msvc
```

4. ติดตั้ง Visual Studio 2022 Build Tools หรือ Visual Studio Community พร้อม workload `Desktop development with C++`

5. ติดตั้ง native build tools ที่ dependency ใช้:

```powershell
winget install -e --id NASM.NASM
winget install -e --id 7zip.7zip
```

6. รัน build script จาก root ของ repository:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

PowerShell script นี้จะ:
- ดาวน์โหลด `libcef.lib` หากยังไม่ได้ตั้ง `CEF_PATH`
- ดาวน์โหลดและแตก DirectX SDK x86 libraries หากยังไม่ได้ตั้ง `DX_SDK`
- เข้า Visual Studio x86 developer shell
- บิ้ว `client`, `renderer`, และ `loader` สำหรับ `i686-pc-windows-msvc`

ผลลัพธ์อยู่ที่:
- `target/i686-pc-windows-msvc/release/client.dll`
- `target/i686-pc-windows-msvc/release/loader.dll`
- `target/i686-pc-windows-msvc/release/renderer.exe`

หมายเหตุ:
- ใช้ stable toolchain ตามที่ระบุใน `rust-toolchain.toml`
- ไม่จำเป็นต้องใช้ `nightly-2022-11-06` สำหรับสถานะปัจจุบันของ repository
- ถ้าคุณมี CEF libraries อยู่แล้ว ให้ตั้ง `CEF_PATH` ไปยังโฟลเดอร์ที่มี `libcef.lib`
- ถ้าคุณมี DirectX SDK June 2010 x86 libraries อยู่แล้ว ให้ตั้ง `DX_SDK` ไปยังโฟลเดอร์ `Lib/x86`

## การ cross-compile Windows client จาก macOS/Linux
- ติดตั้ง `cargo-xwin`: `cargo install cargo-xwin --locked`
- ตรวจว่า `XWIN_ACCEPT_LICENSE=1` ถูกตั้งไว้แล้ว ถ้าใช้ script ตัวนี้จะตั้งให้อัตโนมัติ
- ติดตั้ง `7z` สำหรับแตก DirectX SDK archive, `nasm`, และ LLVM สำหรับ `llvm-lib`
- ตั้ง `DX_SDK` ไปยัง DirectX SDK `Lib/x86` ที่มีอยู่แล้วได้ หรือปล่อยให้ script ดาวน์โหลดและแตกให้
- รัน `scripts/build-client-win32.sh`

script นี้จะดาวน์โหลด `libcef.lib` หากยังไม่ได้ตั้ง `CEF_PATH` และจะบิ้ว `client`, `renderer`, และ `loader` สำหรับ `i686-pc-windows-msvc` โดย output จะอยู่ใน `target/i686-pc-windows-msvc/release/`