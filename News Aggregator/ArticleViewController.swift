//
//  ArticleViewController.swift
//  News Aggregator
//
//  Created by Minh Doan on 7/9/16.
//  Copyright © 2016 Paw Studio. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var btnPubDate: UIBarButtonItem!
    
    var articleURL : NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        webview.hidden = true
        toolbar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if articleURL != nil {
            let request : NSURLRequest = NSURLRequest(URL: articleURL)
            webview.loadRequest(request)
            
            if webview.hidden {
                webview.hidden = false
                toolbar.hidden = false
            }
        }
    }

    @IBAction func showPublishDate(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
