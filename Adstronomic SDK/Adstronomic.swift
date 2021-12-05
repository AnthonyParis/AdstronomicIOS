import AVKit
import AVFoundation
import UIKit

public class Adstronomic {
    public static var campaignId: String = ""
    public static var API_URL: String = ""
    
    public static var BANNER_OBJ: AdObject?
    public static var INTERSTITIAL_OBJ: AdObject?
    public static var REWARDED_OBJ: AdObject?
    
    private static let dispatchGroup = DispatchGroup()
    
    public static func initialize(campaignId: String) {
        if(Configuration.SDK_VERSION == "DEV.0.1") {
            if(Configuration.API_VERSION == "DEV.0.1") {
                print("Adstronomic Ready !")
                Adstronomic.campaignId = campaignId
                Adstronomic.API_URL = Configuration.API
            } else {
                print("Please Update API Version")
            }
        } else {
            print("Please Update SDK Version")
        }
    }
    
    public static func ifAdForThisTypeAvailable(type: AdType) -> Bool {
        switch type {
            case .Banner:
                return BANNER_OBJ == nil ? false : true
            case .Interstitial:
                return INTERSTITIAL_OBJ == nil ? false : true
            case .Rewarded:
                return REWARDED_OBJ == nil ? false : true
        }
    }
    
    public static func loadAndShow(view: UIViewController, ad: BannerAdController) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if Adstronomic.ifAdForThisTypeAvailable(type: .Banner) {
                ad.show(view: view.view)
                timer.invalidate()
            }
        }
    }
    
    public static func loadAndShow(view: UIViewController, ad: InterstitialAdController) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if Adstronomic.ifAdForThisTypeAvailable(type: .Interstitial) {
                view.present(ad, animated: true, completion: nil)
                timer.invalidate()
            }
        }
    }
    
    public static func loadAndShow(view: UIViewController, ad: RewardedAdController) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if Adstronomic.ifAdForThisTypeAvailable(type: .Rewarded) {
                view.present(ad, animated: true, completion: nil)
                timer.invalidate()
            }
        }
    }
    
    public static func loadBanner() {
        if(Adstronomic.campaignId != "") {
            var urlStr = Adstronomic.API_URL + "AdsService/BannerAd"
            urlStr += "?campaignId=" + Adstronomic.campaignId
            
            jsonObjectRequest(urlStr: urlStr, completion: { (json) in
                Adstronomic.BANNER_OBJ = json
            })
        }
    }
    
    public static func loadInterstitial() {
        if(Adstronomic.campaignId != "") {
            var urlStr = Adstronomic.API_URL + "AdsService/InterstitialAd"
            urlStr += "?campaignId=" + Adstronomic.campaignId
            
            jsonObjectRequest(urlStr: urlStr, completion: { (json) in
                Adstronomic.INTERSTITIAL_OBJ = json
            })
        }
    }
    
    public static func loadRewarded() {
        if(Adstronomic.campaignId != "") {
            var urlStr = Adstronomic.API_URL + "AdsService/RewardedAd"
            urlStr += "?campaignId=" + Adstronomic.campaignId
            
            jsonObjectRequest(urlStr: urlStr, completion: { (json) in
                Adstronomic.REWARDED_OBJ = json
            })
        }
    }
    
    public static func loadAdsData() {
        loadBanner()
        loadInterstitial()
        loadRewarded()
    }
    
    public static func jsonObjectRequest(urlStr: String, completion: @escaping (AdObject) -> ()) {
        dispatchGroup.enter()
        if let url = URL(string: urlStr)
        {
            URLSession.shared.dataTask(with: url) { data, res, err in
                if let data = data {
                    let decoder = JSONDecoder()
                    if let adObject = try? decoder.decode(AdObject.self, from: data) {
                        dispatchGroup.leave()
                        completion(adObject)
                    }
                }
            }.resume()
        }
    }
    
    public static func postJsonObjectRequest(urlStr: String, promoId: String, completion: @escaping (Int) -> ()) {
        if let url = URL(string: urlStr)
        {
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            
            let json = [
                "campaignId": Adstronomic.campaignId,
                "promoId": promoId
            ]
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) {
                URLSession.shared.uploadTask(with: request, from: jsonData) { data, res, err in
                    if let httpResponse = res as? HTTPURLResponse {
                        completion(httpResponse.statusCode)
                    }
                }.resume()
            }
        }
    }
    
    public static func parseURL(link: String) -> String {
        return link.replacingOccurrences(of: " ", with: "%20")
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
