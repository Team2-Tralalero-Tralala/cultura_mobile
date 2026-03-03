/*
 * คำอธิบาย : Component ปุ่มที่ใช้ในแอป
 */
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // วิธีเรียกใช้ปุ่ม
        child: Button(
          text: "จองเลย", // เปลี่ยนข้อความบนปุ่มได้
          onPressed: () {// เมื่อกดปุ่มจะทำงานในนี้
            print("จองแล้ว");// เปลี่ยนเป็นฟังก์ชันอื่นๆ ได้
          },
        ),
      ),
    );
  }
}

class Button extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
/*
 * คําอธิบาย : ฟังก์ชันสำหรับสร้างปุ่มที่สามารถกดได้และแสดงข้อความบนปุ่ม
 * Input : onPressed (ฟังก์ชันที่ต้องการให้ทำงานเมื่อกดปุ่ม), text (ข้อความที่จะแสดงบนปุ่ม)
 * Output : ปุ่มที่สามารถกดได้และแสดงข้อความบนปุ่ม
 */
  const Button({
    super.key,
    this.onPressed,
    this.text = "จอง",
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BF6A),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: "Sarabun",
          ),
        ),
      ),
    );
  }
}