import 'dart:io';

//import 'package:document_viewer/document_viewer.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class DocViewerPage extends StatefulWidget {
  final String url;

  const DocViewerPage({required this.url, Key? key}) : super(key: key);

  @override
  State<DocViewerPage> createState() => _DocViewerPageState();
}

class _DocViewerPageState extends State<DocViewerPage> {
  late final WebViewController _controller;
  int progressStatus = 0;
  bool _isLoading = false;

  String? filePath;



  Future<void> delay() async {
    await Future.delayed(Duration(milliseconds: 2000));
  }

  @override
  void initState() {
    super.initState();

    //delay();



   /* _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              progressStatus = progress;
            });
            // Optionally show progress indicator
            //print('Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              progressStatus = 0;
              _isLoading = true;


            });

            print('Page started loading: $url');
          },
          onPageFinished: (String url) {

            print('Page finished loading: $url');
          },
          onHttpError: (HttpResponseError error) {
            print('HTTP error: ${error.response}');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
           /* if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }*/
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://docs.google.com/gview?embedded=true&url=${widget.url}'),
        //Uri.parse(widget.url),
      );

    _controller.setBackgroundColor(Colors.white);*/

    //_controller.reload();
    //_controller.reload();
    //_controller.reload();

    checkAndOpen();

  }


  Future<void> checkAndOpen() async {
    if(isDocx(widget.url)){
      await downloadDocxFile();
      Navigator.pop(context);
    } else{
      await downloadPdfFile();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.clearCache(); // Clear the WebView cache if needed
    _controller.clearLocalStorage();
    super.dispose();
  }


  bool isDocx(String url) {
    final lowerCaseUrl = url.toLowerCase(); // Normalize case for comparison

    if (lowerCaseUrl.endsWith('.docx')) {
      return true;
    } else  {
      print('The URL is for a DOCX file.');
      return false;
    }
  }

  Future<void> listenForPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  _openOtherTypeFile(String filePath) async {
    final extension = path.extension(filePath);//import 'package:path/path.dart' as path;
    await OpenFile.open(filePath);
  }

  Future<String> downloadPdfFile() async {
    await listenForPermission(); // Ensure permission is granted
    final directory = await getApplicationDocumentsDirectory();
    final pdfFilePath = '${directory.path}/resume_.pdf'; // Change extension to .pdf

    // Replace with the URL of your PDF file
    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      // Write the PDF file to local storage
      File file = File(pdfFilePath);
      await file.writeAsBytes(response.bodyBytes);

      print('Download Complete');
      _openOtherTypeFile(pdfFilePath); // You can rename this method if needed

      return pdfFilePath;
    } else {
      throw Exception("Failed to download PDF file");
    }
  }

  Future<String> downloadDocxFile() async {
    await listenForPermission(); // Ensure permission is granted
    final directory = await getApplicationDocumentsDirectory();
    final mfilePath = '${directory.path}/resume_.docx';

    // Replace with the URL of your DOCX file
    //final response = await http.get(Uri.parse('https://talentturbo.s3.amazonaws.com/resume/dev/candidate/profile/2756/Chatbot.docx'));
    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      // Write the DOCX file to local storage
      File file = File(mfilePath);
      await file.writeAsBytes(response.bodyBytes);

      print('Download Complete');
      _openOtherTypeFile(mfilePath);

      return mfilePath;
    } else {
      throw Exception("Failed to download DOCX file");
    }
  }

  void loadDocx() async{
    downloadDocxFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing Resume')),
     /* body:  FutureBuilder<String>(
        future: downloadDocxFile(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            return Container(
              color: Colors.white,
              //child: DocumentViewer(filePath: snapshot.data!),
              child: Text('data'),
            );
          } else {
            return Center(child: Text("No Document Loaded"));
          }
        },
      ),*/

      /*body: Stack(
        children: [
          *//*WebViewWidget(
              controller: _controller,

          ),*//*

          PDF().cachedFromUrl(widget.url,
            errorWidget: (er)=>Center(child: Text(er.toString()))
          ),

          _isLoading ?  LinearProgressIndicator(
                            value: progressStatus / 100,
                            minHeight: 4,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ): Container()

        ],
      ),*/

      body: Center(child: CircularProgressIndicator(),),

    );
  }
}
