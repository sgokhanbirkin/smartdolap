import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/di/dependency_injection.dart';
import 'package:smartdolap/features/auth/domain/entities/user.dart' as domain;
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_cubit.dart';
import 'package:smartdolap/features/auth/presentation/viewmodel/auth_state.dart';
import 'package:smartdolap/features/profile/data/profile_stats_service.dart';
import 'package:smartdolap/features/profile/data/prompt_preference_service.dart';
import 'package:smartdolap/features/profile/data/user_recipe_service.dart';
import 'package:smartdolap/features/profile/domain/entities/profile_stats.dart';
import 'package:smartdolap/features/profile/domain/entities/prompt_preferences.dart';
import 'package:smartdolap/features/profile/domain/entities/user_recipe.dart';
import 'package:smartdolap/features/profile/presentation/view/user_recipe_form_page.dart';

/// Profile page - User profile and settings
class ProfilePage extends StatefulWidget {
  /// Profile page constructor
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final PromptPreferenceService _prefService = sl<PromptPreferenceService>();
  final ProfileStatsService _statsService = sl<ProfileStatsService>();
  final UserRecipeService _userRecipeService = sl<UserRecipeService>();

  late PromptPreferences _prefs;
  late ProfileStats _stats;
  List<UserRecipe> _userRecipes = <UserRecipe>[];

  bool _isLoading = true;
  late AnimationController _pulseController;
  final TextEditingController _noteCtrl = TextEditingController();
  final Map<String, TextEditingController> _customControllers =
      <String, TextEditingController>{
        'diet': TextEditingController(),
        'cuisine': TextEditingController(),
        'tone': TextEditingController(),
        'goal': TextEditingController(),
      };
  String? _activeCustomKey;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
      lowerBound: 0.9,
      upperBound: 1.04,
    )..repeat(reverse: true);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _prefs = _prefService.getPreferences();
    _stats = _statsService.load();
    _userRecipes = _userRecipeService.fetch();
    _noteCtrl.text = _prefs.customNote;
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _noteCtrl.dispose();
    for (final TextEditingController c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _savePrefs(PromptPreferences prefs) async {
    setState(() => _prefs = prefs);
    await _prefService.savePreferences(prefs);
  }

  int get _favoritesCount => 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        tr('profile_title'),
        style: TextStyle(fontSize: AppSizes.textL),
      ),
      automaticallyImplyLeading: false,
      elevation: AppSizes.appBarElevation,
      toolbarHeight: AppSizes.appBarHeight,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _heroCard(context),
                SizedBox(height: AppSizes.verticalSpacingL),
                _promptPreviewCard(context),
                SizedBox(height: AppSizes.verticalSpacingL),
                _statsTables(context),
                SizedBox(height: AppSizes.verticalSpacingL),
                _collectionCard(context),
                SizedBox(height: AppSizes.verticalSpacingL),
                _preferenceControls(context),
                SizedBox(height: AppSizes.verticalSpacingL),
                _languageAndLogout(context),
              ],
            ),
          ),
        ),
  );

  Widget _heroCard(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (BuildContext context, AuthState state) {
      final domain.User? user = state.whenOrNull(authenticated: (u) => u);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFE0F7FA), Color(0xFFFCE4EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            ScaleTransition(
              scale: _pulseController,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(Icons.person, size: AppSizes.iconXL),
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _prefs.nickname.isNotEmpty
                      ? _prefs.nickname
                      : (user?.displayName ?? tr('profile_nickname_placeholder')),
                  style: TextStyle(
                    fontSize: AppSizes.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: tr('profile_edit_nickname'),
                  onPressed: _editNickname,
                ),
              ],
            ),
            if (user != null)
              Text(
                user.email,
                style: TextStyle(fontSize: AppSizes.textS),
              ),
            SizedBox(height: AppSizes.verticalSpacingS),
            Text(
              tr('profile_prompt_desc'),
              style: TextStyle(fontSize: AppSizes.textS),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.verticalSpacingM),
            _levelProgress(context),
            SizedBox(height: AppSizes.verticalSpacingM),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSizes.spacingM,
              runSpacing: AppSizes.verticalSpacingS,
              children: <Widget>[
                _heroStatBadge(
                  icon: Icons.auto_awesome,
                  label: tr('profile_generated'),
                  value: '${_stats.aiRecipes}',
                ),
                _heroStatBadge(
                  icon: Icons.restaurant,
                  label: tr('profile_user_recipes'),
                  value: '${_stats.userRecipes}',
                ),
                _heroStatBadge(
                  icon: Icons.star_border,
                  label: tr('profile_favorites'),
                  value: '$_favoritesCount',
                ),
              ],
            ),
          ],
        ),
      );
    },
  );

  Widget _heroStatBadge({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizes.spacingL,
          vertical: AppSizes.verticalSpacingS,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppSizes.iconS, color: Colors.deepOrangeAccent),
            SizedBox(width: AppSizes.spacingS),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: AppSizes.spacingXS),
            Text(label, style: TextStyle(fontSize: AppSizes.textS)),
          ],
        ),
      );

  Widget _levelProgress(BuildContext context) {
    final double progress =
        _stats.nextLevelXp == 0 ? 0 : _stats.xp / _stats.nextLevelXp;
    return Column(
      children: <Widget>[
        Text(
          tr('profile_level', namedArgs: <String, String>{'level': '${_stats.level}'}),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSizes.verticalSpacingS),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingS / 2),
        Text(
          tr(
            'profile_level_progress',
            namedArgs: <String, String>{
              'current': '${_stats.xp}',
              'next': '${_stats.nextLevelXp}',
            },
          ),
          style: TextStyle(fontSize: AppSizes.textXS),
        ),
      ],
    );
  }

  Widget _promptPreviewCard(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                tr('profile_prompt_preview'),
                style: TextStyle(
                  fontSize: AppSizes.textM,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: tr('profile_copy_prompt'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _prefs.composePrompt()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr('profile_prompt_copied'))),
                  );
                },
                icon: const Icon(Icons.copy_all),
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          Text(
            _prefs.composePrompt(),
            style: TextStyle(fontSize: AppSizes.textS),
          ),
          SizedBox(height: AppSizes.verticalSpacingS),
          Text(
            tr('profile_story_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _statsTables(BuildContext context) {
    final List<MapEntry<String, String>> rows = _prefs.summaryRows(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              tr('profile_summary_title'),
              style: TextStyle(
                fontSize: AppSizes.textM,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.verticalSpacingS),
            ...rows.map((MapEntry<String, String> entry) {
              final String label = tr('profile_${entry.key}');
              return Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizes.verticalSpacingS),
                child: Row(
                  children: <Widget>[
                    Text(label),
                    const Spacer(),
                    Text(
                      entry.value,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _collectionCard(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tr('profile_collection_title'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Wrap(
            spacing: AppSizes.spacingM,
            runSpacing: AppSizes.verticalSpacingS,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _usageChip(
                context,
                tr('profile_generated'),
                '${_stats.aiRecipes}',
                Icons.auto_awesome,
              ),
              _usageChip(
                context,
                tr('profile_user_recipes'),
                '${_stats.userRecipes}',
                Icons.restaurant,
              ),
              _usageChip(
                context,
                tr('profile_photo_uploads'),
                '${_stats.photoUploads}',
                Icons.photo_camera_outlined,
              ),
            ],
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          _collectionActions(context),
          if (_userRecipes.isNotEmpty) ...<Widget>[
            SizedBox(height: AppSizes.verticalSpacingM),
            Text(tr('profile_recent_recipes')),
            ..._userRecipes.take(3).map(
              (UserRecipe recipe) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  recipe.isAIRecommendation
                      ? Icons.auto_awesome
                      : Icons.restaurant,
                ),
                title: Text(recipe.title),
                subtitle: Text(
                  recipe.description.isEmpty
                      ? tr('profile_recipe_advice')
                      : recipe.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _collectionActions(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool twoColumns = constraints.maxWidth >= 480;
          final double width =
              twoColumns ? (constraints.maxWidth - AppSizes.spacingM) / 2 : constraints.maxWidth;
          final List<Widget> buttons = <Widget>[
            SizedBox(
              width: width,
              child: FilledButton.icon(
                onPressed: _simulateAiRecipe,
                icon: const Icon(Icons.bolt),
                label: Text(tr('profile_simulate_ai')),
              ),
            ),
            SizedBox(
              width: width,
              child: OutlinedButton.icon(
                onPressed: _createManualRecipe,
                icon: const Icon(Icons.note_add_outlined),
                label: Text(tr('profile_add_manual_recipe')),
              ),
            ),
            SizedBox(
              width: width,
              child: OutlinedButton.icon(
                onPressed: _uploadDishPhoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(tr('profile_upload_photo')),
              ),
            ),
          ];
          return Wrap(
            spacing: AppSizes.spacingM,
            runSpacing: AppSizes.spacingM,
            children: buttons,
          );
        },
      );

  Widget _usageChip(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) =>
      Container(
        width: 110,
        padding: EdgeInsets.all(AppSizes.padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radius),
          color: Theme.of(context).colorScheme.secondaryContainer,
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            SizedBox(height: AppSizes.verticalSpacingS),
            Text(value, style: TextStyle(fontSize: AppSizes.textL)),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _preferenceControls(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(AppSizes.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            tr('profile_customize_title'),
            style: TextStyle(
              fontSize: AppSizes.textM,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          _chipGroup(
            context,
            fieldKey: 'diet',
            title: tr('profile_diet_title'),
            hint: tr('profile_diet_hint'),
            options: <String>['dengeli', 'vegan', 'vejetaryen', 'keto', 'protein'],
            customValues: _prefs.customDiets,
            selected: _prefs.dietStyle,
            onSelected: (String value) =>
                _savePrefs(_prefs.copyWith(dietStyle: value)),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          _chipGroup(
            context,
            fieldKey: 'cuisine',
            title: tr('profile_cuisine_title'),
            hint: tr('profile_cuisine_hint'),
            options: <String>['Akdeniz', 'Anadolu', 'Asya', 'Latin', 'Nordic'],
            customValues: _prefs.customCuisines,
            selected: _prefs.cuisineFocus,
            onSelected: (String value) =>
                _savePrefs(_prefs.copyWith(cuisineFocus: value)),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          _chipGroup(
            context,
            fieldKey: 'tone',
            title: tr('profile_mood_title'),
            hint: tr('profile_mood_hint'),
            options: <String>['enerjik', 'huzurlu', 'romantik', 'sporcu'],
            customValues: _prefs.customTones,
            selected: _prefs.tone,
            onSelected: (String value) => _savePrefs(_prefs.copyWith(tone: value)),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          _chipGroup(
            context,
            fieldKey: 'goal',
            title: tr('profile_goal_title'),
            hint: tr('profile_goal_hint'),
            options: <String>['pratik', 'gourmet', 'budget', 'detox'],
            customValues: _prefs.customGoals,
            selected: _prefs.goal,
            onSelected: (String value) => _savePrefs(_prefs.copyWith(goal: value)),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(tr('profile_servings')),
          SegmentedButton<int>(
            segments: <ButtonSegment<int>>[
              for (final int s in <int>[1, 2, 4, 6])
                ButtonSegment<int>(value: s, label: Text('$s')),
            ],
            selected: <int>{_prefs.servings},
            onSelectionChanged: (Set<int> selection) =>
                _savePrefs(_prefs.copyWith(servings: selection.first)),
          ),
          SizedBox(height: AppSizes.verticalSpacingM),
          Text(
            tr('profile_custom_note'),
            style: TextStyle(
              fontSize: AppSizes.textS,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.spacingXS),
          Text(
            tr('profile_custom_note_hint'),
            style: TextStyle(
              fontSize: AppSizes.textXS,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSizes.spacingS),
          TextField(
            controller: _noteCtrl,
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.edit_note_outlined),
              hintText: tr('profile_custom_note_hint'),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radius),
              ),
            ),
            onChanged: (String value) =>
                _savePrefs(_prefs.copyWith(customNote: value)),
          ),
        ],
      ),
    ),
  );

  Widget _chipGroup(
    BuildContext context, {
    required String fieldKey,
    required String title,
    required List<String> options,
    required String hint,
    required String selected,
    required List<String> customValues,
    required ValueChanged<String> onSelected,
  }) {
    final TextEditingController controller = _customControllers[fieldKey]!;
    final bool isExpanded = _activeCustomKey == fieldKey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(title, style: TextStyle(fontSize: AppSizes.textS)),
            const Spacer(),
            IconButton(
              icon: Icon(isExpanded ? Icons.close : Icons.add),
              onPressed: () => _toggleCustomInput(fieldKey),
            ),
          ],
        ),
        Text(
          hint,
          style: TextStyle(
            fontSize: AppSizes.textXS,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingS),
        Wrap(
          spacing: AppSizes.spacingS,
          runSpacing: AppSizes.verticalSpacingS / 2,
          children: <Widget>[
            ...options.map(
              (String option) => ChoiceChip(
                label: Text(option),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
              ),
            ),
            ...customValues.map(
              (String option) => InputChip(
                label: Text(option),
                selected: option == selected,
                onSelected: (_) => onSelected(option),
                onDeleted: () => _removeCustomValue(fieldKey, option),
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState:
              isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: EdgeInsets.only(top: AppSizes.verticalSpacingS),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: tr('profile_custom_${fieldKey}_label'),
                hintText: tr('profile_custom_${fieldKey}_hint'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _addCustomValue(fieldKey),
                ),
              ),
              onSubmitted: (_) => _addCustomValue(fieldKey),
            ),
          ),
        ),
        SizedBox(height: AppSizes.verticalSpacingM),
      ],
    );
  }

  Widget _languageAndLogout(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Text(tr('language'), style: TextStyle(fontSize: AppSizes.textM)),
      SizedBox(height: AppSizes.verticalSpacingS),
      Wrap(
        spacing: AppSizes.spacingM,
        children: <Widget>[
          OutlinedButton(
            onPressed: () => context.setLocale(const Locale('tr', 'TR')),
            child: const Text('Türkçe'),
          ),
          OutlinedButton(
            onPressed: () => context.setLocale(const Locale('en', 'US')),
            child: const Text('English'),
          ),
        ],
      ),
      SizedBox(height: AppSizes.verticalSpacingL),
      ElevatedButton.icon(
        onPressed: () => context.read<AuthCubit>().logout(),
        icon: const Icon(Icons.logout),
        label: Text(tr('logout')),
      ),
    ],
  );

  void _toggleCustomInput(String key) {
    setState(() {
      _activeCustomKey = _activeCustomKey == key ? null : key;
    });
  }

  void _addCustomValue(String key) {
    final TextEditingController controller = _customControllers[key]!;
    final String value = controller.text.trim();
    if (value.isEmpty) {
      return;
    }
    final List<String> list = List<String>.from(_customListForKey(key));
    if (list.contains(value)) {
      controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('profile_custom_${key}_exists'))),
      );
      return;
    }
    list.add(value);
    controller.clear();
    _toggleCustomInput(key);
    _savePrefs(_prefsWithList(key, list));
  }

  void _removeCustomValue(String key, String value) {
    final List<String> list = List<String>.from(_customListForKey(key))
      ..remove(value);
    _savePrefs(_prefsWithList(key, list));
  }

  List<String> _customListForKey(String key) {
    switch (key) {
      case 'diet':
        return _prefs.customDiets;
      case 'cuisine':
        return _prefs.customCuisines;
      case 'tone':
        return _prefs.customTones;
      case 'goal':
        return _prefs.customGoals;
      default:
        return const <String>[];
    }
  }

  PromptPreferences _prefsWithList(String key, List<String> values) {
    switch (key) {
      case 'diet':
        return _prefs.copyWith(customDiets: values);
      case 'cuisine':
        return _prefs.copyWith(customCuisines: values);
      case 'tone':
        return _prefs.copyWith(customTones: values);
      case 'goal':
        return _prefs.copyWith(customGoals: values);
      default:
        return _prefs;
    }
  }

  Future<void> _editNickname() async {
    final TextEditingController controller =
        TextEditingController(text: _prefs.nickname);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(tr('profile_edit_nickname')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: tr('profile_nickname_hint')),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('confirm')),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _savePrefs(_prefs.copyWith(nickname: controller.text.trim()));
    }
  }

  Future<void> _simulateAiRecipe() async {
    final ProfileStats stats = await _statsService.incrementAiRecipes();
    await _statsService.addXp(40);
    if (!mounted) {
      return;
    }
    setState(() => _stats = stats);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('profile_ai_recipe_recorded'))),
    );
  }

  Future<void> _createManualRecipe() async {
    final bool? created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => UserRecipeFormPage(onSubmit: ({
          required String title,
          required List<String> ingredients,
          required List<String> steps,
          String description = '',
          List<String>? tags,
          String? imagePath,
          String? videoPath,
        }) async {
          await _userRecipeService.createManual(
            title: title,
            description: description,
            ingredients: ingredients,
            steps: steps,
            tags: tags ?? <String>[],
            imagePath: imagePath,
            videoPath: videoPath,
          );
        }),
      ),
    );
    if (!mounted) {
      return;
    }
    if (created == true) {
      final ProfileStats stats =
          await _statsService.incrementUserRecipes();
      if (!mounted) {
        return;
      }
      setState(() {
        _userRecipes = _userRecipeService.fetch();
        _stats = stats;
      });
    }
  }

  Future<void> _uploadDishPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final ProfileStats stats = await _statsService.incrementUserRecipes(
        withPhoto: true,
      );
      if (!mounted) {
        return;
      }
      setState(() => _stats = stats);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('profile_photo_upload_placeholder'))),
      );
    }
  }
}
