//
//  MapViewUIRep.swift
//  HelsinkiBikeBuddy
//
//  Created by Juan Covarrubias on 5.3.2021.
//

import SwiftUI
import MapKit

// TODO: When userlocation is unavailable display only the rental station on map
struct MapView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    var rentalStation: BikeRentalStation

    init(rentalStation: BikeRentalStation) {
        self.rentalStation = rentalStation
    }

    private var minLat: Double {
        if rentalStation.lat <= UserLocationService.shared.userLocation2D!.latitude {
            return rentalStation.lat
        }
        return UserLocationService.shared.userLocation2D!.latitude
    }

    private var minLon: Double {
        if rentalStation.lon <= UserLocationService.shared.userLocation2D!.longitude {
            return rentalStation.lon
        }
        return UserLocationService.shared.userLocation2D!.longitude
    }

    private var maxLat: Double {
        if rentalStation.lat >= UserLocationService.shared.userLocation2D!.latitude {
            return rentalStation.lat
        }
        return UserLocationService.shared.userLocation2D!.latitude
    }

    private var maxLon: Double {
        if rentalStation.lon >= UserLocationService.shared.userLocation2D!.longitude {
            return rentalStation.lon
        }
        return UserLocationService.shared.userLocation2D!.longitude
    }

    private var centerPoint: CLLocationCoordinate2D {
        if UserLocationService.shared.userLocation2D == nil {
            return rentalStation.coordinate
        }
        return CLLocationCoordinate2D(
            latitude: (maxLat + minLat) * 0.5,
            longitude: (maxLon + minLon) * 0.5
        )
    }

    private var zoom: Double {
        if UserLocationService.shared.userLocation2D == nil {
            return 1
        }
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
        return mapView
    }

    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        let annotation = MKPointAnnotation()
        annotation.coordinate = rentalStation.coordinate
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
        annotation.coordinate = rentalStation.coordinate
        uiView.addAnnotation(annotation)
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
