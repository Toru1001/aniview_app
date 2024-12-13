import 'package:aniview_app/api/get_searchedAnime.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final List<Map<String, String>> users = [
    {'username': 'Frieren101'},
    {'username': 'Frieren19'},
    {'username': 'frierenTes'},
    {'username': 'Frieren35'}
  ];
  List<Map<String, String>> animeData = [];
  final _searchedText = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool hasError = false;
  bool hasSearched = false;
  int currentPage = 1;
  bool isFetchingNextPage = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchedText.dispose();
    _scrollController.dispose();
    super.dispose();
  }

   Future<void> fetchAnimeData({bool isNextPage = false}) async {
    if (!isNextPage && _searchedText.text.isEmpty) {
      setState(() {
        hasSearched = false;
      });
      return;
    }

    if (isLoading || isFetchingNextPage) return;

    if (!isNextPage) {
      setState(() {
        isLoading = true;
        hasError = false;
        hasSearched = true;
        animeData = [];
        currentPage = 1;
        hasMoreData = true;
      });
    } else {
      setState(() {
        isFetchingNextPage = true;
      });
    }

    try {
      final result = await fetchSearch(_searchedText.text, page: currentPage);
      final List<Anime> animeList = result['data'];
      final bool hasNextPage = result['hasNextPage'];

      setState(() {
        if (isNextPage) {
          animeData.addAll(animeList.map((anime) => {
            'id': anime.id,
            'img': anime.img,
            'title': anime.title,
          }));
        } else {
          animeData = animeList.map((anime) => {
            'id': anime.id,
            'img': anime.img,
            'title': anime.title,
          }).toList();
        }

        hasMoreData = hasNextPage;
        isLoading = false;
        isFetchingNextPage = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isFetchingNextPage = false;
        hasError = true;
      });
      debugPrint('Error fetching anime data: $e');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        hasMoreData &&
        !isFetchingNextPage) {
      currentPage++;
      fetchAnimeData(isNextPage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: SafeArea(
        child: Column(
          children: [
            _searchBar(),
            Expanded(
              child: hasSearched
                  ? isLoading && animeData.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                        )
                      : animeData.isNotEmpty
                          ? SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _searchedUsers(),
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Anime',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 20.0,
                                      childAspectRatio: 0.55,
                                    ),
                                    itemCount: animeData.length,
                                    itemBuilder: (context, index) {
                                      final anime = animeData[index];
                                      return GestureDetector(
                                        onTap: () {
                                          if (anime['id'] != null) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AnimeDetailsPage(
                                                  animeId: anime['id']!,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.network(
                                                anime['img'] ?? '',
                                                height: 250,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Container(
                                                    height: 250,
                                                    width: double.infinity,
                                                    color: const Color.fromARGB(255, 21, 21, 33),
                                                    child: Center(
                                                      child: CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                (loadingProgress.expectedTotalBytes ?? 1)
                                                            : null,
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  height: 180,
                                                  color: Colors.grey,
                                                  child: const Icon(Icons.broken_image, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              anime['title'] ?? 'No Title',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  if (isFetchingNextPage)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : hasError
                              ? const Center(
                                  child: Text(
                                    'Failed to load data.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              : const Center(
                                  child: Text(
                                    'No results found.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                  : const Center(
                      child: Text(
                        'Enter something in the Search',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      color: const Color(0xFF201F31),
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchedText,
        onSubmitted: (_) => fetchAnimeData(),
        style: const TextStyle(color: Colors.grey),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF696969).withOpacity(.5),
          contentPadding: const EdgeInsets.all(10),
          hintText: 'Search',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 18),
          prefixIcon: const Icon(Icons.search, size: 30, color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _searchedUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Users',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      users[index]['username']!,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
