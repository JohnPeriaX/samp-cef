# SAMP CEF

หมายเหตุสำคัญ: fork นี้จัดทำสำหรับการใช้งานภาษาไทยเท่านั้น

ถ้าจะนำไปใช้กับภาษาอื่นหรือประเทศอื่น ควรปรับ locale, encoding, fonts, และเอกสารให้เหมาะกับงานของคุณเองก่อนใช้งานจริง

โปรเจกต์นี้ฝัง CEF เข้าไปใน SA:MP เพื่อให้สร้างอินเทอร์เฟซในเกมด้วย HTML / CSS / JavaScript ได้

โปรเจกต์นี้เป็นเฟรมเวิร์กหรือ SDK ไม่ใช่ไฟล์ที่ดาวน์โหลดไปใช้ได้ทันที หากต้องการพัฒนาต่อควรมีพื้นฐาน JS / HTML / CSS

## สิ่งที่ทำได้
- สร้าง browser view จาก gamemode หรือจาก client-side plugin ผ่าน C ABI
- แสดง browser บนวัตถุในเกม พร้อมระบบเสียงแบบใกล้เคียง spatial sound
- ส่งและรับ custom event ระหว่าง server และ client

## รายการ Crate
- `cef` - Rust wrapper สำหรับ CEF C API
- `cef-api` - Rust wrapper สำหรับสร้าง client plugin ที่ใช้ CEF
- `client` - client CEF plugin
- `d3dx9` - bindings สำหรับ DirectX SDK
- `loader` - ตัวโหลดขนาดเล็กที่ทำให้ระบบทำงานได้ และควรถูกตั้งชื่อเป็น `cef.asi`
