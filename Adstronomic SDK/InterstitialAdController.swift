import AVKit
import AVFoundation
import UIKit

public class InterstitialAdController: UIViewController {

    @IBOutlet weak var UIAdImage: UIImageView!

    private var onAdLoadFailed: (() -> ())?
    private var onAdLoaded: (() -> ())?
    private var onAdClosed: (() -> ())?
    private var onAdShown: (() -> ())?
    var player: AVPlayer?
    
    public static func initializeObject() -> InterstitialAdController {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Adstronomic", bundle: Bundle(for: InterstitialAdController.self))
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "InterstitialAdController") as! InterstitialAdController
        newViewController.modalPresentationStyle = .fullScreen
        
        return newViewController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!Adstronomic.ifAdForThisTypeAvailable(type: .Interstitial)) {
            onAdLoadFailed?()
            return
        }
        
        let fileURL = URL(string: (Adstronomic.INTERSTITIAL_OBJ?.fileURL)!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let fileExtension = fileURL?.pathExtension
        
        if (fileExtension == "mp4" || fileExtension == "m4a") { // Video
            player = AVPlayer(url: fileURL!)
            let layer = AVPlayerLayer(player: player)
            layer.frame = view.bounds
            layer.videoGravity = .resizeAspectFill
            view.layer.insertSublayer(layer, at: 0)
            
            player?.automaticallyWaitsToMinimizeStalling = false
            player?.play()
        }
        else if (fileExtension == "png" || fileExtension == "jpg" || fileExtension == "webp") { // Image
            UIAdImage.isHidden = false
            UIAdImage.load(url: fileURL!)
        }
        else {
            print("Format unsupported: " + (fileExtension ?? "unknown"))
            onAdLoadFailed?()
            return
        }
        
        onAdLoaded?()
        sendToBackendImpression()
        onAdShown?()
    }
    
    private func sendToBackendImpression() {
        if (Adstronomic.INTERSTITIAL_OBJ!.id != nil) {
            let urlStr = Adstronomic.API_URL + "MetricsService/InterstitialImpressionEvent"
            Adstronomic.postJsonObjectRequest(urlStr: urlStr, promoId: Adstronomic.INTERSTITIAL_OBJ!.id!, completion: { (requestStatus) in
            })
        }
    }
    
    private func sendToBackendClick() {
        if (Adstronomic.INTERSTITIAL_OBJ!.id != nil) {
            let urlStr = Adstronomic.API_URL + "MetricsService/ClickEvent"
            Adstronomic.postJsonObjectRequest(urlStr: urlStr, promoId: Adstronomic.INTERSTITIAL_OBJ!.id!, completion: { (requestStatus) in
            })
        }
    }
    
    @IBAction func openStoreLink(_ sender: Any) {
        sendToBackendClick()
        if (Adstronomic.INTERSTITIAL_OBJ!.storeURL != nil) {
            if let url = URL(string: "itms-apps://apple.com/app/" + Adstronomic.INTERSTITIAL_OBJ!.storeURL!) {
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
    
    @IBAction func CloseAd(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        player?.pause()
        onAdClosed?()
    }
    
    public func setOnAdLoadFailed(completionHandler: @escaping () -> ()) {
        onAdLoadFailed = completionHandler
    }
    
    public func setOnAdLoaded(completionHandler: @escaping () -> ()) {
        onAdLoaded = completionHandler
    }
    
    public func setOnAdClosed(completionHandler: @escaping () -> ()) {
        onAdClosed = completionHandler
    }
    
    public func setOnAdShown(completionHandler: @escaping () -> ()) {
        onAdShown = completionHandler
    }
    
    public func returnPlayer() -> AVPlayerViewController? {
        if (!Adstronomic.ifAdForThisTypeAvailable(type: .Interstitial)) {
            return nil
        }
        
        if let link = Adstronomic.INTERSTITIAL_OBJ?.fileURL {
            let fileURL = URL(string: link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            let fileExtension = fileURL?.pathExtension
            
            if (fileExtension == "mp4" || fileExtension == "m4a") {
                guard let url = URL(string: Adstronomic.parseURL(link: link)) else { return nil }
                
                let player = AVPlayer(url: url)

                let controller = AVPlayerViewController()
                controller.player = player

                return controller
            }
        }

        return nil
    }
}
