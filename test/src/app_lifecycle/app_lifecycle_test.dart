import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle/src/app_lifecycle/app_lifecycle.dart';
import 'package:provider/provider.dart';

void main() {
  group('AppLifecycleObserver', () {
    testWidgets('should provide a ValueNotifier with initial state',
        (tester) async {
      late ValueNotifier<AppLifecycleState> lifecycleListenable;

      await tester.pumpWidget(
        AppLifecycleObserver(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  lifecycleListenable =
                      Provider.of<ValueNotifier<AppLifecycleState>>(context, listen: false);
                  return Container();
                },
              ),
            ),
          ),
        ),
      );

      expect(lifecycleListenable.value, AppLifecycleState.inactive);
    });

    testWidgets('should update lifecycle state when app state changes',
        (tester) async {
      late ValueNotifier<AppLifecycleState> lifecycleListenable;

      await tester.pumpWidget(
        AppLifecycleObserver(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  lifecycleListenable =
                      Provider.of<ValueNotifier<AppLifecycleState>>(context, listen: false);
                  return Container();
                },
              ),
            ),
          ),
        ),
      );

      // Simulate app going to background
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(lifecycleListenable.value, AppLifecycleState.paused);

      // Simulate app coming back to foreground
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(lifecycleListenable.value, AppLifecycleState.resumed);
    });
  });
}