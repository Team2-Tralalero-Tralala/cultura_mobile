/**
 * คำอธิบาย : Component สำหรับแสดงแถบเมนูนำทางด้านล่าง (Bottom Navigation)
 * ประกอบด้วยปุ่ม แพ็กเกจมาใหม่, หน้าแรก (ปุ่มลอยตรงกลาง), และ แพ็กเกจยอดนิยม
 */
import 'package:flutter/material.dart';

enum BottomNavType { NEW, HOME, POPULAR }

class BottomNavigate extends StatelessWidget {
  final BottomNavType active;
  final ValueChanged<BottomNavType>? onChange;

  const BottomNavigate({
    super.key,
    this.active = BottomNavType.HOME,
    this.onChange,
  });

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับกำหนดสีของไอคอนและข้อความตามสถานะ active
   * Input : type (BottomNavType) - ประเภทของเมนู
   * Output : Color - สีที่ใช้แสดงผล
   */
  Color _getItemColor(BottomNavType type) {
    if (active == type) {
      return Colors.black;
    }
    return Colors.grey;
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับสร้างปุ่มเมนูด้านล่าง (ซ้าย/ขวา)
   * Input : type (BottomNavType), icon (IconData), label (String)
   * Output : Widget - ปุ่มเมนูพร้อมไอคอนและข้อความ
   */
  Widget _buildNavItem(
    BottomNavType type,
    IconData icon,
    String label,
  ) {
    return GestureDetector(
      onTap: () => onChange?.call(type),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: _getItemColor(type),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _getItemColor(type),
            ),
          ),
        ],
      ),
    );
  }

  /*
   * คำอธิบาย : ฟังก์ชันหลักสำหรับการสร้าง UI ของ Component BottomNavigate
   * Input : context (BuildContext)
   * Output : Widget - แถบเมนูนำทางด้านล่างพร้อมปุ่มลอยตรงกลาง
   */
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNavItem(
                  BottomNavType.NEW,
                  Icons.fiber_new,
                  "แพ็กเกจมาใหม่",
                ),
                const SizedBox(width: 48),
                _buildNavItem(
                  BottomNavType.POPULAR,
                  Icons.work_outline,
                  "แพ็กเกจยอดนิยม",
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => onChange?.call(BottomNavType.HOME),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.home_outlined,
                  size: 28,
                  color: _getItemColor(BottomNavType.HOME),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}