import 'package:flutter/material.dart';
import 'package:instagram/notification.dart';
import './style.dart' as style;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (c) => Store1()),
          ChangeNotifierProvider(create: (c) => Store2()),
        ],
        child: MaterialApp(
            theme: style.theme,
            home: MyApp()
        ),
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
  var userImage;

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

  saveData() async{
    var storage = await SharedPreferences.getInstance();
    storage.setString('name', 'john');
    var a = storage.get('name');
    print(a);
  }

  addData(moreData) {
    setState(() {
      data.add(moreData);
    });
  }

  @override
  void initState(){
    super.initState();
    initNotifications(context);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Text('+'),onPressed: (){showNotifications2();},),

      appBar: AppBar(
        title: Text('Instagram'),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () async {
              var picker = ImagePicker();
              var image = await picker.pickImage(source: ImageSource.gallery);
              if(image != null){
                setState(() {
                  userImage = File(image.path);
                });
              }

              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Upload(userImage : userImage , addData: addData,) )
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
  Upload({Key? key , this.userImage, this.addData}) : super(key: key);
  final addData;
  final userImage;
  DateTime now = DateTime.now();
  var storyText = TextEditingController();
  var newStory = {
    "id": 960927,
    "image":"",
    "likes":0,
    "date":"",
    "content": "",
    "liked": false,
    "user": "Me"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(userImage),
          Text('이미지업로드화면'),
          TextField(controller: storyText,),
          Row(
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
              IconButton(
                onPressed: (){
                  newStory['image'] = userImage;
                  newStory['content'] = storyText.text;
                  newStory['date'] = DateFormat.yMMMMd().format(now);
                  addData(newStory);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.add_box),
              )
            ],
          ),

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
            widget.data[i]['image'].runtimeType == String
            ? Image.network(widget.data[i]['image']) : Image.file(widget.data[i]['image']),
            Container(
              constraints: BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Text(widget.data[i]['user']),
                    onTap: (){
                      context.read<Store1>().getData();
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => Profile() )
                      );
                    },
                  ),
                  Text('좋아요 ${widget.data[i]['likes'].toString()}'),
                  Text(widget.data[i]['date']),
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

class Store1 extends ChangeNotifier{
  var follower = 0;
  var status = '팔로우';
  var profileImage = [];
  
  getData() async{
    var result = await http.get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    print(result2);
    notifyListeners();
  }
  
  pressFollow(){
    if (status == '팔로우'){
      follower++;
      status = '팔로잉';
    }else{
      follower--;
      status = '팔로우';
    }
    notifyListeners();
  }
}

class Store2 extends ChangeNotifier{
  var name = 'John Kim';
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<Store2>().name),),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
              delegate: SliverChildBuilderDelegate(
                    (c,i) => Image.network(context.watch<Store1>().profileImage[i]),
                    childCount: context.watch<Store1>().profileImage.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2))
        ],
      )
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(Icons.account_circle , size: 45,),
        Text('팔로워 ${context.watch<Store1>().follower.toString()}'),
        ElevatedButton(onPressed: (){
          context.read<Store1>().pressFollow();
        }, child: Text(context.watch<Store1>().status))
      ],
    );
  }
}
