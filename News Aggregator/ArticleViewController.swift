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
    @IBOutlet weak var btnCopyLink: UIBarButtonItem!
    
    var articlesButtonItem : UIBarButtonItem!
    
    var articleURL : NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()

        webview.hidden = true
        toolbar.hidden = true
        
        articlesButtonItem = UIBarButtonItem(title: "Articles", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ArticleViewController.showArticleViewController))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ArticleViewController.handleDisplayModeChangeWithNotification(_:)), name: "DisplayModeChangeNotification", object: nil)
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
            
            if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
        }
    }

    @IBAction func copyLink(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = articleURL.absoluteString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showArticleViewController() {
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }
    
    func handleDisplayModeChangeWithNotification(notification: NSNotification) {
        let displayModeObject = notification.object as? NSNumber
        let nextDisplayMode = displayModeObject?.integerValue
        
        if toolbar.items?.count == 3 {
            toolbar.items?.removeAtIndex(0)
        }
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue {
            toolbar.items?.insert(articlesButtonItem, atIndex: 0)
        } else {
            toolbar.items?.insert(splitViewController!.displayModeButtonItem(), atIndex: 0)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            let firstItem = toolbar.items?[0] as UIBarButtonItem!
            if firstItem?.title == "Articles" {
                toolbar.items?.removeAtIndex(0)
            }
        } else if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
            if toolbar.items?.count == 3 {
                toolbar.items?.removeAtIndex(0)
            }
            
            if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                toolbar.items?.insert(articlesButtonItem, atIndex: 0)
            } else {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
