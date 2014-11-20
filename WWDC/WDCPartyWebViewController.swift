//
//  WDCPartyWebViewController.swift
//  SFParties
//
//  Created by Genady Okrain on 11/20/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

import UIKit
import WebKit

@objc class WDCPartyWebViewController: UIViewController {
    var webView: WKWebView?
    var url = NSURL?()

    override func loadView() {
        super.loadView()

        self.webView = WKWebView()
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView!.loadRequest(NSURLRequest(URL:url!))
    }

    @IBAction func share(sender: AnyObject) {
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [title!, url!], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
