//
//  TabBarViewController.swift
//  Metsterios
//
//  Created by Chelsea Green on 3/27/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Mapbox

class TabBarViewController: UITabBarController, CLLocationManagerDelegate {
    
    var profileVC : ProfileViewController?
    var preferencesVC : PreferencesViewController?
    var addEventVC : AddEventViewController?
    var calendarVC : CalendarViewController?
    var mapViewVC : MapViewController?
    var chatHistoryVC : ChatListViewController?
    
    //var mapViewVC : Mapbx?
    var saveButton : UIBarButtonItem!
    
    // location
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("====== ENTER TABBAR View Controller =====")
        view.backgroundColor = UIColor.whiteColor()
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        
        
        profileVC = ProfileViewController()
        preferencesVC = PreferencesViewController()
        addEventVC = AddEventViewController()
        calendarVC = CalendarViewController()
        mapViewVC = MapViewController()
        chatHistoryVC = mainStoryboard.instantiateViewControllerWithIdentifier("ChatListViewController") as? ChatListViewController

        //mapViewVC = Mapbx()
        
        // get map updates
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.viewControllers = [profileVC! , preferencesVC! , mapViewVC!, calendarVC!, chatHistoryVC!]
        
        let profile = UITabBarItem(title: "Profile", image: UIImage(named: "tabar"), tag: 0)
        let pref = UITabBarItem(title: "Preference", image: UIImage(named: "preferenceicon"), tag: 1)
        let map = UITabBarItem(title: "Map", image: UIImage(named: "mapicon"), tag: 4)
        let cal = UITabBarItem(title: "Events", image: UIImage(named: "eventicon"), tag: 3)
        let connections = UITabBarItem(title: "Connections", image: UIImage(named: "Chat Bubble Dots"), tag: 2)
        
        self.selectedIndex = 2
       
        profileVC?.tabBarItem = profile
        preferencesVC?.tabBarItem = pref
        mapViewVC?.tabBarItem = map
        calendarVC?.tabBarItem = cal
        chatHistoryVC?.tabBarItem = connections
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        let location:CLLocation = locations[locations.count-1]
        
        if (location.horizontalAccuracy > 0) {
            self.locationManager.stopUpdatingLocation()
            print(location.coordinate)
            let point1 = MGLPointAnnotation()
            let lat = Double(location.coordinate.latitude)
            let lon = Double(location.coordinate.longitude)
            Users.sharedInstance().lat = lat
            Users.sharedInstance().long = lon
            point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            // new location update present location : TODO
            print("comes till here..")
            RequestInfo.sharedInstance().postReq("111003")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                })
            }
        }
    }
}
