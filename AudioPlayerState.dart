Scaffold(
  body: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
    builder: (context, state) {
      return ListView.builder(
        itemCount: dailyAyahs.length,
        itemBuilder: (context, index) {
          final ayah = dailyAyahs[index];
          final isHighlighted = (ayah.surah == state.currentSurah && ayah.ayah == state.currentAyah);

          return Container(
            color: isHighlighted ? Colors.amber.withOpacity(0.2) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              ayah.text,
              style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 20),
            ),
          );
        },
      );
    },
  ),
  bottomNavigationBar: BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
    builder: (context, state) {
      if (state.status == AudioStatus.initial) return const SizedBox.shrink();

      return MiniPlayerWidget(
        reciterName: state.selectedReciter.nameAr,
        currentAyahText: state.currentAyahText,
        isPlaying: state.status == AudioStatus.playing,
        isDownloaded: state.isDownloaded,
        currentRepeat: state.currentRepeatCount,
        targetRepeat: state.targetAyahRepeat,
        onPlayPause: () => context.read<AudioPlayerCubit>().togglePlayPause(),
        onOpenControls: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => AudioSettingsBottomSheet(
              initialAyahRepeat: state.targetAyahRepeat,
              initialRangeRepeat: state.targetRangeRepeat,
              initialDelaySeconds: state.delaySeconds,
              onApplySettings: (ayahRep, rangeRep, delay) {
                context.read<AudioPlayerCubit>().updateSettings(
                  ayahRepeat: ayahRep,
                  rangeRepeat: rangeRep,
                  delay: delay,
                );
              },
            ),
          );
        },
      );
    },
  ),
);