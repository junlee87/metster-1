//
//  MapViewController.swift
//  Metsterios
//
//  Created by Naveen Mysore on 4/16/16.
//  Copyright © 2016 Chelsea Green. All rights reserved.
//

import UIKit
import Mapbox
import Firebase
import Quickblox
class EventViewController:BaseVC, UITableViewDelegate, UITableViewDataSource, MGLMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MGLMapView!
    var hostedPlaces = [Place]()
    var pinAnnotations = [MGLPointAnnotation]()
    var attndictionary:Dictionary<String, String>?
    var attvdictionary:Dictionary<String, String>?
    let locationManager = CLLocationManager()
    let newValues : NSMutableArray? = []
    
    var mode = "edit"
    var notesTextField = MainTextField(frame: CGRectMake(screenWidth-178, (screenHeight/2)+52, 100, 30))
    var editButton = UIButton(frame: CGRectMake(screenWidth-75, (screenHeight/2)+52, 70, 30))
    
    var view_mode = "members"
    var lineView : UIView?
    @IBOutlet var searchbar: UITextField!
   
    
    var noticeLabel = UILabel(frame: CGRectMake(0, (screenHeight/2)+85, screenWidth, 12.0))
    
    // testing class object
    
    /*
     * usage 
     var point = Pinned( name: String,
                        address: String,
                        category: String,
                        latitude: Double,
                        longitude: Double,
                        image_url: String,
                        phone: String,
                        ratings: String,
                        reviewcount: String,
                        snippet: String,
                        votes: String)
     */
    
    class Pinned {
        var name: String
        var address : String
        var category : String
        var latitude : Double
        var longitude : Double
        var image_url : String
        var phone : String
        var ratings : String
        var reviewcount : String
        var snippet : String
        var votes : String
        
        init(name: String,
             address: String,
             category: String,
             latitude: Double,
             longitude: Double,
             image_url: String,
             phone: String,
             ratings: String,
             reviewcount: String,
             snippet: String,
             votes: String) {
            self.name = name
            self.address = address
            self.category = category
            self.latitude = latitude
            self.longitude = longitude
            self.image_url = image_url
            self.phone = phone
            self.ratings = ratings
            self.reviewcount = reviewcount
            self.snippet = snippet
            self.votes = votes
        }
    }
    
    
    class member {
        var name: String
        var address : String
        var category : String
        var latitude : Double
        var longitude : Double
        var image_url : String
        var phone : String
        var ratings : String
        var reviewcount : String
        var snippet : String
        var votes : String
        
        init(name: String,
             address: String,
             category: String,
             latitude: Double,
             longitude: Double,
             image_url: String,
             phone: String,
             ratings: String,
             reviewcount: String,
             snippet: String,
             votes: String) {
            self.name = name
            self.address = address
            self.category = category
            self.latitude = latitude
            self.longitude = longitude
            self.image_url = image_url
            self.phone = phone
            self.ratings = ratings
            self.reviewcount = reviewcount
            self.snippet = snippet
            self.votes = votes
        }
    }
    
    
    
    var pinnedPlaces = [Pinned]()
    
    let ref = Firebase(url: "https://metsterios.firebaseio.com")
    
    var submitButton = SearchButton(frame: CGRectMake((screenWidth)-45, 52, 40, 40))
    var voteButton = UIButton(frame: CGRectMake(5, (screenHeight/2)+65, 70, 30))
    
    var showmembersButton = UIButton(frame: CGRectMake(0, (screenHeight)-50, (screenWidth/3), 50))
    var showpinnedButton = UIButton(frame: CGRectMake((screenWidth/3), (screenHeight)-50,(screenWidth/3), 50))
    var showunpinnedButton = UIButton(frame: CGRectMake(2*(screenWidth/3), (screenHeight)-50,(screenWidth/3), 50))

    // list attbrs
    var names : NSMutableArray? = []
    var images : NSMutableArray? = []
    var categories : NSMutableArray? = []
    var snippets : NSMutableArray? = []
    var details : NSMutableArray? = []
    var dictionary = NSDictionary()
    
    var placesTableView : UITableView = UITableView()
    
    var popTime = dispatch_time(DISPATCH_TIME_NOW,
                                Int64(4.0 * Double(NSEC_PER_SEC)))
    
 
    @IBOutlet var loadingact: UIActivityIndicatorView!
    
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("enter event view controller")
        print(Users.sharedInstance().event_id)
        //full screen size
        // let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        
        //-----
        
        // Create the navigation bar
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.whiteColor()
        //navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        let event_name = Users.sharedInstance().selected_event_name as! String
        let event_data = Users.sharedInstance().selected_event_data! as userevents
        
        
        print("------ Event data -----")
        print(event_data.eventname)
        print(event_data.eventdate)
        self.view_mode = "members"
        Users.sharedInstance().query = nil
        print("-----------------------")
        
        navigationItem.title = event_name
        
        // Create left and right button for navigation item
        let leftButton =  UIBarButtonItem(title: "Back", style:   UIBarButtonItemStyle.Plain, target: self, action: #selector(self.backPressed))
        //let rightButton = UIBarButtonItem(title: "Right", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        
        // Create two buttons for the navigation item
        navigationItem.leftBarButtonItem = leftButton
        //navigationItem.rightBarButtonItem = rightButton
        
        // Assign the navigation item to the navigation bar
        navigationBar.items = [navigationItem]
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)

        
        //-----
        
        /*
         showmembersButton.backgroundColor = UIColor.whiteColor()
         showpinnedButton.backgroundColor = UIColor.whiteColor()
         showunpinnedButton.backgroundColor = UIColor.whiteColor()
        */
        
        var bimage = UIImage(named: "people_blue")! as UIImage
        showmembersButton = UIButton(type: UIButtonType.System) as UIButton
        showmembersButton.backgroundColor = UIColor.whiteColor()
        showmembersButton.frame = CGRectMake(0, (screenHeight)-50, (screenWidth/3), 50)
        showmembersButton.setBackgroundImage(bimage, forState: UIControlState.Normal)
        showmembersButton.addTarget(self, action: #selector(EventViewController.showmemberpressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(showmembersButton)
        showmembersButton.hidden = false
        

        //----
        
        bimage = UIImage(named: "places_gray")! as UIImage
        showpinnedButton = UIButton(type: UIButtonType.System) as UIButton
        showpinnedButton.frame = CGRectMake((screenWidth/3), (screenHeight)-50,(screenWidth/3), 50)
        showpinnedButton.setBackgroundImage(bimage, forState: UIControlState.Normal)
        showpinnedButton.backgroundColor = UIColor.whiteColor()
        showpinnedButton.addTarget(self, action: #selector(EventViewController.showpinnedpressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(showpinnedButton)
        showpinnedButton.hidden = false
        
        
        
        bimage = UIImage(named: "nearby_gray")! as UIImage
        showunpinnedButton = UIButton(type: UIButtonType.System) as UIButton
        showunpinnedButton.frame = CGRectMake(2*(screenWidth/3), (screenHeight)-50,(screenWidth/3), 50)
        showunpinnedButton.backgroundColor = UIColor.whiteColor()
        showunpinnedButton.setBackgroundImage(bimage, forState: UIControlState.Normal)
        showunpinnedButton.addTarget(self, action: #selector(EventViewController.showplacespressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(showunpinnedButton)
        showunpinnedButton.hidden = false
        
        
        self.searchbar.placeholder = "search: e.g sushi, pizza..."
        
        //let screenWidth = screenSize.width;
        //let screenHeight = screenSize.height;
        // 0, (screenHeight/2)+100, screenWidth, 145
        lineView = UIView(frame: CGRectMake(0, (screenHeight/2)+85, screenWidth, 15.0))
        lineView!.layer.borderWidth = 15.0
        let color2 = hexStringToUIColor("#47D509")
        lineView!.layer.borderColor = color2.CGColor
        self.view.addSubview(lineView!)
        lineView!.hidden = true
        
    
        editButton.backgroundColor = UIColor.whiteColor()
        editButton.layer.cornerRadius = 5
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        editButton.setTitle("invite", forState: UIControlState.Normal)
        editButton.setTitleColor(UIColor(red: 0, green: 0.6549, blue: 0.9373, alpha: 1.0), forState: UIControlState.Normal)
        editButton.addTarget(self, action: #selector(EventViewController.editpressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(editButton)
        editButton.hidden = false
        
        let notes=NSAttributedString(string: "@gid", attributes: [NSForegroundColorAttributeName : UIColor.grayColor().colorWithAlphaComponent(0.6)])
        notesTextField.attributedPlaceholder = notes
        notesTextField.backgroundColor = UIColor.whiteColor()
        notesTextField.delegate = self
        self.view.addSubview(notesTextField)
        notesTextField.hidden = true
        
        
        noticeLabel.textAlignment = NSTextAlignment.Left
        noticeLabel.text = "test"
        noticeLabel.textColor = UIColor.whiteColor()
        noticeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        noticeLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(self.noticeLabel)
        noticeLabel.hidden = true
        
        findpeople()
        
        placesTableView.dataSource = self
        placesTableView.delegate = self
        placesTableView.rowHeight = 100
        self.view.addSubview(self.placesTableView)
        placesTableView.hidden = false
        var recognizer = UISwipeGestureRecognizer(target: self, action: Selector("didSwipe"))
        placesTableView.addGestureRecognizer(recognizer)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Users.sharedInstance().places?.removeAllObjects()
        
        submitButton.addTarget(self, action: #selector(self.searchmade), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(submitButton)
        submitButton.hidden = false
        
        loadingact.hidden = true
        // close keyboard
        //Looks for single or multiple taps.
        
        //view.removeGestureRecognizer(tap)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: 40.7326808,
                                                        longitude: -73.9843407),
                                                        zoomLevel: 12, animated: false)
        
        
        // Set the delegate property of our map view to self after instantiating it.
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        
        
        self.hostedPlaces.removeAll()
        let eid = Users.sharedInstance().event_id as! String
        
         let event_ref = Firebase(url: "\(self.ref)/\(eid)/places")
         // Read data and react to changes
         event_ref.observeEventType(.Value, withBlock: { snapshot in
         if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
         for snap in snapshots {
            if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                let key = snap.key
                let place = Place(key: key, dictionary: postDictionary)
                print (place.name )
                print (place.votes)
                var vote_count = String(0)
                let votes = place.votes as! String
                let vot = votes.characters.split{$0 == "-"}.map(String.init)
                vote_count = String (vot.count)
                self.add_annot(place.latitude, lon: place.longitude, name: place.name, address: place.address, votes: vote_count, place_id: key)
                self.hostedPlaces.insert(place, atIndex: 0)
                
                
                //these are pinned location get them in a list
                let point = Pinned( name: place.name,
                                    address: place.address,
                                    category: place.category,
                                    latitude: Double(place.longitude)!,
                                    longitude: Double(place.longitude)!,
                                    image_url: place.image_url,
                                    phone: "",
                                    ratings: "",
                                    reviewcount: "",
                                    snippet: "",
                                    votes: place.votes as! String)
                self.pinnedPlaces.append(point)
                
             }
            }
         }
         // TableView updates when there is new data.
         
         }, withCancelBlock: { error in
         self.alertMessage("Error", message: "Something went wrong.")
         })
        
        print("---- event memebers")
        let event_mref = Firebase(url: "\(self.ref)/\(eid)/users")
        print("\(self.ref)/\(eid)/users")
        // Read data and react to changes
        event_mref.observeEventType(.Value, withBlock: { snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                for snap in snapshots {
                    print("here")
                    print(snap.value)
                }
            }
            // TableView updates when there is new data.
            
            }, withCancelBlock: { error in
                self.alertMessage("Error", message: "Something went wrong.")
        })
        print("---- event memebers")
        
        
        var mlat = 0.0
        var mlon = 0.0
         
         for hostedPlace in self.hostedPlaces {
            let latitude = Double(hostedPlace.latitude)
            let longitude = Double(hostedPlace.longitude)
            mlat = mlat + latitude!
            mlon = mlon + longitude!
            print(latitude)
            print(longitude)
            print(hostedPlace.address)
         }
        
        if (self.hostedPlaces.count > 0 ){
            mlat = mlat / Double(hostedPlaces.count)
            mlon = mlon / Double(hostedPlaces.count)
            print ("move to ")
            print(mlat)
            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: mlat,
                                    longitude: mlon),
                                    zoomLevel: 12, animated: true)
        } else {
         // print Users.sharedInstance().lat
            /* seems to be working on phone lets ignore for now
            let lati = Users.sharedInstance().lat as! Double
            let longi = Users.sharedInstance().long as! Double
            mapView.setCenterCoordinate(CLLocationCoordinate2D(latitude: lati,
                                        longitude: longi),
                                        zoomLevel: 12, animated: true)
             */
        }
        
    }
    
    func didSwipe(recognizer: UIGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Ended {
            let swipeLocation = recognizer.locationInView(self.placesTableView)
            if let swipedIndexPath = placesTableView.indexPathForRowAtPoint(swipeLocation) {
                if let swipedCell = self.placesTableView.cellForRowAtIndexPath(swipedIndexPath) {
                    print("swipped")
                    print(swipedCell)
                }
            }
        }
    }
    
    func backPressed() {
        print ("back pressed")
        navigationController?.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    
    func editpressed(){
        if(mode as String == "edit") {
            self.notesTextField.hidden = false
            editButton.setTitle("send", forState: UIControlState.Normal)
            self.mode = "send"
            // call the update function to save
            
        } else {
            self.notesTextField.hidden = true
            
            
            let mesage = "Hello man!"
            
            
            let message = QBMPushMessage(payload: [QBMPushMessageSoundKey: "default", QBMPushMessageAlertKey: mesage])
            
            // Send push to groups 'man' and 'car'
            QBRequest.sendPush(message, toUsers: self.notesTextField.text!, successBlock: { (respose: QBResponse, event: QBMEvent?) in
                
                
                }, errorBlock: { (error : QBError?) in
                    
                    
            })
            
            /*
            RequestInfo.sharedInstance().postReq("111003")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Unable to save preference")
                        self.alertMessage("Error", message: "Unable to update.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Preference Saved!", message: "")
                })
            }
            */
            editButton.setTitle("invite", forState: UIControlState.Normal)
            self.mode = "edit"
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func showmemberpressed(){
        self.view_mode = "members"
 
        self.showmembersButton.setBackgroundImage(UIImage(named: "people_blue"), forState: UIControlState.Normal)
        self.showpinnedButton.setBackgroundImage(UIImage(named: "places_gray"), forState: UIControlState.Normal)
        self.showunpinnedButton.setBackgroundImage(UIImage(named: "nearby_gray"), forState: UIControlState.Normal)
        
        var count = 0
        if(Users.sharedInstance().event_people == nil){
            count = 0
        } else {
            let memb = Users.sharedInstance().event_people as! NSArray
            count = memb.count
        }
        
        if (count == 1) {
            noticeLabel.text = "  \(count) member for this event"
        } else {
            noticeLabel.text = "  \(count) members for this event"
        }
        noticeLabel.hidden = false
        self.lineView!.hidden = false
        
        self.placesTableView.reloadData()
    }
    
    func showpinnedpressed(){
        self.view_mode = "pinned"
        self.showmembersButton.setBackgroundImage(UIImage(named: "people_gray"), forState: UIControlState.Normal)
        self.showpinnedButton.setBackgroundImage(UIImage(named: "places_blue"), forState: UIControlState.Normal)
        self.showunpinnedButton.setBackgroundImage(UIImage(named: "nearby_gray"), forState: UIControlState.Normal)
        self.placesTableView.reloadData()
        for pin in self.pinnedPlaces {
            print(pin.name)
        }
        var count = self.pinnedPlaces.count
        
        if (count == 1) {
            noticeLabel.text = "  \(count) location pinned by a event member"
        } else {
            noticeLabel.text = "  \(count) locations pinned by a event members"
        }
        noticeLabel.hidden = false
        self.lineView!.hidden = false
        //---
        // reload the table and check the mode there
    }
    
    func showplacespressed(){
        self.view_mode = "places"
        self.showmembersButton.setBackgroundImage(UIImage(named: "people_gray"), forState: UIControlState.Normal)
        self.showpinnedButton.setBackgroundImage(UIImage(named: "places_gray"), forState: UIControlState.Normal)
        self.showunpinnedButton.setBackgroundImage(UIImage(named: "nearby_blue"), forState: UIControlState.Normal)
        self.placesTableView.reloadData()
        
        var count = 0
        if (Users.sharedInstance().query == nil ){
            noticeLabel.text = "  please make search to list places"
        } else {
            if Users.sharedInstance().places == nil {
                count = 0
            } else {
                count = Users.sharedInstance().places!.count
            }
            let quer = Users.sharedInstance().query as! String
            noticeLabel.text = "  \(count) places found for search \(quer)"
            noticeLabel.hidden = false
        }
    }
    
    func searchmade() {
        print ("search made enter")
        let query = searchbar.text! as String
        let eventid = Users.sharedInstance().event_id
        Users.sharedInstance().query = query as String
        //-- clean data of previous search
        //clean_data()
        
        findFood(query, eventid: eventid as! String)
        print ("search made leave")
        
    }
    
    
    func findpeople() {
        print ("find people...")
        Users.sharedInstance().event_people = []
        RequestInfo.sharedInstance().postReq("998101")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed to get event info.")
                    self.alertMessage("Error", message: "Unable to reach server.")
                })
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                print("Found people")
                let peoplenb = Users.sharedInstance().event_people as! NSArray
                print(peoplenb.count)
                for person in peoplenb {
                    print(person)
                }
                var count = 0
                if(Users.sharedInstance().event_people == nil){
                    count = 0
                } else {
                    let memb = Users.sharedInstance().event_people as! NSArray
                    count = memb.count
                }
                
                if (count == 1) {
                    self.noticeLabel.text = "  \(count) member for this event"
                } else {
                    self.noticeLabel.text = "  \(count) members for this event"
                }
                self.noticeLabel.hidden = false
                self.lineView!.hidden = false
                self.placesTableView.reloadData()
            })
        }
    }

    
    func findFood(query : String, eventid : String) {
        print ("enter findfood")
        
        print(searchbar.text)
        
        Users.sharedInstance().search_mode = "group"
        loadingact.hidden = false
        loadingact.startAnimating()
        
        if(newValues?.count > 0) {
            newValues?.removeAllObjects()
        }
        
        RequestInfo.sharedInstance().postReq("999000")
        { (success, errorString) -> Void in
            guard success else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("Failed at getting foodz")
                    self.alertMessage("Error", message: "Unable to connect.")
                })
                return
            }
            
            dispatch_after(self.popTime, self.GlobalMainQueue) {
                
                for item in Users.sharedInstance().places! {
                    print(Users.sharedInstance().place_id)
                    let restaurantData : NSData = (item.dataUsingEncoding(NSUTF8StringEncoding))!
                    
                    do {
                        let restaurantInfo = try NSJSONSerialization.JSONObjectWithData(restaurantData , options: .AllowFragments) as! NSMutableDictionary
                        self.newValues!.addObject(restaurantInfo)
                    } catch {
                        print(error)
                    }
                }
                
                // newValues will have the data
                for value in self.newValues! {
                    print ("----")
                    print (value)
                    let latitude = value.valueForKey("latitude") as! String
                    let longitude = value.valueForKey("longitude") as! String
                    let name = value.valueForKey("name") as! String
                    let address = value.valueForKey("address") as! String
                    //let drivedistance = value.valueForKey("drivedistance") as! String
                    print(latitude)
                    print(longitude)
                    //print(drivedistance)
                    //self.add_annot(latitude, lon: longitude, name: name, address: address, dis: drivedistance)
                }
                //self.mapView.addAnnotations(self.pinAnnotations)
                //self.mapView.showAnnotations(self.pinAnnotations, animated: false)
                //self.mapView.selectAnnotation((self.mapView.annotations?.first)!, animated: true)
                self.loadingact.stopAnimating()
                self.loadingact.hidden = true
                self.placesTableView.hidden = false
                self.voteButton.hidden = false
                self.placesTableView.reloadData()
                self.placesTableView.bringSubviewToFront(self.view)
            }
        }
        
    }

        
    func clean_data(){
        
        if ( mapView.annotations?.count > 0 ) {
            let annt = mapView.annotations
            for at in annt!{
                mapView.removeAnnotation(at)
            }
            
        }
        attndictionary?.removeAll()
        attvdictionary?.removeAll()
        pinAnnotations.removeAll()
        self.newValues?.removeAllObjects()
        self.names?.removeAllObjects()
        self.images?.removeAllObjects()
        self.categories?.removeAllObjects()
        self.snippets?.removeAllObjects()
        self.details?.removeAllObjects()
        
    }
    
    func add_annot(lat : String, lon : String, name : String, address : String, votes: String, place_id : String){
        let lpoint = MGLPointAnnotation()
        lpoint.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(lon)!)
        lpoint.title = name
        lpoint.subtitle = address
        mapView.addAnnotation(lpoint)
        
        // fit the map to the annotation(s)
        mapView.showAnnotations(mapView.annotations!, animated: false)
        
        // pop-up the callout view
        // mapView.selectAnnotation(lpoint, animated: true)
        pinAnnotations.append(lpoint)
        // attndictionary.setValue(dis, forKey: name as String)
        
        if (attndictionary == nil) {
            attndictionary = [name: votes]
        }
        else if var foofoo = attndictionary {
            foofoo[name] = votes
            attndictionary = foofoo
        }
        
        if (attvdictionary == nil) {
            attvdictionary = [name: place_id]
        }
        else if var foofoo = attndictionary {
            foofoo[name] = place_id
            attvdictionary = foofoo
        }
        
        update_map_focus(lpoint)
        
        //attndictionary.
        // fit the map to the annotation(s)
        
    }
    
    
    
    func update_map_focus(att : MGLPointAnnotation) {
        
        let point1 = MGLPointAnnotation()
        point1.coordinate = att.coordinate
        //mapView.flyToCamera(<#T##camera: MGLMapCamera##MGLMapCamera#>, completionHandler: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
        
        // set the map's center coordinate
        mapView.setCenterCoordinate(point1.coordinate,
                                    zoomLevel: 12, animated: true)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.mapView.selectAnnotation(att, animated: true) // set att
        }
        
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
            Users.sharedInstance().lat = lat as Double
            Users.sharedInstance().long = lon as Double
            point1.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            mapView.centerCoordinate = point1.coordinate
            // new location update present location : TODO
        }
    }
    
    // Use the default marker; see our custom marker example for more information
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        let label = UILabel(frame: CGRectMake(0, 0, 50, 50))
        label.textAlignment = .Right
        label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
        label.font = UIFont.systemFontOfSize(18)
        let dis = attndictionary![annotation.title!!]
        label.numberOfLines = 0;
        label.text = dis! + "\nvote"
        return label
        
    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        // return UIButton(type: .DetailDisclosure)
        return UIButton(type: .ContactAdd)
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
        //mapView.deselectAnnotation(annotation, animated: false)
        let evnt = Users.sharedInstance().event_id as! String
        let alert = UIAlertController(title: "Vote up", message: "Do you want to vote up this location?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                print(Users.sharedInstance().email!)
                
                //-- vote up
                let placeid = self.attvdictionary![annotation.title!!]! as String
                Users.sharedInstance().vote_event_id = evnt as String
                Users.sharedInstance().vote_place_id = placeid as String
                
                let event_ref = Firebase(url: "\(self.ref)/\(evnt as String)/places/\(placeid as String)")
                // Read data and react to changes
                print("here")
                print("\(self.ref)/\(evnt as String)/places/\(placeid as String)")
                event_ref.observeEventType(.Value, withBlock: { snapshot in
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        for snap in snapshots {
                            if(snap.key == "votes") {
                                    let vot = snap.value as! String
                                    print (vot)
                                    let votes = vot.characters.split{$0 == "-"}.map(String.init)
                                    if votes.contains(Users.sharedInstance().email as! String) {
                                        print ("vote already counted")
                                        // notice
                                        let alert = UIAlertController(title: "vote up", message: "Your vote is already counted.", preferredStyle: UIAlertControllerStyle.Alert)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                        
                                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
                                            switch action.style{
                                            case .Default:
                                                print("default")
                                                
                                            case .Cancel:
                                                print("cancel")
                                                
                                            case .Destructive:
                                                print("destructive")
                                            }
                                        }))
                                        
                                    } else {
                                        //Vote to a place in event
                                        
                                         RequestInfo.sharedInstance().postReq("997670")
                                         { (success, errorString) -> Void in
                                         guard success else {
                                         dispatch_async(dispatch_get_main_queue(), {
                                         print("Failed at saving")
                                         self.alertMessage("Error", message: "Unable to connect.")
                                         })
                                         return
                                         }
                                         dispatch_async(dispatch_get_main_queue(), {
                                         print("suucssssss")
                                         //self.alertMessage("Success!", message: "Event Confirmed")
                                         })
                                         }
                                        
                                    }
                                
                            }
      
                        }
                    }
                    // TableView updates when there is new data.
                    
                    }, withCancelBlock: { error in
                        self.alertMessage("Error", message: "Something went wrong.")
                })
                
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidLayoutSubviews() {
        placesTableView.frame = CGRectMake(0, (screenHeight/2)+100, screenWidth, 145)
    }
    
    
    //MARK : Table View delegate & data source methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        print ("table view count")
        print (self.view_mode as String)
        
        if(self.view_mode == "places") {
        
        if tableView == placesTableView  {
            if Users.sharedInstance().places == nil {
                count = 0
            } else {
                count = Users.sharedInstance().places!.count
            }
         }
            
        }
        
        if(self.view_mode == "members") {
            // return members
            if(Users.sharedInstance().event_people == nil){
                print ("memebrs nil")
                count = 0
            } else {
                let memb = Users.sharedInstance().event_people as! NSArray
                count = memb.count
                print ("memeb")
                print (count)
            }
        }
        
        if(self.view_mode == "pinned"){
            // return pinned count
            count = self.pinnedPlaces.count
        }
        return count!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let friendCell = UITableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        let cell = PlaceTableViewCell(frame: CGRectMake(0,0, self.view.frame.width, 50))
        
        
        if(self.view_mode == "places") {
        
        if Users.sharedInstance().places != nil {
            
            for item in newValues! {
                // print (item)
                /*
                 address, category, coordinates, image, name, phone, ratings, review_count, snippet
                 */
                let newName = item.valueForKey("name")
                self.names?.addObject(newName!)
                
                let newImage = item.valueForKey("image_url")
                self.images?.addObject(newImage!)
                
                let category = item.valueForKey("category")
                self.categories?.addObject(category!)
                // placeDescpLabel
                
                let snippet = item.valueForKey("snippet")
                let ratings = item.valueForKey("ratings")
                // let review_count = item.valueForKey("review_count")
                let details = ratings!
                self.details?.addObject(details)
                self.snippets?.addObject(snippet!)
                print("---->")
                print(newName)
                
            }
            Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
            
            // setup cell values here...
            cell.placeNameLabel!.text = names![indexPath.row] as? String
            cell.placeDescpLabel!.text = categories![indexPath.row] as? String
            cell.placeSnippetLabel!.text = snippets![indexPath.row] as? String
            cell.placedetailsLabel!.text = details![indexPath.row] as? String
            
            let url = NSURL(string: images![indexPath.row] as! String)!
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.placeImage!.image = UIImage(data: data)
                    })
                }
            }
            task.resume()
        }
        }
        
        if(self.view_mode == "members"){
         
            let people = Users.sharedInstance().event_people as! NSArray
            //let keys = people.allKeys
            
            print (people.count)
            let person = people[indexPath.row]
            print (person["name"])
            let name = person["name"] as! String
            cell.placeNameLabel!.text = name
            //cell.placeDescpLabel!.text = person["p_gid"] as? String
            cell.placeDescpLabel!.text = person["ame"] as? String
            cell.placeSnippetLabel!.text = person["gid"] as? String
            //var notice = person["poston"] as? String
            //notice = "also searched for \(Users.sharedInstance().query!) \(notice!)"
            //cell.itemdetail!.text = notice
            
            let access = person["fb_id"] as! String
            let facebookProfileUrl = NSURL(string: "http://graph.facebook.com/\(access)/picture?type=large")
            let task = NSURLSession.sharedSession().dataTaskWithURL(facebookProfileUrl!)
            { (responseData, responseUrl, error) -> Void in
                if let data = responseData{
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.placeImage!.image = UIImage(data: data)
                        //let image : UIImage = UIImage(data: data)!
                        //cache.set(value: image.asData(), key: "profile_image.jpg")
                    })
                }
            }
            task.resume()
        }
        

        
        if(self.view_mode == "pinned"){
    
            if self.pinnedPlaces.count != 0 {
    
                for pin in self.pinnedPlaces {
                    // print (item)
                    /*
                     address, category, coordinates, image, name, phone, ratings, review_count, snippet
                     */
                    let newName = pin.name
                    self.names?.addObject(newName)
                    
                    let newImage = pin.image_url
                    self.images?.addObject(newImage)
                    
                    let category = pin.category
                    self.categories?.addObject(category)
                    // placeDescpLabel
                    
                    let snippet = pin.snippet
                    let ratings = pin.ratings
                    // let review_count = item.valueForKey("review_count")
                    let details = ratings
                    self.details?.addObject(details)
                    self.snippets?.addObject(snippet)
                    print("---->")
                    print(newName)
                    
                }
                
                // setup cell values here...
                cell.placeNameLabel!.text = names![indexPath.row] as? String
                cell.placeDescpLabel!.text = categories![indexPath.row] as? String
                cell.placeSnippetLabel!.text = snippets![indexPath.row] as? String
                cell.placedetailsLabel!.text = details![indexPath.row] as? String
                
                let url = NSURL(string: images![indexPath.row] as! String)!
                let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (responseData, responseUrl, error) -> Void in
                    if let data = responseData{
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            cell.placeImage!.image = UIImage(data: data)
                        })
                    }
                }
                task.resume()
            }
            
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("comer gere")
        
        if(self.view_mode == "places") {
        
        Users.sharedInstance().place_id = Users.sharedInstance().place_ids![indexPath.row] as? String
        print(Users.sharedInstance().place_id)
        let placeid = Users.sharedInstance().place_id
        let item = newValues![indexPath.row]
        let evnt = Users.sharedInstance().event_id as! String
        print ("selected.")
        print (item)
        
        // alert
        
        
        let alert = UIAlertController(title: "name", message: "Do you want to pin this location?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Pin", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                print("default")
                
                /* check if that location is aleardy pinned
                if pinned dont pin again just add it as a vote
                if someone chooses to upvote add vote
                 */
                
                var to_fb = item as! Dictionary<String, AnyObject>
                let vt = Users.sharedInstance().email as! String + "-"
                to_fb["votes"] = vt
                
                let myRootRef = Firebase(url: "\(self.ref)/\(evnt)/places/\(placeid as! String)/")
                myRootRef.setValue(to_fb)
                
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
            
        }
        
        
        if(self.view_mode == "members"){
            
            let people = Users.sharedInstance().event_people as! NSArray
            //let keys = people.allKeys
            
            print (people.count)
            let person = people[indexPath.row]
            print (person["name"])

        }
        
        if(self.view_mode == "pinned"){
            print ("pinned")
        }
        
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        print ("enter select option")
        
        let save = UITableViewRowAction(style: .Normal, title: "Accept") { action, index in
            print(Users.sharedInstance().event_id)
            print("save button tapped")
            
            //SAVE TO CONFIRMED EVENTSSSSSS
            RequestInfo.sharedInstance().postReq("998000")
            { (success, errorString) -> Void in
                guard success else {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("Failed at saving")
                        self.alertMessage("Error", message: "Unable to connect.")
                    })
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    print("suucssssss")
                    self.alertMessage("Success!", message: "Event Confirmed")
                })
            }
        }
        save.backgroundColor = lightBlue
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            print("delete button tapped")
            print(Users.sharedInstance().event_id)
        }
        delete.backgroundColor = darkBlue
   
        return [delete]
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}