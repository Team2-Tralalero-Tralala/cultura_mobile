/**
 * คำอธิบาย : Component สำหรับแสดงข้อมูลแพ็กเกจท่องเที่ยว (รูปภาพ, ชื่อ, สถานที่, สถานะการจอง, จำนวนคน, แท็ก และราคา)
 */
import 'package:flutter/material.dart';

enum BookingStatus { OPEN, CLOSED, UPCOMING }

class PackageCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final DateTime? bookingStart;
  final DateTime? bookingEnd;
  final BookingStatus bookingStatus;
  final String? statusText;
  final int booked;
  final int capacity;
  final List<String> tags;
  final double priceTHB;
  final VoidCallback? onClick;

  const PackageCard({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    this.bookingStart,
    this.bookingEnd,
    this.bookingStatus = BookingStatus.OPEN,
    this.statusText,
    this.booked = 0,
    this.capacity = 50,
    this.tags = const [],
    this.priceTHB = 0,
    this.onClick,
  });

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับแปลงวันที่ให้อยู่ในรูปแบบวันที่ไทย (เช่น 25 พ.ค. 2568)
   * Input : d (DateTime?) - วันที่ที่ต้องการแปลง
   * Output : String - ข้อความวันที่ในรูปแบบภาษาไทย
   */
  String _formatThaiDate(DateTime? d) {
    if (d == null) return "";
    final months = [
      "", "ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
      "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."
    ];
    final yearBE = d.year + 543;
    return "${d.day} ${months[d.month]} $yearBE";
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับสร้างข้อความแสดงสถานะการจองตามเงื่อนไขของสถานะและช่วงวัน
   * Input : ข้อมูลจากตัวแปรภายใน Class (bookingStatus, bookingStart, bookingEnd, statusText)
   * Output : String - ข้อความสถานะการจองที่พร้อมแสดงผล
   */
  String _buildStatusText() {
    if (statusText != null && statusText!.isNotEmpty) return statusText!;

    final startStr = _formatThaiDate(bookingStart);
    final endStr = _formatThaiDate(bookingEnd);

    if (bookingStatus == BookingStatus.OPEN && bookingStart != null && bookingEnd != null) {
      return "เปิดจองแล้ว วันที่ $startStr ถึง $endStr";
    }
    if (bookingStatus == BookingStatus.UPCOMING && bookingStart != null) {
      return "เปิดให้จองวันที่ $startStr";
    }
    if (bookingStatus == BookingStatus.CLOSED && bookingEnd != null) {
      return "ปิดจองแล้ว ตั้งแต่ $endStr";
    }
    return "สถานะการจอง";
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับกำหนดสีของป้ายสถานะ (Badge) ตามสถานะการจอง
   * Input : ข้อมูลจากตัวแปร bookingStatus
   * Output : Color - ค่าสีที่กำหนดตามมาตรฐาน UI
   */
  Color _getBadgeColor() {
    switch (bookingStatus) {
      case BookingStatus.OPEN:
        return const Color(0xFF00C853); // emerald-600
      case BookingStatus.UPCOMING:
        return const Color(0xFFFFB300); // amber-500
      case BookingStatus.CLOSED:
        return const Color(0xFF94A3B8); // slate-400
    }
  }

  /*
   * คำอธิบาย : ฟังก์ชันหลักสำหรับการสร้าง UI ของ Component PackageCard
   * Input : context (BuildContext)
   * Output : Widget - บล็อกการ์ดหนึ่งใบที่ประกอบด้วยข้อมูลทั้งหมด
   */
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: 168,
        height: 221,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: onClick != null 
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพ
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                image,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            
            // เนื้อหา
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 7),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // ป้ายสถานะ (Badge)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _buildStatusText(),
                        style: const TextStyle(color: Colors.white, fontSize: 7),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    Text(
                      'จำนวนคน $booked/$capacity จองแล้ว',
                      style: const TextStyle(fontSize: 8, color: Color(0xFF475569)),
                    ),
                    
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: [
                        ...tags.take(3).map((t) => _buildTag(t)),
                        if (tags.length > 3) _buildTag('...'),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      'ราคา THB ${priceTHB.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับสร้าง Widget ของแต่ละแท็กเพื่อใช้ในการแสดงผล
   * Input : text (String) - ข้อความที่ต้องการแสดงในแท็ก
   * Output : Widget - กล่องข้อความแท็กที่มีรูปแบบตามดีไซน์
   */
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 7, color: Colors.grey),
        maxLines: 1,
      ),
    );
  }
}