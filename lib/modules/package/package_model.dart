class PackageModel {
  final int id;
  final String title;
  final String location;
  final String imageUrl;
  final DateTime? bookingStart;
  final DateTime? bookingEnd;
  final int booked;
  final int capacity;
  final List<String> tags;
  final double priceTHB;

  PackageModel({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    this.bookingStart,
    this.bookingEnd,
    this.booked = 0,
    this.capacity = 50,
    this.tags = const [],
    this.priceTHB = 0,
  });

  /*
   * คำอธิบาย : แปลง JSON จาก API ให้เป็น PackageModel
   * Input : json (Map<String, dynamic>) - ข้อมูลจาก API
   * Output : PackageModel
   */
  factory PackageModel.fromJson(Map<String, dynamic> json) {
    const baseUrl = 'https://cultura-api-mobile.onrender.com';

    // ดึง tags จาก tags[].tag.name
    List<String> parseTags(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) {
        return raw
            .map((e) {
              if (e is Map && e['tag'] is Map) {
                return e['tag']['name']?.toString() ?? '';
              }
              return e.toString();
            })
            .where((t) => t.isNotEmpty)
            .toList();
      }
      return [];
    }

    // ดึงรูป COVER จาก images[] แล้วเติม baseUrl
    String parseImageUrl(dynamic raw) {
      if (raw == null) return '';
      if (raw is List) {
        final cover = raw.firstWhere(
          (e) => e is Map && e['type'] == 'COVER',
          orElse: () => raw.isNotEmpty ? raw.first : null,
        );
        if (cover != null && cover is Map) {
          final path = cover['filepath']?.toString() ?? '';
          return path.isNotEmpty ? '$baseUrl$path' : '';
        }
      }
      return '';
    }

    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    return PackageModel(
      id: json['id'] ?? json['package_id'] ?? 0,
      title: json['name'] ?? json['title'] ?? json['package_name'] ?? '',
      location: json['address'] ?? json['location'] ?? json['place'] ?? '',
      imageUrl: parseImageUrl(json['images']),
      bookingStart: parseDate(
        json['bookingStartDate'] ?? json['booking_start'],
      ),
      bookingEnd: parseDate(json['bookingEndDate'] ?? json['booking_end']),
      booked: (json['booked'] ?? json['booked_count'] ?? 0) as int,
      capacity: (json['capacity'] ?? json['max_capacity'] ?? 50) as int,
      tags: parseTags(json['tags']),
      priceTHB:
          double.tryParse(
            (json['price'] ?? json['price_thb'] ?? 0).toString(),
          ) ??
          0,
    );
  }
}
