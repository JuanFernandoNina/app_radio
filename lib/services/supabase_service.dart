import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/radio_content.dart';
import '../models/category.dart';
import '../models/carousel_item.dart';

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

  // AUTH - Login
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
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

  // CONTENT - Obtener todo el contenido activo
  static Future<List<RadioContent>> getActiveContent() async {
    final response = await client
        .from('radio_content')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List).map((json) => RadioContent.fromJson(json)).toList();
  }

  // CONTENT - Obtener todo el contenido (admin)
  static Future<List<RadioContent>> getAllContent() async {
    final response = await client
        .from('radio_content')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => RadioContent.fromJson(json)).toList();
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
  static Future<RadioContent> updateContent(String id, RadioContent content) async {
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

  // CATEGORY - Obtener / Crear / Eliminar categorías
  static Future<List<Category>> getCategories() async {
    final response = await client.from('categories').select().order('name');
    return (response as List).map((j) => Category.fromJson(j)).toList();
  }

  static Future<Category> createCategory(Category category) async {
    final response = await client.from('categories').insert(category.toJson()).select().single();
    return Category.fromJson(response);
  }

  static Future<void> deleteCategory(String id) async {
    await client.from('categories').delete().eq('id', id);
  }

  // CAROUSEL - Obtener / Crear / Actualizar / Eliminar items
  static Future<List<CarouselItem>> getActiveCarousel() async {
    final response = await client
        .from('carousel_items')
        .select()
        .eq('is_active', true)
        .order('order_position', ascending: true);
    return (response as List).map((j) => CarouselItem.fromJson(j)).toList();
  }

  static Future<List<CarouselItem>> getAllCarousel() async {
    final response = await client.from('carousel_items').select().order('order_position', ascending: true);
    return (response as List).map((j) => CarouselItem.fromJson(j)).toList();
  }

  static Future<CarouselItem> createCarousel(CarouselItem item) async {
    final response = await client.from('carousel_items').insert(item.toJson()).select().single();
    return CarouselItem.fromJson(response);
  }

  static Future<CarouselItem> updateCarousel(String id, CarouselItem item) async {
    final response = await client.from('carousel_items').update(item.toJson()).eq('id', id).select().single();
    return CarouselItem.fromJson(response);
  }

  static Future<void> deleteCarousel(String id) async {
    await client.from('carousel_items').delete().eq('id', id);
  }

  // STORAGE - Subir archivo
  static Future<String> uploadFile(String bucket, String path, List<int> bytes) async {
    final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    await client.storage.from(bucket).uploadBinary(path, data);
    return client.storage.from(bucket).getPublicUrl(path);
  }

  // STORAGE - Eliminar archivo
  static Future<void> deleteFile(String bucket, String path) async {
    await client.storage.from(bucket).remove([path]);
  }
}