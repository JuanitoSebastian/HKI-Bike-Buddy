//
//  MapViewUIRep.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import SwiftUI
import MapKit

/// MapView displayes a MapKit map with an annotation for the users location and an annotation for the bike rental station
/// MapView determines the right area to display on the map: keeping the user and the bike rental station always visible
struct MapView: UIViewRepresentable {

    @ObservedObject private var userLocationService: UserLocationService = UserLocationService.shared
    private var bikeRentalStation: BikeRentalStation
    private let minimumZoomValue: Double = 250

    /// - Parameter bikeRentalStation: The bike rental station to display on the map
    init(bikeRentalStation: BikeRentalStation) {
        self.bikeRentalStation = bikeRentalStation
    }

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let annotation = MKPointAnnotation()
        annotation.coordinate = bikeRentalStation.coordinate
        let mapView = map
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
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
        annotation.coordinate = bikeRentalStation.coordinate
        uiView.addAnnotation(annotation)
    }

    private var map: MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        return mapView
    }
}

// MARK: - Determining the area to display on the map
/// The right area to display is determined by calculating the midpoint and
/// the distance between the two coordinates
extension MapView {
    private var minLat: Double {
        if bikeRentalStation.lat <= userLocationService.userLocation2D!.latitude {
            return bikeRentalStation.lat
        }
        return userLocationService.userLocation2D!.latitude
    }

    private var minLon: Double {
        if bikeRentalStation.lon <= userLocationService.userLocation2D!.longitude {
            return bikeRentalStation.lon
        }
        return userLocationService.userLocation2D!.longitude
    }

    private var maxLat: Double {
        if bikeRentalStation.lat >= userLocationService.userLocation2D!.latitude {
            return bikeRentalStation.lat
        }
        return userLocationService.userLocation2D!.latitude
    }

    private var maxLon: Double {
        if bikeRentalStation.lon >= userLocationService.userLocation2D!.longitude {
            return bikeRentalStation.lon
        }
        return userLocationService.userLocation2D!.longitude
    }

    private var centerPoint: CLLocationCoordinate2D {
        if userLocationService.userLocation2D == nil {
            return bikeRentalStation.coordinate
        }
        return CLLocationCoordinate2D(
            latitude: (maxLat + minLat) * 0.5,
            longitude: (maxLon + minLon) * 0.5
        )
    }

    private var zoom: Double {
        if userLocationService.userLocation == nil {
            return minimumZoomValue
        }
        let location1 = CLLocation(latitude: minLat, longitude: minLon)
        let location2 = CLLocation(latitude: maxLat, longitude: maxLon)
        var zoom = location1.distance(from: location2)
        zoom *= 1.5
        return zoom < minimumZoomValue ? minimumZoomValue : zoom
    }
}

// MARK: - Coordinator
/// Coordinator class is used for custom annotations on the map
extension MapView {

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                let userLocationView = MKUserLocationView(annotation: annotation, reuseIdentifier: "User")
                userLocationView.tintColor = UIColor(Color("UserAnnotation"))
                return userLocationView
            } else {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker")
                annotationView.glyphImage = UIImage(systemName: "bicycle")
                annotationView.markerTintColor = UIColor(Color("StationAnnotation"))
                return annotationView
            }

        }
    }

}
