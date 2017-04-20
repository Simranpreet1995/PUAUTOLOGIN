//
//  WelcomeViewController.swift
//  PUAUTOLOGIN
//
//  Created by Saini  on 10/22/16.
//  Copyright © 2016 Saini . All rights reserved.
//

import UIKit
import GoogleMaps

class WelcomeViewController1: UIViewController,UIWebViewDelegate,NSURLConnectionDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //addSlideMenuButton()
        //let url = URL(string: "http://www.google.com/")!
        //webview.loadRequest(URLRequest(url: url)
    }
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: 30.760618, longitude: 76.765388, zoom: 16.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 30.760618, longitude: 76.765388)
        marker.title = "Panjab University"
        marker.snippet = "Chandigarh"
        marker.map = mapView
        mapView.settings.myLocationButton = true
        
    }

   
}
