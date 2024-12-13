import 'package:aniview_app/widgets/addReviewModal.dart';
import 'package:aniview_app/widgets/review.dart';
import 'package:flutter/material.dart';

class AllReviewsModal extends StatefulWidget {
  final String img;
  final String title;
  final String id;
  final String genre;

  const AllReviewsModal({
    Key? key,
    required this.img,
    required this.title,
    required this.id,
    required this.genre
  }): super(key: key);

  @override
  State<AllReviewsModal> createState() => _AllReviewsModalState();
}

class _AllReviewsModalState extends State<AllReviewsModal> {
  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: const Text(
                      'Close',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                          color: Colors.grey),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                ),
                  const Text(
                    'Reviews',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: Colors.white),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  GestureDetector(
                    onTap: (){
                      showModalBottomSheet(
                  isScrollControlled: true,
                  backgroundColor: Color(0xFF2A2940),
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => AddReviewModal(
                    genre: widget.genre,
                    id: widget.id,
                    img: widget.img,
                    title: widget.title,
                  ),
                );
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                          color: Colors.redAccent),
                    ),
                  ),
              ],
            ),
           Expanded(
             child: ListView.builder(itemCount: 5, itemBuilder: (context, index){
              return ReviewWidget(
                  username: "User1024",
                  dateTime: "12/06/2024",
                  rating: 5,
                  comment: "I like the series overall <3. Hoping for season 2!",
                );
             }),
           )
          ],
        ),
      ),
    );
  }
}