import 'package:flutter/material.dart';

class ChangePic extends StatefulWidget {
  const ChangePic({super.key});

  @override
  State<ChangePic> createState() => _ChangePicState();
}

final List<String> imageUrls = [
  'https://i.pinimg.com/736x/06/b8/45/06b8454a2ce7a8270c26ee70d0ebfd16.jpg',
  'https://i.pinimg.com/736x/8e/d8/28/8ed828d79c3ebe987177a16da535e9cb.jpg',
  'https://i.pinimg.com/736x/8c/08/bc/8c08bccd5c20fa27d0fb8300b29369fe.jpg',
  'https://i.pinimg.com/736x/1e/cf/aa/1ecfaa7ad81dffd2952321cdf3763725.jpg',
  'https://i.pinimg.com/736x/af/5c/0b/af5c0bff5273af1d8f944a3a6347d6a5.jpg',
  'https://i.pinimg.com/736x/2e/a2/68/2ea2683e67f28283431f5f9b8d0b2f8d.jpg',
  'https://i.pinimg.com/736x/6f/4e/ad/6f4eaddfb45810ecfbbefab432d77fd8.jpg',
  'https://i.pinimg.com/736x/68/df/3f/68df3f3cab27704fbd7dfd0edfbcda58.jpg',
];

String? selectedImage;

class _ChangePicState extends State<ChangePic> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF201F31),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF201F31),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.grey.shade800,
                      width: 5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: selectedImage != null
                        ? NetworkImage(selectedImage!)
                        : null,
                    child: selectedImage == null
                        ? Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: 100,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedImage = imageUrls[index];
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImage == imageUrls[index]
                                  ? Colors.red
                                  : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(imageUrls[index]),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
