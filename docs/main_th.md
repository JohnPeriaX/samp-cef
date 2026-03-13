## โครงสร้างไฟล์
- ควรวาง `cef.asi` ไว้ในโฟลเดอร์ root ของเกม โดยไฟล์นี้ถูกบิ้วมาจาก `loader.dll`
- ควรวางโฟลเดอร์ `cef` ไว้ในตำแหน่งเดียวกัน
- จะมีโฟลเดอร์ `CEF` อยู่ที่ `Documents/GTA San Andreas User Files/CEF/` สำหรับเก็บ cookie, cache และข้อมูลอื่นของ Chromium
- `gta_sa.exe`
- `cef.asi`
- `cef/`
    - `client.dll`
    - `libcef.dll`
    - `renderer.exe`
    - และไฟล์อื่น ๆ

## หมายเหตุการบิ้ว
ดูรายละเอียด prerequisite และการ cross-compile Windows client ได้ที่ `docs/build.th.md`

## คำแนะนำและข้อจำกัดบางส่วน
- ควรใช้ browser ตัวเดียวสำหรับทุกอินเทอร์เฟซเพื่อประสิทธิภาพที่ดีที่สุด และให้สื่อสารกันผ่าน event system ที่มีอยู่แล้ว
- ถ้ามี plugin ที่ใช้ relative path อาจเกิดพฤติกรรมไม่คาดคิด เช่น `cleo_text` และ `cleo_saves` อาจถูกสร้างไว้ในโฟลเดอร์ `cef` ดังนั้นควรใช้ absolute path

## Pawn API

`cef_create_browser(player_id, browser_id, const url[], hidden, focused)`

สร้าง browser ให้กับผู้เล่นหนึ่งคน `browser_id` สามารถเป็น ID ใดก็ได้คล้าย dialog ใน SAMP ค่า `focused` หมายถึง browser จะรับ input ทั้งหมดจากเมาส์และคีย์บอร์ด

`cef_destroy_browser(player_id, browser_id)`

ลบ browser

`cef_hide_browser(player_id, browser_id, hide)`

ซ่อน browser

`cef_emit_event(player_id, const event_name[], args…)`

ส่ง event ไปยัง client รองรับ argument ชนิด `string`, `integer`, `float`

`cef_subscribe(const event_name[], const callback[])`

subscribe event จาก client callback มีรูปแบบ `Callback(player_id, const arguments[])` โดย `arguments` เป็น string ที่คั่นค่าด้วยช่องว่าง

`cef_player_has_plugin(player_id)`

ตรวจว่าผู้เล่นมี plugin ติดตั้งอยู่หรือไม่

`cef_create_ext_browser(player_id, browser_id, const texture[], const url[], scale)`

สร้าง browser ที่จะถูกนำไปแสดงบน texture ของ object ในภายหลัง ค่า `scale` จะคูณขนาด texture เช่น `250x30` จะกลายเป็น `1250x150` เมื่อ `scale` เท่ากับ 5

`cef_append_to_object(player_id, browser_id, object_id)`

เปลี่ยน texture บน object ให้เป็นของ browser โดย browser นั้นต้องถูกสร้างด้วย `cef_create_ext_browser`

`cef_remove_from_object(player_id, browser_id, object_id)`

คืน texture เดิมให้ object

`cef_toggle_dev_tools(player_id, browser_id, enabled)`

เปิดหรือปิด dev tools

`native cef_set_audio_settings(player_id, browser_id, Float:max_distance, Float:reference_distance)`

เปลี่ยนการตั้งค่าเสียงของ browser โดย `reference_distance` คือระยะที่ volume ยังเป็น 1.0 และจะค่อย ๆ ลดลงจนถึง `max_distance` ที่ volume เป็น 0

`cef_focus_browser(player_id, browser_id, focused)`

ทำให้ browser ได้ focus เหมือนตอนถูกสร้างด้วย `focused = true`

`cef_always_listen_keys(player_id, browser_id, listen)`

ให้ browser ฟัง input ของผู้เล่นแม้จะไม่ได้ focus เพื่อรองรับ JS key handler แบบ background เช่น `window.addEventListener("keyup")`

`cef_load_url(player_id, browser_id, const url[])`

โหลดหน้าใหม่ตาม URL ที่กำหนด เร็วกว่าการ destroy แล้วสร้าง browser ใหม่

`cef_create_browser`, `cef_create_ext_browser` และ `cef_load_url` รองรับ local file ด้วย:
- relative path เช่น `index.html` หรือ `ui/main.html` จะถูก resolve จาก `<gta_path>/cef/assets/`
- path เช่น `cef/assets/index.html` จะถูก resolve จาก game root
- absolute path เช่น `C:\\Games\\GTA San Andreas\\cef\\assets\\index.html` ใช้ได้เฉพาะเมื่อไฟล์นั้นอยู่ภายใน `<gta_path>/cef/assets` จริง
- การพยายามออกนอก `<gta_path>/cef/assets` เช่น `..` traversal หรือ `file://` URL โดยตรง จะถูก block ฝั่ง client

### Handlers

`forward OnCefBrowserCreated(player_id, browser_id, status_code)`

ถูกเรียกเมื่อผู้เล่นสร้าง browser สำเร็จจาก server หรือ plugin ถ้ามี error ค่า `status_code` จะเป็น 0 ไม่เช่นนั้นจะเป็น HTTP response code เช่น 200 หรือ 404

`forward OnCefInitialize(player_id, success)`

ถูกเรียกเมื่อผู้เล่นเชื่อมต่อเข้า server พร้อม plugin หรือ timeout หากไม่มี plugin ทำหน้าที่คล้าย `cef_player_has_plugin` แบบอัตโนมัติ

## Browser API

`cef.set_focus(focused)`

ตั้ง focus ให้ browser โดย browser จะถูก render เป็นลำดับสุดท้ายและรับ mouse/keyboard events ได้

`cef.on(event_name, callback)`

subscribe event จาก server หรือ client plugin

`cef.off(event_name, callback)`

ยกเลิกการ subscribe event

`cef.hide(hide)`

ซ่อน browser และ mute เสียง

`cef.emit(event_name, args…)`

trigger event ตามชื่อที่กำหนด argument ส่งได้หลายชนิด แต่ฝั่ง server จะมองเป็น string ที่คั่นด้วยช่องว่าง ส่วน client plugin จะรองรับเต็มรูปแบบ

## C API

ส่วนนี้ deprecated แล้วและใช้งานไม่ได้จริงในตอนนี้

ดูตัวอย่าง Rust ที่ใช้ C API ได้จาก crate `cef-interface` และไฟล์ `client/external.rs`

```C++
    #include <cstdint>
    
    // Do not call next event handlers for this event.
    static const int EXTERNAL_BREAK = 1;
    // Continue handling. If all handlers returns this, server will got the event.
    static const int EXTERNAL_CONTINUE = 0;
    
    using BrowserReadyCallback = void(*)(uint32_t);
    using EventCallback = int(*)(const char*, cef_list_value_t*);
    
    extern "C" {
        // Check if a browser exists.
        bool cef_browser_exists(uint32_t browser);
        // Is a browser ready (created and the page is loaded)
        bool cef_browser_ready(uint32_t browser);
        // Make a request to create a browser.
        void cef_create_browser(uint32_t id, const char *url, bool hidden, bool focused);
        // Create `CefListValue`. THE CLIENT OWNS IT!!!
        cef_list_value_t *cef_create_list();
        // Destroy a browser.
        void cef_destroy_browser(uint32_t id);
        // Trigger an event with given args.
        void cef_emit_event(const char *event, cef_list_value_t *list);
        // Focus a browser.
        void cef_focus_browser(uint32_t id, bool focus);
        // Check if a GTA window is active.
        bool cef_gta_window_active();
        // Hide a browser.
        void cef_hide_browser(uint32_t id, bool hide);
        // Can a browser receive input events now.
        bool cef_input_available(uint32_t browser);
        // Subscribe on browser ready events (like pawn one).
        void cef_on_browser_ready(uint32_t browser, BrowserReadyCallback callback);
        // Kind of deprecated
        bool cef_ready();
        // Subscribe on an event.
        void cef_subscribe(const char *event, EventCallback callback);
        // `cef_input_available` + `cef_focus_browser`, but atomic. This function should be used in this cases.
        bool cef_try_focus_browser(uint32_t browser);
    }
```

ตัวอย่าง:
- https://gist.github.com/ZOTTCE/5c5bf3b63b1fec29c104e0085cd51f9f
- https://gist.github.com/ZOTTCE/7dee2d196138457772aa79355069014a