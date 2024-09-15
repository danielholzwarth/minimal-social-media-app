import 'package:app/components/my_drawer.dart';
import 'package:app/components/my_post_button.dart';
import 'package:app/components/my_textfield.dart';
import 'package:app/database/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final TextEditingController newPostController = TextEditingController();
  final FirestoreDatabase firestoreDatabase = FirestoreDatabase();

  void postMessage() {
    if (newPostController.text.isNotEmpty) {
      String message = newPostController.text;
      firestoreDatabase.addPost(message);
      newPostController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        title: const Text("H O M E"),
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  child: MyTextfield(
                    hintText: "Say something ..",
                    obscureText: false,
                    controller: newPostController,
                  ),
                ),
                MyPostButton(onTap: postMessage)
              ],
            ),
          ),
          StreamBuilder(
            stream: firestoreDatabase.getPostsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              if (snapshot.hasData) {
                final posts = snapshot.data!.docs;
                final DateFormat formatter = DateFormat('yyyy-MM-dd');

                return Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      String message = post['PostMessage'];
                      String userEmail = post['UserEmail'];
                      Timestamp timeStamp = post['TimeStamp'];

                      return Padding(
                        padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          child: ListTile(
                            title: Text(message),
                            subtitle: Text(
                              userEmail,
                              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                            ),
                            trailing: Text(formatter.format(timeStamp.toDate())),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }

              return const Text("No data");
            },
          )
        ],
      ),
    );
  }
}
