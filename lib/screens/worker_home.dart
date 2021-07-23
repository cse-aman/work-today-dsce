import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:work_today/components/request_card.dart';
import 'package:work_today/model/request.dart';
import 'package:work_today/screens/ownProfile.dart';
import 'package:work_today/screens/userprofile.dart';
import 'package:work_today/services/firebase_user.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

final _firestore = FirebaseFirestore.instance;

class WorkerHome extends StatefulWidget {
   bool isdark;
  WorkerHome({this.isdark});

  @override
  _WorkerHomeState createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:this.widget.isdark?Colors.grey[850]: Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor:this.widget.isdark?Colors.grey[850]: Color(0xFFF6F6F6),
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsets.only(
            left: 18.0,
            top: 12.0,
            bottom: 12.0,
            right: 12.0,
          ),
          child: IconButton(
            icon: Icon(
              Icons.notifications,
              size: 25.0,
              color: this.widget.isdark?Colors.white:Colors.black,
            ),
            onPressed: () {},
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: GestureDetector(

              child:Icon(Icons.account_circle_outlined,color: Colors.deepPurple,size: 30.0, ) ,
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => ownProfile(
                  isdark: widget.isdark,
                )));
              },
            ),
          ),
          Padding(
          padding: const EdgeInsets.all(3.0),
          child: GestureDetector(

            child:Icon(Icons.brightness_4_outlined,color: Colors.deepPurple,size: 30.0, ) ,
            onTap: (){
              setState(() {
                widget.isdark = !widget.isdark;
              });
            },
          ),
        ),

//          Icon(Icons.supervised_user_circle, size: 25.0, color: Colors.black),

          FlatButton(
              onPressed: () {
                FirebaseCurrentUser().signOut();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        isdark: this.widget.isdark,
                      ),
                      settings: RouteSettings(name: 'Home Screen'),
                    ));
              },
              child: Text('Logout',
                style: TextStyle(
              color: this.widget.isdark?Colors.white:Colors.black,
              ),)),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(left: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25.0,
            ),
            Text("Hii ${FirebaseCurrentUser.appUser.name},\nHere Are Your Requests",
                style: TextStyle(
                    fontFamily: 'FV_ALMELO',

                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    wordSpacing: 2.5,
                    color: this.widget.isdark?Colors.white:Colors.black)),
            SizedBox(
              height: 45.0,
            ),
            Expanded(child: RequestStream(
              isdark: widget.isdark,
            )),
          ],
        ),
      ),
    );
  }
}


class RequestStream extends StatefulWidget {
  final bool isdark;
  RequestStream({this.isdark});
  @override
  _RequestStreamState createState() => _RequestStreamState();
}

class _RequestStreamState extends State<RequestStream> {


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(stream: _firestore.collection("users").doc(FirebaseCurrentUser.user.uid).collection("request").snapshots(),builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.lightBlueAccent,
          ),
        );
      }

      final requests = snapshot.data.docs.reversed;
      List<Widget> requestCardList = [];
      for (var request in requests) {
        var data = request.data();

        // if(!availableUserID.contains(docID))
        //   continue;

        RequestHirer hirerRequest = RequestHirer(
          hirerName: data['hirername'],
          hirerID: data['hirerid'],
          requestID: data['requestid'],
          location: data['location'],
          job: data['job'],
          isAccepted: data['isAccepted'],
          amount: data['offer'],
          email: data['email'],
          phoneNo: data['phoneNo'],
        );

        requestCardList.add(WorkerRequestCard(
          isdark: widget.isdark,
          hirerRequest: hirerRequest,));
      }


      return Container(
        alignment: Alignment.center,
        width: double.infinity,
        child: ListView(
          children: requestCardList,
        ),
      );
    },);
  }
}
