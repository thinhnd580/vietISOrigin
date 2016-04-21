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

class TripViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnReverse: UIButton!
    @IBOutlet weak var mapView: UIView!
    
    var route: Route?
    var pointList:[AnyObject] = []
    var googlemap:(GMSMapView) = GMSMapView()
    var markers:[GMSMarker] = []
    var trackingPoint: CLLocation?
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation : CLLocation?
    
    override func viewWillAppear(animated: Bool) {
        self.edgesForExtendedLayout = UIRectEdge.None
        self.mapView.updateConstraints()
        self.navigationItem.title = "Detail"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerNib(UINib(nibName: "DirectionCell", bundle: nil), forCellReuseIdentifier: "DirectionCell")
        //init google map
        self.setupMapView()
        self.setupMapforDirection(0)
        
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
    
    
    func setupMapView(){
        let camera = GMSCameraPosition.cameraWithLatitude(21.022693,
                                                          longitude: 105.8018584, zoom: 11)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        print(self.mapView.bounds.size.height)
        print(screenSize.height/3)
        self.googlemap = GMSMapView.mapWithFrame(CGRect.init(x: 0.0, y: 0.0, width:screenSize.width, height: self.mapView.bounds.size.height), camera: camera)
        self.googlemap.myLocationEnabled = true
        self.googlemap.settings.myLocationButton = true
        self.googlemap.delegate = self
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
            markers.append(marker)
            
            
        }

    }
    
    func setupMapforDirection(direction:Int){
        //direction = 0 : show origin way
        //direction = 1 : show return way
        
        
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
    
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
    }
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
        print("You marker at \(marker.position.latitude), \(marker.position.longitude)")
        self.googlemap.selectedMarker = marker
        let camera = GMSCameraPosition.cameraWithLatitude(marker.position.latitude,
                                                          longitude: marker.position.longitude, zoom: 15)
        googlemap.camera = camera
        return true
        
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if((NSUserDefaults.standardUserDefaults().objectForKey("PointID")) == nil){
            print("selected")
            let point_temp:(Point)
            if(!self.btnReverse.selected){
                let selectedMarker = markers[indexPath.row]
                self.mapView(self.googlemap, didTapMarker: selectedMarker)
                point_temp = self.pointList[indexPath.row] as! Point
            }
            else{
                let selectedMarker = markers.reverse()[indexPath.row]
                self.mapView(self.googlemap, didTapMarker: selectedMarker)
                point_temp = self.pointList.reverse()[indexPath.row] as! Point
            }
            
            self.trackingPoint = CLLocation(latitude: point_temp.lat!.doubleValue, longitude: point_temp.long!.doubleValue)
            
            NSUserDefaults.standardUserDefaults().setObject(point_temp.lat, forKey: "lat")
            NSUserDefaults.standardUserDefaults().setObject(point_temp.long, forKey: "long")
            
            let pointID = point_temp.objectID.URIRepresentation().absoluteString
            NSUserDefaults.standardUserDefaults().setObject(pointID, forKey: "PointID")
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            appDelegate.locationManager.delegate = appDelegate
            appDelegate.locationManager.startUpdatingLocation()
            appDelegate.locationManager.allowsBackgroundLocationUpdates = true
        }
        else{
//            let point_temp:(Point)
//            point_temp = self.pointList[indexPath.row] as! Point
//            
//            let currentPointId = NSUserDefaults.standardUserDefaults().valueForKey("PointID")
//            if(currentPointId == )
        }
        
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
