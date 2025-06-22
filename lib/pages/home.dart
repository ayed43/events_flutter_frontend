import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:demo/components/home_components/home_components.dart';
import 'package:demo/cubits/home_cobit/home_cubit.dart';
import 'package:demo/cubits/home_cobit/home_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit,HomeStates>(builder: (context, state) {
      return ConditionalBuilder(
          condition: state is !LoadingState,
          builder: (context) => CategoryWidget(HomeCubit.get(context).categories),
          fallback: (context) => Center(child: CircularProgressIndicator()));
    }, listener: (context, state) {

    },);


  }
}
