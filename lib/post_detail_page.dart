import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:wordpress_client/wordpress_client.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<Comment>? comments;
  bool _isLoading = true;
  String? _error;

  late final WordpressClient client;

  @override
  void initState() {
    super.initState();
    client = WordpressClient(
        baseUrl: Uri.parse('https://wp.flutterdev.io/wp-json/wp/v2'));
    _loadComments();
  }

  Future<void> _loadComments() async {
    final request = ListCommentRequest(post: [widget.post.id]);
    final loadedComments = await client.comments.list(request);

    loadedComments.map(
      onSuccess: (response) {
        setState(() {
          comments = response.data;
          _isLoading = false;
        });
      },
      onFailure: (response) {
        setState(() {
          _error = response.error.toString();
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title?.rendered ?? ''),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.post.featuredImageUrl != null)
                        Image.network(
                          widget.post.featuredImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      const SizedBox(height: 16),
                      Text(
                        widget.post.title?.rendered ?? '',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      if (widget.post.excerpt?.rendered != null)
                        Text(parse(widget.post.excerpt!.rendered!).body?.text ??
                            ''),
                      const SizedBox(height: 8),
                      Text(parse(widget.post.content?.rendered ?? '')
                              .body
                              ?.text ??
                          ''),
                      const SizedBox(height: 16),
                      if (comments != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comments',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            ...comments!.map((comment) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                      parse(comment.content?.rendered ?? '')
                                              .body
                                              ?.text ??
                                          ''),
                                )),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
