import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/hybrid_audio_player_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/models/daily_task.dart';

class AudioCubit extends Cubit<PlaybackProgressState> {
  final HybridAudioPlayerService _audioService;
  StreamSubscription? _progressSubscription;

  AudioCubit({required HybridAudioPlayerService audioService})
      : _audioService = audioService,
        super(audioService.currentState) {
    _progressSubscription = _audioService.progressStream.listen((state) {
      emit(state);
    });
  }

  Future<void> playTask(DailyTask task) async {
    final List<AyahPlaybackItem> items = [];
    for (int a = task.fromAyah; a <= task.toAyah; a++) {
      items.add(
        AyahPlaybackItem(
          surahNumber: task.surahNumber,
          ayahNumber: a,
          surahArabicName: task.surahArabicName,
          textArabic: 'الآية رقم $a من سورة ${task.surahArabicName}',
        ),
      );
    }
    await _audioService.loadAyahPortion(items, autoPlay: true);
  }

  Future<void> playAyahRange({
    required int surahNumber,
    required String surahArabicName,
    required int fromAyah,
    required int toAyah,
  }) async {
    final List<AyahPlaybackItem> items = [];
    for (int a = fromAyah; a <= toAyah; a++) {
      items.add(
        AyahPlaybackItem(
          surahNumber: surahNumber,
          ayahNumber: a,
          surahArabicName: surahArabicName,
          textArabic: 'الآية رقم $a من سورة $surahArabicName',
        ),
      );
    }
    await _audioService.loadAyahPortion(items, autoPlay: true);
  }

  Future<void> togglePlayPause() => _audioService.togglePlayPause();
  Future<void> skipNext() => _audioService.skipNext();
  Future<void> skipPrevious() => _audioService.skipPrevious();
  Future<void> seekToAyahIndex(int index) => _audioService.seekToAyahIndex(index);

  void setRepetitionSettings({
    int? ayahRepeats,
    int? portionCycles,
    int? intervalDelay,
    ReciterInfo? reciter,
    bool? autoDownload,
  }) {
    _audioService.setRepetitionSettings(
      ayahRepeats: ayahRepeats,
      portionCycles: portionCycles,
      intervalDelay: intervalDelay,
      reciter: reciter,
      autoDownload: autoDownload,
    );
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
