//
//  TopicsTableViewController.swift
//  News Aggregator
//
//  Created by Minh Doan on 7/9/16.
//  Copyright © 2016 Paw Studio. All rights reserved.
//

import UIKit

class TopicsTableViewController: UITableViewController, XMLParserDelegate {

    var xmlParser : XMLParser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml")
        xmlParser = XMLParser()
        xmlParser.delegate = self
        xmlParser.startParsingContents(url!)
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
//        cell.descriptionLabel.text = currentDictionary["description"]
        let url = NSURL(string: currentDictionary["media:content"]!)
        let imageData = NSData(contentsOfURL: url!)
        cell.iconImage.image = UIImage(data: imageData!)
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
