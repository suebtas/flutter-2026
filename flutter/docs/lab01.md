# Lab: การรันแอปพลิเคชัน Flutter ด้วย Docker Android Emulator

**วัตถุประสงค์:** 
เพื่อให้นักศึกษาสามารถตั้งค่าและรันแอปพลิเคชัน Flutter บน Android Emulator ที่ทำงานอยู่ภายใน Docker Container ได้ โดยไม่จำเป็นต้องติดตั้งโปรแกรม Android Studio ตัวเต็ม ช่วยลดการใช้ทรัพยากรของเครื่องคอมพิวเตอร์

---

## 🛠 สิ่งที่ต้องเตรียมพร้อม (Prerequisites)

ก่อนเริ่มการทดลอง ตรวจสอบให้แน่ใจว่าเครื่องคอมพิวเตอร์ของคุณมีโปรแกรมต่อไปนี้ติดตั้งอยู่แล้ว:
1. **Docker Desktop:** สำหรับรัน Android Emulator ใน Container
2. **Flutter SDK:** ติดตั้งและตั้งค่า Path เรียบร้อยแล้ว (เช่น `D:\data\projects\flutter\tools\flutter\bin`)
3. **Android SDK Platform-Tools (ADB):** มีคำสั่ง `adb` ใน Path ของระบบ หรือดาวน์โหลดแบบ "Command line tools only" แทนการลง Android Studio ตัวเต็ม (เช่น `D:\data\projects\flutter\tools\platform-tools`)

### การติดตั้งเครื่องมือที่จำเป็นผ่าน Command Line (สำหรับ Windows)

หากเครื่องคอมพิวเตอร์ของคุณยังไม่ได้ติดตั้งเครื่องมือ สามารถใช้คำสั่ง PowerShell เหล่านี้เพื่อดาวน์โหลดและตั้งค่าแบบรวดเร็วได้:

**1. ดาวน์โหลดและติดตั้ง Docker Desktop:**
ใช้ `winget` (Windows Package Manager) ในการติดตั้ง:
```powershell
winget install Docker.DockerDesktop
```
*(หมายเหตุ: หลังจากติดตั้งเสร็จ อาจจะต้อง Restart เครื่อง 1 ครั้ง และเปิดโปรแกรม Docker Desktop ให้ทำงาน)*

**2. ดาวน์โหลด Flutter SDK:**
สร้างโฟลเดอร์สำหรับเก็บ SDK และทำการโคลนจาก Github:
```powershell
# สร้างโฟลเดอร์สำหรับติดตั้งและเข้าไปยังโฟลเดอร์นั้น
mkdir D:\data\projects\flutter\tools
cd D:\data\projects\flutter\tools

# ดาวน์โหลด Flutter SDK รุ่น stable
git clone https://github.com/flutter/flutter.git -b stable
```

**3. ดาวน์โหลด Android SDK Platform-Tools (สำหรับคำสั่ง ADB):**
ดาวน์โหลดและแตกไฟล์ ZIP ของเครื่องมือ Platform-tools:
```powershell
# ดาวน์โหลดไฟล์ zip ของ Platform-Tools
Invoke-WebRequest -Uri "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -OutFile "D:\data\projects\flutter\tools\platform-tools.zip"

# แตกไฟล์ zip (จะได้โฟลเดอร์ C:\src\platform-tools)
Expand-Archive -Path "D:\data\projects\flutter\tools\platform-tools.zip" -DestinationPath "D:\data\projects\flutter\tools" -Force
```

**4. ตั้งค่า Path Environment Variables:**
เพิ่ม Path ของ Flutter และ ADB ลงในระบบ เพื่อให้สามารถเรียกใช้คำสั่งจากโฟลเดอร์ใดก็ได้:
```powershell
# กำหนด Path ปัจจุบันของ User
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# กำหนดโฟลเดอร์ที่ต้องการเพิ่ม
$flutterPath = "D:\data\projects\flutter\tools\flutter\bin"
$adbPath = "D:\data\projects\flutter\tools\platform-tools"

# ตรวจสอบและเพิ่ม Path (หากยังไม่มี)
if ($currentPath -notmatch [regex]::Escape($flutterPath)) {
    $currentPath += ";$flutterPath"
}
if ($currentPath -notmatch [regex]::Escape($adbPath)) {
    $currentPath += ";$adbPath"
}

# บันทึก Path กลับเข้าสู่ระบบ
[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
```
*(สำคัญ: หลังจากรันคำสั่งตั้งค่า Path เสร็จแล้ว ให้ทำการปิด Terminal หรือ Command Prompt แล้วเปิดใหม่เพื่อให้ระบบรับรู้ Path ที่อัปเดต)*

---

## 📝 ขั้นตอนการทดลอง

### ขั้นตอนที่ 1: สตาร์ท Android Emulator บน Docker

เราจะใช้ Image `budtmo/docker-android` เพื่อจำลองเครื่อง Android ขึ้นมา ทำการเปิด Terminal/Command Prompt แล้วรันคำสั่งต่อไปนี้:

```bash
docker run -d -p 6080:6080 -p 5554:5554 -p 5555:5555 -e EMULATOR_DEVICE="Samsung Galaxy S10" -e WEB_VNC=true --device /dev/kvm --name android-emulator budtmo/docker-android:emulator_11.0
```

**คำอธิบายคำสั่ง:**
- `-p 6080:6080`: แมปพอร์ตสำหรับดูหน้าจอ Emulator ผ่าน Web Browser (VNC)
- `-p 5555:5555`: แมปพอร์ตสำหรับให้ ADB เชื่อมต่อ (สำคัญมากสำหรับการรันโค้ด)
- `-e EMULATOR_DEVICE="Samsung Galaxy S10"`: กำหนดรุ่นของอุปกรณ์จำลอง
- `--device /dev/kvm`: เปิดใช้งาน Hardware Acceleration (เพื่อให้ Emulator ลื่นไหลขึ้น)

**การดูหน้าจอ Emulator:**
เปิด Web Browser แล้วไปที่ `http://localhost:6080` คุณจะเห็นหน้าจอของมือถือ Android ปรากฏขึ้น

---

### ขั้นตอนที่ 2: เชื่อมต่อ ADB กับ Docker Emulator

เมื่อ Emulator บูตเสร็จแล้ว เราต้องสั่งให้คอมพิวเตอร์ของเราเชื่อมต่อกับ Emulator ตัวนี้ผ่านระบบเครือข่าย

1. เปิด Terminal พิมพ์คำสั่ง:
   ```bash
   adb connect localhost:5555
   ```
2. ตรวจสอบว่า Flutter มองเห็น Emulator หรือไม่:
   ```bash
   flutter devices
   ```
   *หากเชื่อมต่อสำเร็จ จะมีรายชื่ออุปกรณ์แสดงขึ้นมา เช่น `sdk gphone x86 64`*

---

### ขั้นตอนที่ 3: สร้างและเตรียมความพร้อมโปรเจกต์ Flutter (Demo)

ในการเริ่มต้นทดสอบ เราจะสร้างโปรเจกต์ Flutter ตัวอย่างแบบง่ายๆ (Demo) ด้วยคำสั่งต่อไปนี้:

```bash
# เปลี่ยนไปยังโฟลเดอร์หลักสำหรับเก็บโปรเจกต์
cd D:\data\projects\

# สร้างโปรเจกต์ใหม่ชื่อ lab01
flutter create lab01
```
*(คำสั่งนี้จะสร้างโฟลเดอร์ `lab01` พร้อมโค้ดตัวอย่างแอปพลิเคชัน Counter เบื้องต้นให้อัตโนมัติ)*

จากนั้นเข้าไปยังโฟลเดอร์โปรเจกต์ Flutter ของคุณ: 
```bash
cd D:\data\projects\lab01\
```

**ทำความเข้าใจโค้ดตัวอย่าง (Counter App):**
โค้ดที่ระบบสร้างขึ้นมาให้จะอยู่ในไฟล์ `lib/main.dart` ซึ่งเป็นแอปพลิเคชันนับตัวเลขอย่างง่าย โดยมีกลไกหลักๆ ดังนี้:
- **`main()`**: จุดเริ่มต้นของโปรแกรมที่สั่งให้ UI เริ่มวาดบนหน้าจอผ่าน `runApp()`
- **`MyApp`**: วิดเจ็ตหลัก (Stateless) ที่กำหนดโครงสร้างของแอป เช่น ธีมสี (Theme) และกำหนดหน้าจอแรก
- **`MyHomePage`**: หน้าจอหลัก (Stateful) ที่ผู้ใช้โต้ตอบด้วยได้
- **State Management**: มีตัวแปร `_counter` เก็บค่าตัวเลข และฟังก์ชัน `_incrementCounter()` ที่เมื่อถูกเรียก จะใช้ `setState()` สั่งให้ Flutter วาดหน้าจอใหม่พร้อมตัวเลขที่เพิ่มขึ้น
- **UI Structure**: ใช้ `Scaffold` วางโครงสร้างหน้าจอ ประกอบด้วย AppBar ด้านบน, ข้อความแสดงตัวเลขตรงกลาง (body), และปุ่มกด `FloatingActionButton` มุมขวาล่าง

**⚠️ ปัญหาที่พบบ่อย (Troubleshooting):**
หากคุณเพิ่งโคลนโค้ดมาหรือสร้างโปรเจกต์ไว้ก่อนหน้านี้ เมื่อสั่งรันอาจเจอ Error ลักษณะนี้:
> `AndroidManifest.xml could not be found.`
> `No application found for TargetPlatform.android_x64.`

**สาเหตุ:** โฟลเดอร์ที่จำเป็นสำหรับฝั่ง Android ขาดหายไป
**วิธีแก้:** ให้รันคำสั่งเพื่อสร้างไฟล์ Platform ใหม่สำหรับ Android ภายในโฟลเดอร์โปรเจกต์:

```bash
flutter create .
```
*(จุด `.` หมายถึงโฟลเดอร์ปัจจุบัน คำสั่งนี้จะสร้างไฟล์ AndroidManifest.xml และตั้งค่าโฟลเดอร์ `android/` ให้สมบูรณ์)*

---

### ขั้นตอนที่ 4: สั่งรันแอปพลิเคชัน Flutter

เมื่อทุกอย่างพร้อมแล้ว ทำการสั่งรันแอปพลิเคชันไปที่ Emulator โดยระบุอุปกรณ์เป็น `localhost:5555`:

```bash
flutter run -d localhost:5555
```

**ข้อสังเกต:**
- ครั้งแรกที่รันอาจจะใช้เวลานานนิดหน่อยเนื่องจาก Gradle จะทำการดาวน์โหลดและ Build ไฟล์ของระบบ Android
- เมื่อ Build เสร็จสมบูรณ์ แอปพลิเคชัน Flutter ของคุณจะไปปรากฏบนหน้าจอ Emulator ใน Web Browser (`http://localhost:6080`) ทันที

---

## 🔍 กลไกการทำงานเบื้องหลัง: `flutter run` ส่งแอปเข้า Docker Emulator ได้อย่างไร?

เมื่อเราพิมพ์คำสั่ง `flutter run` จะมีกระบวนการทำงานเบื้องหลังเพื่อนำแอปพลิเคชันไปรันบน Emulator ใน Docker ดังนี้:

1. **การเชื่อมต่อผ่าน ADB (Android Debug Bridge):** 
   จากการใช้คำสั่งรัน Docker เราได้แมปพอร์ต `5555` ของ Container ออกมายัง `5555` ของเครื่องโฮสต์ (`-p 5555:5555`) 
   เมื่อเราใช้คำสั่ง `adb connect localhost:5555` เครื่องมือ ADB บนคอมพิวเตอร์ของเราจึงสามารถเชื่อมต่อผ่านเครือข่ายเข้าไปยังระบบ Android ภายใน Docker Container ได้โดยตรง ส่งผลให้ Flutter มองเห็น Emulator นี้เสมือนเป็นอุปกรณ์ที่เชื่อมต่อกับเครื่องเราตามปกติ

2. **การคอมไพล์และสร้างไฟล์ติดตั้ง (Build Process):** 
   เมื่อสั่ง `flutter run` ระบบบนเครื่องคอมพิวเตอร์หลัก (Host) ของเราจะรับหน้าที่รัน Gradle และคอมไพล์ซอร์สโค้ดให้กลายเป็นไฟล์แอปพลิเคชันแอนดรอยด์ หรือ **APK (Android Package Kit)**

3. **การคัดลอกและติดตั้ง (Transfer & Install):** 
   หลังจากสร้างไฟล์ APK เสร็จแล้ว Flutter จะสั่งงานผ่าน **ADB** เพื่อทำการส่ง (Push) และติดตั้ง (Install) ไฟล์ APK ดังกล่าวข้ามพอร์ต `5555` (Network) เข้าไปใน Android Emulator ที่อยู่ใน Docker

4. **การสั่งรันแอปพลิเคชัน (Launch):** 
   เมื่อติดตั้งเสร็จสมบูรณ์ ADB จะส่งคำสั่งไปยัง Emulator เพื่อเปิดแอปพลิเคชันขึ้นมาแสดงผล ทำให้เราสามารถใช้งานแอปได้ผ่านทาง Web VNC (`http://localhost:6080`)

---

## 💡 สรุป

ด้วยวิธีการนี้ นักศึกษาสามารถเขียนโค้ดและทดสอบแอปพลิเคชัน Android ได้โดยใช้เพียง Docker และ Command Line Tools โดยไม่จำเป็นต้องเปิด Android Studio ซึ่งช่วยประหยัด RAM และ CPU ของเครื่องคอมพิวเตอร์ได้อย่างมาก
