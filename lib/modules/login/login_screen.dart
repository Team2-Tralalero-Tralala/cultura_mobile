import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF287A5B), Color(0xFF388E6B)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- Logo Section ---
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  'assets/images/logo-white.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // --- White Card Section ---
              Expanded(
                child: Stack(
                  children: [
                    // Translucent background rounded square
                    Positioned(
                      top: 0,
                      left: 24,
                      right: 24,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    // Main White Card
                    Positioned(
                      top: 15,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Bottom Waves
                            Positioned(
                              bottom: -MediaQuery.of(context).viewInsets.bottom,
                              left: 0,
                              right: 0,
                              height: 250,
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(),
                                child: CustomPaint(
                                  painter: _BottomWavesPainter(),
                                  size: const Size(double.infinity, 250),
                                ),
                              ),
                            ),

                            // Scrollable content
                            Positioned.fill(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.only(
                                  left: 28,
                                  right: 28,
                                  top: 40,
                                  bottom: 120, // space to scroll past the wave
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    const Center(
                                      child: Text(
                                        'ยินดีต้อนรับ',
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F5A3E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Subtitle
                                    const Center(
                                      child: Text(
                                        'กรุณากรอกข้อมูลเพื่อเข้าสู่ระบบ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),

                                    // Username Label
                                    const Text(
                                      'ชื่อผู้ใช้',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Username Field
                                    TextField(
                                      controller: controller.usernameController,
                                      decoration: InputDecoration(
                                        hintText: 'ป้อนชื่อผู้ใช้',
                                        hintStyle: const TextStyle(
                                          color: Color(0xFF88DEB0),
                                        ),
                                        filled: false,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE0E0E0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF24EE98),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Password Label
                                    const Text(
                                      'รหัสผ่าน',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF424242),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Password Field
                                    Obx(
                                      () => TextField(
                                        controller:
                                            controller.passwordController,
                                        obscureText:
                                            !controller.isPasswordVisible.value,
                                        decoration: InputDecoration(
                                          hintText: 'ป้อนรหัสผ่าน',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFF88DEB0),
                                          ),
                                          filled: false,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 16,
                                              ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE0E0E0),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF24EE98),
                                              width: 1.5,
                                            ),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller.isPasswordVisible.value
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: const Color(0xFF88DEB0),
                                            ),
                                            onPressed: controller
                                                .togglePasswordVisibility,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),

                                    // Login Button
                                    Obx(
                                      () => Container(
                                        width: double.infinity,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.3,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: controller.isLoading.value
                                              ? () {}
                                              : controller.login,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF24EE98,
                                            ),
                                            foregroundColor: const Color(
                                              0xFF112D20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: controller.isLoading.value
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Color(
                                                          0xFF112D20,
                                                        ),
                                                        strokeWidth: 2.5,
                                                      ),
                                                )
                                              : const Text(
                                                  'เข้าสู่ระบบ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final fillPaint = Paint()
      ..color = const Color(0xFF24EE98)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color.fromARGB(255, 1, 61, 35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height + 100),
          radius: size.width * 0.65,
        ),
      );

    final path2 = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height + 40),
          radius: size.width * 0.55,
        ),
      );

    final combinedPath = Path.combine(PathOperation.union, path1, path2);

    // Draw filled area
    canvas.drawPath(combinedPath, fillPaint);
    // Draw white stroke
    canvas.drawPath(combinedPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
