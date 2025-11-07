import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/radio_content.dart';
import '../models/category.dart';
import '../models/carousel_item.dart';
import '../models/event.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Inicializar Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // ==================== AUTH ====================

  // AUTH - Login
  static Future<AuthResponse> signInWithEmail(
      String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // AUTH - Logout
  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // AUTH - Usuario actual
  static User? get currentUser => client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ==================== CONTENT ====================

  // CONTENT - Obtener todo el contenido activo
  static Future<List<RadioContent>> getActiveContent() async {
    final response = await client
        .from('radio_content')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RadioContent.fromJson(json))
        .toList();
  }

  // CONTENT - Obtener todo el contenido (admin)
  static Future<List<RadioContent>> getAllContent() async {
    final response = await client
        .from('radio_content')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RadioContent.fromJson(json))
        .toList();
  }

  // CONTENT - Crear contenido
  static Future<RadioContent> createContent(RadioContent content) async {
    final response = await client
        .from('radio_content')
        .insert(content.toJson())
        .select()
        .single();

    return RadioContent.fromJson(response);
  }

  // CONTENT - Actualizar contenido
  static Future<RadioContent> updateContent(
      String id, RadioContent content) async {
    final response = await client
        .from('radio_content')
        .update(content.toJson())
        .eq('id', id)
        .select()
        .single();

    return RadioContent.fromJson(response);
  }

  // CONTENT - Eliminar contenido
  static Future<void> deleteContent(String id) async {
    await client.from('radio_content').delete().eq('id', id);
  }

  // ==================== CATEGORY ====================

  // CATEGORY - Obtener categorías
  static Future<List<Category>> getCategories() async {
    final response = await client.from('categories').select().order('name');
    return (response as List).map((j) => Category.fromJson(j)).toList();
  }

  // CATEGORY - Crear categoría
  static Future<Category> createCategory(Category category) async {
    final response = await client
        .from('categories')
        .insert(category.toJson())
        .select()
        .single();
    return Category.fromJson(response);
  }

  // CATEGORY - Eliminar categoría
  static Future<void> deleteCategory(String id) async {
    await client.from('categories').delete().eq('id', id);
  }

  // ==================== CAROUSEL ====================

  // CAROUSEL - Obtener carrusel activo
  static Future<List<CarouselItem>> getActiveCarousel() async {
    final response = await client
        .from('carousel_items')
        .select()
        .eq('is_active', true)
        .order('order_position', ascending: true);
    return (response as List).map((j) => CarouselItem.fromJson(j)).toList();
  }

  // CAROUSEL - Obtener todo el carrusel (admin)
  static Future<List<CarouselItem>> getAllCarousel() async {
    final response = await client
        .from('carousel_items')
        .select()
        .order('order_position', ascending: true);
    return (response as List).map((j) => CarouselItem.fromJson(j)).toList();
  }

  // CAROUSEL - Crear item
  static Future<CarouselItem> createCarousel(CarouselItem item) async {
    final response = await client
        .from('carousel_items')
        .insert(item.toJson())
        .select()
        .single();
    return CarouselItem.fromJson(response);
  }

  // CAROUSEL - Actualizar item
  static Future<CarouselItem> updateCarousel(
      String id, CarouselItem item) async {
    final response = await client
        .from('carousel_items')
        .update(item.toJson())
        .eq('id', id)
        .select()
        .single();
    return CarouselItem.fromJson(response);
  }

  // CAROUSEL - Eliminar item
  static Future<void> deleteCarousel(String id) async {
    await client.from('carousel_items').delete().eq('id', id);
  }

  // ==================== EVENTS ====================

  // EVENTS - Obtener eventos activos
  static Future<List<Event>> getActiveEvents() async {
    final response = await client
        .from('events')
        .select()
        .eq('is_active', true)
        .order('event_date', ascending: true);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // EVENTS - Obtener eventos por rango de fechas
  static Future<List<Event>> getEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await client
        .from('events')
        .select()
        .eq('is_active', true)
        .gte('event_date', startDate.toIso8601String().split('T')[0])
        .lte('event_date', endDate.toIso8601String().split('T')[0])
        .order('event_date', ascending: true)
        .order('start_time', ascending: true);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // EVENTS - Obtener eventos de hoy
  static Future<List<Event>> getTodayEvents() async {
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];

    final response = await client
        .from('events')
        .select()
        .eq('is_active', true)
        .eq('event_date', todayStr)
        .order('start_time', ascending: true);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // EVENTS - Obtener próximos recordatorios
  static Future<List<Event>> getUpcomingReminders({int days = 7}) async {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));

    final response = await client
        .from('events')
        .select()
        .eq('is_active', true)
        .eq('is_reminder', true)
        .gte('event_date', now.toIso8601String().split('T')[0])
        .lte('event_date', future.toIso8601String().split('T')[0])
        .order('event_date', ascending: true)
        .order('start_time', ascending: true);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // EVENTS - Obtener todos los eventos (admin)
  static Future<List<Event>> getAllEvents() async {
    final response = await client
        .from('events')
        .select()
        .order('event_date', ascending: false);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // EVENTS - Crear evento
  static Future<Event> createEvent(Event event) async {
    final response =
        await client.from('events').insert(event.toJson()).select().single();

    return Event.fromJson(response);
  }

  // EVENTS - Actualizar evento
  static Future<Event> updateEvent(String id, Event event) async {
    final response = await client
        .from('events')
        .update(event.toJson())
        .eq('id', id)
        .select()
        .single();

    return Event.fromJson(response);
  }

  // EVENTS - Eliminar evento
  static Future<void> deleteEvent(String id) async {
    await client.from('events').delete().eq('id', id);
  }

  // EVENTS - Toggle estado activo
  static Future<Event> toggleEventActive(String id, bool isActive) async {
    final response = await client
        .from('events')
        .update({'is_active': isActive})
        .eq('id', id)
        .select()
        .single();

    return Event.fromJson(response);
  }

  // ==================== STORAGE ====================

  // STORAGE - Subir archivo
  static Future<String> uploadFile(
      String bucket, String path, List<int> bytes) async {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(path, data);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  // STORAGE - Eliminar archivo
  static Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}
