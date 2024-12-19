import 'package:aniview_app/pages/subpages/view_watchlist.dart';
import 'package:aniview_app/pages/subpages/watched.dart';
import 'package:aniview_app/widgets/allReviewsModal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class MyWatchlist extends StatefulWidget {
  const MyWatchlist({super.key});

  @override
  State<MyWatchlist> createState() => _MyWatchlistState();
}

class _MyWatchlistState extends State<MyWatchlist> {
  final TextEditingController _watchlistNameController =
      TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorText;

  void _showAddWatchlistDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF201F31),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Watchlist',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _watchlistNameController,
                      decoration: InputDecoration(
                        hintText: 'Watchlist name',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF3E3C5A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        errorText: _errorText,
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: () async {
                            final name = _watchlistNameController.text.trim();

                            if (name.isEmpty) {
                              setDialogState(() {
                                _errorText = 'Watchlist name cannot be empty';
                              });
                              return;
                            } else {
                              setDialogState(() {
                                _errorText = null;
                              });
                            }

                            await _addWatchlistToFirestore(name);
                            _watchlistNameController.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addWatchlistToFirestore(String name) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.collection('watchlist').add({
      'name': name,
      'createdAt': Timestamp.now(),
    });
  }

  Widget _buildWatchlistGrid() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text(
          'Please log in to view your watchlists.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final userDoc = _firestore.collection('users').doc(userId);

    return StreamBuilder<QuerySnapshot>(
      stream: userDoc.collection('watchlist').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.redAccent,));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No watchlists created yet.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final watchlists = snapshot.data!.docs;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: watchlists.length,
          itemBuilder: (context, index) {
            final watchlist = watchlists[index];
            final name = watchlist['name'] ?? 'Unnamed';

            final animeCollection = userDoc
                .collection('watchlist')
                .doc(watchlist.id)
                .collection('anime');

            return FutureBuilder<QuerySnapshot>(
              future: animeCollection
                  .orderBy('addedAt', descending: true)
                  .limit(1)
                  .get(),
              builder: (context, animeSnapshot) {
                String backgroundImage = '';

                if (animeSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.redAccent,));
                }

                if (animeSnapshot.hasData &&
                    animeSnapshot.data!.docs.isNotEmpty) {
                  final latestAnime = animeSnapshot.data!.docs.first;
                  backgroundImage = latestAnime['animeImage'] ?? '';
                }

                return GestureDetector(
                  onTap: () {
                    print(watchlist.id);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWatchlist(
                          watchlistId: watchlist.id,
                          watchlistTitle: name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundImage.isEmpty
                          ? const Color(0xFF3E3C5A)
                          : null,
                      image: backgroundImage.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(backgroundImage),
                              fit: BoxFit.cover,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        if (backgroundImage.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(backgroundImage),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201F31),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showAddWatchlistDialog,
                        child: Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.library_add_outlined,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Create',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          print('Clicked');
                          Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWatched()
                      ),
                    );

                        },
                        child: Container(
                          height: 150,
                          decoration: const BoxDecoration(
                            color: const Color.fromARGB(255, 21, 21, 33),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Watched Anime',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildWatchlistGrid(),
              ],
            )),
      ),
    );
  }
}
