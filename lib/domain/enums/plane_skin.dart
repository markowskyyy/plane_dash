enum SkinStatus { available, purchased, selected }

class PlaneSkin {
  final String id;
  final String name;
  final String assetImage;
  final int price;
  SkinStatus status;

  PlaneSkin({
    required this.id,
    required this.name,
    required this.assetImage,
    required this.price,
    this.status = SkinStatus.available,
  });
}