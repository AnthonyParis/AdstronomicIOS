//
//  ViewController.swift
//  Adstronomic
//
//  Created by Pythony on 05/12/2021.
//

import UIKit

class ViewController: UIViewController {

    var bannerAdController: BannerAdController?
    var interstitialAdController: InterstitialAdController?
    var rewardedAdController: RewardedAdController?

    @IBOutlet weak var bannerAdResult: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        Adstronomic.initialize(campaignId: "DB901CE6-07C7-499D-B4DA-4CD34CD82C45")
        Adstronomic.loadAdsData()

        bannerAdController = BannerAdController.initializeObject()
        interstitialAdController = InterstitialAdController.initializeObject()
        rewardedAdController = RewardedAdController.initializeObject()
    }

    @IBAction func startBannerAd(_ sender: Any) {
        bannerAdController?.showInComponent(uiImageView: bannerAdResult)
    }

    @IBAction func startInterstitialAd(_ sender: Any) {
        if let interstitialAdResult = interstitialAdController?.returnPlayer() {
            present(interstitialAdResult, animated: true) {
                interstitialAdResult.player?.play()
            }
        }
    }

    @IBAction func startRewardedAd(_ sender: Any) {
        if let rewardedAdResult = rewardedAdController?.returnPlayer() {
            present(rewardedAdResult, animated: true) {
                rewardedAdResult.player?.play()
            }
        }
    }

}
