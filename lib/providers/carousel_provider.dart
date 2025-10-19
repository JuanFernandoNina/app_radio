import 'package:flutter/material.dart';
import '../models/carousel_item.dart';
import '../services/supabase_service.dart';

class CarouselProvider extends ChangeNotifier {
  List<CarouselItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CarouselItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActiveCarousel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await SupabaseService.getActiveCarousel();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllCarousel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await SupabaseService.getAllCarousel();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCarousel(CarouselItem item) async {
    try {
      final created = await SupabaseService.createCarousel(item);
      _items.add(created);
      _items.sort((a, b) => a.orderPosition.compareTo(b.orderPosition));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCarousel(String id, CarouselItem item) async {
    try {
      final updated = await SupabaseService.updateCarousel(id, item);
      final idx = _items.indexWhere((i) => i.id == id);
      if (idx != -1) _items[idx] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCarousel(String id) async {
    try {
      await SupabaseService.deleteCarousel(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
