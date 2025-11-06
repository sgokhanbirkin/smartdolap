// ignore_for_file: directives_ordering, prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/pantry/presentation/view/add_pantry_item_page.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_cubit.dart';
import 'package:smartdolap/features/pantry/presentation/viewmodel/pantry_state.dart';
import 'package:smartdolap/product/widgets/empty_state.dart';
import 'package:smartdolap/product/widgets/pantry_item_card.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';

/// Pantry page - Shows user's pantry items
class PantryPage extends StatelessWidget {
  /// Pantry page constructor
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('pantry_title'),
        style: TextStyle(fontSize: AppSizes.textL),
      ),
      automaticallyImplyLeading: false,
      elevation: AppSizes.appBarElevation,
      toolbarHeight: AppSizes.appBarHeight,
    ),
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.padding),
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (BuildContext context, AuthState state) => state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_) => EmptyState(messageKey: 'auth_error'),
            unauthenticated: () => EmptyState(messageKey: 'auth_error'),
            authenticated: (domain.User user) => BlocProvider<PantryCubit>(
              create: (BuildContext _) => sl<PantryCubit>()..watch(user.id),
              child: BlocBuilder<PantryCubit, PantryState>(
                builder: (BuildContext context, PantryState s) {
                  if (s is PantryLoading || s is PantryInitial) {
                    return EmptyState(
                      messageKey: 'pantry_empty_message',
                      lottieUrl:
                          'https://assets2.lottiefiles.com/packages/lf20_Stt1R2.json',
                    );
                  }
                  if (s is PantryFailure) {
                    return EmptyState(messageKey: 'pantry_empty_message');
                  }
                  final PantryLoaded loaded = s as PantryLoaded;
                  if (loaded.items.isEmpty) {
                    return EmptyState(
                      messageKey: 'pantry_empty_message',
                      actionLabelKey: 'pantry_empty_cta',
                      onAction: () => _addItem(context, user.id),
                      lottieUrl:
                          'https://assets9.lottiefiles.com/packages/lf20_totrpclr.json',
                    );
                  }
                  return ListView.separated(
                    itemCount: loaded.items.length,
                    separatorBuilder: (_, __) =>
                        SizedBox(height: AppSizes.verticalSpacingS),
                    itemBuilder: (BuildContext _, int i) =>
                        PantryItemCard(item: loaded.items[i]),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
    floatingActionButton: Builder(
      builder: (BuildContext context) => FloatingActionButton.extended(
        onPressed: () {
          final AuthState state = context.read<AuthCubit>().state;
          state.whenOrNull(
            authenticated: (domain.User user) => _addItem(context, user.id),
          );
        },
        label: Text(tr('add_item')),
        icon: const Icon(Icons.add),
      ),
    ),
  );

  Future<void> _addItem(BuildContext context, String userId) async {
    final bool? created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => BlocProvider<PantryCubit>(
          create: (_) => sl<PantryCubit>()..watch(userId),
          child: AddPantryItemPage(userId: userId),
        ),
      ),
    );
    if (created == true) {
      // no-op, stream will update list
    }
  }
}
