import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/**
 * คำอธิบาย : Controller สำหรับจัดการ Logic ของ Carousel (เลื่อนรูปภาพอัตโนมัติ, จัดการสถานะหน้าปัจจุบัน และรายการรูปภาพ)
 */
class CarouselController extends GetxController {
  // เก็บแค่ชื่อไฟล์ตามที่ Dev แนะนำ
  final List<String> imageFiles = [
    'carousel1.jpg',
    'carousel2.jpg',
    'carousel3.png',
    'carousel4.jpg',
    'carousel5.jpg',
    'carousel6.jpg',
    'carousel7.jpg',
    'carousel8.jpg',
  ];

  final PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startAutoPlay();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับจัดการเวลาให้เลื่อนรูปอัตโนมัติทุกๆ 5 วินาที
   * Input : ไม่มี
   * Output : void
   */
  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentPage.value < imageFiles.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentPage.value,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับอัปเดต state เมื่อรูปถูกเปลี่ยน (ไม่ว่าจะปัดด้วยมือหรือเลื่อนอัตโนมัติ) และรีเซ็ตเวลาใหม่
   * Input : index (int) - ลำดับของหน้าปัจจุบันที่กำลังแสดง
   * Output : void
   */
  void handlePageChanged(int index) {
    currentPage.value = index;
    _startAutoPlay();
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับเลื่อนไปยังรูปภาพถัดไป (ฝั่งขวา)
   * Input : ไม่มี
   * Output : void
   */
  void nextPage() {
    if (currentPage.value < imageFiles.length - 1) {
      pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    } else {
      pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }

  /*
   * คำอธิบาย : ฟังก์ชันสำหรับเลื่อนไปยังรูปภาพก่อนหน้า (ฝั่งซ้าย)
   * Input : ไม่มี
   * Output : void
   */
  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    } else {
      pageController.animateToPage(imageFiles.length - 1, duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
    }
  }
}

/**
 * คำอธิบาย : Component สำหรับแสดง Carousel เลื่อนรูปภาพพร้อมจุดสถานะ (Indicator) และปุ่มกดลูกศรซ้าย-ขวา
 */
class CustomCarousel extends GetView<CarouselController> {
  
  CustomCarousel({super.key}) {
    if (!Get.isRegistered<CarouselController>()) {
      Get.put(CarouselController());
    }
  }

  /*
   * คำอธิบาย : ฟังก์ชันหลักสำหรับการสร้าง UI ของ Component CustomCarousel
   * Input : context (BuildContext)
   * Output : Widget - บล็อก Carousel ที่พร้อมแสดงผล
   */
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, 
      child: Stack(
        children: [
          // รูปภาพ
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.handlePageChanged,
            itemCount: controller.imageFiles.length,
            itemBuilder: (context, index) {
              // *** นำ Path มาต่อกับชื่อไฟล์ที่นี่ ***
              return Image.asset(
                'assets/images/${controller.imageFiles[index]}',
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),

          // ปุ่มลูกศรซ้าย
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 28),
              onPressed: controller.previousPage,
            ),
          ),

          // ปุ่มลูกศรขวา
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 28),
              onPressed: controller.nextPage,
            ),
          ),

          // จุด Indicator
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.imageFiles.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.currentPage.value == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}