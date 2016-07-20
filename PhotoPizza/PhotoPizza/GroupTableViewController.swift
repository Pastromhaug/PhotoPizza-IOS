//
//  GroupTableViewController.swift
//  vuepal
//
//  Created by Per-Andre on 7/13/16.
//  Copyright © 2016 Gary Cheng. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftyJSON
import DKImagePickerController
import Agrume
import Photos

class GroupTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    //MARK: Properties
    var groupsList = [Group]()
    var groups = [String:Group]() {
        didSet {
            groupsList = Array(groups.values)
            tableView.reloadData()
        }
    }
    @IBOutlet var groupTableView: UITableView!
    
    //refs
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    
    struct refAndHandle {
        var ref: FIRDatabaseReference
        var handle: FIRDatabaseHandle?
    }
    
    var refsAndHandles = [refAndHandle]() {
        didSet {
            self.groups = [:]
            for var i in refsAndHandles {
                i.handle = i.ref.observeEventType(.Value,
                    withBlock: { snapshot in
                        let groupDict = JSON(snapshot.value!)
                        let groupName = groupDict["groupName"].stringValue
                        let groupId = groupDict["groupId"].stringValue
                        let avatarImgId = groupDict["avatarImgId"].stringValue
                        let update = groupDict["update"].stringValue
                        
                        let newGroup = Group(id: groupId,  name: groupName)
                        newGroup.update = update
                        
                        let storageRef = self.storage.referenceForURL("gs://photo-pizza.appspot.com")
                        let photoRef = storageRef.child("images/" + avatarImgId)
                        photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
                            if (error != nil) {
                                // Uh-oh, an error occurred!
                                self.groups[newGroup.id] = newGroup
                            } else {
                                // Data for "images/island.jpg" is returned
                                // ... let islandImage: UIImage! = UIImage(data: data!)
                                newGroup.avatar = UIImage(data: data!)
                                self.groups[newGroup.id] = newGroup
                            }
                        }
                        
                        
                        
                    },
                    withCancelBlock: { error in
                        print(error.description)
                    }
                )
            }
        }
        
//        willSet {
//            for var i in refsAndHandles {
//                i.ref.removeObserverWithHandle(i.handle!)
//            }
//        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        initGroups()
        navigationController!.navigationBar.barTintColor = UIColor(red:0.38, green:0.28, blue:0.62, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.93, green:0.93, blue:0.93, alpha:1.0)]
        self.tableView.backgroundColor = UIColor(red:0.9995, green:0.9995, blue:0.9995, alpha:1.0)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // Listeners for the groups
    func initGroups() {
        let userGroupRef = self.ref.child("users/" + currentUser.firebaseId)
        userGroupRef.observeEventType(.Value, withBlock: { snapshot in
            let validGroups = JSON(snapshot.value!)["groups"]
            var tempRefsAndhandles = [refAndHandle]()
            for (group, _):(String, JSON) in validGroups {
                let validGroupRef = self.ref.child("groups/" + group)
                let tempRefAndHandle = refAndHandle(ref: validGroupRef, handle: nil)
                tempRefsAndhandles.append(tempRefAndHandle)
            }
            self.refsAndHandles = tempRefsAndhandles
            
            })
        }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return groupsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroupTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let group = groupsList[indexPath.row]
        
        cell.groupLabel.text = group.name
        cell.groupImage.image = group.avatar
        cell.groupUpdate.text = group.update
        cell.contentView.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.0)
        
        return cell
    }
    


    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    
    // MARK: - Navigation

   
     //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let detailViewController = segue.destinationViewController as! PicStreamCollectionViewController
            if let selectedCell = sender as? GroupTableViewCell {
                detailViewController.navigationItem.title = selectedCell.groupLabel.text
            }
        }
    }

    

}
