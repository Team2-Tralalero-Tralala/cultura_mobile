/**
 * คำอธิบาย : Component สำหรับแสดงแถบเมนูนำทางด้านล่าง (Bottom Navigation) 
 * โดยกำหนดให้กรอบสีดำแสดงเฉพาะไอคอน "แพ็กเกจมาใหม่" เท่านั้น
 */
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum BottomNavType { NEW, HOME, POPULAR }

class BottomNavigate extends StatelessWidget {
  final BottomNavType current;
  final Function(BottomNavType) onChanged;

  const BottomNavigate({
    super.key,
    required this.current,
    required this.onChanged,
  });

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับแปลงค่า BottomNavType เป็น index เพื่อนำไปคำนวณตำแหน่งของวงกลมไฮไลต์
   * Input : ใช้ค่าจากตัวแปร current ภายใน Class
   * Output : int - index ของเมนู (0, 1, 2)
   */
  int _getIndex() {
    switch (current) {
      case BottomNavType.NEW:
        return 0;
      case BottomNavType.HOME:
        return 1;
      case BottomNavType.POPULAR:
        return 2;
    }
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับสร้างแต่ละเมนูใน Bottom Navigation
   * Input : type (BottomNavType), icon (IconData), label (String), route (String?)
   * Output : Widget - รายการเมนู 1 ช่อง
   */
  Widget _buildItem(
    BottomNavType type,
    IconData icon,
    String label, [
    String? route,
  ]) {
    final bool showBlackBorder = type == BottomNavType.NEW;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          onChanged(type);
          if (current != type && route != null) {
            Get.toNamed(route);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showBlackBorder
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(icon, size: 34, color: Colors.black),
                  )
                : Icon(icon, size: 34, color: Colors.black),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
   * คำอธิบาย : ฟังก์ชันหลักสำหรับสร้าง UI ของ Component BottomNavigate
   * Input : context (BuildContext)
   * Output : Widget - แถบเมนูนำทางด้านล่างพร้อม Animation ไฮไลต์
   */
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double itemWidth = width / 3;
    const double circleSize = 120;

    final double leftPosition =
        (_getIndex() * itemWidth) + (itemWidth - circleSize) / 2;

    return Container(
      height: 110,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: leftPosition,
            top: -10,
            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: const BoxDecoration(
                color: Color(0xFFE5E5E5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              _buildItem(
                BottomNavType.NEW,
                Icons.fiber_new_outlined,
                "แพ็กเกจมาใหม่",
                '/newPackages',
              ),
              _buildItem(
                BottomNavType.HOME,
                Icons.home_outlined,
                "หน้าแรก",
                '/home',
              ),
              _buildItem(
                BottomNavType.POPULAR,
                Icons.work_outline,
                "แพ็กเกจยอดนิยม",
                '/popularPackages',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
