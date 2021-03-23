//
//  MapViewUIRep.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {

    var rentalStation: RentalStation

    init(rentalStation: RentalStation) {
        self.rentalStation = rentalStation
    }

    private var minLat: Double {
        if rentalStation.lat <= UserLocationService.shared.userLocation2D.latitude {
            return rentalStation.lat
        }
        return UserLocationService.shared.userLocation2D.latitude
    }

    private var minLon: Double {
        if rentalStation.lon <= UserLocationService.shared.userLocation2D.longitude {
            return rentalStation.lon
        }
        return UserLocationService.shared.userLocation2D.longitude
    }

    private var maxLat: Double {
        if rentalStation.lat >= UserLocationService.shared.userLocation2D.latitude {
            return rentalStation.lat
        }
        return UserLocationService.shared.userLocation2D.latitude
    }

    private var maxLon: Double {
        if rentalStation.lon >= UserLocationService.shared.userLocation2D.longitude {
            return rentalStation.lon
        }
        return UserLocationService.shared.userLocation2D.longitude
    }

    private var centerPoint: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: (maxLat + minLat) * 0.5,
            longitude: (maxLon + minLon) * 0.5
        )
    }

    private var zoom: Double {
        let location1 = CLLocation(latitude: minLat, longitude: minLon)
        let location2 = CLLocation(latitude: maxLat, longitude: maxLon)
        var zoom = location1.distance(from: location2)
        zoom *= 1.5
        return zoom
    }

    private var map: MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.mapType = .standard
        mapView.layer.cornerRadius = 10
        return mapView
    }

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let annotation = MKPointAnnotation()
        annotation.coordinate = rentalStation.coordinate
        let mapView = map
        let region = MKCoordinateRegion(center: centerPoint, latitudinalMeters: zoom, longitudinalMeters: zoom)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        let region = MKCoordinateRegion(center: centerPoint, latitudinalMeters: zoom, longitudinalMeters: zoom)
        uiView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = rentalStation.coordinate
        uiView.addAnnotation(annotation)
    }
}
