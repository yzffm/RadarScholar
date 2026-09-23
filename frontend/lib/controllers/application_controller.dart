import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application.dart';
import '../repositories/application_repository.dart';

// --- Repository Provider ---

// applicationRepositoryProvider is now provided directly in application_repository.dart
// We just re-export or use it directly from there.

// --- Saved Scholarships State ---

sealed class SavedScholarshipsState {
  const SavedScholarshipsState();
}

class SavedScholarshipsInitial extends SavedScholarshipsState {
  const SavedScholarshipsInitial();
}

class SavedScholarshipsLoading extends SavedScholarshipsState {
  const SavedScholarshipsLoading();
}

class SavedScholarshipsSuccess extends SavedScholarshipsState {
  final List<SavedScholarship> savedScholarships;
  const SavedScholarshipsSuccess(this.savedScholarships);
}

class SavedScholarshipsEmpty extends SavedScholarshipsState {
  const SavedScholarshipsEmpty();
}

class SavedScholarshipsError extends SavedScholarshipsState {
  final String message;
  const SavedScholarshipsError(this.message);
}

class SavedScholarshipsController
    extends StateNotifier<SavedScholarshipsState> {
  final ApplicationRepository _repository;

  SavedScholarshipsController(this._repository)
    : super(const SavedScholarshipsInitial());

  Future<void> fetchSavedScholarships() async {
    state = const SavedScholarshipsLoading();
    try {
      final items = await _repository.getSavedScholarships();
      if (items.isEmpty) {
        state = const SavedScholarshipsEmpty();
      } else {
        state = SavedScholarshipsSuccess(items);
      }
    } catch (e) {
      state = const SavedScholarshipsError(
        'Gagal memuat beasiswa yang disimpan.',
      );
    }
  }

  Future<void> saveScholarship(String scholarshipId) async {
    try {
      await _repository.saveScholarship(scholarshipId);
      await fetchSavedScholarships(); // Refresh list
    } catch (e) {
      // Handle error gracefully or throw to UI
      throw Exception('Gagal menyimpan beasiswa');
    }
  }

  Future<void> unsaveScholarship(String scholarshipId) async {
    try {
      await _repository.unsaveScholarship(scholarshipId);
      if (state is SavedScholarshipsSuccess) {
        final currentItems =
            (state as SavedScholarshipsSuccess).savedScholarships;
        final updatedItems = currentItems
            .where((s) => s.scholarshipId != scholarshipId)
            .toList();
        if (updatedItems.isEmpty) {
          state = const SavedScholarshipsEmpty();
        } else {
          state = SavedScholarshipsSuccess(updatedItems);
        }
      } else {
        await fetchSavedScholarships();
      }
    } catch (e) {
      throw Exception('Gagal menghapus beasiswa yang disimpan');
    }
  }
}

final savedScholarshipsControllerProvider =
    StateNotifierProvider<SavedScholarshipsController, SavedScholarshipsState>((
      ref,
    ) {
      final repo = ref.watch(applicationRepositoryProvider);
      return SavedScholarshipsController(repo);
    });

// --- Applications State ---

sealed class ApplicationsState {
  const ApplicationsState();
}

class ApplicationsInitial extends ApplicationsState {
  const ApplicationsInitial();
}

class ApplicationsLoading extends ApplicationsState {
  const ApplicationsLoading();
}

class ApplicationsSuccess extends ApplicationsState {
  final List<Application> applications;
  const ApplicationsSuccess(this.applications);
}

class ApplicationsEmpty extends ApplicationsState {
  const ApplicationsEmpty();
}

class ApplicationsError extends ApplicationsState {
  final String message;
  const ApplicationsError(this.message);
}

class ApplicationsController extends StateNotifier<ApplicationsState> {
  final ApplicationRepository _repository;

  ApplicationsController(this._repository) : super(const ApplicationsInitial());

  Future<void> fetchApplications() async {
    state = const ApplicationsLoading();
    try {
      final items = await _repository.getApplications();
      if (items.isEmpty) {
        state = const ApplicationsEmpty();
      } else {
        state = ApplicationsSuccess(items);
      }
    } catch (e) {
      state = const ApplicationsError('Gagal memuat aplikasi beasiswa.');
    }
  }

  Future<void> createApplication(
    String scholarshipId, {
    DateTime? targetDeadline,
    String? notes,
  }) async {
    try {
      await _repository.createApplication(
        scholarshipId: scholarshipId,
        targetDeadline: targetDeadline,
        notes: notes,
      );
      await fetchApplications();
    } catch (e) {
      throw Exception(
        'Gagal membuat tracking aplikasi. Mungkin Anda sudah memiliki tracking untuk beasiswa ini.',
      );
    }
  }
}

final applicationsControllerProvider =
    StateNotifierProvider<ApplicationsController, ApplicationsState>((ref) {
      final repo = ref.watch(applicationRepositoryProvider);
      return ApplicationsController(repo);
    });

// --- Application Detail State ---

final applicationDetailProvider = FutureProvider.family<Application, String>((
  ref,
  id,
) async {
  final repo = ref.watch(applicationRepositoryProvider);
  return await repo.getApplication(id);
});
