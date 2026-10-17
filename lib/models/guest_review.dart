class GuestReview {
  final String customerName;
  final String avatarIcon;
  final int stars;
  final String comment;
  final String timestamp;
  final String experienceType;
  final String fixTarget;

  GuestReview({
    required this.customerName,
    required this.avatarIcon,
    required this.stars,
    required this.comment,
    this.timestamp = 'Just now',
    this.experienceType = 'normal',
    this.fixTarget = '',
  });

  Map<String, dynamic> toJson() => {
    'customer_name': customerName,
    'avatar_icon': avatarIcon,
    'stars': stars,
    'comment': comment,
    'timestamp': timestamp,
    'experience_type': experienceType,
    'fix_target': fixTarget,
  };

  factory GuestReview.fromJson(Map<String, dynamic> json) {
    return GuestReview(
      customerName: json['customer_name'] as String? ?? 'Guest',
      avatarIcon: json['avatar_icon'] as String? ?? '😋',
      stars: json['stars'] as int? ?? 5,
      comment: json['comment'] as String? ?? 'Great service!',
      timestamp: json['timestamp'] as String? ?? 'Just now',
      experienceType: json['experience_type'] as String? ?? 'normal',
      fixTarget: json['fix_target'] as String? ?? '',
    );
  }

  static List<GuestReview> createStarterReviews() {
    return [
      GuestReview(
        customerName: 'Henri Le Blanc',
        avatarIcon: '👑',
        stars: 5,
        comment: 'A culinary marvel! Exceptional plating and impeccable flavor profile.',
        timestamp: '1m ago',
        experienceType: 'critic',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'Emily Watson',
        avatarIcon: '⚡',
        stars: 5,
        comment: 'Fastest burger in town! Left a 30% speedy tip!',
        timestamp: '2m ago',
        experienceType: 'speedy',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'David Miller',
        avatarIcon: '🍨',
        stars: 5,
        comment: 'The 50s Milkshake Bar and Wurlitzer Jukebox vibe is unmatched!',
        timestamp: '3m ago',
        experienceType: 'ambience',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'Warren Sterling',
        avatarIcon: '💼',
        stars: 5,
        comment: 'Outstanding franchise potential! Generous returns on every burger flipped.',
        timestamp: '5m ago',
        experienceType: 'investor',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'Marcus Vance',
        avatarIcon: '✨',
        stars: 5,
        comment: 'Sparkling clean dining room and spotless booths. A joy to eat here!',
        timestamp: '7m ago',
        experienceType: 'cleanliness',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'Chloe Bennett',
        avatarIcon: '🍔',
        stars: 4,
        comment: 'Delicious food and cozy atmosphere, definitely coming back!',
        timestamp: '9m ago',
        experienceType: 'normal',
        fixTarget: '',
      ),
      GuestReview(
        customerName: 'Arthur Pendelton',
        avatarIcon: '⏳',
        stars: 2,
        comment: 'Waited forever at the table and left hungry.',
        timestamp: '12m ago',
        experienceType: 'walkout',
        fixTarget: 'waiter',
      ),
      GuestReview(
        customerName: 'Sophia Reynolds',
        avatarIcon: '😋',
        stars: 5,
        comment: 'Crispy fries and juicy patties. Best lunch spot downtown!',
        timestamp: '15m ago',
        experienceType: 'normal',
        fixTarget: '',
      ),
    ];
  }
}

class StarRatingBreakdown {
  final double overall;
  final String overallFormatted;
  final double foodQuality;
  final double serviceSpeed;
  final double ambience;
  final double cleanliness;

  StarRatingBreakdown({
    required this.overall,
    required this.overallFormatted,
    required this.foodQuality,
    required this.serviceSpeed,
    required this.ambience,
    required this.cleanliness,
  });

  Map<String, dynamic> toJson() => {
    'overall': overall,
    'overall_formatted': overallFormatted,
    'food_quality': foodQuality,
    'service_speed': serviceSpeed,
    'ambience': ambience,
    'cleanliness': cleanliness,
  };

  factory StarRatingBreakdown.fromJson(Map<String, dynamic> json) {
    return StarRatingBreakdown(
      overall: (json['overall'] as num?)?.toDouble() ?? 5.0,
      overallFormatted: json['overall_formatted'] as String? ?? '5.0',
      foodQuality: (json['food_quality'] as num?)?.toDouble() ?? 5.0,
      serviceSpeed: (json['service_speed'] as num?)?.toDouble() ?? 5.0,
      ambience: (json['ambience'] as num?)?.toDouble() ?? 5.0,
      cleanliness: (json['cleanliness'] as num?)?.toDouble() ?? 5.0,
    );
  }
}
