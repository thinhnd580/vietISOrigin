//
//  TripViewController.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/8/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit
import Foundation
import GoogleMaps
import Alamofire
import CoreLocation

class TripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnReverse: UIButton!
    @IBOutlet weak var mapView: UIView!
    
    
    var route: Route?
    var pointList:[AnyObject] = []
    var googlemap:(GMSMapView) = GMSMapView()
    var trackingPoint: CLLocation?
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation : CLLocation?
    
    override func viewWillAppear(animated: Bool) {
        self.edgesForExtendedLayout = UIRectEdge.None
        self.mapView.updateConstraints()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "DirectionCell", bundle: nil), forCellReuseIdentifier: "DirectionCell")
        
        if let pointID = NSUserDefaults.standardUserDefaults().valueForKey("PointID") {
            for index in 0...pointList.count-1{
                let point = pointList[index] as! Point
                if( (pointID as! String) == point.objectID.URIRepresentation().absoluteString){
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(index: index))
                    cell?.backgroundColor = UIColor.brownColor()
                }
            }
            
        }
        
        let camera = GMSCameraPosition.cameraWithLatitude(21.022693,
                                                          longitude: 105.8018584, zoom: 11)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        print(self.mapView.bounds.size.height)
        print(screenSize.height/3)
        self.googlemap = GMSMapView.mapWithFrame(CGRect.init(x: 0.0, y: 0.0, width:screenSize.width, height: self.mapView.bounds.size.height), camera: camera)
        self.googlemap.myLocationEnabled = true
        self.mapView.addSubview(self.googlemap)
    
        
        for index in 0...pointList.count-1{
            let point = self.pointList[index] as! Point
            print("\(point.lat!.floatValue)+\(point.long!.floatValue)")
            let x = point.lat!.doubleValue
            let y = point.long!.doubleValue
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2DMake(x, y)
            marker.title = point.name
            marker.snippet = "Vietnam"
            marker.map = self.googlemap
        }
        
        self.setupMapView(0)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnChangeDirectionClicked(sender: AnyObject) {
        
        
        self.btnReverse.selected = !self.btnReverse.selected
        self.tableView.reloadData()
        
    }
    
    
    func setupMapView(way:Int){
        //way = 0 : show origin way
        //way = 1 : show return way
//        self.getDirectionFromGoogle()

        if let polyEncoded = self.route?.polyline!{
            let path = GMSPath(fromEncodedPath: polyEncoded)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 7
            polyline.strokeColor = UIColor.greenColor()
            polyline.map = self.googlemap
                
            
        }
        
        
        else{
            self.getDirectionFromGoogle()
        }
    }
    
    
    func getDirectionFromGoogle(){
        let startLat = 21.0471598
        let startLong = 105.8769165
        let endLat = 20.9502109
        let endLong = 105.7450316
        let url = "https://maps.googleapis.com/maps/api/directions/json"
        
        let urlString = "\(url)?origin=\(startLat),\(startLong)&destination=\(endLat),\(endLong)&mode=transit&sensor=true&key=AIzaSyCuSymnNzggY1QwVQTFybjQxQfhjw9-tR0"
        
        
        Alamofire.request(.GET, urlString)
            .responseJSON { response in
                
                if let JSON = response.data {
                    //                    print("JSON: \(JSON)")
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(JSON , options: []) as! [String:AnyObject]
                        //TODO  : direction change for each time
                        print(json["routes"]!)
                        let routes:[AnyObject] = json["routes"]! as! [AnyObject]
                        print("count \(routes.count)")
                        if(routes.count > 0){
                            let routeDict = routes[0] as! [String:AnyObject]
                            let routeOverviewPolyline = routeDict["overview_polyline"] as! [String:AnyObject]
                            let points = routeOverviewPolyline["points"] as! String
                            let path = GMSPath(fromEncodedPath: points)
                            
                            let polyline = GMSPolyline(path: path)
                            polyline.strokeWidth = 7
                            polyline.strokeColor = UIColor.greenColor()
                            polyline.map = self.googlemap
                            
                        }
                        
                        
                        
                    } catch let error {
                        print("json error: \(error)")
                    }
                    
                }
        }
        
    }
    

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        let errorAlert = UIAlertView(title: "Error", message: "Failed to Get Your Location", delegate: nil, cancelButtonTitle: "Ok")
        errorAlert.show()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last! as CLLocation
        print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        print("Destination position: \((self.trackingPoint?.coordinate.longitude)) , \((self.trackingPoint?.coordinate.latitude))")
        if self.trackingPoint == nil{
            print("Point is not selected")
            
        }
        else{
            print("Point is selected ")
            
            
            let distance = self.trackingPoint?.distanceFromLocation(newLocation)
            print(distance!)
            if(distance < 500){
                var localNotification = UILocalNotification()
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
                localNotification.alertBody = "new Blog Posted at iOScreator.com"
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            }
            else{
                
            }
            
            
            
        }
        
    }
    
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let point_temp = self.pointList[indexPath.row] as! Point
        self.trackingPoint = CLLocation(latitude: point_temp.lat!.doubleValue, longitude: point_temp.long!.doubleValue)
        
        NSUserDefaults.standardUserDefaults().setObject(point_temp.lat, forKey: "lat")
        NSUserDefaults.standardUserDefaults().setObject(point_temp.long, forKey: "long")
        
        
        let pointID = point_temp.objectID.URIRepresentation().absoluteString
        NSUserDefaults.standardUserDefaults().setObject(pointID, forKey: "PointID")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationManager.delegate = appDelegate
        appDelegate.locationManager.startUpdatingLocation()
        appDelegate.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pointList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("DirectionCell", forIndexPath: indexPath) as! DirectionCell
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if self.btnReverse.selected {
            let point = self.pointList.reverse()[indexPath.row] as! Point
            
            cell.lbAddress.text = point.name
        }
        else{
            let point = self.pointList[indexPath.row] as! Point
            cell.lbAddress.text = point.name
            
            
            
        }
        
        
        
        return cell
        
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
