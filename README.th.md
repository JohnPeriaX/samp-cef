# SAMP CEF

โปรเจกต์นี้ฝัง CEF เข้าไปใน SA:MP เพื่อให้สร้างอินเทอร์เฟซในเกมด้วย HTML / CSS / JavaScript ได้

โปรเจกต์นี้เป็นเฟรมเวิร์กหรือ SDK ไม่ใช่ไฟล์ที่ดาวน์โหลดไปใช้ได้ทันที หากต้องการพัฒนาต่อควรมีพื้นฐาน JS / HTML / CSS

## สิ่งที่ทำได้
- สร้าง browser view จาก gamemode หรือจาก client-side plugin ผ่าน C ABI
- แสดง browser บนวัตถุในเกม พร้อมระบบเสียงแบบใกล้เคียง spatial sound
- ส่งและรับ custom event ระหว่าง server และ client

## รายการ Crate
- `cef` - Rust wrapper สำหรับ CEF C API
- `cef-api` - Rust wrapper สำหรับสร้าง client plugin ที่ใช้ CEF
- `cef-interface` - ตัวอย่าง Rust plugin
- `cef-sys` - bindings สำหรับ CEF C API
- `client` - client CEF plugin
- `d3dx9` - bindings สำหรับ DirectX SDK
- `loader` - ตัวโหลดขนาดเล็กที่ทำให้ระบบทำงานได้ และควรถูกตั้งชื่อเป็น `cef.asi`
- `messages` - protobuf messages สำหรับสื่อสารกับ server
- `network` - ตัวเชื่อม quinn ลักษณะคล้าย laminar
- `proto` - ไฟล์ proto ต้นฉบับ
- `renderer` - ตัวเชื่อมระหว่าง CEF renderer process กับ logic หลัก
- `server` - server-side plugin

## ดาวน์โหลด
build ล่าสุดจาก branch master อยู่ใน GitHub Actions

[GitHub Actions](https://github.com/ZOTTCE/samp-cef/actions)

ตอนนี้มี build สำหรับระบบปฏิบัติการเหล่านี้:

- CentOS 7 (`cef-centos-7.so`)
- Debian 9, 10, 11 (`cef-debian-*.so`)
- Ubuntu 18.04, 20.04 (`cef-ubuntu-*.so`)
- Windows (`cef-windows.dll`)

รวมถึงไฟล์ฝั่ง client เช่น `cef.asi`, `client.dll`, และ `renderer.exe`

## การบิ้ว
### สิ่งที่ต้องมี
- ติดตั้ง Rust ตามเวอร์ชันที่ระบุใน `rust-toolchain.toml` และเพิ่ม target `i686-pc-windows-msvc` หากจะบิ้ว Windows client
- ต้องมี CEF แบบ prebuilt หากต้องการใช้ความสามารถบางส่วน เช่น stream ฝั่ง client
- ตั้ง environment variable `CEF_PATH` ให้ชี้ไปยังโฟลเดอร์ที่มี `libcef.lib` หากต้องการใช้ไฟล์ของคุณเอง
- สำหรับ client build ต้องมี DirectX SDK (June 2010) หรือกำหนด `DX_SDK` ให้ชี้ไปยัง `Lib/x86`

### วิธีบิ้วบน Windows แบบที่ทดสอบแล้ว
ขั้นตอนด้านล่างนี้ใช้บิ้วบน Windows ได้จริงตามสถานะปัจจุบันของ repo

1. ติดตั้ง Rustup

```powershell
winget install -e --id Rustlang.Rustup
```

2. ปิดแล้วเปิด PowerShell ใหม่หนึ่งครั้งหลังติดตั้ง

ถ้า shell ปัจจุบันยังไม่เห็น `rustup` ให้รีเฟรช PATH หนึ่งครั้ง

```powershell
$env:Path = ([Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User'))
```

3. ติดตั้ง target 32-bit MSVC

```powershell
rustup target add i686-pc-windows-msvc
```

4. ติดตั้ง Visual Studio 2022 Build Tools หรือ Visual Studio Community พร้อม workload `Desktop development with C++`

5. ติดตั้งเครื่องมือ native เพิ่มเติมที่ dependency ใช้

```powershell
winget install -e --id NASM.NASM
winget install -e --id 7zip.7zip
```

6. รันสคริปต์บิ้วจาก root ของ repo

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

สคริปต์นี้จะทำงานให้อัตโนมัติ:
- ดาวน์โหลด `libcef.lib` หากยังไม่ได้ตั้ง `CEF_PATH`
- ดาวน์โหลดและแตก DirectX SDK x86 libraries หากยังไม่ได้ตั้ง `DX_SDK`
- เปิด Visual Studio x86 MSVC developer environment
- บิ้ว `client`, `renderer`, และ `loader` สำหรับ `i686-pc-windows-msvc`

ไฟล์ผลลัพธ์หลังบิ้วอยู่ที่:
- `target/i686-pc-windows-msvc/release/client.dll`
- `target/i686-pc-windows-msvc/release/loader.dll`
- `target/i686-pc-windows-msvc/release/renderer.exe`

หมายเหตุ:
- repo ปัจจุบันใช้ stable toolchain ตาม `rust-toolchain.toml` ไม่ต้องใช้ nightly เก่า `nightly-2022-11-06`
- หากคุณมี `libcef.lib` อยู่แล้ว ให้ตั้ง `CEF_PATH` ไปยังโฟลเดอร์นั้นก่อนรันสคริปต์
- หากคุณมี DirectX SDK x86 libraries อยู่แล้ว ให้ตั้ง `DX_SDK` ไปยังโฟลเดอร์ `Lib/x86`

### หมายเหตุเพิ่มเติม
หากเจอ linker error บางกรณีอาจต้องแก้ path ที่ hard-code ไว้ใน source

- `client/build.rs` - path ค่าเริ่มต้นของ DirectX SDK

### การบิ้วส่วน Rust ทั่วไป
หากต้องการบิ้วเฉพาะ server ให้ใช้คำสั่งนี้

```sh
rustup target add i686-pc-windows-msvc
cargo build --release --package server
```

### การบิ้ว Windows client บน Windows
ใช้ `scripts/build-client-win32.ps1` เพื่อบิ้ว `client`, `renderer`, และ `loader` บน Windows host

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build-client-win32.ps1
```

### การ cross-compile Windows client จาก macOS/Linux
ใช้ `scripts/build-client-win32.sh` เพื่อบิ้ว `client`, `renderer`, และ `loader` สำหรับ `i686-pc-windows-msvc` บน non-Windows host

สคริปต์นี้พึ่งพา `cargo-xwin` (`cargo install cargo-xwin --locked`), `7z` สำหรับแตก DirectX SDK, และจะดาวน์โหลด `libcef.lib` ให้ถ้ายังไม่ได้ตั้ง `CEF_PATH`

ถ้าต้องการใช้ OpenAL แทน `rodio` สำหรับเสียง ให้บิ้ว `client` โดยปิด default features

```sh
cargo build --release --target i686-pc-windows-msvc --package client --no-default-features
```

จากนั้นวาง `openal.dll` เป็น `sound.dll` ในโฟลเดอร์ `cef`

ถ้าต้องการบิ้วเฉพาะบาง crate ให้เพิ่ม `--package <NAME>`

หากพยายามบิ้วทุก crate บน Linux อาจเจอ error ดังนั้นควรระบุ `--package server` เมื่อบิ้วเฉพาะฝั่ง server

## เวอร์ชัน CEF
เวอร์ชันปัจจุบันของ CEF และ Chromium คือ:

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

## เอกสาร
- [docs/main_en.md](docs/main_en.md)
- [docs/build.md](docs/build.md)
- [docs/main_th.md](docs/main_th.md)
- [docs/build.th.md](docs/build.th.md)
- GitHub wiki

## วิดีโอตัวอย่าง
- https://www.youtube.com/watch?v=Jh9IBlOKoVM (ตัวอย่าง character เต็มจอ)
- https://www.youtube.com/watch?v=jU-O8_t1AfI (อินเทอร์เฟซแบบเรียบง่าย)
- https://www.youtube.com/watch?v=qs7n8LoVYs4 (อินเทอร์เฟซ GTA แบบปรับแต่งเอง)
- https://www.youtube.com/watch?v=vcyTjn3RJhs (voice chat)
- https://www.youtube.com/watch?v=6OnCSHKcOGU (ทีวีในครัว)

## TODO ใหญ่: ตัวอย่าง
แนวคิดโดยรวมคล้ายกับการทำงานใน FiveM หรือ RAGE:MP