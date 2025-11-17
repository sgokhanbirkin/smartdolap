import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smartdolap/core/constants/app_sizes.dart';
import 'package:smartdolap/core/widgets/avatar_widget.dart';
import 'package:smartdolap/features/household/domain/entities/household_message.dart';
import 'package:smartdolap/features/household/presentation/viewmodel/share_cubit.dart';

/// Messages tab page - Shows messages and message input
class MessagesTabPage extends StatefulWidget {
  /// Messages tab page constructor
  const MessagesTabPage({
    required this.messages,
    required this.householdId,
    required this.userId,
    required this.userName,
    required this.avatarId,
    super.key,
  });

  final List<HouseholdMessage> messages;
  final String householdId;
  final String userId;
  final String userName;
  final String? avatarId;

  @override
  State<MessagesTabPage> createState() => _MessagesTabPageState();
}

class _MessagesTabPageState extends State<MessagesTabPage> {
  final TextEditingController _messageController = TextEditingController();
  final ValueNotifier<bool> _hasText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    _hasText.value = _messageController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _hasText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Expanded(
            child: widget.messages.isEmpty
                ? Center(
                    child: Text(
                      tr('no_messages'),
                      style: TextStyle(
                        fontSize: AppSizes.textM,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.all(AppSizes.padding),
                    itemCount: widget.messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final HouseholdMessage message = widget.messages[index];
                      return _buildMessageItem(context, message);
                    },
                  ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context,
    HouseholdMessage message,
  ) {
    final DateTime messageTime = message.createdAt;
    
    // Format time as HH:mm
    final String formattedTime = '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AvatarWidget(
            avatarId: message.avatarId,
            size: 32.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        message.userName,
                        style: TextStyle(
                          fontSize: AppSizes.textS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: AppSizes.textXS,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (message.text != null && message.text!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      message.text!,
                      style: TextStyle(fontSize: AppSizes.textM),
                    ),
                  ),
                if (message.recipeId != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      tr('recipe_shared'),
                      style: TextStyle(
                        fontSize: AppSizes.textS,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: tr('type_message'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendMessage(context),
            ),
          ),
          SizedBox(width: 8.w),
          ValueListenableBuilder<bool>(
            valueListenable: _hasText,
            builder: (BuildContext context, bool hasText, Widget? child) {
              return IconButton.filled(
                onPressed: !hasText
                    ? null
                    : () => _handleSendMessage(context),
                icon: const Icon(Icons.send),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendMessage(BuildContext context) async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    try {
      await context.read<ShareCubit>().sendMessage(
            householdId: widget.householdId,
            userId: widget.userId,
            userName: widget.userName,
            text: text,
            avatarId: widget.avatarId,
          );
      _messageController.clear();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('error_sending_message'))),
        );
      }
    }
  }
}

