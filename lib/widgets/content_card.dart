import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/radio_content.dart';
import '../screens/player_screen.dart';

class ContentCard extends StatelessWidget {
  final RadioContent content;

  const ContentCard({super.key, required this.content});

  // Design constants
  static const Color _kAccent = Colors.amber;
  static const Color _kBackground = Colors.white;
  static const double _kBorderRadius = 17;
  static const double _kImageSize = 80.0;
  static const double _kIconSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kBackground,
        borderRadius: BorderRadius.circular(_kBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(content: content),
              ),
            );
          },
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'content-${content.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(_kBorderRadius),
                    child: content.thumbnailUrl != null
                        ? CachedNetworkImage(
                            imageUrl: content.thumbnailUrl!,
                            width: _kImageSize,
                            height: _kImageSize,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: _kImageSize,
                              height: _kImageSize,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(_kAccent),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: _kImageSize,
                              height: _kImageSize,
                              color: _kAccent.withOpacity(0.1),
                              child: const Icon(
                                Icons.radio,
                                color: Colors.white54,
                                size: 40,
                              ),
                            ),
                          )
                        : Container(
                            width: _kImageSize,
                            height: _kImageSize,
                            decoration: BoxDecoration(
                              color: _kAccent.withOpacity(0.15),
                              border: Border.all(
                                color: _kAccent.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.radio,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        content.title,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (content.description != null)
                        Text(
                          content.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 15,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        Text(
                          'Programa de radio',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (content.audioUrl != null) ...[
                            Icon(
                              Icons.audiotrack,
                              size: _kIconSize,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Audio',
                              style: TextStyle(
                                color: Colors.amber[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          if (content.videoUrl != null) ...[
                            if (content.audioUrl != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Icon(
                              Icons.videocam,
                              size: _kIconSize,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Video',
                              style: TextStyle(
                                color: Colors.amber[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.amber[600],
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Versión alternativa con diseño más grande (para destacados)
class ContentCardLarge extends StatelessWidget {
  final RadioContent content;

  const ContentCardLarge({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black87,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerScreen(content: content),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Imagen más grande
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: content.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: content.thumbnailUrl!,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.radio,
                              color: Colors.white54,
                              size: 60,
                            ),
                          ),
                        )
                      : Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepPurple[400]!,
                                Colors.deepPurple[700]!,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.radio,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                ),

                const SizedBox(width: 20),

                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (content.description != null)
                        Text(
                          content.description!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (content.audioUrl != null)
                            _buildBadge(Icons.audiotrack, 'Audio', Colors.blue),
                          if (content.videoUrl != null) ...[
                            if (content.audioUrl != null)
                              const SizedBox(width: 8),
                            _buildBadge(Icons.videocam, 'Video', Colors.purple),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
