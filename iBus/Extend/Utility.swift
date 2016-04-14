//
//  Utility.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/13/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit

class Utility: NSObject {
    static  func parseTxtToPoint (path: String, encoding: NSStringEncoding, error: NSErrorPointer) -> [(lat:String, long:String, name: String)]? {
        // Load the CSV file and parse it
        var items:[(lat:String, long:String, name: String)]?
        items = []
        do {
            let mytext = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            print(mytext)   // "some text\n"
            let lines:[String] = mytext.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()) as [String]
            
            for line in lines {
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    
                    let values =  line.componentsSeparatedByString(",")
                    //                var range = values[0].rangeOfString("\"")
                    
                    let item = (lat: values[0], long: values[1], name: values[2])
                    items?.append(item)
                }
            }
            
            
        } catch let error as NSError {
            print("error loading from url \(path)")
            print(error.localizedDescription)
        }
        
        
        
        return items
    }
    
    static func parseTxtToRoute (path: String, encoding: NSStringEncoding, error: NSErrorPointer) -> [(busNumber:String, routeTrip:String, tripDetail: String, polyline: String)]? {
        // Load the CSV file and parse it
        
        
        var items:[(busNumber:String, routeTrip:String, tripDetail: String, polyline: String)]?
        items = []
        
        
        
        do {
            let polylines = parseTxtToPolyline()
            
            
            
            let mytext = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            print(mytext)   // "some text\n"
            let lines:[String] = mytext.componentsSeparatedByString("\n==============================\n") as [String]
            
//            let l:[String] = mytext.componentsSeparatedByString("==============================")
            var index = 0
            for line in lines {
                if line != "" {
                    // For a line with double quotes
                    // we use NSScanner to perform the parsing
                    
                    let values =  line.componentsSeparatedByString(",,,")
                    //                var range = values[0].rangeOfString("\"")
                    
                    if(((polylines?.count)!-1)<index){
                        let item = (busNumber: values[0], routeTrip: values[1], tripDetail: values[2], polyline: "")
                        items?.append(item)
                    }
                    else{
                        let item = (busNumber: values[0], routeTrip: values[1], tripDetail: values[2], polyline: polylines![index])
                        items?.append(item)
                    }
                    
                    
                    index += 1
                }
            }
            
            
        } catch let error as NSError {
            print("error loading from url \(path)")
            print(error.localizedDescription)
        }
        //        print("this is content $$$$$$$$$$$$$$$ \(content)")
        
        return items
    }
    
    
    
    static func parseTxtToPolyline () -> [String]? {
        // Load the CSV file and parse it
        
        var items:[String]?
        items = []
        
        if let path = NSBundle.mainBundle().pathForResource("polyline", ofType: "txt") {
            var error_:NSError
            
            do {
                let mytext = try String(contentsOfFile: path)
                print(mytext)   // "some text\n"
                
                let lines:[String] = mytext.componentsSeparatedByString("\n==============================\n") as [String]
                //            let l:[String] = mytext.componentsSeparatedByString("==============================")
                for line in lines {
                    if line != "" {
                        items?.append(line)
                    }
                }
                
                
            } catch let error as NSError {
                print("error loading from url \(path)")
                print(error.localizedDescription)
            }

            
            
        }
        else{
            print("cann't load data form routes.text")
        }

        
        return items
    }

    

}
