//
//  WebViewController.swift
//  BookLovr
//
//  Created by Christopher Rene on 3/15/17.
//  Copyright © 2017 Christopher Rene. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "http://www.twitter.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
