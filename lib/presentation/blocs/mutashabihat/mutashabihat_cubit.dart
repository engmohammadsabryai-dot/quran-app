import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/mutashabiha_item.dart';
import '../../../domain/repositories/i_mutashabihat_repository.dart';

class MutashabihatState extends Equatable {
  final List<MutashabihaItem> items;
  final MutashabihaItem? activeComparison;
  final bool isLoading;

  const MutashabihatState({
    this.items = const [],
    this.activeComparison,
    this.isLoading = false,
  });

  MutashabihatState copyWith({
    List<MutashabihaItem>? items,
    MutashabihaItem? activeComparison,
    bool? isLoading,
  }) {
    return MutashabihatState(
      items: items ?? this.items,
      activeComparison: activeComparison ?? this.activeComparison,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [items, activeComparison, isLoading];
}

class MutashabihatCubit extends Cubit<MutashabihatState> {
  final IMutashabihatRepository _repository;
  StreamSubscription? _subscription;

  MutashabihatCubit({required IMutashabihatRepository repository})
      : _repository = repository,
        super(const MutashabihatState(isLoading: true)) {
    _subscription = _repository.watchMutashabihat().listen((items) {
      emit(state.copyWith(items: items, isLoading: false));
    });
  }

  void openComparisonModal(MutashabihaItem item) {
    emit(state.copyWith(activeComparison: item));
  }

  void closeComparisonModal() {
    emit(state.copyWith(activeComparison: null));
  }

  List<MutashabihaItem> getForTaskRange(int surah, int fromAyah, int toAyah) {
    return _repository.getMutashabihatForAyahRange(surah, fromAyah, toAyah);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
