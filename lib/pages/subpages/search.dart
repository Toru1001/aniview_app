import 'package:aniview_app/api/get_searchedAnime.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/pages/subpages/anime_details.dart';
import 'package:aniview_app/pages/subpages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<QueryDocumentSnapshot> searchedUsers = [];
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
          animeData = animeList
              .map((anime) => {
                    'id': anime.id,
                    'img': anime.img,
                    'title': anime.title,
                  })
              .toList();
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

  Future<void> searchUsers() async {
    if (_searchedText.text.isEmpty) return;

    setState(() {
      isLoading = true;
      hasError = false;
      searchedUsers = [];
    });

    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      print('Searching for users with query: ${_searchedText.text}');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: _searchedText.text)
          .where('username', isLessThanOrEqualTo: '${_searchedText.text}\uf8ff')
          .get();

      final docs = querySnapshot.docs
          .where((doc) => doc.id != currentUserId) // Exclude current user
          .toList();

      print('Found ${docs.length} users (excluding current user)');

      setState(() {
        searchedUsers = docs;
        isLoading = false;
        hasSearched = true;
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
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
                  ? isLoading && animeData.isEmpty && searchedUsers.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              if (animeData.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Center(
                                    child: Text(
                                      'No anime found.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 18),
                                    ),
                                  ),
                                ),
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
                                            builder: (context) =>
                                                AnimeDetailsPage(
                                              animeId: anime['id']!,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            anime['img'] ?? '',
                                            height: 250,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                height: 250,
                                                width: double.infinity,
                                                color: const Color.fromARGB(
                                                    255, 21, 21, 33),
                                                child: Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            (loadingProgress
                                                                    .expectedTotalBytes ??
                                                                1)
                                                        : null,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              height: 180,
                                              color: Colors.grey,
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.white),
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
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 250,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child:
                                  Image.asset('assets/icons/ConanSearch.png'),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Enter search...',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
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
        onSubmitted: (_) => {fetchAnimeData(), searchUsers()},
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
            itemCount: searchedUsers.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        userId: searchedUsers[index].id,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                            searchedUsers[index]['imageUrl'] ?? ''),
                        child: searchedUsers[index]['imageUrl'] == null
                            ? Icon(Icons.person, size: 40, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        searchedUsers[index]['username'] ?? 'No username',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (searchedUsers.isEmpty)
          Center(
            child: Text(
              'No users found.',
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ),
      ],
    );
  }
}
