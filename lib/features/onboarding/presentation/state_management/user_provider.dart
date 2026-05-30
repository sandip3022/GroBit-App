import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class UserState {
  final String name;
  final bool isOnboardingCompleted;
  final bool isBackRestored;

  UserState({required this.name, required this.isOnboardingCompleted,required this.isBackRestored});
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState(name: '', isOnboardingCompleted: false, isBackRestored: false)) {
    _loadUser();
  }

  void _loadUser() {
    final box = Hive.box('settings');
    final name = box.get('userName', defaultValue: '') as String;
    final completed = box.get('onboardingCompleted', defaultValue: false) as bool;
    final isBackRestored = box.get('isBackRestored', defaultValue: false) as bool;
    state = UserState(name: name, isOnboardingCompleted: completed, isBackRestored: isBackRestored);
  }

  Future<void> setName(String name) async {
    final box = Hive.box('settings');
    await box.put('userName', name);
    state = UserState(name: name, isOnboardingCompleted: state.isOnboardingCompleted, isBackRestored: state.isBackRestored);
  }

  Future<void> setisBackRestored(bool value) async {
    final box = Hive.box('settings');
    await box.put('isBackRestored', value);
    state = UserState(name: state.name, isOnboardingCompleted: state.isOnboardingCompleted, isBackRestored: value);
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboardingCompleted', true);
    state = UserState(name: state.name, isOnboardingCompleted: true, isBackRestored: state.isBackRestored);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});