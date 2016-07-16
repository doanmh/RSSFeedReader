//
//  RSSListTableViewController.swift
//  News Aggregator
//
//  Created by Minh Doan on 7/16/16.
//  Copyright © 2016 Paw Studio. All rights reserved.
//

import UIKit
import CoreData

protocol ChangeFeedDelegate : class {
    func didChangeFeed(newURL : NSURL, name: String)
}

class RSSListTableViewController: UITableViewController {

    var rssLinksArray = [NSManagedObject]()
    weak var delegate: ChangeFeedDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = editButtonItem()
        fetchData()
    }
    
    func fetchData() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "RSSLinks")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            rssLinksArray = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not load \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssLinksArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idRSSLinkCell", forIndexPath: indexPath) as UITableViewCell
    
        let feedName = rssLinksArray[indexPath.row].valueForKey("name") as! String
        cell.textLabel!.text = feedName

        return cell
    }
 
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let urlString = rssLinksArray[indexPath.row].valueForKey("url") as! String
        let feedName = rssLinksArray[indexPath.row].valueForKey("name") as! String
        let url = NSURL(string: urlString)
        delegate?.didChangeFeed(url!, name : feedName)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let feedToDelete = rssLinksArray[indexPath.row]
            managedContext.deleteObject(feedToDelete)
            do {
                try managedContext.save()
                fetchData()
            } catch let error as NSError {
                print("Could not load \(error), \(error.userInfo)")
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            self.tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

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
