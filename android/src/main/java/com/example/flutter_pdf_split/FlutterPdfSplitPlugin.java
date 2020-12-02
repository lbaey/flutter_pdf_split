package com.example.flutter_pdf_split;

import androidx.annotation.NonNull;

import com.tom_roush.pdfbox.multipdf.Splitter;
import com.tom_roush.pdfbox.pdmodel.PDDocument;

import java.io.File;
import java.io.IOException;
import java.util.AbstractMap;
import java.util.HashMap;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPdfSplitPlugin
 */
public class FlutterPdfSplitPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private static final String TAG = "FlutterPdfSplitPlugin";

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
            String path = call.argument("filePath");
            String outDirectory = call.argument("outDirectory");

            //Verifying outDirectory existence
            File directory = new File(outDirectory);
            if (!directory.isDirectory()) {
                result.error("PDF_SPLIT", "outDirectory " + outDirectory + "is not a directory", null);
            }

            //Loading an existing PDF document
            File file = new File(path);
            PDDocument doc = null;
            try {
                doc = PDDocument.load(file);
            } catch (IOException e) {
                e.printStackTrace();
                result.error("PDF_SPLIT", "Error loading " + path, null);
            }

            //Instantiating Splitter class
            Splitter splitter = new Splitter();

            //splitting the pages of a PDF document
            List<PDDocument> Pages = null;
            try {
                Pages = splitter.split(doc);
            } catch (IOException e) {
                e.printStackTrace();
                result.error("PDF_SPLIT", "Error splitting " + path, null);
            }

            //Creating an iterator
            Iterator<PDDocument> iterator = Pages.listIterator();

            //Saving each page as an individual document
            int i = 1;
            List<String> pagePaths = new ArrayList<>();

            while (iterator.hasNext()) {
                PDDocument pd = iterator.next();
                String singlePageFileName = outDirectory + "/page_" + i++ + ".pdf";
                try {
                    pd.save(singlePageFileName);
                    android.util.Log.d(TAG, "onMethodCall: " + singlePageFileName);
                    pd.close();
                    pagePaths.add(singlePageFileName);
                } catch (IOException e) {
                    e.printStackTrace();
                    result.error("PDF_SPLIT", "Error saving " + singlePageFileName, null);
                }
            }
            try {
                doc.close();
            } catch (IOException e) {
                e.printStackTrace();
                result.error("PDF_SPLIT", "Error closing " + path, null);
            }

            Map splitResult = new HashMap<String,Object>();
            splitResult.put("pageCount", Pages.size());
            splitResult.put("pagePaths", pagePaths);
            result.success(splitResult);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
