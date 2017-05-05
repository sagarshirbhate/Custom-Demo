//
//  ViewController.swift
//  Custom Demo
//
//  Created by Sagar Shirbhate on 5/5/17.
//  Copyright © 2017 Sagar Shirbhate. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    
//=========================== Variable Initializations ===========================
    @IBOutlet weak var segmentController    : UISegmentedControl!
    @IBOutlet weak var mapView              : MKMapView!
    @IBOutlet weak var tableView            : UITableView!
    @IBOutlet weak var activityIndicator    : UIActivityIndicatorView!
                   var dataArray            :[Crimes] = []
    
    
    
//MARK: =========================== View Life Cycles ===========================
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateViewAtStart()
        self.downloadDataFromService("http://api.spotcrime.com/crimes.json?key=e4f8df6be39a06bf7c326e5eb340ba956cfd9e0bc90d464ada3f63c355d9&lat=33.85741&lon=-84.24847&radius=0.01")
        self.tableView.estimatedRowHeight = 44 ;
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    
//Mark: =========================== Update View At Startup ===========================
    func updateViewAtStart() {
        self.mapView.isHidden   = true
        self.tableView.isHidden = true
        self.activityIndicator.isHidden = false
        self.segmentController.isHidden = true
    }

    
//MARK: =========================== Segment Method ===========================
    @IBAction func segmentChanged(_ sender: Any) {
        if self.segmentController.selectedSegmentIndex == 0 {
            self.mapView.isHidden   = false
            self.tableView.isHidden = true
        }else{
            self.mapView.isHidden   = true
            self.tableView.isHidden = false
        }
    }

//MARK:===========================  Download Data from Service ===========================
    func downloadDataFromService(_ urlString : String){
        if Reachability.isConnectedToNetwork() == true {
            
            let url : URL = URL(string: urlString)!
            let request = URLRequest(url: url as URL)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                        
                        let crimes = json?["crimes"] as! [[String:Any]]
                        
                        for obj in crimes{
                            
                        let crime = Crimes()
                        crime.cdid = obj["cdid"] as? Int
                        crime.type = obj["type"] as? String
                        crime.date = obj["date"] as? String
                        crime.address = obj["address"] as? String
                        crime.link = obj["link"] as? String
                        crime.lat = obj["lat"] as? Double
                        crime.lon = obj["lon"] as? Double
                        self.dataArray.append(crime)
                        }
                        
                        self.updateMapAndTableview()
                        
                    } else {
                        self.updateMapAndTableview()
                        self.showAlert("Data not fetched from server")
                    }
                }
            })
            
            task.resume()
        }else{
            self.updateMapAndTableview()
            self.showAlert("Device internet is not Working")
        }

    }
    

    
    
    
//MARK: =========================== Update MapView & TableView ===========================
    func updateMapAndTableview(){
        
        DispatchQueue.main.async {
       
        var annotationArray : [CustomPointAnnotation] = []
        
        for obj in self.dataArray{
        
        let annotation  = CustomPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(obj.lat!,obj.lon!)
        
            switch obj.type! {
            case "Assault":
                annotation.imageName = #imageLiteral(resourceName: "icon_assault")
                break ;
            case "Theft":
                annotation.imageName = #imageLiteral(resourceName: "icon_theft")
                break ;
            case "Burglary":
                annotation.imageName = #imageLiteral(resourceName: "icon_burglary")
                break ;
            case "Vandalism":
                annotation.imageName = #imageLiteral(resourceName: "icon_vandalism")
                break ;
            case "Robbery":
                annotation.imageName = #imageLiteral(resourceName: "icon_robbery")
                break ;
            default:
                break ;
            }
            
        annotation.title = obj.address
        annotationArray.append(annotation)
        }
        
            // to set zoom level of Map
            if self.dataArray.count > 0 {
                let crime = self.dataArray[0]
                let span = MKCoordinateSpanMake(0.075, 0.075)
                let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: crime.lat!, longitude: crime.lon!), span: span)
                self.mapView.setRegion(region, animated: true)
            }
            
            
        self.mapView.addAnnotations(annotationArray)
        self.tableView.reloadData()
            
            self.mapView.isHidden   = false
            self.tableView.isHidden = true
            self.activityIndicator.isHidden = true
            self.segmentController.isHidden = false
            
        }
        
        
        
    }
    
    
//Mark: =========================== Show Alert ===========================
    func showAlert(_ message:String){
        
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "No Internet", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:nil)
            
        }
        
    }
}





// MARK:=========================== Tableview Delegates & Data Sources===========================
extension ViewController : UITableViewDelegate , UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let crime = self.dataArray[indexPath.row] as Crimes
        
        cell.textLabel?.text = crime.type!+" on "+crime.date!+" at "+crime.address!
        
        switch crime.type! {
        case "Assault":
             cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "icon_assault"))
            break ;
        case "Theft":
             cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "icon_theft"))
            break ;
        case "Burglary":
             cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "icon_burglary"))
            break ;
        case "Vandalism":
             cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "icon_vandalism"))
            break ;
        case "Robbery":
             cell.accessoryView = UIImageView.init(image: #imageLiteral(resourceName: "icon_robbery"))
            break ;
        default:
            break ;
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}










//MARK : =========================== MAPVIEW Delegates ===========================
extension ViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "Location"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = cpa.imageName
        
        return anView
    }
    
    
    
}





//MARK: =========================== Model Class For Crimes===========================
class Crimes {
    var cdid: Int?
    var type: String?
    var date: String?
    var address: String?
    var link: String?
    var lat: Double?
    var lon: Double?
}
