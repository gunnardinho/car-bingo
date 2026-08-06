import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

/// Bootstrap seam. Firestore/Drift/prefs initialization (ARCHITECTURE.md §4)
/// lands here in the next increment; today it ensures bindings and mounts the
/// [ProviderScope]. Catalog loading happens lazily via `catalogProvider`.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: CarBingoApp()));
}
