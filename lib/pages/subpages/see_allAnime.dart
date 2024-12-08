import 'package:aniview_app/api/get_seeAll.dart';
import 'package:aniview_app/models/anime_model.dart';
import 'package:aniview_app/widgets/anime_grid.dart';
import 'package:aniview_app/widgets/appBar.dart';
import 'package:flutter/material.dart';

class SeeAllAnime extends StatefulWidget {
  final String type;
  final String filter;
  final String title;

  const SeeAllAnime({
    Key? key,
    required this.type,
    required this.filter,
    required this.title,
  }) : super(key: key);

  @override
  State<SeeAllAnime> createState() => _SeeAllAnimeState();
}

class _SeeAllAnimeState extends State<SeeAllAnime> {
  List<Map<String, String>> animeData = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAnimeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      appBar: const AniviewAppBar(),
      body: Container(
        margin: const EdgeInsets.all(10),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
              height: 10,
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.redAccent,
                      ),
                    )
                  : hasError
                      ? const Center(
                          child: Text(
                            'Failed to load data.',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : AnimeGridWidget(animeList: animeData),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchAnimeData() async {
    
    try {
      List<Anime> animeList = await fetchSeeAll(widget.filter, widget.type);
      
      setState(() {
        animeData = animeList
            .map((anime) => {
                  'id': anime.id,
                  'img': anime.img,
                  'title': anime.title,
                })
            .toList();
        isLoading = false;
        hasError = animeList.isEmpty;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching anime data: $e');
    }
  }
}
