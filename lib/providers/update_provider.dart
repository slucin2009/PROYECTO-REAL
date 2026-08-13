import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_fix/models/app_version.dart';
import 'package:campus_fix/services/update_service.dart';

final updateStatusProvider = FutureProvider<AppVersion?>(
  (ref) async {
    final updateService = UpdateService();

    try {
      return await updateService.checkForUpdates();
    } catch (_) {
      return null;
    }
  },
);

final updateDialogShownProvider =
    StateProvider<bool>((ref) => false);