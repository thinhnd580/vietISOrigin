    //
//  ListViewController.swift
//  iBus
//
//  Created by Thinh Nguyen on 4/8/16.
//  Copyright © 2016 Thinh Nguyen. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import MagicalRecord

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var txtFieldSearchContent: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    var busList:[AnyObject] = []
    override func viewWillAppear(animated: Bool) {
        //set up navigation bar
        self.edgesForExtendedLayout = UIRectEdge.None
        let btnCity = UIBarButtonItem(title: "HN", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(self.btnCityClicked(_:)));
        self.navigationItem.leftBarButtonItem = btnCity
        self.navigationItem.title = "IBus"
        self.navigationController?.navigationBar.barTintColor = UIColor.yellowColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //register cell
        self.tableView.registerNib(UINib(nibName: "BusCell", bundle: nil), forCellReuseIdentifier: "BusCell")
        self.loadData()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return busList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("BusCell", forIndexPath: indexPath) as! BusCell
        let bus = busList[indexPath.row] as! Route
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.lbBusNumber.text =  "\(bus.busNumber!)"
        cell.lbBusTrip.text = "\(bus.routeTrip!)"
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tripVC = TripViewController(nibName: "TripViewController", bundle: nil)
        let routeSelected = self.busList[indexPath.row] as! Route
        tripVC.pointList = (routeSelected.goPoints!.array)
        tripVC.route = routeSelected
        self.navigationController?.pushViewController(tripVC, animated: true)
    }
    
    func btnCityClicked(sender:UIButton){
        
        /* Confic picker */
        let list = ["Hà Nội","Hải Phòng","Đà Nẵng","Hồ Chí minh"]
        ActionSheetStringPicker.showPickerWithTitle("City", rows: list, initialSelection: 1, doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            
            self.navigationItem.leftBarButtonItem?.title = "\(index)"
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender)
        

    }
    
    func loadData(){
        //init enity for the fist time
        self.busList = Route.MR_findAll()
        if( self.busList.count == 0){
            self.preloadData()
            self.busList = Route.MR_findAll()
        }
        
        self.tableView.reloadData()
    }
    
    
    func preloadData () {
    // Retrieve data from the source file
        if let contentsOfURL = NSBundle.mainBundle().pathForResource("routes", ofType: "txt") {
            // Remove all the menu items before preloading
            removeData()
            var error:NSError?
            if let items = Utility.parseTxtToRoute(contentsOfURL, encoding: NSUTF8StringEncoding, error: &error) {
                // Preload the menu items
                for item in items{
                    let route = Route.MR_createEntity() as! Route
                    route.busNumber = item.busNumber
                    route.routeTrip = item.routeTrip
                    route.tripDetail = item.tripDetail
                    route.polyline = "yxm_CcafeSvArDRAb@HJDNIdBg@JCdAvCLb@Qk@BFxDfK~B`Fr@hAhBrBpClCfCbCtAjBx@hBn@jBbEbNlCrJ~GvUnLda@?RKTSTqBnAmA`A[`@}ArAyFdEcAr@qBt@iBxAkB~AoBxByAvBuBhCl@t@`@]VgA`BoBfAYHK|BnL?j@ECQ?SJGRBTNNT@PI`G\\hFCbEFjELpFBtBB|ERvDRjAc@vDwAzAu@x@KpB?~DItECrAZ~Cv@_@`BkA~Fg@rBaA`GcBrHk@dCxBDn_@N|MHtBAAhBOlGSvMKx@a@bNC~B[|KNvAxA|EC^Vl@F\\Bt@{AxC`@Tv@}ANUd@]bCc@jBp@xSlKpGhDxHrEv@d@jAf@hFzBxL|E`G|BfE~A|@p@f@j@bJ~MxBnDp@tArBjDvNzV`DlFnEbIzCfFzAlCrF`JdCvDlGpK~@nBh@|@zA~AdBhCpNhU~LpRvHvLdMlQjCbD~BfD|HfK|NfSrMfRbDnFdE~FxB~CzCtDfDxD|LrPnKbOfLbPdHvJnZhb@tI|LnApB~DtFxC`ExKfPtBtCdDtElAlBpAfBGHeA`A?JRBd@j@zBxDH@N?p@ONIn@|@iCrBsBbBKBKA"
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                }
            }
        }
        else{
            print("cann't load data form routes.text")
        }
        
        if let contentsOfURL = NSBundle.mainBundle().pathForResource("goPoints01", ofType: "txt") {
            
            var error:NSError?
            if let items = Utility.parseTxtToPoint(contentsOfURL, encoding: NSUTF8StringEncoding, error: &error) {
                // Preload the menu items
                
                for item in items{
                    let point = Point.MR_createEntity() as! Point
                    point.lat = NSNumber.init(double: Double(item.lat)!)
                    point.long = NSNumber.init(double: Double(item.long)!)
                    point.name = item.name
                    let route = Route.MR_findFirstByAttribute("busNumber", withValue: "01") as! Route
                    point.addRouteObject(route)
                    route.addGoPointObject(point)
                    
                    NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreAndWait()
                }
                
            }
        }
        else{
            print("cann't load data form point.txt")
        }
        
        
    }
    
    func removeData () {
        // Remove the existing items
        let routes = Route.MR_findAll()
        for route in routes {
            route as! Route
            route.MR_deleteEntity()
        }
        
        let points = Point.MR_findAll()
        for point in points {
            point as! Point
            point.MR_deleteEntity()
        }
        
    }
    @IBAction func btnSearchClicked(sender: AnyObject) {
        let query = self.txtFieldSearchContent.text
        
        // Predict Route
        let routePredict = NSPredicate(format: "busNumber CONTAINS[c] %@ OR tripDetail CONTAINS[c] %@", query!, query! )
        let routes:[AnyObject] = Route.MR_findAllWithPredicate(routePredict)
        self.busList = routes
        self.tableView.reloadData()
        

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
