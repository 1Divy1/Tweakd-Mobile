import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostsSection extends StatelessWidget {
  final bool isOwner;

  const PostsSection({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<, >(
      builder: (context, state) {
        return Container();
      },
    );
  }
}
