import Flutter
import UIKit
import MediaPlayer

class MyImageViewNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var imageView: UIImageView!
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = UIView()
        
        super.init()
        // iOS views can be created here
        
        if let args = args as? Dictionary<String, Any>,
           let imageUrl = args["imageUrl"] as? String {
            createNativeView(imageUrl: imageUrl)
            
        }
    }
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(imageUrl: String){
        imageView = UIImageView()
        _view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: _view.leftAnchor, constant: 20).isActive = true
        imageView.rightAnchor.constraint(equalTo: _view.rightAnchor, constant: -20).isActive = true
        imageView.bottomAnchor.constraint(equalTo: _view.bottomAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: _view.topAnchor).isActive = true
        
        if let uint64Value = UInt64(imageUrl) {
            getPhotoInLibrary(localId: uint64Value)
        } else {
            imageView?.image = UIImage(named: "nosongfound")
        }
        
        
    }
    
    func getPhotoInLibrary(localId: UInt64) {
        let mediaQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: localId, forProperty: MPMediaItemPropertyPersistentID, comparisonType: .equalTo)
        mediaQuery.addFilterPredicate(predicate)
        let mediaItems = mediaQuery.items

        // Check if there's a matching media item
        if let mediaItem = mediaItems?.first {
            // Use the retrieved media item as needed
            if let artwork = mediaItem.artwork, let image = artwork.image(at: CGSize(width: 100, height: 100)) {
                imageView?.image = image
            } else {
                imageView?.image = UIImage(named: "nosongfound")
            }
        } else {
            imageView?.image = UIImage(named: "nosongfound")
        }
        
        
    }
}
