import AVKit
import AVFoundation
import UIKit

public class BannerAdController {
    
    var bannerView: UIImageView?
    
    public static func initializeObject() -> BannerAdController {
        return BannerAdController()
    }
    
    public func show(view: UIView) {
        if (!Adstronomic.ifAdForThisTypeAvailable(type: .Banner)) {
            return
        }
        
        let fileURL = URL(string: (Adstronomic.BANNER_OBJ?.fileURL)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let fileExtension = fileURL?.pathExtension
        
        if (fileExtension == "png" || fileExtension == "jpg" || fileExtension == "webp") { // Image
            if bannerView != nil {
                remove(view: view)
            }
            
            bannerView = UIImageView()
            bannerView?.load(url: fileURL!)
            bannerView?.frame = CGRect(x: (view.frame.size.width - 320) / 2, y: view.frame.size.height - 50, width: 320, height: 50)
            
            bannerView?.isUserInteractionEnabled = true
            bannerView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openStoreLink)))
            
            view.addSubview(bannerView!)
        }
        else {
            print("Format unsupported: " + (fileExtension ?? "unknown"))
            return
        }
        
        sendToBackendImpression()
    }
    
    public func remove(view: UIView) {
        view.willRemoveSubview(bannerView!)
    }
    
    private func sendToBackendImpression() {
        if (Adstronomic.BANNER_OBJ!.id != nil) {
            let urlStr = Adstronomic.API_URL + "MetricsService/BannerImpressionEvent"
            Adstronomic.postJsonObjectRequest(urlStr: urlStr, promoId: Adstronomic.BANNER_OBJ!.id!, completion: { (requestStatus) in
            })
        }
    }
    
    private func sendToBackendClick() {
        if (Adstronomic.BANNER_OBJ!.id != nil) {
            let urlStr = Adstronomic.API_URL + "MetricsService/ClickEvent"
            Adstronomic.postJsonObjectRequest(urlStr: urlStr, promoId: Adstronomic.BANNER_OBJ!.id!, completion: { (requestStatus) in
            })
        }
    }
    
    @objc private func openStoreLink(_ recognizer: UITapGestureRecognizer) {
        sendToBackendClick()
        if (Adstronomic.BANNER_OBJ!.storeURL != nil) {
            if let url = URL(string: "itms-apps://apple.com/app/" + Adstronomic.REWARDED_OBJ!.storeURL!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                 }
                else {
                    // Earlier versions
                    if UIApplication.shared.canOpenURL(url as URL) {
                        UIApplication.shared.openURL(url as URL)
                    }
                }
            }
        }
    }
    
    public func showInComponent(uiImageView: UIImageView) {
        if (!Adstronomic.ifAdForThisTypeAvailable(type: .Banner)) {
            return
        }
        
        if let link = Adstronomic.BANNER_OBJ?.fileURL {
            let fileURL = URL(string: link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let fileExtension = fileURL?.pathExtension
            
            if (fileExtension == "png" || fileExtension == "jpg" || fileExtension == "jpeg" || fileExtension == "webp") {
                uiImageView.load(url: URL(string: Adstronomic.parseURL(link: link))!)
            }
        }
    }
}
