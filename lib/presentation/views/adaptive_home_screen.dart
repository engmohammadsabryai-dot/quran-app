import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_theme.dart';
import '../blocs/kids/kids_garden_cubit.dart';
import '../blocs/plan/plan_bloc.dart';
import '../blocs/plan/plan_event.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_state.dart';
import 'adult/adult_classical_home_view.dart';
import 'kids/kids_interactive_home_view.dart';
import 'onboarding/user_welcome_setup_dialog.dart';

class AdaptiveHomeScreen extends StatefulWidget {
  const AdaptiveHomeScreen({super.key});

  @override
  State<AdaptiveHomeScreen> createState() => _AdaptiveHomeScreenState();
}

class _AdaptiveHomeScreenState extends State<AdaptiveHomeScreen> {
  bool _hasEnteredApp = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.activeProfile != null) {
          // Trigger plan loading for the active user
          context.read<PlanBloc>().add(LoadPlanForUserEvent(state.activeProfile!.userId));

          // If child mode, personalize mascot name
          if (state.isKidsMode) {
            context.read<KidsGardenCubit>().setMascotName(state.activeProfile!.name);
          }
        }
      },
      builder: (context, state) {
        // 1. Initial User Welcome Window with Surah Al-Hijr Ayah 9 recitation by Mahmoud Khalil Al-Husary
        if (!_hasEnteredApp) {
          return Scaffold(
            backgroundColor: const Color(0xFFF1F5F9),
            body: SafeArea(
              child: Center(
                child: UserWelcomeSetupDialog(
                  existingProfile: state.activeProfile,
                  onComplete: () {
                    setState(() {
                      _hasEnteredApp = true;
                    });
                  },
                ),
              ),
            ),
          );
        }

        final isKidsMode = state.isKidsMode;

        return Theme(
          data: isKidsMode ? AppTheme.kidsFunTheme() : AppTheme.adultTheme(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isKidsMode
                ? KidsInteractiveHomeView(
                    key: const ValueKey('KidsModeView'),
                    onSwitchProfile: () => setState(() => _hasEnteredApp = false),
                  )
                : AdultClassicalHomeView(
                    key: const ValueKey('AdultModeView'),
                    onSwitchProfile: () => setState(() => _hasEnteredApp = false),
                  ),
          ),
        );
      },
    );
  }
}
