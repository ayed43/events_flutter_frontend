import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:demo/cubits/chat_cubit/chat_cubit.dart';
import 'package:demo/cubits/chat_cubit/chat_states.dart';
import 'package:demo/pages/provider/send_message_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit,ChatStates>(builder: (context, state) {
      return ConditionalBuilder(condition: state is !ChatLoadingProvidersState, builder:
          (context) {
            var cubit=ChatCubit.get(context);
            return ListView.separated(
              physics: BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return Divider(
                  color: Colors.grey.shade300,
                  height: 10,);
              },
              itemCount: cubit.providers.length,
              itemBuilder: (context, index) {
                return ListTile(onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SendMessagePage(
                  provider: cubit.providers[index],
                ),));
                },

                title: Text(cubit.providers[index].name!),
                  subtitle: Text(cubit.providers[index].companyName ?? 'No description'),
                  leading: Image.asset('assets/images/logo.png'),

                );
              },
            );
          }
          , fallback:(context) => Center(child: CircularProgressIndicator()),);
    }, listener: (context, state) {

    },);
  }
}
