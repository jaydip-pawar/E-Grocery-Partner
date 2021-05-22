import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_grocery_partner/providers/product_provider.dart';
import 'package:e_grocery_partner/services/firebase_services.dart';
import 'package:e_grocery_partner/widgets/banner_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({Key key}) : super(key: key);

  @override
  _BannerScreenState createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {

  FirebaseServices _services = FirebaseServices();
  bool _visible = false;
  File _image;
  var _imagePathText = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var _provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          BannerCard(),
          Divider(
            thickness: 3,
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            child: Center(
              child: Text(
                'ADD NEW BANNER',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      color: Colors.grey[200],
                      child: _image != null ? Image.file(_image, fit: BoxFit.fill,) : Center(child: Text("No Image Selected"),),
                    ),
                  ),
                  TextFormField(
                    controller: _imagePathText,
                    enabled: false,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(
                    visible: _visible ? false : true,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _visible = true;
                              });
                            },
                            child: Text(
                              'Add New Banner',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _visible,
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    getBannerImage().then((value) {
                                      if(_image != null) {
                                        _imagePathText.text = _image.path;
                                      }
                                    });
                                  },
                                  child: Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: _image != null ? false : true,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor: _image != null ? Theme.of(context).primaryColor : Colors.grey,
                                    ),
                                    onPressed: () {
                                      EasyLoading.show(status: 'Saving...');
                                      uploadBannerImage(_image.path, _provider.shopName).then((url) {
                                        if(url != null) {
                                          _services.saveBanner(url);
                                          setState(() {
                                            _imagePathText.clear();
                                            _image = null;
                                          });
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Banner Upload',
                                            content: 'Banner Image uploaded successfully...',
                                          );
                                        } else {
                                          EasyLoading.dismiss();
                                          _provider.alertDialog(
                                            context: context,
                                            title: 'Banner Upload',
                                            content: 'Banner Upload failed',
                                          );
                                        }
                                      });
                                    },
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _visible = false;
                                      _imagePathText.clear();
                                      _image = null;
                                    });
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<File> getBannerImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if(pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      print("No image selected.");
    }
    return _image;
  }

  Future<String> uploadBannerImage(filePath, shopName) async {
    File file = File(filePath);
    var timeStamp = Timestamp.now().millisecondsSinceEpoch;

    FirebaseStorage _storage = FirebaseStorage.instance;

    try {
      await _storage.ref('vendorBanner/$shopName/$timeStamp').putFile(file);
    } on FirebaseException catch (e) {
      print(e.code);
    }
    String downloadUrl = await _storage.ref('vendorBanner/$shopName/$timeStamp').getDownloadURL();
    return downloadUrl;
  }

}
