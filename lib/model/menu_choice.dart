import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class MenuChoice {
  const MenuChoice({this.title, this.icon, this.color});

  final String title;
  final IconData icon;
  final Color color;

}

const List<MenuChoice> choices = const <MenuChoice>[
  const MenuChoice(title: 'Copy', icon: MaterialCommunityIcons.content_copy, color: Colors.black),
  const MenuChoice(title: 'Move', icon: MaterialCommunityIcons.folder_move, color: Colors.black),
];