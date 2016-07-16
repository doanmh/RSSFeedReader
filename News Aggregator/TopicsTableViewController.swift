//
//  TopicsTableViewController.swift
//  News Aggregator
//
//  Created by Minh Doan on 7/9/16.
//  Copyright © 2016 Paw Studio. All rights reserved.
//

import UIKit
import CoreData

class TopicsTableViewController: UITableViewController, XMLParserDelegate, ChangeFeedDelegate {

    @IBOutlet weak var navigator: UINavigationItem!
    
    var xmlParser : XMLParser!
    var url : NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xmlParser = XMLParser()
        xmlParser.delegate = self
        self.refreshControl?.addTarget(self, action: #selector(TopicsTableViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//            }
    
    func refresh(refreshControl: UIRefreshControl) {
        xmlParser.startParsingContents(url!)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    @IBAction func addLink(sender: AnyObject) {
        let alert = UIAlertController(title: "Add RSS Feed", message: "Give it a name and a RSS Feed Link", preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {(action:UIAlertAction) -> Void in
            let nameField = alert.textFields![0]
            let linkField = alert.textFields![1]
            self.saveAction(nameField.text!, link: linkField.text!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {(action:UIAlertAction) -> Void in})
        alert.addTextFieldWithConfigurationHandler({(nameField : UITextField) -> Void in})
        alert.addTextFieldWithConfigurationHandler({(linkField : UITextField) -> Void in})
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func saveAction(name: String, link: String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("RSSLinks", inManagedObjectContext: managedContext)
        let rssLink = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        rssLink.setValue(name, forKey: "name")
        rssLink.setValue(link, forKey: "url")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return xmlParser.arrParseData.count
    }

    
    func parsingWasFinished() {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath) as! SummaryTableViewCell
        let currentDictionary = xmlParser.arrParseData[indexPath.row] as Dictionary<String, String>
        let articleTitle = NSMutableAttributedString(string: currentDictionary["title"]!, attributes: [NSFontAttributeName : UIFont.boldSystemFontOfSize(15)])
        let articleDescription = NSMutableAttributedString(string: currentDictionary["description"]!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(13)])
        let attributedString = NSMutableAttributedString(attributedString: articleTitle)
        let newLine = NSMutableAttributedString(string: "\n\n")
        attributedString.appendAttributedString(newLine)
        attributedString.appendAttributedString(articleDescription)
        cell.titleLabel.attributedText = attributedString
        if currentDictionary["media:content"] != nil {
            let url = NSURL(string: currentDictionary["media:content"]!)
            let imageData = NSData(contentsOfURL: url!)
            if imageData != nil {
                cell.iconImage.image = UIImage(data: imageData!)
            }
        } else {
            cell.iconImage.image = UIImage(named: "Image")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dictionary = xmlParser.arrParseData[indexPath.row] as Dictionary<String, String>
        let articleLink = dictionary["link"]
        let articleViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idArticleViewController") as! ArticleViewController
        articleViewController.articleURL = NSURL(string: articleLink!)
        showDetailViewController(articleViewController, sender: self)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 140
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "idShowRSSList" {
            let rssListTableViewController = segue.destinationViewController as! RSSListTableViewController
            rssListTableViewController.delegate = self
        }
    }
    
    func didChangeFeed(newURL: NSURL, name: String) {
        url = newURL
        xmlParser.startParsingContents(url!)
        navigator.title = name
        self.tableView.reloadData()
    }
}
