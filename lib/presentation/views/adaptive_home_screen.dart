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

class AdaptiveHomeScreen extends StatelessWidget {
  const AdaptiveHomeScreen({super.key});

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
        final isKidsMode = state.isKidsMode;

        return Theme(
          data: isKidsMode ? AppTheme.kidsFunTheme() : AppTheme.adultTheme(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: isKidsMode
                ? const KidsInteractiveHomeView(key: ValueKey('KidsModeView'))
                : const AdultClassicalHomeView(key: ValueKey('AdultModeView')),
          ),
        );
      },
    );
  }
}
