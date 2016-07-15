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

    
    var groups = [Group]()
    @IBOutlet var groupTableView: UITableView!
    
    //refs
    let storage = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        //loadSampleMeals()
        initGroups()
        navigationController!.navigationBar.barTintColor = UIColor(red:0.38, green:0.28, blue:0.62, alpha:1.0)
        navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.88, green:0.88, blue:0.88, alpha:1.0)]
        self.tableView.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadSampleMeals() {
        let photo1 = UIImage(named: "Fjord")!
        let group1 = Group(name: "Norway 2016 Trip", avatar: photo1, update: "Gary added 15 new photos")
        
        let photo2 = UIImage(named: "Family")!
        let group2 = Group(name: "Family Vaca", avatar: photo2, update: "New photos from Paige, Gary, Ken")
        
        let photo3 = UIImage(named: "Friends")!
        let group3 = Group(name: "Berkeley Takes Nice", avatar: photo3, update: "Anjali added 5 photos")
        
        groups += [group1, group2, group3]
    }
    
    // Listeners for the groups
    func initGroups() {
        //let groupRef = self.ref.child("groups")
        //let curGroupRef = groupRef.child(self.navigationItem.title!)
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        groups = [Group]()
        ref.queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: { snapshot in
            print("we made it here: \(self.navigationItem.title)")
            let json = JSON(snapshot.value!)["groups"]
            print(json)
            print("json count: \(json.count)")
            for (_, newDict):(String, JSON) in json {
                let groupName = newDict["groupName"].stringValue
                let avatarImgId = newDict["avatarId"].stringValue
                
                let newGroup = Group(name: groupName, avatar: UIImage(named: "noAvatar"))
                self.groups.append(newGroup)
                newGroup.update = newDict["update"].stringValue ?? ""

                print("NEWVAL: \(groupName)")
               
                let photoRef = storageRef.child("images/" + avatarImgId)
                
                photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                        self.groupTableView.reloadData()
                    } else {
                        // Data for "images/island.jpg" is returned
                        // ... let islandImage: UIImage! = UIImage(data: data!)
                        newGroup.avatar = UIImage(data: data!)
                        //self.loadView()
                        
                        self.groupTableView.reloadData()
                        
                    }
                }
                self.groupTableView.reloadData()
            }
        })
        
    }
    
    func dbListen() {
        let storageRef = storage.referenceForURL("gs://photo-pizza.appspot.com")
        //let postRef = FIRDatabase.database().reference().child("images")
        let groupRef = self.ref.child("groups")
        //let curGroupRef = groupRef.child(self.navigationItem.title!)
        
        groupRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let newDict = snapshot.value as! Dictionary<String, AnyObject>
            let groupName = newDict["groupName"] as! String
            for group in self.groups {
                if group.name == groupName{
                    return
                }
            }
            let avatarImgId = newDict["avatarId"] as! String
            let newGroup = Group(name: groupName, avatar: UIImage(named: "noAvatar"))
            self.groups.append(newGroup)
            let photoRef = storageRef.child("images/" + avatarImgId)
            
            photoRef.dataWithMaxSize(1 * 4000 * 4000) { (data, error) -> Void in
                if (error != nil) {
                    // Uh-oh, an error occurred!
                    self.groupTableView.reloadData()
                } else {
                    // Data for "images/island.jpg" is returned
                    // ... let islandImage: UIImage! = UIImage(data: data!)
                    newGroup.avatar = UIImage(data: data!)
                    self.groupTableView.reloadData()
                    
                }
            }
            self.groupTableView.reloadData()
            
        })
        groupRef.observeEventType(.ChildRemoved, withBlock: { (snapshot) in
            let newDict = snapshot.value as! Dictionary<String, AnyObject>
            let groupName = newDict["groupName"] as! String
            let len = self.groups.count
            for i in 0..<len {
                let curr = self.groups[i]
                if (curr.name == groupName) {
                    self.groups.removeAtIndex(i)
                    self.groupTableView.reloadData()
                    return
                }
            }
            print(self.groups)
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
        return groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "GroupTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let group = groups[indexPath.row]
        
        cell.groupLabel.text = group.name
        cell.groupImage.image = group.avatar
        cell.groupUpdate.text = group.update
        
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
