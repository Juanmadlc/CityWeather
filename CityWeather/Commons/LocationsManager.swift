//
//  LocationManager.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 29/06/2026.
//

import CoreLocation

class LocationsManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    static let shared = LocationsManager()
    @Published var city: String?
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestCity() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let city = placemarks?.first?.locality {
                DispatchQueue.main.async {
                    self.city = city
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func getCity() -> String? {
        return self.city
    }
    
    
}
