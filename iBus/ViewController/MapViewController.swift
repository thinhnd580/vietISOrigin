//
//  MapViewController.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/21/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController  {

    var googlemap:(GMSMapView) = GMSMapView()
    
    @IBOutlet weak var mapView: UIView!
    override func viewWillAppear(animated: Bool) {
        self.edgesForExtendedLayout = UIRectEdge.None
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let camera = GMSCameraPosition.cameraWithLatitude(21.022693,
                                                          longitude: 105.8018584, zoom: 11)
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        print(self.mapView.bounds.size.height)
        print(screenSize.height/3)
        self.googlemap = GMSMapView.mapWithFrame(CGRect.init(x: 0.0, y: 0.0, width:screenSize.width , height: screenSize.height-40), camera: camera)
        self.googlemap.myLocationEnabled = true
        self.googlemap.settings.myLocationButton = true
        self.mapView.addSubview(self.googlemap)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
//        self.mapView.addSubview(self.googlemap)


        // Dispose of any resources that can be recreated.
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
