import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:demo/api_models/providers/provider_model.dart';
import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/chat_cubit/chat_states.dart';
import 'package:demo/pages/provider/archive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SendMessagePage extends StatelessWidget {
  final Provider provider;
  const SendMessagePage({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    return BlocProvider(
      create: (context) => ChatCubit()..getProviders(),
      child: BlocConsumer<ChatCubit, ChatStates>(
        listener: (context, state) {
          // يمكن تضيف Snackbar هنا إذا أُرسلت الرسالة
        },
        builder: (context, state) {
          var cubit = ChatCubit.get(context);
          return Scaffold(
            // Add resizeToAvoidBottomInset to handle keyboard
            resizeToAvoidBottomInset: true,
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
                    'Message ${provider.name}',
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
            body: SafeArea(
              child: SingleChildScrollView(
                // Add physics for better scrolling experience
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact ${provider.name}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: bodyController,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 5,
                        // Add textInputAction to handle keyboard better
                        textInputAction: TextInputAction.newline,
                      ),
                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.indigo, Colors.indigoAccent],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ConditionalBuilder(
                          condition: state is !ChatSendMessageLoading,
                          builder: (context) {
                            return ElevatedButton(
                              onPressed: () {
                                final title = titleController.text.trim();
                                final body = bodyController.text.trim();

                                if (title.isEmpty || body.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Please fill in both fields')),
                                  );
                                  return;
                                }

                                cubit.sendMessage(provider.id!, title, body);
                                final snackBar = SnackBar(
                                  elevation: 0,
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.transparent,
                                  margin: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                                  content: AwesomeSnackbarContent(
                                    title: 'Congrats!',
                                    message: 'Message sent successfully',
                                    contentType: ContentType.success,
                                  ),
                                  duration: const Duration(seconds: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(snackBar);

                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text(
                                'Send Message',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                          fallback: (context) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add extra space when keyboard might be visible
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0,
                      ),

                      Container(
                        width: double.infinity,
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArchivePage(provider_id: provider.id!),
                                  ),
                                );
                              },
                              child: const Text('Show Archive'),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Add bottom padding to ensure content is not hidden behind keyboard
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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
}