//
//  MKMapViewViewController.swift
//  PUAUTOLOGIN
//
//  Created by Saini  on 2/8/17.
//  Copyright © 2017 Saini . All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MKMapViewViewController: BaseViewController{
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager = CLLocationManager()
    fileprivate var startedLoadingPOIs = false
    fileprivate var places = [Place]()
    fileprivate var arViewController: ARViewController!


    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        mapView.showsUserLocation=true;
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func showARController(_ sender: UIButton) {
        arViewController = ARViewController()
        //1
        arViewController.dataSource = self
        //2
        arViewController.maxVisibleAnnotations = 30
        arViewController.headingSmoothingFactor = 0.05
        //3
        arViewController.setAnnotations(places)
        
        self.present(arViewController, animated: true, completion: nil)
        
    }
    func showInfoView(forPlace place: Place) {
        //1
        let alert = UIAlertController(title: place.placeName , message: place.infoText, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //2
        arViewController.present(alert, animated: true, completion: nil)
    }
}
extension MKMapViewViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //1
        if locations.count > 0 {
            let location = locations.last!
            print("Accuracy: \(location.horizontalAccuracy)")
            
            //2
            if location.horizontalAccuracy < 100 {
                //3
                manager.stopUpdatingLocation()
                let span = MKCoordinateSpan(latitudeDelta: 0.014, longitudeDelta: 0.014)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                mapView.region = region
                //1
                if !startedLoadingPOIs {
                    startedLoadingPOIs = true
                    //2
                    let loader = PlacesLoader()
                    loader.loadPOIS(location: location, radius: 1000) { placesDict, error in
                        //3
                        if let dict = placesDict {
                            //1
                            guard let placesArray = dict.object(forKey: "results") as? [NSDictionary]  else { return }
                            //2
                            for placeDict in placesArray {
                                //3
                                let latitude = placeDict.value(forKeyPath: "geometry.location.lat") as! CLLocationDegrees
                                let longitude = placeDict.value(forKeyPath: "geometry.location.lng") as! CLLocationDegrees
                                let reference = placeDict.object(forKey: "reference") as! String
                                let name = placeDict.object(forKey: "name") as! String
                                let address = placeDict.object(forKey: "vicinity") as! String
                                
                                let location = CLLocation(latitude: latitude, longitude: longitude)
                                //4
                                let place = Place(location: location, reference: reference, name: name, address: address)              
                                self.places.append(place)
                                //5
                                let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
                                //6
                                DispatchQueue.main.async {
                                    self.mapView.addAnnotation(annotation)
                                }
                            }
    
                        }
                    }
                }
            }
        }
    }

}

extension MKMapViewViewController: ARDataSource {
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let annotationView = AnnotationView()
        annotationView.annotation = viewForAnnotation
        annotationView.delegate = self
        annotationView.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        return annotationView
    }
}

extension MKMapViewViewController: AnnotationViewDelegate {
    func didTouch(annotationView: AnnotationView) {
        //1
        if let annotation = annotationView.annotation as? Place {
            //2
            let placesLoader = PlacesLoader()
            placesLoader.loadDetailInformation(forPlace: annotation) { resultDict, error in
                
                //3
                if let infoDict = resultDict?.object(forKey: "result") as? NSDictionary {
                    annotation.phoneNumber = infoDict.object(forKey: "formatted_phone_number") as? String
                    annotation.website = infoDict.object(forKey: "website") as? String
                    
                    //4
                    self.showInfoView(forPlace: annotation)
                }
            }
        }
    }
}

