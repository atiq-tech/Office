import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_first_work_dnpdf/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double progress = 0;

  bool didDownloadPDF = false;

  String progressString = 'File has not been downloaded yet.';

  Future download(Dio dio, String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: updateProgress,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      var file = File(savePath).openSync(mode: FileMode.write);
      file.writeFromSync(response.data);
      await file.close();
    } catch (e) {
      print(e);
    }
  }

  void updateProgress(done, total) {
    progress = done / total;
    setState(() {
      if (progress >= 1) {
        progressString =
            '✅ File has finished downloading. Try opening the file.';
        didDownloadPDF = true;
      } else {
        progressString = 'Download progress: ' +
            (progress * 100).toStringAsFixed(0) +
            '% done.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'First, download a PDF file. Then open it.',
            ),
            TextButton(
              onPressed: didDownloadPDF
                  ? null
                  : () async {
                      var tempDir = await getTemporaryDirectory();
                      download(Dio(), imageUrl, tempDir.path + fileName);
                    },
              child: Text('Download a PDF file'),
            ),
            Text(
              progressString,
            ),
            TextButton(
              onPressed: !didDownloadPDF
                  ? null
                  : () async {
                      var tempDir = await getTemporaryDirectory();
                      await Pspdfkit.present(tempDir.path + fileName);
                    },
              child: Text('Open the downloaded file using PSPDFKit'),
            ),
          ],
        ),
      ),
    );
  }
}
