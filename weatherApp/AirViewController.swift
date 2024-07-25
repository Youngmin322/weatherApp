//
//  AirViewController.swift
//  weatherApp
//
//  Created by 조영민 on 6/6/24.
//

import UIKit
import WebKit

class AirViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlKorString = "https://weather.naver.com/airMovieFcast"
        let urlString = urlKorString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string:urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        }
}
