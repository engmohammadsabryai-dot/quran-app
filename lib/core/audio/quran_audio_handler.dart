import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;

  // Callbacks for skip actions to be handled by repetition loop engine
  void Function()? onSkipNext;
  void Function()? onSkipPrevious;

  QuranAudioHandler(this._player) {
    // Listen to player state and broadcast to OS
    _player.playbackEventStream.listen(_broadcastState);

    // Listen to current sequence index
    _player.currentIndexStream.listen((index) {
      // Index updates can trigger media item updates
    });
  }

  void updateCurrentMediaItem({
    required String id,
    required String surahName,
    required int ayahNumber,
    required String reciterName,
    Duration? duration,
    Uri? artUri,
  }) {
    mediaItem.add(
      MediaItem(
        id: id,
        album: 'مصحف الحفظ',
        title: 'سورة $surahName - الآية $ayahNumber',
        artist: reciterName,
        duration: duration,
        artUri: artUri,
        displayTitle: 'سورة $surahName - الآية $ayahNumber',
        displaySubtitle: reciterName,
        displayDescription: 'تكرار الحفظ والورد القرآني',
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
      ),
    );
  }

  void _broadcastState(PlaybackEvent event) {
    final isPlaying = _player.playing;
    final processingState = _player.processingState;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[processingState]!,
        playing: isPlaying,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (onSkipNext != null) {
      onSkipNext!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipPrevious != null) {
      onSkipPrevious!();
    }
  }
}
