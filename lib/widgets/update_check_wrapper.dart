import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campus_fix/providers/update_provider.dart';
import 'package:campus_fix/widgets/update_dialog.dart';

class UpdateCheckWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const UpdateCheckWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<UpdateCheckWrapper> createState() =>
      _UpdateCheckWrapperState();
}

class _UpdateCheckWrapperState
    extends ConsumerState<UpdateCheckWrapper> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdate();
    });
  }

  Future<void> _checkForUpdate() async {
    if (_checking || !mounted) {
      return;
    }

    _checking = true;

    try {
      final update = await ref.read(
        updateStatusProvider.future,
      );

      if (!mounted || update == null) {
        debugPrint(
          '[UpdateCheck] No hay actualización disponible',
        );

        return;
      }

      final alreadyShown =
          ref.read(updateDialogShownProvider);

      if (alreadyShown) {
        return;
      }

      ref
          .read(updateDialogShownProvider.notifier)
          .state = true;

      debugPrint(
        '[UpdateCheck] Diálogo mostrado',
      );

      await showDialog(
        context: context,
        barrierDismissible: !update.isRequired,
        barrierColor: Colors.black54,
        builder: (context) {
          return PopScope(
            canPop: !update.isRequired,
            child: UpdateDialog(
              updateInfo: update,
              onLater: update.isRequired
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
            ),
          );
        },
      );
    } catch (e) {
      debugPrint(
        '[UpdateCheck] Error mostrando actualización: $e',
      );
    } finally {
      _checking = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}