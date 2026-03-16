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
      body: Column(
        children: [
          /// Header + search bar
          HeaderWidget(
            onSearchChanged: (value) {
              controller.search(value);
            },
          ),

          /// ข้อความผลลัพธ์
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(
              () => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'ผลลัพธ์การค้นหา "${controller.keyword.value}"',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          /// รายการ package
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),

                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
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

                    bookingStart: DateTime.tryParse(pkg["bookingStart"] ?? ""),

                    bookingEnd: DateTime.tryParse(pkg["bookingEnd"] ?? ""),

                    booked: 0,
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

          /// bottom navigation
          BottomNavigate(current: BottomNavType.HOME, onChanged: (type) {}),
        ],
      ),
    );
  }
}
