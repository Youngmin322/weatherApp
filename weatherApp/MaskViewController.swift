//
//  MaskViewController.swift
//  weatherApp
//
//  Created by 조영민 on 6/6/24.
//

import UIKit
import WebKit

class MaskViewController: UIViewController {
    @IBOutlet weak var MaskView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let urlKorString = "https://msearch.shopping.naver.com/search/all?query=마스크&bt=-1&frm=MOSCPRO"
        let urlString = urlKorString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        guard let url = URL(string:urlString) else { return }
        let request = URLRequest(url: url)
        MaskView.load(request)
        }

}
