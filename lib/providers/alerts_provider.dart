import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_data.dart';
import '../models/alert_item.dart';

final alertsProvider = StateProvider<List<AlertItem>>((ref) => kMockAlerts);
