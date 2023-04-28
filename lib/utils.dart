import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void customSnackBar(BuildContext context,String message, Color color){
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,))
      .closed
      .then((value) => ScaffoldMessenger.of(context)
      .clearSnackBars());
}

//PICK IMAGE
Future<Uint8List?> pickImage(BuildContext context) async{
  FilePickerResult? pickedImage = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.image);
  try{
    if(pickedImage!=null){
      if(kIsWeb){
        //FOR WEB
        return pickedImage.files.single.bytes;
      }
      //FOR MOBILE
      return await File(pickedImage.files.single.path!).readAsBytes();
    }else{
      customSnackBar(context, "No Photo Was Selected", Colors.red);
    }
  }catch(e){
    customSnackBar(context, e.toString(), Colors.red);
  }
  return null;
}