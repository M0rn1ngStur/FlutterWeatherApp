import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer(
      {super.key, required this.recentSearches, required this.setCity});

  final List<String> recentSearches;
  final Function setCity;

  @override
  State<NavDrawer> createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Recent searches',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          Column(
              children: widget.recentSearches
                  .map(
                    (e) => ListTile(
                      leading: Icon(Icons.input),
                      title: Text(e),
                      onTap: () {
                        widget.setCity(e);
                      },
                    ),
                  )
                  .toList()),
        ],
      ),
    );
  }
}
