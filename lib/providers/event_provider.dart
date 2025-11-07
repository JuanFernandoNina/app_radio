import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/supabase_service.dart';

class EventProvider with ChangeNotifier {
  List<Event> _events = [];
  List<Event> _todayEvents = [];
  List<Event> _reminders = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Event> get events => _events;
  List<Event> get todayEvents => _todayEvents;
  List<Event> get reminders => _reminders;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Eventos filtrados por fecha seleccionada
  List<Event> get eventsForSelectedDate {
    return _events.where((event) {
      return event.eventDate.year == _selectedDate.year &&
             event.eventDate.month == _selectedDate.month &&
             event.eventDate.day == _selectedDate.day;
    }).toList();
  }

  // Obtener eventos de la semana actual
  List<Event> get weekEvents {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _events.where((event) {
      return event.eventDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             event.eventDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }

  // Cambiar fecha seleccionada
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Cargar eventos activos
  Future<void> loadActiveEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await SupabaseService.getActiveEvents();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar eventos: ${e.toString()}';
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar eventos por rango de fechas
  Future<void> loadEventsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await SupabaseService.getEventsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = 'Error al cargar eventos: ${e.toString()}';
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar eventos de hoy
  Future<void> loadTodayEvents() async {
    try {
      _todayEvents = await SupabaseService.getTodayEvents();
      notifyListeners();
    } catch (e) {
      _todayEvents = [];
    }
  }

  // Cargar recordatorios
  Future<void> loadReminders({int days = 7}) async {
    try {
      _reminders = await SupabaseService.getUpcomingReminders(days: days);
      notifyListeners();
    } catch (e) {
      _reminders = [];
    }
  }

  // Cargar todo (eventos del mes + hoy + recordatorios)
  Future<void> loadAll() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    await Future.wait([
      loadEventsByDateRange(startDate: startOfMonth, endDate: endOfMonth),
      loadTodayEvents(),
      loadReminders(),
    ]);
  }

  // Refrescar todo
  Future<void> refresh() async {
    await loadAll();
  }

  // Verificar si una fecha tiene eventos
  bool hasEventsOnDate(DateTime date) {
    return _events.any((event) =>
        event.eventDate.year == date.year &&
        event.eventDate.month == date.month &&
        event.eventDate.day == date.day);
  }

  // Contar eventos en una fecha
  int countEventsOnDate(DateTime date) {
    return _events.where((event) =>
        event.eventDate.year == date.year &&
        event.eventDate.month == date.month &&
        event.eventDate.day == date.day).length;
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}