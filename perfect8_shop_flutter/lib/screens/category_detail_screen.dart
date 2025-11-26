import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/category.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.imageUrls != null && category.imageUrls!.isNotEmpty)
                Column(
                  children: category.imageUrls!
                      .map((url) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Image.asset(url),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 16),
              if (category.textUrl != null)
                FutureBuilder(
                  future: rootBundle.loadString(category.textUrl!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(snapshot.data ?? 'Could not load text');
                    }
                    if (snapshot.hasError) {
                      return Text('Error loading text: ${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}