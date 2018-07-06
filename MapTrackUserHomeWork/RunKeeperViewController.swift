//
//  RunKeeperViewController.swift
//  MapTrackUserHomeWork
//
//  Created by 黃翊倫 on 2018/6/20.
//  Copyright © 2018年 黃翊倫. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import HealthKit
import CoreData


class RunKeeperViewController: UIViewController {
    
    @IBOutlet weak var recordRouteSwitchButton: UISwitch!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var removeRouteButton: UIButton!

    var polyine = MKPolyline()
    var seconds = 0.0
    var distance = 0.0
    var reportOpen = false
    var returnData = ReturnData()
    var friends = [Friend]()
    lazy var myLocations = [CLLocation]()
    lazy var timer = Timer()
    let MY_NAME = "HuangYi"
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        mainMapView.delegate = self
        
        locationManager.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.pausesLocationUpdatesAutomatically = false
        
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways
            else{
                return
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 20.0
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let location = locationManager.location else{
            print("location is not found")
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mainMapView.setRegion(region, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        timer.invalidate()
        //不顯示該頁面時 時間計時器停止
    }
    
    @IBAction func openFriendsLocationList(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "朋友名單", message: nil, preferredStyle: .actionSheet)
        
        for friend in friends {
            
                let myFriend = UIAlertAction(title: friend.friendName, style: .default) { (UIAlertAction) in
                    
                    let lat = Double(friend.lat.replacingOccurrences(of:" ", with: ""))
                    let lon = Double(friend.lon.replacingOccurrences(of:" ", with:""))
                    var coordinate=CLLocationCoordinate2D()
                    if let lat = lat,let lon = lon{
                        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: coordinate, span: span)
                    
                    self.mainMapView.setRegion(region, animated: true)
                    
                }
                alertController.addAction(myFriend)
            
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func RecordRoute(_ sender: UISwitch) {
        if sender.isOn {
        
            seconds = 0.0
            distance = 0.0
            myLocations.removeAll()
            mainMapView.userTrackingMode = .follow
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(eachSecond(timer:)), userInfo: nil, repeats: true)
        }else {
           
            timer.invalidate()
            mainMapView.userTrackingMode = .none
        }
    }
   
    @IBAction func RemoveRoute(_ sender: UIButton) {
        
        myLocations.removeAll()
        
        mainMapView.remove(polyine)
    
    }
    
    @IBAction func ReportLocationUISwitch(_ sender: UISwitch) {
        
        if sender.isOn == true {
            reportOpen = true
        } else {
            reportOpen = false
        }
        
        
    }
    @IBAction func mapTypeChange(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            mainMapView.mapType = .standard
        case 1:
            mainMapView.mapType = .satellite
        case 2:
            mainMapView.mapType = .hybrid
        default:
            mainMapView.mapType = .standard
        }
    }
    
    
    @objc
    func eachSecond(timer: Timer) {
        
        seconds+=1
        let secondQuantity = HKQuantity(unit: HKUnit.second(), doubleValue: seconds)
        timeLabel.text = "時間： " + secondQuantity.description
        
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: distance)
        
        distanceLabel.text = "距離： " + distanceQuantity.description
        
        mainMapView.remove(polyine)
        
        polyine = polyline()
        
        mainMapView.add(polyine , level: .aboveRoads)
       
    }
    
    //繪製路徑的方法
    func polyline() -> MKPolyline {
        
        var coords = [CLLocationCoordinate2D]()
        
        for location in myLocations{
            coords.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
        
        polyine = MKPolyline(coordinates: coords, count: myLocations.count)
    
        return polyine
    }
}

extension RunKeeperViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let region = mapView.region
        print("center:\(region.center.latitude),\(region.center.longitude)")
        print("span:\(region.span.latitudeDelta),\(region.span.longitudeDelta)")
    }
    
    //運動軌跡的顏色 寬度
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2.0
        
        return renderer
    }
    
    //設定圖標
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation{
            return nil
        }
        let identifier = "friends"
        var result = mapView.dequeueReusableAnnotationView(withIdentifier:
            identifier)as?MKPinAnnotationView
        
        if result == nil {
            
            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
        }else{
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        result?.pinTintColor = .orange
        
        
       return result
    }
}

extension RunKeeperViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //列印出自己所在經緯度
        guard let coordinate = locations.last?.coordinate else{
            assertionFailure("找不到您的經緯度")
            return
        }
        print("coordinate:\(coordinate.latitude),\(coordinate.longitude)")
        
        //加入myLocations 用來 繪製 路徑
        for location in locations {
            if location.horizontalAccuracy < 20 {
                if myLocations.count > 0 {
                    distance += location.distance(from: myLocations.last!)
                }
                myLocations.append(location)
            }
        }
        
        //回報自己位置
        if reportOpen {
            
        let urlString = "http://class.softarts.cc/FindMyFriends/updateUserLocation.php?GroupName=cp101&UserName=HuangYi&Lat=\(coordinate.latitude)&Lon=\(coordinate.longitude)"
        
        guard let url = URL(string: urlString) else {
            
            assertionFailure("Invalid URL string.")
            return
        }
        let updateML = UpdateMyLocation(updateURL: url)
        updateML.update { (error, bool) in
            if let error = error {
                print("Error:\(error)")
                return
            }
            if let bool = bool{
                print("result:\(bool)")
            }
        }
        }
        
        //取得朋友位置
        let friendUrlString = "http://class.softarts.cc/FindMyFriends/queryFriendLocations.php?GroupName=cp101"
        guard let friendUrl = URL(string: friendUrlString) else{
            assertionFailure("invalid friend url string.")
            return
        }
        let getFL = GetFriendsLocation(gflURL: friendUrl)
        getFL.getFriends { (error, newItems) in
            if let error = error{
                print("Error:\(error)")
                //show alert to user.
                return
            }
            if let items = newItems {
                self.returnData = items
            }
        }
        
        for friend in returnData.friends{
            if friend.friendName == MY_NAME{
                let index = returnData.friends.index(of: friend)
                if let index = index {
                print("index:\(index)")
                returnData.friends.remove(at: index)
                }
            }
        }
        print("returnData.friends:\(returnData.friends)")
        
        if self.friends != returnData.friends {
            
            friends = returnData.friends
            self.mainMapView.removeAnnotations(self.mainMapView.annotations)
            
            for friend in friends {
                if friend.friendName != MY_NAME {
                let lat = Double(friend.lat.replacingOccurrences(of:" ", with: ""))
                let lon = Double(friend.lon.replacingOccurrences(of:" ", with:""))
                let annotation = MKPointAnnotation()
                if let lat = lat ,let lon = lon{
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                }
                print("lat:\(String(describing: lat)),lon:\(String(describing: lon))")
                print("friend coordinate:\(annotation.coordinate)")
                annotation.title = friend.friendName
                print("title:\(friend.friendName)")
                    annotation.subtitle = "latitude:\(friend.lat),longitude:\(friend.lon)"
                DispatchQueue.main.asyncAfter(deadline: .now()+3.0) {
                    self.mainMapView.addAnnotation(annotation)
                }
            }
          }
        }
    }
}
