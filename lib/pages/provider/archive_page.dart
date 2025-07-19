import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/chat_cubit/chat_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key, required this.provider_id});
  final int provider_id;

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
  }

  List<dynamic> _filterMessages(List<dynamic> messages, String filter) {
    if (filter == 'all') return messages;
    return messages.where((message) => message.status == filter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'success':
        return Colors.green;
      case 'ignored':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'success':
        return Icons.check_circle;
      case 'ignored':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit()..getMessages(widget.provider_id),
      child: BlocConsumer<ChatCubit, ChatStates>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    'Archive page ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! ChatGetAllMessagesLoading,
              builder: (context) {
                var cubit = ChatCubit.get(context);
                var filteredMessages = _filterMessages(cubit.messages, selectedFilter);

                return Column(
                  children: [
                    // Toggle Buttons Filter
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(8),
                      child: Center(
                        child: ToggleButtons(
                          borderRadius: BorderRadius.circular(8),
                          // selectedBorderColor: Colors.indigo.shade700,
                          // borderColor: Colors.grey.shade300,
                          fillColor: Colors.indigo.shade200,
                          selectedColor: Colors.white,
                          color: Colors.grey.shade600,
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            minWidth: 80,
                          ),
                          isSelected: [
                            selectedFilter == 'all',
                            selectedFilter == 'pending',
                            selectedFilter == 'success',
                            selectedFilter == 'ignored',
                          ],
                          onPressed: (index) {
                            setState(() {
                              switch (index) {
                                case 0:
                                  selectedFilter = 'all';
                                  break;
                                case 1:
                                  selectedFilter = 'pending';
                                  break;
                                case 2:
                                  selectedFilter = 'success';
                                  break;
                                case 3:
                                  selectedFilter = 'ignored';
                                  break;
                              }
                            });
                          },
                          children: const [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('All', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Pending', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('Success', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('Failed', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    // Messages List
                    Expanded(
                      child: _buildMessagesList(filteredMessages),
                    ),
                  ],
                );
              },
              fallback: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
        listener: (context, state) {
          // Handle state changes if needed
        },
      ),
    );
  }

  Widget _buildMessagesList(List<dynamic> filteredMessages) {
    if (filteredMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No messages found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        var cubit = ChatCubit.get(context);
        cubit.getMessages(widget.provider_id);
      },
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredMessages.length,
        itemBuilder: (context, index) {
          final message = filteredMessages[index];
          final statusColor = _getStatusColor(message.status ?? '');
          final statusIcon = _getStatusIcon(message.status ?? '');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Handle message tap
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Logo/Avatar
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.message,
                                color: Colors.blue.shade300,
                                size: 24,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Message content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.title ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.body ?? 'No Content',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (message.status ?? 'unknown').toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEmptyStateMessage() {
    switch (selectedFilter) {
      case 'all':
        return 'No messages in archive';
      case 'pending':
        return 'No pending messages';
      case 'success':
        return 'No successful messages';
      case 'ignored':
        return 'No failed messages';
      default:
        return 'No messages found';
    }
  }
}