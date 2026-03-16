import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package_detail_controller.dart';

class PackageDetailScreen extends GetView<PackageDetailController> {
  const PackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PackageDetailController>()) {
      Get.put(PackageDetailController());
    }

    // ตัวแปรสำหรับจัดการสไลด์รูปภาพที่พัก
    final PageController galleryPageController = PageController();
    final RxInt currentGalleryPage = 0.obs;

    // ตัวแปรสำหรับจัดการสไลด์รูปภาพ Cover ด้านบน
    final PageController coverPageController = PageController();
    final RxInt currentCoverPage = 0.obs;

    // ตัวแปรสำหรับจัดการจำนวนคนในแถบด้านล่าง
    final RxInt passengerCount = 1.obs;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // ===== แถบด้านล่างสำหรับกดจอง (Bottom Bar) =====
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ส่วนซ้าย: จำนวนและราคา
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('จำนวน', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      const SizedBox(width: 12),
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                if (passengerCount.value > 1) passengerCount.value--;
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
                              ),
                            ),
                            Obx(() => Text(
                                  '${passengerCount.value}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                )),
                            InkWell(
                              onTap: () => passengerCount.value++,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('คน', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final price = controller.packageData.value?['price'] ?? 0;
                    final total = price * passengerCount.value;
                    return Text(
                      'ราคาสุทธิ THB ${controller.formatPrice(total)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    );
                  }),
                ],
              ),
              // ส่วนขวา: ปุ่มจอง
              SizedBox(
                height: 44,
                width: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853), // สีเขียวตาม Mockup
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: controller.bookPackage,
                  child: const Text(
                    'จอง',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00C853)));
        }

        if (controller.errorMessage.value != null && controller.errorMessage.value!.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value ?? '', style: const TextStyle(color: Colors.red)),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('กลับไป')),
              ],
            ),
          );
        }

        final package = controller.packageData.value;
        if (package == null) return const Center(child: Text('ไม่พบข้อมูล'));

        final name = package['name'] ?? 'ไม่มีชื่อแพ็คเกจ';
        final description = package['description'] ?? '';
        final suggestion = package['suggestion'] ?? '';
        final List<dynamic> tags = package['tags'] ?? [];
        final List<dynamic> facilities = package['facilities'] ?? [];
        final List<dynamic> homestayPackages = package['homestayPackages'] ?? [];
        final List<dynamic> images = package['images'] ?? [];
        
        // แยกรูปภาพ Cover (สไลด์ด้านบน) และ Gallery (สไลด์ที่พักด้านล่าง)
        final coverUrls = images
            .where((img) => img['type'] == 'COVER')
            .map<String>((img) => 'https://cultura-api-mobile.onrender.com${img['filepath'] ?? ''}')
            .toList();
        
        // ถ้า API ไม่ได้แยก type ไว้ ให้ดึงมาใช้ทั้งหมดได้เลย
        final galleryUrls = images
            .where((img) => img['type'] == 'GALLERY')
            .map<String>((img) => 'https://cultura-api-mobile.onrender.com${img['filepath'] ?? ''}')
            .toList();
            
        final displayGalleryUrls = galleryUrls.isNotEmpty ? galleryUrls : coverUrls;
        final displayCoverUrls = coverUrls.isNotEmpty ? coverUrls : galleryUrls;

        final bookingStartDate = package['bookingStartDate'] != null ? DateTime.parse(package['bookingStartDate']) : null;
        final bookingEndDate = package['bookingEndDate'] != null ? DateTime.parse(package['bookingEndDate']) : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== 1. Hero Image Slider (COVER) & Back Button =====
              Stack(
                children: [
                  SizedBox(
                    height: 320, 
                    child: displayCoverUrls.isNotEmpty
                        ? PageView.builder(
                            controller: coverPageController,
                            onPageChanged: (index) => currentCoverPage.value = index,
                            itemCount: displayCoverUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                displayCoverUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 50)),
                              );
                            },
                          )
                        : Container(color: Colors.grey[300], child: const Center(child: Icon(Icons.image, size: 50))),
                  ),
                  
                  // ปุ่มลูกศรซ้าย-ขวา สำหรับ Cover
                  if (displayCoverUrls.length > 1)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                            onPressed: () => coverPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
                            onPressed: () => coverPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                          ),
                        ],
                      ),
                    ),
                  
                  // ปุ่ม Back
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== 2. Title & Tags & Description =====
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          // Tags
                          if (tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: tags.map<Widget>((tagItem) {
                                final tagName = tagItem is Map ? (tagItem['tag']?['name'] ?? '') : '';
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    tagName,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 12),
                          // Description
                          Text(
                            description,
                            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                          ),
                        ],
                      ),
                    ),

                    // ===== 3. Green Booking Bar =====
                    if (bookingStartDate != null && bookingEndDate != null)
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF00C853),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'เปิดจองแล้ว วันที่ ${controller.formatThaiDate(bookingStartDate)} - ${controller.formatThaiDate(bookingEndDate)}',
                          style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),

                    // ===== 4. Location Pin =====
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 20, color: Colors.black87),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'เมืองฮอยอัน (Hoi An), เวียดนามกลาง', 
                              style: TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ===== 5. Accommodation Details & GALLERY CAROUSEL =====
              if (homestayPackages.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.home_work_outlined, size: 24, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('รายละเอียดที่พัก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // กรอบที่พักทั้งหมด
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // วนลูปแสดงข้อมูลที่พัก (Text)
                              ...homestayPackages.map<Widget>((homestayItem) {
                                final homestay = homestayItem is Map ? homestayItem['homestay'] as Map? : null;
                                if (homestay == null) return const SizedBox.shrink();

                                final homestayName = homestay['name'] ?? '-';
                                final address = homestay['address'] ?? '-';
                                final type = homestay['type'] ?? 'โฮมสเตย์';
                                final capacity = homestay['capacity'] ?? 0;
                                final homeFacilities = (homestay['facilities'] as List?)?.map((f) => f['name']).join(', ') ?? '-';

                                return Column(
                                  children: [
                                    _buildHomestayInfoRow(Icons.sell_outlined, 'ชื่อที่พัก :', homestayName),
                                    _buildHomestayInfoRow(Icons.location_on_outlined, 'ที่ตั้ง :', address),
                                    _buildHomestayInfoRow(Icons.bed_outlined, 'ประเภทที่พัก :', type),
                                    _buildHomestayInfoRow(Icons.person_outline, 'ความจุผู้เข้าพัก :', 'สูงสุด $capacity คน / ห้อง'),
                                    _buildHomestayInfoRow(Icons.calendar_today_outlined, 'เช็คอิน :', 'เวลา 14.00 น.'),
                                    _buildHomestayInfoRow(Icons.calendar_month_outlined, 'เช็คเอาท์ :', 'เวลา 14.00 น.'),
                                    _buildHomestayInfoRow(Icons.chair_alt_outlined, 'สิ่งอำนวยความสะดวก :', homeFacilities),
                                  ],
                                );
                              }).toList(),

                              const SizedBox(height: 8),
                              const Text('รูปภาพที่พัก :', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 12),

                              // ===== แกลเลอรีรูปที่พัก ช่องเดียวเลื่อนซ้าย-ขวา =====
                              if (displayGalleryUrls.isNotEmpty)
                                SizedBox(
                                  height: 220, // ความสูงของรูปที่พัก
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: PageView.builder(
                                          controller: galleryPageController,
                                          onPageChanged: (index) => currentGalleryPage.value = index,
                                          itemCount: displayGalleryUrls.length,
                                          itemBuilder: (context, index) {
                                            return Image.network(
                                              displayGalleryUrls[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            );
                                          },
                                        ),
                                      ),
                                      // ลูกศรซ้าย
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                                          onPressed: () => galleryPageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                        ),
                                      ),
                                      // ลูกศรขวา
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 28),
                                          onPressed: () => galleryPageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                                        ),
                                      ),
                                      // จุดไข่ปลา
                                      Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Obx(() => Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            displayGalleryUrls.length,
                                            (index) => Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: currentGalleryPage.value == index ? Colors.white : Colors.white.withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        )),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ===== 6. Facilities Section =====
              if (facilities.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.support_agent, size: 24, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('สิ่งอำนวยความสะดวก (สำหรับแพ็คเกจ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: facilities.map<Widget>((fac) {
                            final facName = fac is Map ? fac['name'] ?? '' : '';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
                                  Expanded(child: Text(facName, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ===== 7. Suggestions/Warnings =====
              if (suggestion.isNotEmpty)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, size: 24, color: Colors.black87),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text('คำแนะนำสำหรับผู้เข้าร่วมกิจกรรม (สิ่งที่ควรทราบ & สิ่งที่ควรเตรียม)', 
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildBulletText(suggestion),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // Widget Helper สำหรับสร้างแถวรายละเอียดในกรอบที่พัก ให้เป็นระเบียบ
  Widget _buildHomestayInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          SizedBox(
            width: 140, // ฟิกซ์ความกว้างของ Label ให้ตรงกันทุกบรรทัด
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // Widget Helper สำหรับสร้าง Bullet Point
  Widget _buildBulletText(String text) {
    final lines = text.split('\n').where((e) => e.trim().isNotEmpty).toList();
    if (lines.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54)),
              Expanded(child: Text(line.replaceAll('•', '').trim(), style: const TextStyle(fontSize: 13, color: Colors.black87))),
            ],
          ),
        );
      }).toList(),
    );
  }
}