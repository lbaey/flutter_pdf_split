package com.example.flutter_pdf_split;

import androidx.annotation.NonNull;

import com.tom_roush.pdfbox.multipdf.Splitter;
import com.tom_roush.pdfbox.pdmodel.PDDocument;

import java.io.File;
import java.io.IOException;
import java.util.Iterator;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterPdfSplitPlugin */
public class FlutterPdfSplitPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_pdf_split");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("split")) {
      String path = call.argument("path");

      //Loading an existing PDF document
      File file = new File(path);
      PDDocument doc = null;
      try {
        doc = PDDocument.load(file);
      } catch (IOException e) {
        e.printStackTrace();
        result.error("PDF_SPLIT", "Error loading " + path, null );
      }

      //Instantiating Splitter class
      Splitter splitter = new Splitter();

      //splitting the pages of a PDF document
      List<PDDocument> Pages = null;
      try {
        Pages = splitter.split(doc);
      } catch (IOException e) {
        e.printStackTrace();
        result.error("PDF_SPLIT", "Error splitting " + path, null );
      }

      //Creating an iterator
      Iterator<PDDocument> iterator = Pages.listIterator();

      //Saving each page as an individual document
      int i = 1;

      String shortPath = path.replaceAll(".pdf$", "");

      while(iterator.hasNext()){
        PDDocument pd = iterator.next();
        try {
          pd.save(shortPath + "_" + i++ + ".pdf");
        } catch (IOException e) {
          e.printStackTrace();
          result.error("PDF_SPLIT", "Error saving " + shortPath + "_" + (i - 1), null );
        }
      }
      result.success(Pages.size());
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
