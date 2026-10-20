import 'package:equatable/equatable.dart';
import 'reciter_model.dart';

enum AudioStatus { initial, loading, playing, paused, stopped, error }

class AudioPlayerState extends Equatable {
  final AudioStatus status;
  final Reciter selectedReciter;
  final int currentSurah;
  final int currentAyah;
  final String currentAyahText;
  final int currentRepeatCount;      // كم مرة تكررت الآية الحالية حتى الآن
  final int targetAyahRepeat;        // إجمالي مرات تكرار كل آية
  final int currentRangeLoop;        // كم مرة تكرر المقطع بالكامل
  final int targetRangeRepeat;       // إجمالي مرات تكرار المقطع
  final int delaySeconds;            // المهلة بين الآيات
  final bool isDownloaded;           // هل الآية الحالية محملة أوفلاين
  final String? errorMessage;

  const AudioPlayerState({
    required this.status,
    required this.selectedReciter,
    required this.currentSurah,
    required this.currentAyah,
    required this.currentAyahText,
    this.currentRepeatCount = 1,
    this.targetAyahRepeat = 3,
    this.currentRangeLoop = 1,
    this.targetRangeRepeat = 1,
    this.delaySeconds = 0,
    this.isDownloaded = false,
    this.errorMessage,
  });

  factory AudioPlayerState.initial(Reciter defaultReciter) {
    return AudioPlayerState(
      status: AudioStatus.initial,
      selectedReciter: defaultReciter,
      currentSurah: 1,
      currentAyah: 1,
      currentAyahText: '',
    );
  }

  AudioPlayerState copyWith({
    AudioStatus? status,
    Reciter? selectedReciter,
    int? currentSurah,
    int? currentAyah,
    String? currentAyahText,
    int? currentRepeatCount,
    int? targetAyahRepeat,
    int? currentRangeLoop,
    int? targetRangeRepeat,
    int? delaySeconds,
    bool? isDownloaded,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      selectedReciter: selectedReciter ?? this.selectedReciter,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentAyahText: currentAyahText ?? this.currentAyahText,
      currentRepeatCount: currentRepeatCount ?? this.currentRepeatCount,
      targetAyahRepeat: targetAyahRepeat ?? this.targetAyahRepeat,
      currentRangeLoop: currentRangeLoop ?? this.currentRangeLoop,
      targetRangeRepeat: targetRangeRepeat ?? this.targetRangeRepeat,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedReciter,
        currentSurah,
        currentAyah,
        currentAyahText,
        currentRepeatCount,
        targetAyahRepeat,
        currentRangeLoop,
        targetRangeRepeat,
        delaySeconds,
        isDownloaded,
        errorMessage,
      ];
}