import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*
 * คำอธิบาย : Interface สำหรับ Props ของ TagsSection
 * ใช้กำหนดข้อมูลที่จะส่งผ่านเข้ามาใน Component
 */
class TagsSectionProps {
  /// รายการแท็กที่จะแสดง (array of strings)
  final List<String> tags;
  
  /// ฟังก์ชันที่เรียกเมื่อคลิกแท็ก
  final ValueChanged<String>? onTagClick;

  const TagsSectionProps({
    required this.tags,
    this.onTagClick,
  });
}

/*
 * คำอธิบาย : Controller สำหรับจัดการ Logic ของ TagsSection
 * ใช้ GetX จัดการ state และ event การคลิกแท็ก
 */
class TagsSectionController extends GetxController {
  final TagsSectionProps props;

  TagsSectionController(this.props);

  /*
   * ฟังก์ชัน : handleTagClick
   * คำอธิบาย : จัดการเมื่อคลิกแท็ก
   * Input : tag (string) - แท็กที่ถูกคลิก
   * Output : void
   */
  void handleTagClick(String tag) {
    if (props.onTagClick != null) {
      props.onTagClick!(tag);
    } else {
      debugPrint("Tag clicked: $tag");
    }
  }
}

/**
 * คำอธิบาย: Component สำหรับแสดงส่วนของแท็กกิจกรรมรูปแบบ grid (กิจกรรมที่แนะนำ)
 * Input:
 *   - props: TagsSectionProps (ประกอบด้วย tags และ onTagClick)
 * Output: Widget ที่ render ส่วนของแท็ก
 */
class TagsSection extends GetView<TagsSectionController> {
  final TagsSectionProps props;

  TagsSection({
    super.key,
    required this.props,
  }) {
    // ลงทะเบียน Controller ถ้ายังไม่มี
    if (!Get.isRegistered<TagsSectionController>(tag: props.hashCode.toString())) {
      Get.put(TagsSectionController(props), tag: props.hashCode.toString());
    }
  }

  @override
  String? get tag => props.hashCode.toString();

  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tags Grid
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: props.tags.map((tag) {
                return Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: InkWell(
                    onTap: () => controller.handleTagClick(tag),
                    borderRadius: BorderRadius.circular(8.0),
                    hoverColor: Colors.grey.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
