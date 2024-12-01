import 'package:flutter/material.dart';

class AnimeListWidget extends StatefulWidget {
  final List<Map<String, String>> animeList;

  const AnimeListWidget({
    Key? key,
    required this.animeList,
  }) : super(key: key);

  @override
  State<AnimeListWidget> createState() => _AnimeListWidgetState();
}

class _AnimeListWidgetState extends State<AnimeListWidget> {
  bool isLoading = true;
  bool hasError = false;
  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.animeList.length,
        itemBuilder: (context, index) {
          final anime = widget.animeList[index];
          
          return GestureDetector(
            onTap: () {
              print(anime['id']);
              // Navigator.pushNamed(
              //   context,
              //   '/details', 
              //   arguments: {'id': anime['id']}, 
              // );
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      anime['img'].toString(),
                      height: 180,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        width: 120,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      ),
                      
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 120,
                    child: Text(
                      anime['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
