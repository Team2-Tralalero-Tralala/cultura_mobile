import 'package:flutter/material.dart';

class CategoryItem {
  final String label;
  final String iconName;
  final VoidCallback? onClick;

  const CategoryItem({
    required this.label,
    required this.iconName,
    this.onClick,
  });
}

class CategoryWidget extends StatelessWidget {
  final List<CategoryItem>? categories;

  const CategoryWidget({super.key, this.categories});

  static final List<CategoryItem> _defaultCategories = [
    const CategoryItem(label: 'ทะเล', iconName: 'waves'),
    const CategoryItem(label: 'ที่พัก', iconName: 'hotel'),
    const CategoryItem(label: 'ล่องเรือ', iconName: 'directions_boat'),
    const CategoryItem(label: 'แคมป์ปิ้ง', iconName: 'local_fire_department'),
    const CategoryItem(label: 'ปีนเขา', iconName: 'terrain'),
    const CategoryItem(label: 'ธรรมชาติ', iconName: 'forest'),
    const CategoryItem(label: 'โฮมสเตย์', iconName: 'change_history'),
    const CategoryItem(label: 'อื่นๆ', iconName: 'directions_bike'),
  ];

  static const Map<String, IconData> _iconMap = {
    'waves': Icons.waves_outlined,
    'hotel': Icons.hotel_outlined,
    'directions_boat': Icons.directions_boat_outlined,
    'local_fire_department': Icons.local_fire_department_outlined,
    'terrain': Icons.terrain_outlined,
    'forest': Icons.forest_outlined,
    'change_history': Icons.change_history_outlined,
    'directions_bike': Icons.directions_bike_outlined,
  };

  IconData _resolveIcon(String iconName) {
    return _iconMap[iconName] ?? Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final items = (categories == null || categories!.isEmpty)
        ? _defaultCategories
        : categories!;

    return SizedBox(
      width: double.infinity,
      height: 112,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      _CategoryTile(
                        item: items[i],
                        icon: _resolveIcon(items[i].iconName),
                      ),
                      if (i != items.length - 1) const SizedBox(width: 18),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryItem item;
  final IconData icon;

  const _CategoryTile({required this.item, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: item.onClick ?? () {},
      child: SizedBox(
        width: 58,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 33, color: Colors.black),
            ),
            const SizedBox(height: 9),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
