import Flutter
import UIKit
import PDFKit

public class SwiftFlutterPdfSplitPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_pdf_split", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPdfSplitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion"
        {
            result("iOS " + UIDevice.current.systemVersion)
        }
        else if call.method == "split"
        {
            guard let args = call.arguments as! NSDictionary? else {
                return result(FlutterError(code: "RENDER_ERROR",
                                           message: "Arguments not sended",
                                           details: nil))
            }
            let pdfFilePath = args["filePath"] as! String
            let outDirectory = args["outDirectory"] as! String
            let outFileNamePrefix = args["outFileNamePrefix"] as! String

            if #available(iOS 11.0, *) {
                let url = NSURL.fileURL(withPath: pdfFilePath)
                if url.isFileURL {
                    let pdfDocument = PDFDocument(url: url)
                
                    let pages = pdfDocument!.pageCount
                    var pagePaths = [String]()
                    
                    for index in 0...pages-1 {
                        let page = (pdfDocument?.page(at: index))!
                        let singlePageFilename = outDirectory + "/" + outFileNamePrefix + String(index) + ".pdf"
                        let singlePageFilenameUrl = NSURL.fileURL(withPath: singlePageFilename)
                        let singlePage = PDFDocument.init()
                        singlePage.insert(page, at: 0)

                      // https://stackoverflow.com/questions/6553540/merge-pdf-files-on-ios/64191028#64191028
                        do {
                            let documentDataForSaving : Data! = singlePage.dataRepresentation()
                            try documentDataForSaving?.write(to: singlePageFilenameUrl)
                        } catch {
                            print(error)
                        }
                        
                        pagePaths.append(singlePageFilename)
                        print(singlePageFilename)
                    }
                    var splitResult = [String : Any]()
                    splitResult["pageCount"] = pages
                    splitResult["pagePaths"] = pagePaths
                    
                    result(splitResult)
                }
            } else {
                result(FlutterMethodNotImplemented)
            }

        }
        else {
            result(FlutterMethodNotImplemented)
        }
    }
}
