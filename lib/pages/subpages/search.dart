import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF201F31),
      height: double.infinity,
      width: double.infinity,
      child:  Padding(
        padding: EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          children: [
            _searchBar(),
            SizedBox(height: 20),
            Container(
              child: Column(
                children: [

                ],
              ),
            )
           
          ],
        ),
      ),
    );
  }

    Container _searchBar() {
    return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF696969).withOpacity(0.02),
                blurRadius: 20,
                spreadRadius: 0.0
              )
            ]
          ),
        child: TextField(
          style: TextStyle(color: Colors.grey),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFF696969).withOpacity(.5),
            contentPadding: const EdgeInsets.all(10),
            hintText: 'Search',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.search, size: 30, color: Colors.grey,),
            ),
            suffixIcon: Container(
              width: 100,
              child: const IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    VerticalDivider(
                      color: Colors.grey,
                      thickness: 0.1,
                      indent: 10,
                      endIndent: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: Colors.grey,),
                    ),
                  ],
                ),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            )
          ),
        ));
  }
}