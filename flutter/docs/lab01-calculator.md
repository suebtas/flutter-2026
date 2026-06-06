# การสร้างแอปพลิเคชันเครื่องคิดเลข (Lab 01 Calculator)

**วัตถุประสงค์:**
เพื่อให้นักศึกษาสามารถประยุกต์ใช้ความรู้พื้นฐานของ Flutter ในการสร้างแอปพลิเคชันที่ซับซ้อนขึ้น โดยฝึกการจัดการสถานะ (State) การจัดหน้าจอ (Layout) และการเขียนลอจิก (Logic) พื้นฐานทีละขั้นตอน

---

## 📝 ขั้นตอนการทดลอง

### ขั้นตอนที่ 1: สร้างโปรเจกต์ใหม่
สร้างโปรเจกต์ Flutter ใหม่ชื่อว่า `lab01-calculator`:

```bash
cd D:\data\projects\
flutter create --project-name lab01_calculator lab01-calculator
cd lab01-calculator
```

### ขั้นตอนที่ 2: เตรียมโครงสร้างไฟล์ `main.dart`
เปิดไฟล์ `lib/main.dart` ลบโค้ดเดิมทั้งหมด (ที่เป็นแอปนับเลข) แล้วใส่โครงสร้างพื้นฐานของแอปพลิเคชัน:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  // เราจะเพิ่มตัวแปรและฟังก์ชันที่นี่ในขั้นตอนต่อไป

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('หน้าจอเครื่องคิดเลข'),
      ),
    );
  }
}
```

### ขั้นตอนที่ 3: เพิ่มตัวแปรสำหรับจัดการสถานะ (State Variables)
แอปพลิเคชันเครื่องคิดเลขต้องมีการจำค่าตัวเลขที่กด และผลลัพธ์ ให้เพิ่มตัวแปรเหล่านี้ลงในคลาส `_CalculatorHomePageState`:

```dart
class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String output = "0"; // ค่าที่จะแสดงบนหน้าจอ
  String _output = "0"; // ค่าชั่วคราวระหว่างที่ผู้ใช้กำลังพิมพ์
  double num1 = 0; // ตัวเลขแรกที่ใช้คำนวณ
  double num2 = 0; // ตัวเลขที่สองที่ใช้คำนวณ
  String operand = ""; // เครื่องหมาย (+, -, x, /)

  // ... (ฟังก์ชัน build อยู่ด้านล่าง)
}
```

### ขั้นตอนที่ 4: สร้างฟังก์ชันสำหรับปุ่มกด (Helper Widget)
เพื่อไม่ให้ต้องเขียนโค้ดปุ่มซ้ำๆ กัน 16 ปุ่ม เราจะสร้างฟังก์ชันช่วยสร้างปุ่ม `buildButton` ภายในคลาส `_CalculatorHomePageState`:

```dart
  Widget buildButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24.0),
            textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            // โทรเรียกฟังก์ชันคำนวณเมื่อปุ่มถูกกด (จะเขียนในขั้นตอนที่ 6)
            buttonPressed(buttonText);
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
```

### ขั้นตอนที่ 5: จัดวาง Layout ของเครื่องคิดเลข
แก้ไขฟังก์ชัน `build(BuildContext context)` เพื่อจัดวางส่วนแสดงผลตัวเลข (ด้านบน) และตารางปุ่มกด (ด้านล่าง):

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: <Widget>[
          // ส่วนแสดงผลตัวเลข
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Text(
              output,
              style: const TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(child: Divider()), // เส้นแบ่ง
          // ส่วนตารางปุ่มกด
          Column(
            children: [
              Row(children: [buildButton("7"), buildButton("8"), buildButton("9"), buildButton("/")]),
              Row(children: [buildButton("4"), buildButton("5"), buildButton("6"), buildButton("x")]),
              Row(children: [buildButton("1"), buildButton("2"), buildButton("3"), buildButton("-")]),
              Row(children: [buildButton("."), buildButton("0"), buildButton("C"), buildButton("+")]),
              Row(children: [buildButton("=")]), // ปุ่มเท่ากับจองพื้นที่เต็มแถว
            ],
          )
        ],
      ),
    );
  }
```

### ขั้นตอนที่ 6: เขียนลอจิกการคำนวณ
เพิ่มฟังก์ชัน `buttonPressed` (วางไว้ก่อนฟังก์ชัน `buildButton`) เพื่อให้เครื่องคิดเลขสามารถประมวลผลได้จริง:

```dart
  void buttonPressed(String buttonText) {
    if (buttonText == "C") {
      // เคลียร์ค่าทั้งหมด
      _output = "0";
      num1 = 0;
      num2 = 0;
      operand = "";
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "/" || buttonText == "x") {
      // เมื่อกดเครื่องหมายคณิตศาสตร์
      num1 = double.parse(output);
      operand = buttonText;
      _output = "0"; // รีเซ็ตหน้าจอเพื่อรอรับตัวเลขที่สอง
    } else if (buttonText == "=") {
      // เมื่อกดเครื่องหมายเท่ากับ ทำการคำนวณ
      num2 = double.parse(output);

      if (operand == "+") _output = (num1 + num2).toString();
      if (operand == "-") _output = (num1 - num2).toString();
      if (operand == "x") _output = (num1 * num2).toString();
      if (operand == "/") _output = (num1 / num2).toString();

      num1 = 0;
      num2 = 0;
      operand = "";

      // ตัดทศนิยม .0 ทิ้งหากผลลัพธ์เป็นจำนวนเต็ม
      if (_output.endsWith(".0")) {
        _output = _output.substring(0, _output.length - 2);
      }
    } else {
      // เมื่อกดตัวเลขหรือจุดทศนิยม
      if (buttonText == ".") {
        if (!_output.contains(".")) {
          _output = _output + buttonText;
        }
      } else if (_output == "0") {
        _output = buttonText; // แทนที่เลข 0 เริ่มต้น
      } else {
        _output = _output + buttonText; // นำตัวเลขมาต่อท้ายเรื่อยๆ
      }
    }

    // สั่งให้ Flutter วาดหน้าจอใหม่ด้วยค่าล่าสุด
    setState(() {
      output = _output;
    });
  }
```

### ขั้นตอนที่ 7: อัปเดตไฟล์ทดสอบ (`test/widget_test.dart`)
เปิดไฟล์ `test/widget_test.dart` และแก้ไขชื่อคลาสให้ตรงกับแอปของเรา เพื่อป้องกัน Error ตอนตรวจสอบโค้ด:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:lab01_calculator/main.dart';

void main() {
  testWidgets('Calculator smoke test', (WidgetTester tester) async {
    // โหลดแอปพลิเคชัน
    await tester.pumpWidget(const CalculatorApp());

    // ทดสอบว่าเริ่มต้นหน้าจอแสดงเลข 0
    expect(find.text('0'), findsWidgets);

    // ทดลองจำลองการกดปุ่ม '1'
    await tester.tap(find.text('1'));
    await tester.pump();

    // ต้องพบเลข 1 แสดงบนหน้าจอ
    expect(find.text('1'), findsWidgets);
  });
}
```

### ขั้นตอนที่ 8: ตรวจสอบและรันแอปพลิเคชัน
เมื่อประกอบโค้ดทั้งหมดเสร็จแล้ว ให้รันคำสั่งต่อไปนี้เพื่อตรวจสอบและเปิดแอปพลิเคชันบน Emulator:
```bash
flutter analyze
flutter run -d localhost:5555
```

---

## 💡 สรุปแนวคิดที่ได้เรียนรู้ (Concepts Explained)
- **StatefulWidget & setState:** การใช้ตัวแปรเพื่อเก็บสถานะและสั่ง `setState()` เพื่อให้ Flutter อัปเดต UI เมื่อผู้ใช้กดปุ่ม
- **Layout (Row, Column, Expanded):** การใช้ `Column` เรียงองค์ประกอบแนวตั้ง `Row` เรียงแนวนอน และ `Expanded` เพื่อบังคับให้ปุ่มกดขยายตัวให้มีความกว้างเท่าๆ กันอย่างเป็นระเบียบ
- **Logic & Conditionals:** การใช้ `if-else` ในการตัดสินใจลอจิก ว่าผู้ใช้กดปุ่มประเภทใด (ตัวเลข, เครื่องหมาย, หรือ เคลียร์หน้าจอ)
- **Type Conversion:** การแปลงข้อความ (`String`) บนหน้าจอเป็นตัวเลขทศนิยม (`double.parse`) เพื่อคำนวณทางคณิตศาสตร์ และแปลงกลับเป็นข้อความ (`.toString()`) เพื่อแสดงผล
