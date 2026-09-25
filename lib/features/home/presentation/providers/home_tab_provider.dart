import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HomeTab { converter, history, settings }

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTab>(
  HomeTabNotifier.new,
);

class HomeTabNotifier extends Notifier<HomeTab> {
  @override
  HomeTab build() => HomeTab.converter;

  void select(HomeTab tab) => state = tab;
}
