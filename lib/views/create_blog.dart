import 'dart:io';
import 'package:blog_flutter_desafio/services/crud.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class CreateBlog extends StatefulWidget {
  @override
  _CreateBlogState createState() => _CreateBlogState();
}

class _CreateBlogState extends State<CreateBlog> {
  String authorName, title, desc;

  File selectedImage;
  bool _isLoading = false;
  CrudMethods crudMethods = new CrudMethods();

  Future getImage() async {
    // ignore: deprecated_member_use
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      selectedImage = image;
    });
  }

  uploadBlog() async {
    if (selectedImage != null) {
      setState(() {
        _isLoading = true;
      });

      /// uploading image to firebase storage
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child("blogImages")
          .child("${randomAlphaNumeric(9)}.jpg");

      final StorageUploadTask task = firebaseStorageRef.putFile(selectedImage);

      var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
      print("this is url $downloadUrl");

      Map<String, String> blogMap = {
        "imgUrl": downloadUrl,
        "authorName": authorName,
        "title": title,
        "desc": desc
      };
      crudMethods.addData(blogMap).then((result) {
        Navigator.pop(context);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Flutter",
                style: TextStyle(fontSize: 22, color: Colors.orange),
              ),
              Text(
                "Blog",
                style: TextStyle(fontSize: 22, color: Colors.grey),
              ),
              Text(
                "Desafio",
                style: TextStyle(fontSize: 22, color: Colors.orange),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                uploadBlog();
              },
              child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.file_upload)),
            )
          ],
        ),
        body: _isLoading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: selectedImage != null
                            ? Container(
                                margin: EdgeInsets.symmetric(horizontal: 16),
                                height: 170,
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    selectedImage,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 16),
                                  height: 170,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6)),
                                  width: MediaQuery.of(context).size.width,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    color: Colors.black45,
                                  ),
                                ),
                              )),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: <Widget>[
                            TextField(
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                hintText: "Nome",
                              ),
                              onChanged: (val) {
                                authorName = val;
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(hintText: "T??tulo"),
                              onChanged: (val) {
                                title = val;
                              },
                            ),
                            TextField(
                              keyboardType: TextInputType.multiline,
                              decoration:
                                  InputDecoration(hintText: "Descri????o"),
                              maxLength: 280,
                              maxLines: 5,
                              onChanged: (val) {
                                desc = val;
                              },
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
