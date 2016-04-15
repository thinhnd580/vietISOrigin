//
//  AppDelegate.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/8/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import CoreLocation
import MagicalRecord


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate  {

    var window: UIWindow?
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation : CLLocation?
    var timer: NSTimer?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.makeKeyAndVisible()
        MagicalRecord.setupCoreDataStackWithStoreNamed("Bus")
        
        let ListVC = ListViewController(nibName: "ListViewController", bundle: nil)
        let nav = UINavigationController(rootViewController: ListVC)
        
        window?.rootViewController = nav
        GMSServices.provideAPIKey("AIzaSyCEbY_9RGrZ9qwJEhi7QKqgab-7fVuOPiw")
        UIUserNotificationType.Sound
        if(UIApplication.instancesRespondToSelector(#selector(UIApplication.registerUserNotificationSettings(_:)))) {
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes:[.Sound,.Alert,] , categories: nil) )
//            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert | .Badge, categories: nil))
        }
        
        
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        //TODO stop update when notification on
//        locationManager.startUpdatingLocation()
        startLocation = CLLocation()
        return true
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    application.applicationIconBadgeNumber = 0
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("BackGround comming in")
//        self.locationManager.startUpdatingLocation()
//        UIApplication.beginBackgroundTaskWithExpirationHandler(UIApplication)
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("Active comming in")
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
//        let errorAlert = UIAlertView(title: "Error", message: "Failed to Get Your Location", delegate: nil, cancelButtonTitle: "Ok")
        //TODO 
        print("Get Location error")
//        errorAlert.show()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let lat = NSUserDefaults.standardUserDefaults().valueForKey("lat")
        let long = NSUserDefaults.standardUserDefaults().valueForKey("long")
        
        if( lat != nil &&  long != nil ) {
            let trackPoint = CLLocation(latitude: lat as! Double, longitude: long as! Double)
            let newLocation = locations.last! as CLLocation
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
            print("Destination position: \((trackPoint.coordinate.longitude)) , \((trackPoint.coordinate.latitude))")
            
            
            let distance = trackPoint.distanceFromLocation(newLocation)
            print(distance)
            if(distance < 500){
                var localNotification = UILocalNotification()
                localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
                localNotification.alertBody = "Your bus stop is close, get ready"
                localNotification.timeZone = NSTimeZone.defaultTimeZone()
                localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
                
                UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                
                self.locationManager.stopUpdatingLocation()
                NSUserDefaults.standardUserDefaults().removeObjectForKey("lat")
                NSUserDefaults.standardUserDefaults().removeObjectForKey("long")
//                NSUserDefaults.standardUserDefaults().removeObjectForKey("PointID")
                let errorAlert = UIAlertView(title: "Warring", message: "Getting close to  your Destination", delegate: nil, cancelButtonTitle: "Ok")
                errorAlert.show()
            }

            
        }
        
    }

    

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

