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
    var url: NSURL?
    var observer: JVObserver?

    let webView = WKWebView()
    let progressView = UIProgressView(progressViewStyle: .Default)

    override func loadView() {
        super.loadView()

        // load progress and web views
        webView.addSubview(progressView)
        view = webView

        // auto layout progress view
        progressView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["progressView": progressView]
        webView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[progressView]|", options: [], metrics: nil, views: views))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // load url
        webView.loadRequest(NSURLRequest(URL:url!))

        // update progress
        observer = JVObserver(forObject: webView, keyPath: "estimatedProgress", target: self) { [weak self] _ in
            self?.progressView.progress = Float((self?.webView.estimatedProgress)!)
            if self?.webView.estimatedProgress == 1.0 {
                UIView.animateWithDuration(0.2) {
                    self?.progressView.alpha = 0
                }
            }
        }
    }

    @IBAction func share(sender: UIBarButtonItem) {
        let activity = TUSafariActivity() // open in safari
        let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [title!, url!], applicationActivities: [activity])
        activityViewController.popoverPresentationController?.barButtonItem = sender
        presentViewController(activityViewController, animated: true, completion: nil)
    }
}
