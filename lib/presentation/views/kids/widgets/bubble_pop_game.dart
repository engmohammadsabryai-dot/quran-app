import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../blocs/kids/kids_garden_cubit.dart';

class BubblePopQuizDialog extends StatefulWidget {
  const BubblePopQuizDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const BubblePopQuizDialog(),
    );
  }

  @override
  State<BubblePopQuizDialog> createState() => _BubblePopQuizDialogState();
}

class _BubblePopQuizDialogState extends State<BubblePopQuizDialog> with SingleTickerProviderStateMixin {
  final Set<String> _poppedBubbles = {};
  String? _feedbackMessage;
  bool _isSuccessAnim = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KidsGardenCubit, KidsGardenState>(
      builder: (context, state) {
        if (!state.isQuizActive || state.questions.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentQ = state.questions[state.currentQuestionIndex];

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF3E8FF), Colors.white, Color(0xFFE0F2FE)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: KidsColors.primaryPurple.withOpacity(0.3), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: KidsColors.primaryPurple.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with score & close
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: KidsColors.sunnyOrange,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            'نقاطك: ${state.quizScore}',
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'سؤال ${state.currentQuestionIndex + 1} من ${state.questions.length}',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: KidsColors.primaryPurple),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () {
                        context.read<KidsGardenCubit>().closeQuiz();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Prompt Title
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFDDD6FE)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'فرقع الفقاعة التي تكمل الآية الكريمة! 🫧',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: KidsColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        currentQ.prompt,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.amiri(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4 Interactive Pop Bubbles
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: currentQ.bubbleOptions.map((word) {
                    final isPopped = _poppedBubbles.contains(word);

                    return GestureDetector(
                      onTap: isPopped
                          ? null
                          : () {
                              final isCorrect = context.read<KidsGardenCubit>().answerBubbleQuestion(word);
                              if (isCorrect) {
                                setState(() {
                                  _isSuccessAnim = true;
                                  _feedbackMessage = 'أحسنت! فرقعة صحيحة 🎉';
                                  _poppedBubbles.clear();
                                });

                                Future.delayed(const Duration(milliseconds: 1400), () {
                                  if (mounted) {
                                    setState(() {
                                      _isSuccessAnim = false;
                                      _feedbackMessage = null;
                                    });
                                    if (!context.read<KidsGardenCubit>().state.isQuizActive) {
                                      Navigator.pop(context);
                                    }
                                  }
                                });
                              } else {
                                setState(() {
                                  _poppedBubbles.add(word);
                                  _feedbackMessage = 'ليست هذه الكلمة، جرب فقاعة أخرى! 🎈';
                                });
                              }
                            },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isPopped ? 0.2 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPopped
                                  ? [Colors.grey.shade300, Colors.grey.shade400]
                                  : [
                                      KidsColors.playfulSky.withOpacity(0.85),
                                      KidsColors.primaryPurple.withOpacity(0.85),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: isPopped
                                ? []
                                : [
                                    BoxShadow(
                                      color: KidsColors.playfulSky.withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            word,
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (_feedbackMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isSuccessAnim ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _feedbackMessage!,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: _isSuccessAnim ? const Color(0xFF166534) : const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
