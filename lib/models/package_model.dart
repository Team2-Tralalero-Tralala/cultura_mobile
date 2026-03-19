class PackageModel {
  final int id;
  final String name;
  final String description;
  final String? address;
  final DateTime bookingStartDate;
  final DateTime bookingEndDate;
  final List<TagItem> tags;
  final double price;
  final String suggestion;
  final int capacity;
  final List<Facility> facilities;
  final List<HomestayPackage> homestayPackages;
  final List<ImageItem> images;

  PackageModel({
    required this.id,
    required this.name,
    required this.description,
    this.address,
    required this.bookingStartDate,
    required this.bookingEndDate,
    required this.tags,
    required this.price,
    required this.suggestion,
    required this.capacity,
    required this.facilities,
    required this.homestayPackages,
    required this.images,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'],
      bookingStartDate: DateTime.parse(json['bookingStartDate'] ?? DateTime.now().toIso8601String()),
      bookingEndDate: DateTime.parse(json['bookingEndDate'] ?? DateTime.now().toIso8601String()),
      tags: (json['tags'] as List?)?.map((e) => TagItem.fromJson(e)).toList() ?? [],
      price: (json['price'] ?? 0).toDouble(),
      suggestion: json['suggestion'] ?? '',
      capacity: json['capacity'] ?? 0,
      facilities: (json['facilities'] as List?)?.map((e) => Facility.fromJson(e)).toList() ?? [],
      homestayPackages: (json['homestayPackages'] as List?)?.map((e) => HomestayPackage.fromJson(e)).toList() ?? [],
      images: (json['images'] as List?)?.map((e) => ImageItem.fromJson(e)).toList() ?? [],
    );
  }
}

class TagItem {
  final Tag tag;

  TagItem({required this.tag});

  factory TagItem.fromJson(Map<String, dynamic> json) {
    return TagItem(
      tag: Tag.fromJson(json['tag']),
    );
  }
}

class Tag {
  final String name;

  Tag({required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'] ?? '',
    );
  }
}

class Facility {
  final String name;

  Facility({required this.name});

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      name: json['name'] ?? '',
    );
  }
}

class HomestayPackage {
  final Homestay homestay;

  HomestayPackage({required this.homestay});

  factory HomestayPackage.fromJson(Map<String, dynamic> json) {
    return HomestayPackage(
      homestay: Homestay.fromJson(json['homestay']),
    );
  }
}

class Homestay {
  final String name;
  final String address;
  final String description;
  final String type;
  final int capacity;
  final List<Facility> facilities;

  Homestay({
    required this.name,
    required this.address,
    required this.description,
    required this.type,
    required this.capacity,
    required this.facilities,
  });

  factory Homestay.fromJson(Map<String, dynamic> json) {
    return Homestay(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 0,
      facilities: (json['facilities'] as List?)?.map((e) => Facility.fromJson(e)).toList() ?? [],
    );
  }
}

class ImageItem {
  final String type;
  final String filepath;

  ImageItem({
    required this.type,
    required this.filepath,
  });

  factory ImageItem.fromJson(Map<String, dynamic> json) {
    return ImageItem(
      type: json['type'] ?? '',
      filepath: json['filepath'] ?? '',
    );
  }

  String getFullUrl(String baseUrl) {
    return '$baseUrl$filepath';
  }
}
