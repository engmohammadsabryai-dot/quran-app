import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import 'quran_audio_handler.dart';

class AyahPlaybackItem {
  final int surahNumber;
  final int ayahNumber;
  final String surahArabicName;
  final String textArabic;

  const AyahPlaybackItem({
    required this.surahNumber,
    required this.ayahNumber,
    required this.surahArabicName,
    this.textArabic = '',
  });

  String get id => '${surahNumber}_$ayahNumber';
}

class PlaybackProgressState {
  final AyahPlaybackItem? currentItem;
  final int currentAyahIndex;
  final int totalAyahs;
  final int currentAyahRepeatCount; // 1 to N
  final int targetAyahRepeats; // N
  final int currentPortionCycle; // 1 to M
  final int targetPortionCycles; // M
  final int intervalDelaySeconds; // T
  final bool isInIntervalDelay;
  final int intervalSecondsRemaining;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final ReciterInfo reciter;

  const PlaybackProgressState({
    this.currentItem,
    this.currentAyahIndex = 0,
    this.totalAyahs = 0,
    this.currentAyahRepeatCount = 1,
    this.targetAyahRepeats = 3,
    this.currentPortionCycle = 1,
    this.targetPortionCycles = 1,
    this.intervalDelaySeconds = 2,
    this.isInIntervalDelay = false,
    this.intervalSecondsRemaining = 0,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    required this.reciter,
  });

  PlaybackProgressState copyWith({
    AyahPlaybackItem? currentItem,
    int? currentAyahIndex,
    int? totalAyahs,
    int? currentAyahRepeatCount,
    int? targetAyahRepeats,
    int? currentPortionCycle,
    int? targetPortionCycles,
    int? intervalDelaySeconds,
    bool? isInIntervalDelay,
    int? intervalSecondsRemaining,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    ReciterInfo? reciter,
  }) {
    return PlaybackProgressState(
      currentItem: currentItem ?? this.currentItem,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      totalAyahs: totalAyahs ?? this.totalAyahs,
      currentAyahRepeatCount: currentAyahRepeatCount ?? this.currentAyahRepeatCount,
      targetAyahRepeats: targetAyahRepeats ?? this.targetAyahRepeats,
      currentPortionCycle: currentPortionCycle ?? this.currentPortionCycle,
      targetPortionCycles: targetPortionCycles ?? this.targetPortionCycles,
      intervalDelaySeconds: intervalDelaySeconds ?? this.intervalDelaySeconds,
      isInIntervalDelay: isInIntervalDelay ?? this.isInIntervalDelay,
      intervalSecondsRemaining: intervalSecondsRemaining ?? this.intervalSecondsRemaining,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      reciter: reciter ?? this.reciter,
    );
  }
}

class HybridAudioPlayerService {
  final AudioPlayer _player;
  final NetworkClient _networkClient;
  QuranAudioHandler? _audioHandler;

  // Configuration
  ReciterInfo _currentReciter = AppConstants.availableReciters[0];
  int _targetAyahRepeats = 3; // N (1 to 30)
  int _targetPortionCycles = 1; // M (1 to 10)
  int _intervalDelaySeconds = 2; // T (0 to 15s)
  bool _autoDownloadEnabled = true;

  // Active Playlist / Queue
  List<AyahPlaybackItem> _queue = [];
  int _currentAyahIndex = 0;
  int _currentAyahRepeatCount = 1;
  int _currentPortionCycle = 1;

  // State Management
  final BehaviorSubject<PlaybackProgressState> _progressSubject = BehaviorSubject<PlaybackProgressState>();
  Stream<PlaybackProgressState> get progressStream => _progressSubject.stream;
  PlaybackProgressState get currentState => _progressSubject.value;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  Timer? _delayTimer;
  bool _isDisposed = false;

  HybridAudioPlayerService({
    AudioPlayer? player,
    NetworkClient? networkClient,
  })  : _player = player ?? AudioPlayer(),
        _networkClient = networkClient ?? NetworkClient() {
    _initSubject();
    _initListeners();
  }

  void attachAudioHandler(QuranAudioHandler handler) {
    _audioHandler = handler;
    _audioHandler?.onSkipNext = skipNext;
    _audioHandler?.onSkipPrevious = skipPrevious;
  }

  void _initSubject() {
    _progressSubject.add(
      PlaybackProgressState(
        reciter: _currentReciter,
        targetAyahRepeats: _targetAyahRepeats,
        targetPortionCycles: _targetPortionCycles,
        intervalDelaySeconds: _intervalDelaySeconds,
      ),
    );
  }

  void _initListeners() {
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (_isDisposed) return;
      final isPlaying = state.playing;
      final isBuffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;

      _updateState(
        _progressSubject.value.copyWith(
          isPlaying: isPlaying,
          isBuffering: isBuffering,
        ),
      );

      // Handle ayah completion
      if (state.processingState == ProcessingState.completed) {
        _handleAyahCompleted();
      }
    });

    _positionSubscription = _player.positionStream.listen((pos) {
      if (_isDisposed) return;
      _updateState(_progressSubject.value.copyWith(position: pos));
    });

    _durationSubscription = _player.durationStream.listen((dur) {
      if (_isDisposed) return;
      _updateState(_progressSubject.value.copyWith(duration: dur ?? Duration.zero));
    });
  }

  void _updateState(PlaybackProgressState newState) {
    if (!_progressSubject.isClosed) {
      _progressSubject.add(newState);
    }
  }

  // Set repetition parameters
  void setRepetitionSettings({
    int? ayahRepeats, // N
    int? portionCycles, // M
    int? intervalDelay, // T
    ReciterInfo? reciter,
    bool? autoDownload,
  }) {
    if (ayahRepeats != null) _targetAyahRepeats = ayahRepeats.clamp(1, 30);
    if (portionCycles != null) _targetPortionCycles = portionCycles.clamp(1, 10);
    if (intervalDelay != null) _intervalDelaySeconds = intervalDelay.clamp(0, 15);
    if (reciter != null) _currentReciter = reciter;
    if (autoDownload != null) _autoDownloadEnabled = autoDownload;

    _updateState(
      _progressSubject.value.copyWith(
        targetAyahRepeats: _targetAyahRepeats,
        targetPortionCycles: _targetPortionCycles,
        intervalDelaySeconds: _intervalDelaySeconds,
        reciter: _currentReciter,
      ),
    );
  }

  // Load a sequence of Ayahs for the day's portion
  Future<void> loadAyahPortion(
    List<AyahPlaybackItem> items, {
    int startIndex = 0,
    bool autoPlay = true,
  }) async {
    if (items.isEmpty) return;

    _delayTimer?.cancel();
    await _player.stop();

    _queue = List.from(items);
    _currentAyahIndex = startIndex.clamp(0, _queue.length - 1);
    _currentAyahRepeatCount = 1;
    _currentPortionCycle = 1;

    _updateState(
      _progressSubject.value.copyWith(
        currentItem: _queue[_currentAyahIndex],
        currentAyahIndex: _currentAyahIndex,
        totalAyahs: _queue.length,
        currentAyahRepeatCount: _currentAyahRepeatCount,
        currentPortionCycle: _currentPortionCycle,
        isInIntervalDelay: false,
        intervalSecondsRemaining: 0,
      ),
    );

    if (autoPlay) {
      await _playCurrentAyah();
    }
  }

  /// Cache-First Audio Resolution
  Future<AudioSource> _resolveAudioSource(int surah, int ayah) async {
    final surahPadded = surah.toString().padLeft(3, '0');
    final ayahPadded = ayah.toString().padLeft(3, '0');
    final remoteUrl = _currentReciter.getAyahAudioUrl(surah, ayah);

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final localFilePath = p.join(
        docDir.path,
        'audio',
        _currentReciter.id,
        '${surahPadded}_$ayahPadded.mp3',
      );
      final localFile = File(localFilePath);

      if (await localFile.exists() && (await localFile.length()) > 0) {
        // Cache-Hit: Stream directly from local storage
        debugPrint('🎧 Cache-Hit: Playing local file for $surah:$ayah');
        return AudioSource.file(localFile.path);
      }

      // Cache-Miss: Stream from EveryAyah CDN
      debugPrint('🌐 Cache-Miss: Streaming remote URL for $surah:$ayah -> $remoteUrl');

      if (_autoDownloadEnabled) {
        // Delegate background async download without blocking playback
        _triggerBackgroundDownload(remoteUrl, localFilePath);
      }

      return AudioSource.uri(Uri.parse(remoteUrl));
    } catch (e) {
      debugPrint('⚠️ Error resolving audio source: $e, falling back to direct URI');
      return AudioSource.uri(Uri.parse(remoteUrl));
    }
  }

  void _triggerBackgroundDownload(String url, String destinationPath) {
    unawaited(() async {
      try {
        await _networkClient.downloadFile(
          url: url,
          destinationPath: destinationPath,
        );
        debugPrint('✅ Background download complete: $destinationPath');
      } catch (e) {
        debugPrint('⚠️ Background download failed for $url: $e');
      }
    }());
  }

  Future<void> _playCurrentAyah() async {
    if (_queue.isEmpty || _currentAyahIndex >= _queue.length) return;

    final item = _queue[_currentAyahIndex];
    final audioSource = await _resolveAudioSource(item.surahNumber, item.ayahNumber);

    try {
      try {
        await _player.setAudioSource(audioSource);
        await _player.play();
      } catch (e) {
        debugPrint('⚠️ Error playing primary audio source: $e, attempting resilient fallback');
        try {
          final fallbackUrl = _currentReciter.getSurahAudioUrl(item.surahNumber);
          await _player.setAudioSource(AudioSource.uri(Uri.parse(fallbackUrl)));
          await _player.play();
        } catch (err) {
          debugPrint('⚠️ Resilient fallback failed: $err');
        }
      }

      _audioHandler?.updateCurrentMediaItem(
        id: item.id,
        surahName: item.surahArabicName,
        ayahNumber: item.ayahNumber,
        reciterName: _currentReciter.nameArabic,
      );

      _updateState(
        _progressSubject.value.copyWith(
          currentItem: item,
          currentAyahIndex: _currentAyahIndex,
          currentAyahRepeatCount: _currentAyahRepeatCount,
          currentPortionCycle: _currentPortionCycle,
          isInIntervalDelay: false,
        ),
      );
    } catch (e) {
      debugPrint('Error playing ayah ${item.surahNumber}:${item.ayahNumber}: $e');
    }
  }

  /// Nested Loop Engine handler triggered upon Ayah completion
  void _handleAyahCompleted() {
    _delayTimer?.cancel();

    // Check if Ayah repeat count (N) reached
    if (_currentAyahRepeatCount < _targetAyahRepeats) {
      // Repeat the same Ayah again
      _currentAyahRepeatCount++;
      _startIntervalDelayAndProceed(() {
        _playCurrentAyah();
      });
      return;
    }

    // Ayah N repeats reached. Reset ayah repeat counter and advance to next Ayah
    _currentAyahRepeatCount = 1;

    if (_currentAyahIndex < _queue.length - 1) {
      _currentAyahIndex++;
      _startIntervalDelayAndProceed(() {
        _playCurrentAyah();
      });
      return;
    }

    // Full range completed! Check if portion loop (M) reached
    if (_currentPortionCycle < _targetPortionCycles) {
      _currentPortionCycle++;
      _currentAyahIndex = 0;
      _startIntervalDelayAndProceed(() {
        _playCurrentAyah();
      });
      return;
    }

    // Full nested repetition completed!
    _player.stop();
    _updateState(
      _progressSubject.value.copyWith(
        isPlaying: false,
        isInIntervalDelay: false,
        position: Duration.zero,
      ),
    );
  }

  /// Inserts a silent interval pause of T seconds for mental recitation / vocal shadowing
  void _startIntervalDelayAndProceed(VoidCallback onComplete) {
    if (_intervalDelaySeconds <= 0) {
      onComplete();
      return;
    }

    var remaining = _intervalDelaySeconds;
    _updateState(
      _progressSubject.value.copyWith(
        isInIntervalDelay: true,
        intervalSecondsRemaining: remaining,
      ),
    );

    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        _updateState(
          _progressSubject.value.copyWith(
            isInIntervalDelay: false,
            intervalSecondsRemaining: 0,
          ),
        );
        onComplete();
      } else {
        _updateState(
          _progressSubject.value.copyWith(
            intervalSecondsRemaining: remaining,
          ),
        );
      }
    });
  }

  Future<void> play() async {
    _delayTimer?.cancel();
    if (_queue.isEmpty) return;
    await _player.play();
  }

  Future<void> pause() async {
    _delayTimer?.cancel();
    _updateState(_progressSubject.value.copyWith(isInIntervalDelay: false));
    await _player.pause();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      if (_queue.isNotEmpty) {
        await play();
      }
    }
  }

  Future<void> skipNext() async {
    _delayTimer?.cancel();
    if (_currentAyahIndex < _queue.length - 1) {
      _currentAyahIndex++;
      _currentAyahRepeatCount = 1;
      await _playCurrentAyah();
    }
  }

  Future<void> skipPrevious() async {
    _delayTimer?.cancel();
    if (_player.position.inSeconds > 2) {
      // If played more than 2 seconds, seek to beginning of current ayah
      await _player.seek(Duration.zero);
      return;
    }

    if (_currentAyahIndex > 0) {
      _currentAyahIndex--;
      _currentAyahRepeatCount = 1;
      await _playCurrentAyah();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> seekToAyahIndex(int index) async {
    if (index >= 0 && index < _queue.length) {
      _delayTimer?.cancel();
      _currentAyahIndex = index;
      _currentAyahRepeatCount = 1;
      await _playCurrentAyah();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _delayTimer?.cancel();
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _player.dispose();
    await _progressSubject.close();
  }
}
