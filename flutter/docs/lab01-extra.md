# การเพิ่มปุ่มลดค่า (Decrement) ในแอปพลิเคชัน Flutter (Lab 01 Extra)

เอกสารนี้อธิบายการปรับปรุงโค้ดจากโปรเจกต์ `lab01` มาเป็น `lab01-extra` โดยมีเป้าหมายเพื่อเพิ่มปุ่มสำหรับลดค่าตัวเลข (Decrement) นอกเหนือจากปุ่มเพิ่มค่า (Increment) ที่มีอยู่เดิม

## สิ่งที่แก้ไขใน `lib/main.dart`

### 1. เพิ่มฟังก์ชัน `_decrementCounter`
เราได้เพิ่มฟังก์ชันใหม่เข้าไปในคลาส `_MyHomePageState` เพื่อใช้สำหรับลดค่าของตัวแปร `_counter` ลงทีละ 1 ภายในคำสั่ง `setState()` ซึ่งจะช่วยให้หน้าจอ UI อัปเดตและแสดงผลค่าใหม่ได้ทันที:

```dart
void _decrementCounter() {
  setState(() {
    _counter--;
  });
}
```

### 2. ปรับปรุง `floatingActionButton`
เดิมทีแอปพลิเคชันมีปุ่ม `FloatingActionButton` เพียงปุ่มเดียว เราได้แก้ไขโดยการใช้ Widget `Column` ครอบเอาไว้ เพื่อให้สามารถจัดเรียงปุ่มสองปุ่มในแนวตั้งได้:

```dart
floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // ปุ่มสำหรับเพิ่มค่า
    FloatingActionButton(
      onPressed: _incrementCounter,
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    ),
    const SizedBox(height: 10), // เพิ่ม SizedBox เพื่อเว้นระยะห่างระหว่างปุ่ม
    // ปุ่มสำหรับลดค่า
    FloatingActionButton(
      onPressed: _decrementCounter,
      tooltip: 'Decrement',
      child: const Icon(Icons.remove),
    ),
  ],
),
```

### สรุปการทำงานของโค้ดที่เพิ่มเข้ามา
- เมื่อผู้ใช้กดปุ่ม **(+)** ฟังก์ชัน `_incrementCounter` จะทำงาน และเพิ่มค่าตัวเลขขึ้น 1
- เมื่อผู้ใช้กดปุ่ม **(-)** ฟังก์ชัน `_decrementCounter` จะทำงาน และลดค่าตัวเลขลง 1
- การใช้ `Column` ร่วมกับ `mainAxisAlignment: MainAxisAlignment.end` ช่วยให้ปุ่มทั้งสองเรียงต่อกันและอยู่ที่มุมขวาล่างของหน้าจอได้อย่างสวยงาม