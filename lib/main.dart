import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'modules/login/login_controller.dart';
import 'modules/login/login_screen.dart';
import 'modules/home/home_screen.dart';
import 'modules/package/popular_package_screen.dart';
import 'modules/package/new_package_screen.dart';
import 'modules/package/detail_package_screen.dart';
import 'modules/package/search_package_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const CulturaApp());
}

class CulturaApp extends StatelessWidget {
  const CulturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cultura Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2ECC8F)),
        textTheme: GoogleFonts.sarabunTextTheme(),
      ),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<LoginController>(() => LoginController());
      }),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/popularPackages',
          page: () => const PopularPackageScreen(),
        ),
        GetPage(name: '/newPackages', page: () => const NewPackageScreen()),
        GetPage(
          name: '/packageDetail',
          page: () => const PackageDetailScreen(),
        ),
        GetPage(
          name: '/searchPackages',
          page: () => const SearchPackageScreen(),
        ),
      ],
    );
  }
}
