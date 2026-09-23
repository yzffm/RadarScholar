/// User profile state controller for RadarScholar.
///
/// Manages profile fetch, create, and update operations.
///
/// CPMK 4: Controller layer between Profile View and Repository.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../repositories/user_profile_repository.dart';
import 'auth_controller.dart';

/// Profile state.
sealed class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileLoaded(this.profile);
}

class ProfileNotFound extends ProfileState {
  const ProfileNotFound();
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

/// Profile controller using StateNotifier.
class ProfileController extends StateNotifier<ProfileState> {
  final UserProfileRepository _repository;

  ProfileController(this._repository) : super(const ProfileInitial());

  /// Fetch the current user's profile.
  Future<void> fetchProfile() async {
    state = const ProfileLoading();
    try {
      final profile = await _repository.getMyProfile();
      if (profile != null) {
        state = ProfileLoaded(profile);
      } else {
        state = const ProfileNotFound();
      }
    } catch (e) {
      state = ProfileError('Gagal memuat profil: $e');
    }
  }

  /// Create or update the profile.
  Future<bool> saveProfile(Map<String, dynamic> data) async {
    final currentState = state;
    state = const ProfileLoading();
    try {
      UserProfile profile;
      if (currentState is ProfileLoaded) {
        profile = await _repository.updateMyProfile(data);
      } else {
        profile = await _repository.createMyProfile(data);
      }
      state = ProfileLoaded(profile);
      return true;
    } catch (e) {
      state = ProfileError('Gagal menyimpan profil: $e');
      return false;
    }
  }
}

/// Profile state provider — automatically fetches when authenticated.
final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final repo = ref.watch(userProfileRepositoryProvider);
      final controller = ProfileController(repo);

      // Auto-fetch profile when user is authenticated
      final authState = ref.watch(authControllerProvider);
      if (authState is AuthAuthenticated) {
        controller.fetchProfile();
      }

      return controller;
    });
