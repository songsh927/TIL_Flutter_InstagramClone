import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
      MaterialApp(
          theme: style.theme,
          home: MyApp()
      )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var tab = 0;

  getData() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    print(jsonDecode(result.body));
  }

  @override
  void initState(){
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: (){},
            iconSize: 30,
          )
        ]
      ),

      body: [
        StoryUI(),    //홈화면
        Text('샵')     //샵화면
      ][tab],

      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i){
          setState(() {
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'home',
              activeIcon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'shop',
              activeIcon: Icon(Icons.shopping_bag),
          )
        ],
      ),
    );
  }
}

class StoryUI extends StatelessWidget {
  const StoryUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(itemCount: 10, itemBuilder: (c, i){
      return Container(
          width: double.infinity, height: 600,
          alignment: Alignment.bottomLeft,
          child: Column(
            children: [
              Container(
                //padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 10),
                child: Image.asset('IMG_3504.jpeg'),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                        width: double.infinity,
                        child: Text('좋아요 100', style: TextStyle(fontWeight: FontWeight.w900),)
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: Text('글쓴이')
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: Text('글내용')
                    )
                  ],
                ),
              )
            ],
          )
      );
    }
    );
  }
}
