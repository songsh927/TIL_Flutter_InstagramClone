import 'package:flutter/material.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';

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
  var data = [];

  getData() async {
    var story = await http.get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (story.statusCode == 200){
      setState(() {
        data = jsonDecode(story.body);
      });
    }else{
      data.add('서버오류');
    }
  }

  addData(moreData) {
    setState(() {
      data.add(moreData);
    });
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
            onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Upload() )
              );
            },
            iconSize: 30,
          )
        ]
      ),

      body: [
        StoryUI(data : data , addData : addData),    //홈화면
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

class Upload extends StatelessWidget {
  const Upload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('이미지업로드화면'),
          IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(Icons.close))
        ],
      ),
    );
  }
}


class StoryUI extends StatefulWidget {
  const StoryUI({Key? key, this.data, this.addData}) : super(key: key);
  final data;
  final addData;

  @override
  State<StoryUI> createState() => _StoryUIState();
}

class _StoryUIState extends State<StoryUI> {
  var scroll = ScrollController();

  getMore(int reqtime) async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/more${reqtime}.json'));
    widget.addData(jsonDecode(result.body));
  }

  @override
  void initState() {
    int reqtime = 1;
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent){
        getMore(reqtime);
        reqtime++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if(widget.data.isNotEmpty){
      return ListView.builder(itemCount: widget.data.length, controller: scroll , itemBuilder: (c, i) {
        return Column(
          children: [
            Image.network(widget.data[i]['image']),
            Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('좋아요 ${widget.data[i]['likes'].toString()}'),
                  Text(widget.data[i]['user']),
                  Text(widget.data[i]['content'])
                ],
              ),
            )
          ],
        );
      }
      );
    }else{
      return CircularProgressIndicator();
    }
  }
}