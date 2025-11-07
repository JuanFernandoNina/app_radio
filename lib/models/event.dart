class Event {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? startTime; // Formato "HH:mm"
  final String? endTime;   // Formato "HH:mm"
  final String? imageUrl;
  final bool isReminder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.startTime,
    this.endTime,
    this.imageUrl,
    this.isReminder = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Desde JSON (Supabase)
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      imageUrl: json['image_url'] as String?,
      isReminder: json['is_reminder'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  // A JSON (para Supabase)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0], // Solo fecha
      'start_time': startTime,
      'end_time': endTime,
      'image_url': imageUrl,
      'is_reminder': isReminder,
      'is_active': isActive,
    };
  }

  // Helpers útiles
  String get timeRange {
    if (startTime != null && endTime != null) {
      return '$startTime - $endTime';
    } else if (startTime != null) {
      return startTime!;
    }
    return '';
  }

  bool get isToday {
    final now = DateTime.now();
    return eventDate.year == now.year &&
           eventDate.month == now.month &&
           eventDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return eventDate.year == tomorrow.year &&
           eventDate.month == tomorrow.month &&
           eventDate.day == tomorrow.day;
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? startTime,
    String? endTime,
    String? imageUrl,
    bool? isReminder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      imageUrl: imageUrl ?? this.imageUrl,
      isReminder: isReminder ?? this.isReminder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}