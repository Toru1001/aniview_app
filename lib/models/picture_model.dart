import 'package:flutter/material.dart';

class PictureModel {
  String name;
  String path;

  PictureModel({
    required this.name,
    required this.path,
  });

  static List<PictureModel> getPictures() {
    List<PictureModel> pictures = [];
    pictures.add(PictureModel(name: 'Luffy', path: 'assets/icons/friends'));
    
    return pictures;
  }
}
