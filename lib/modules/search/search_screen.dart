import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/header.dart';
import '../../widgets/card_package.dart';
import '../../widgets/bottom_navigation_bar.dart';

import '../search/search_controller.dart';

class SearchScreen extends StatelessWidget {
  final controller = Get.put(SearchPackageController());
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // nav bar
      bottomNavigationBar: BottomNavigate(
        current: BottomNavType.HOME,
        onChanged: (type) {},
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header 
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4CAF93),
                    Color(0xFF2E7D5E),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // search bar
                  HeaderWidget(
                    onSearchChanged: (value) {
                      controller.search(value);
                    },
                  ),

                  // text ผลลัพธ์
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Obx(() => Text(
                          'ผลลัพธ์การค้นหา "${controller.keyword.value}"',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        )),
                  ),
                ],
              ),
            ),

            //packages grid
            Expanded(
              child: Obx(() {

                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF93),
                    ),
                  );
                }

                if (controller.packages.isEmpty) {
                  return const Center(
                    child: Text(
                      "ไม่พบแพ็กเกจที่ค้นหา",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),

                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,

                    childAspectRatio: 168 / 221,
                  ),

                  itemCount: controller.packages.length,

                  itemBuilder: (context, index) {

                    final pkg = controller.packages[index];

                    return PackageCard(
                      image:
                          "https://cultura-api-mobile.onrender.com${pkg["images"]?[0]?["filepath"] ?? ""}",

                      title: pkg["name"] ?? "",

                      location: pkg["address"] ?? "",

                      bookingStart: DateTime.tryParse(
                          pkg["bookingStartDate"] ?? ""),

                      bookingEnd:
                          DateTime.tryParse(pkg["bookingEndDate"] ?? ""),

                      booked: pkg["booked"] ?? 0,

                      capacity: pkg["capacity"] ?? 0,

                      tags: pkg["tags"] != null
                          ? List<String>.from(pkg["tags"])
                          : ["ไม่มีแท็ก"],

                      priceTHB: (pkg["price"] ?? 0).toDouble(),

                      onClick: () {
                        print("open package detail");
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}