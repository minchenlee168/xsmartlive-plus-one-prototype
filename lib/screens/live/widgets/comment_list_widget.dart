import 'package:flutter/material.dart';

import '../../../models/live_stream.dart';

class CommentListWidget extends StatelessWidget {
  const CommentListWidget({super.key, required this.comments});

  final List<LiveComment> comments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: comments.length,
      itemBuilder: (context, i) => _CommentTile(comment: comments[i]),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});
  final LiveComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              comment.message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.thumb_up_outlined,
                  size: 16, color: Colors.grey),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
