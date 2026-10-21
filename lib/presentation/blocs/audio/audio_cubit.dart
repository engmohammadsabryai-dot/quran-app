import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/audio/hybrid_audio_player_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/local/quran_text_data.dart';
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
          textArabic: QuranTextData.getAyahText(task.surahNumber, a, task.surahArabicName),
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
    int? startAyah,
    bool autoPlay = true,
  }) async {
    final List<AyahPlaybackItem> items = [];
    int initialIndex = 0;
    for (int a = fromAyah; a <= toAyah; a++) {
      if (startAyah != null && a == startAyah) {
        initialIndex = items.length;
      }
      items.add(
        AyahPlaybackItem(
          surahNumber: surahNumber,
          ayahNumber: a,
          surahArabicName: surahArabicName,
          textArabic: QuranTextData.getAyahText(surahNumber, a, surahArabicName),
        ),
      );
    }
    await _audioService.loadAyahPortion(items, startIndex: initialIndex, autoPlay: autoPlay);
  }

  Future<void> togglePlayPause() => _audioService.togglePlayPause();
  Future<void> play() => _audioService.play();
  Future<void> pause() => _audioService.pause();
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
