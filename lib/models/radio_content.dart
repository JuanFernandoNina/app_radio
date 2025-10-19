class RadioContent {
  final String? id;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RadioContent({
    this.id,
    required this.title,
    this.description,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RadioContent.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.tryParse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return RadioContent(
      id: json['id']?.toString(),
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String? ?? json['videoUrl'] as String?,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String?,
      isActive: (json['is_active'] as bool?) ?? (json['isActive'] as bool?) ?? true,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title.isNotEmpty) 'title': title,
      if (description != null) 'description': description,
      if (videoUrl != null) 'video_url': videoUrl,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      'is_active': isActive,
    };
  }

  RadioContent copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? audioUrl,
    String? thumbnailUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RadioContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}