//
//  AddGroupMembersTableViewController.swift
//  vuepal
//
//  Created by Per-Andre on 7/17/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import Firebase

class AddGroupMembersTableViewController: UITableViewController {
    let postRef = FIRDatabase.database().reference().child("groups")
    let databaseRef = FIRDatabase.database().reference()
    let storage = FIRStorage.storage()
    var avatarImageId: String = ""
    var group: Group?
    let searchController = UISearchController(searchResultsController: nil)
    var users = ["hey","what's up", "Per Andre Stromhaug", "Gary", "Paige", "Angali", "Ken"]
    var filteredUsers = [String]()

    // MARK: Actions
    
    @IBAction func doneAction(sender: UIBarButtonItem) {
        let storageRef = self.storage.referenceForURL("gs://photo-pizza.appspot.com")
        let groupId = self.group!.name
        let groupRef = self.postRef.child(groupId)
        let dict:[String:String] = ["groupName": self.group!.name,
                                    "creatorFacebookId": String(currentUser.facebookId),
                                    "creatorFirebaseId": currentUser.firebaseId,
                                    "update": "new group created by " + currentUser.name,
                                    "avatarImgId": self.avatarImageId + ".jpg"]
        groupRef.updateChildValues(dict)
        
        let imgRef = storageRef.child("images/" + self.avatarImageId)
        let uploadData = UIImageJPEGRepresentation((self.group?.avatar!)!, 0.05)!
        imgRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            if (error != nil) {
                print("Error in putData")
            }
            else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                print("putData succeeded")
                
                let groupRef = self.databaseRef.child("groups")
                let curGroupRef = groupRef.child(self.group!.name)
                let curGroupImgRef = curGroupRef.child("images")
                
                //uploads to real time database
                var dict = [String: AnyObject]()
                dict["imgId"] = self.avatarImageId + ".jpg"
                dict["uploaderFirebaseId"] = currentUser.firebaseId
                dict["uploaderFacebookId"] = currentUser.facebookId
                dict["uploaderName"] = currentUser.name
                dict["uploaderEmail"] = currentUser.email
                dict["uploadTimeSince1970"] = NSDate().timeIntervalSince1970
                
                print(dict)
                curGroupImgRef.child(self.avatarImageId).updateChildValues(dict)
            }
        })
        
        
        navigateToGroups()
    }
    
    @IBAction func cancelAction(sender: UIBarButtonItem) {
        navigateToGroups()
    }
    func navigateToGroups() {
        let storyBoard : UIStoryboard? = self.storyboard
        let nextViewController = (storyBoard?.instantiateViewControllerWithIdentifier("newNav"))! as UIViewController
        self.presentViewController(nextViewController, animated:true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.tableFooterView = UIView()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
//        print("filtering")
        filteredUsers = users.filter { res in
            return res.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "memberCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AddGroupMembersTableViewCell
        var user = ""
        if searchController.active && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.labelOutlet.text = user
        cell.detailTextLabel?.text = user
        return cell
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

extension AddGroupMembersTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

