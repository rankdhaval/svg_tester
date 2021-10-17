import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image tester',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image tester'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  final widthController = TextEditingController();
  final heightController = TextEditingController();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File file;
  File fileContent;
  bool show = true;
  double height = 100;
  double width = 100;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: (){

              setState(() {
                show = false;
              });
              setState(() {
                file = writeFile();
                file = File(file.path);
              });
              setState(() {
                show = true;
              });
              readFile(file);
            },
            icon: Icon(Icons.add)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          onSaved: (val){
                            setState(() {
                              height = double.tryParse(val);
                            });
                          },
                          decoration: InputDecoration(
                              label: Text('height'),
                              border: OutlineInputBorder(
                              )
                          ),
                        ),
                      ),
                      SizedBox(width: 20,),
                      Expanded(
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          onSaved: (val){
                            setState(() {
                              height = double.tryParse(val);
                            });
                          },
                          decoration: InputDecoration(
                              label: Text('width'),
                              border: OutlineInputBorder(
                              )
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                            _formKey.currentState.save();
                            print(height);
                          }
                        },
                        child: Text('Show'),
                      )
                    ],
                  ),
                  SizedBox(height: 30,),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(colorsInSVG.length, (index) => GestureDetector(
                      onTap: (){
                        ColorPickerDialog(index);
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: colorsInSVG[index],
                          borderRadius: BorderRadius.all(Radius.circular(27))
                        ),
                      ),
                    )),
                  ),
                  SizedBox(height: 30,),
                  show ?
                  file != null
                      ? SvgPicture.file(file, height: height,width: width,)
                      : Text('Please select images') : Text('Working..'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FilePickerResult result = await FilePicker.platform.pickFiles();

          if(result != null) {
            file = File(result.files.single.path);
            readFile(file);
          }
          setState(() {

          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<String> data;
  String svgFileContent;
  int numColorsInSVG = 0;
  List<String> colorSplit;
  List<Color> colorsInSVG = [];
  void readFile(File file) async{
    data = [];
    svgFileContent ='';
    numColorsInSVG = 0;
    colorSplit = [];
    colorsInSVG = [];
    data = await file.readAsLines();
    print('*' *151);
    debugPrint(data.join());
    print('*' *151);
    svgFileContent = data.join('\n');
    colorSplit = svgFileContent.split('fill="#');
    print(colorSplit.last);
    numColorsInSVG = colorSplit.length;
    setState(() {
      for(int index = 1; index < numColorsInSVG; index++){
        print('*' *151);
        print(colorSplit[index].substring(0,6));
        print(colorSplit[index]);
        colorsInSVG.add(colorConvert(colorSplit[index].substring(0,6)));
      }
    });
    print(colorsInSVG.length);
  }

  File writeFile() {
    for(int index = 1; index < numColorsInSVG; index++){
      colorSplit[index] = 'fill="#'+ colorsInSVG[index-1].toString().substring(10,16).toUpperCase()+ colorSplit[index].substring(6);
      print(colorSplit[index]);
    }
    File newFile = File(file.path);

    String writeStr = colorSplit.join();
    print('%'*100);
    debugPrint(writeStr);
    newFile.writeAsStringSync(writeStr);
    return newFile;
  }

  Color colorConvert(String color) {
    color = color.replaceAll("#", "");
    if (color.length == 6) {
      return Color(int.parse("0xFF"+color));
    } else if (color.length == 8) {
      return Color(int.parse("0x"+color));
    }
  }

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  ColorPickerDialog(int index){
    void changeColor(Color color) => setState(() => colorsInSVG[index] = color);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            titlePadding: const EdgeInsets.all(0.0),
            contentPadding: const EdgeInsets.all(0.0),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: colorsInSVG[index],
                onColorChanged: changeColor,
                colorPickerWidth: 300.0,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: true,
                displayThumbColor: true,
                showLabel: true,
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius: const BorderRadius.only(
                  topLeft: const Radius.circular(2.0),
                  topRight: const Radius.circular(2.0),
                ),
              ),
            ));
      },
    );
  }

}