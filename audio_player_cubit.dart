import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_player_state.dart';
import 'reciter_model.dart';
import 'audio_source_resolver.dart';

class AyahItem {
  final int surah;
  final int ayah;
  final String text;

  const AyahItem({required this.surah, required this.ayah, required this.text});
}

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;

  List<AyahItem> _currentRangeList = [];
  int _currentIndex = 0;
  bool _isManualStop = false;

  AudioPlayerCubit(Reciter defaultReciter) : super(AudioPlayerState.initial(defaultReciter)) {
    _initAudioStreams();
  }

  void _initAudioStreams() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed && !_isManualStop) {
        _handleAyahCompletion();
      }
    });
  }

  // تحميل وتشغيل ورد اليوم (نطاق آيات ربع أو صفحة)
  Future<void> loadAndPlayRange({
    required List<AyahItem> ayahs,
    int? customAyahRepeat,
    int? customRangeRepeat,
    int? customDelaySeconds,
  }) async {
    if (ayahs.isEmpty) return;

    _isManualStop = false;
    _currentRangeList = ayahs;
    _currentIndex = 0;

    emit(state.copyWith(
      status: AudioStatus.loading,
      targetAyahRepeat: customAyahRepeat ?? state.targetAyahRepeat,
      targetRangeRepeat: customRangeRepeat ?? state.targetRangeRepeat,
      delaySeconds: customDelaySeconds ?? state.delaySeconds,
      currentRepeatCount: 1,
      currentRangeLoop: 1,
    ));

    await _playCurrentAyah();
  }

  // تشغيل الآية المحددة الحالية
  Future<void> _playCurrentAyah() async {
    if (_currentIndex >= _currentRangeList.length) return;

    final currentItem = _currentRangeList[_currentIndex];

    // التحقق هل الملف متوفر أوفلاين
    final localFile = await AudioSourceResolver.getLocalFile(
      reciterId: state.selectedReciter.id,
      surah: currentItem.surah,
      ayah: currentItem.ayah,
    );
    final hasOffline = await localFile.exists();

    emit(state.copyWith(
      currentSurah: currentItem.surah,
      currentAyah: currentItem.ayah,
      currentAyahText: currentItem.text,
      isDownloaded: hasOffline,
      status: AudioStatus.loading,
    ));

    try {
      final audioSource = await AudioSourceResolver.resolveAudioSource(
        reciterId: state.selectedReciter.id,
        reciterSubfolder: state.selectedReciter.subfolder,
        surah: currentItem.surah,
        ayah: currentItem.ayah,
      );

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();

      emit(state.copyWith(status: AudioStatus.playing));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: 'فشل تشغيل التلاوة: ${e.toString()}',
      ));
    }
  }

  // خوارزمية التكرار والانتقال الذكي
  Future<void> _handleAyahCompletion() async {
    // 1. هل ما زال هناك تكرارات لنفس الآية؟
    if (state.currentRepeatCount < state.targetAyahRepeat) {
      await _applyIntervalDelay();
      if (_isManualStop) return;

      emit(state.copyWith(currentRepeatCount: state.currentRepeatCount + 1));
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }

    // 2. انتهى تكرار الآية -> الانتقال للآية التالية في المقطع
    if (_currentIndex + 1 < _currentRangeList.length) {
      await _applyIntervalDelay();
      if (_isManualStop) return;

      _currentIndex++;
      emit(state.copyWith(currentRepeatCount: 1));
      await _playCurrentAyah();
      return;
    }

    // 3. انتهت جميع آيات المقطع -> فحص تكرار المقطع كاملاً
    if (state.currentRangeLoop < state.targetRangeRepeat) {
      await _applyIntervalDelay();
      if (_isManualStop) return;

      _currentIndex = 0;
      emit(state.copyWith(
        currentRepeatCount: 1,
        currentRangeLoop: state.currentRangeLoop + 1,
      ));
      await _playCurrentAyah();
      return;
    }

    // 4. اكتمل ورد التسميع والتكرار بالكامل
    emit(state.copyWith(status: AudioStatus.stopped));
  }

  // تطبيق مهلة الترديد الصامت إن وجدت
  Future<void> _applyIntervalDelay() async {
    if (state.delaySeconds > 0) {
      emit(state.copyWith(status: AudioStatus.paused));
      await Future.delayed(Duration(seconds: state.delaySeconds));
    }
  }

  // أزرار التحكم في التشغيل
  Future<void> togglePlayPause() async {
    if (state.status == AudioStatus.playing) {
      await _audioPlayer.pause();
      emit(state.copyWith(status: AudioStatus.paused));
    } else if (state.status == AudioStatus.paused) {
      await _audioPlayer.play();
      emit(state.copyWith(status: AudioStatus.playing));
    } else if (state.status == AudioStatus.stopped && _currentRangeList.isNotEmpty) {
      await loadAndPlayRange(ayahs: _currentRangeList);
    }
  }

  Future<void> stop() async {
    _isManualStop = true;
    await _audioPlayer.stop();
    emit(state.copyWith(status: AudioStatus.stopped));
  }

  // تغيير الشيخ وإعادة تشغيل الآية الحالية بصوته فوراً
  Future<void> changeReciter(Reciter newReciter) async {
    if (newReciter.id == state.selectedReciter.id) return;

    emit(state.copyWith(selectedReciter: newReciter));
    if (state.status == AudioStatus.playing || state.status == AudioStatus.paused) {
      await _playCurrentAyah();
    }
  }

  // تحديث إعدادات التكرار أثناء التشغيل
  void updateSettings({
    required int ayahRepeat,
    required int rangeRepeat,
    required int delay,
  }) {
    emit(state.copyWith(
      targetAyahRepeat: ayahRepeat,
      targetRangeRepeat: rangeRepeat,
      delaySeconds: delay,
    ));
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}