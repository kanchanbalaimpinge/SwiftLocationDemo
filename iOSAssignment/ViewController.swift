//
//  ViewController.swift
//  iOSAssignment
//
//  Created by MacUser on 9/5/16.
//  Copyright © 2016 Kanchan. All rights reserved.
//


import UIKit
import CoreLocation

class ViewController: UIViewController,UITableViewDelegate,CLLocationManagerDelegate,UITabBarDelegate
{

    //Mark: outlets
    @IBOutlet var tabBar_Info:UITabBar!
    @IBOutlet var lbl_Location: UILabel!
    @IBOutlet var lbl_Distance: UILabel!
    @IBOutlet var tbl_List: UITableView!
    
    
    //Mark: Global Variables
    var ary_List : NSMutableArray = NSMutableArray()
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    var userLocation: CLLocation!
    
    var firstLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var distance:Double = 0
    var badgeCount:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_List.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tabBar_Info.selectedItem = self.tabBar_Info.items![0]
        self.updateCurrentLocation()
        
        let titleFont : UIFont = UIFont(name: "Helvetica", size: 16.0)!
        
        let attributesNormal = [
            NSFontAttributeName : titleFont
        ]
        
        
        UITabBarItem.appearance().setTitleTextAttributes(attributesNormal, forState: .Normal)
        
        for tabBarItem in tabBar_Info.items!
        {
            tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -10)
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - User Location
    func updateCurrentLocation()
    {
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            
            // For use in foreground
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        userLocation = manager.location
        
        if(tabBar_Info.selectedItem?.tag == 0)
        {
            self.getUserAdress()
        }
        self .getDistanceTravell()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("didFailWithError %@", error)
    }
    
    func getUserAdress()
    {
        
        CLGeocoder().reverseGeocodeLocation(userLocation, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                
                var tempString : String = ""
                
                if(pm.locality != nil){
                    tempString = tempString +  pm.locality! + ","
                }
                if(pm.postalCode != nil){
                    tempString = tempString +  pm.postalCode! + ","
                }
                if(pm.administrativeArea != nil){
                    tempString = tempString +  pm.administrativeArea! + ","
                }
                if(pm.country != nil){
                    tempString = tempString +  pm.country! + ""
                }
                
                self.lbl_Location.text = tempString
                
                
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func getDistanceTravell()
    {
        distance = 0
        if firstLocation == nil {
            firstLocation = userLocation
        }
        else
        {
            distance = firstLocation.distanceFromLocation(userLocation)
            
            traveledDistance += distance
        }
        
        lbl_Distance.text = String(Int(traveledDistance))
        
        
        if(distance > 50)
        {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "dd MMM,yyyy HH:mm:ss"
            let someDateTime = formatter.stringFromDate(NSDate())
            
            
            let defaults = NSUserDefaults.standardUserDefaults()
            
            
            if (!ary_List.containsObject(someDateTime))
            {
                
                if (tabBar_Info.selectedItem?.tag != 1)
                {
                    badgeCount = badgeCount+1
                    tabBar_Info.items?[1].badgeValue = String(badgeCount);
                }
                
                
                var dateInfo = defaults.objectForKey("DateInfo") as? [String] ?? [String]()
                
                dateInfo.append(someDateTime)
                
                // then update whats in the `NSUserDefault`
                defaults.setObject(dateInfo, forKey: "DateInfo")
                
                // call this after you update
                defaults.synchronize()
            }
            
            
            if (NSUserDefaults.standardUserDefaults().objectForKey("DateInfo") != nil)
            {
                ary_List = NSUserDefaults.standardUserDefaults().objectForKey("DateInfo") as! NSMutableArray
                
                tbl_List.reloadData()
                
            }
            
            let alert = UIAlertController(title: "", message:"You have completed 50 mtrs", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "Ok", style: .Default) { _ in
                
            }
            
            alert.addAction(action)
            self.presentViewController(alert, animated: true){}
        }
        
        firstLocation = userLocation
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        if(item.tag == 0)
        {
            lbl_Location.hidden = false
            lbl_Distance.hidden = true
            tbl_List.hidden = true
            
            self.getUserAdress()
        }
        else if(item.tag == 1)
        {
            lbl_Location.hidden = true
            lbl_Distance.hidden = false
            tbl_List.hidden = true
            
            badgeCount = 0
            tabBar_Info.items?[1].badgeValue = nil
            
        }
        else if(item.tag == 2)
        {
            lbl_Location.hidden = true
            lbl_Distance.hidden = true
            tbl_List.hidden = false
            
        }
        
        //This method will be called when user changes tab.
    }
    
    //Mark: Table View Delegate Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ary_List.count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell",forIndexPath:indexPath)
        
        cell.textLabel?.text = ary_List.objectAtIndex(indexPath.row) as? String
        
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

