import UIKit
import Flutter
import MediaPlayer
import AVKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    var data: [String] = []
    
    var controller: FlutterViewController!
    var flutterResult:FlutterResult!
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        weak var registrar = self.registrar(forPlugin: "my-views")
        let viewRegistrar = self.registrar(forPlugin: "<my-views>")!
        let myImageViewNativeViewFactory = MyImageViewNativeViewFactory(messenger: registrar!.messenger())
        viewRegistrar.register(
            myImageViewNativeViewFactory,
            withId: "myImageView")
        
        controller = window?.rootViewController as! FlutterViewController
        
        let audioChannel = FlutterMethodChannel(name:"audioPickerPlatform",
                                                binaryMessenger: controller.binaryMessenger)
        
        audioChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "pickAudio" {
                self.flutterResult = result
                self.requestMusicLibraryPermission()
            } else if call.method == "playAudio" {
                
                if let args = call.arguments as? Dictionary<String, Any>, let myIdentifier = args["identifier"] as? String {

                    
                    if let uint64Value = UInt64(myIdentifier) {
                        let mediaQuery = MPMediaQuery.songs()
                        let predicate = MPMediaPropertyPredicate(value: uint64Value, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
                        mediaQuery.addFilterPredicate(predicate)
                        let mediaItems = mediaQuery.items

                        // Check if there's a matching media item
                        if let mediaItem = mediaItems?.first {
                            // Use the retrieved media item as needed
                            if let assetURL = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                                let player = AVPlayer(url: assetURL)
                                                   let playerViewController = AVPlayerViewController()
                                                   playerViewController.player = player
                                                   self.controller.present(playerViewController, animated: true) {
                                                       player.play()
                                                   }
                            } else {
                                debugPrint("Failed1")
                            }
                           
                        } else {
                            debugPrint("Failed2")
                        }
                    } else {
                        debugPrint("Failed3")
                    }
                    
                  
                    
                } else {
                    self.flutterResult(FlutterError.init(code: "errorSetDebug", message: "data or format error", details: nil))
                }
            }  else {
                self.flutterResult(FlutterMethodNotImplemented)
                return
            }
        })
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func requestMusicLibraryPermission(){
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                
                let query = MPMediaQuery()
                
                query.addFilterPredicate(MPMediaPropertyPredicate(value: MPMediaType.music.rawValue, forProperty: MPMediaItemPropertyMediaType))
                
                
                if let items = query.items {
                    for item in items {
                        
                        let persistentID = item.persistentID
                        
                        self.data.append("\(persistentID)@@\(String(describing: item.value(forProperty: MPMediaItemPropertyAssetURL)!))@@\(String(describing: item.title!))")
                    }
                    self.flutterResult("\(self.data)")
                }
            } else {
                // Handle the case when access is denied
            }
        }
        
        
    }
}
