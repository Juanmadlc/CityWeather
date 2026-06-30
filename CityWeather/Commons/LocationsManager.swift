//
//  LocationManager.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 29/06/2026.
//

import CoreLocation

final class LocationsManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationsManager()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var lastKnownCity: String?
    private var lastKnownCityDate: Date?

    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override private init() {
        super.init()
        manager.delegate = self
    }

    // Propiedad opcional para lecturas rápidas.
    var cachedCity: String? {
        lastKnownCity
    }

    // API principal: espera permisos, ubicación y hace geocoding.
    func currentCity() async throws -> String {
        let status = manager.authorizationStatus
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        guard CLLocationManager.locationServicesEnabled() else {
            throw NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location services disabled"])
        }

        // Si tenemos una ciudad cacheada reciente, la devolvemos rápido.
        if let city = lastKnownCity, let date = lastKnownCityDate, Date().timeIntervalSince(date) < 60 * 15 {
            return city
        }

        let location = try await nextReasonableLocation()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw NSError(domain: "LocationManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No placemark found"])
        }

        // Puedes ajustar locality/subAdministrativeArea según tu modelo de “ciudad”
        let city = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "Unknown"
        lastKnownCity = city
        lastKnownCityDate = Date()
        return city
    }

    // MARK: - Helpers

    private func nextReasonableLocation() async throws -> CLLocation {
        // Si ya hay una ubicación reciente y precisa, úsala
        if let existing = manager.location, existing.horizontalAccuracy > 0, existing.timestamp > Date(timeIntervalSinceNow: -60) {
            return existing
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, Error>) in
            self.locationContinuation = continuation
            self.manager.startUpdatingLocation()
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .denied, .restricted:
            if let continuation = locationContinuation {
                continuation.resume(throwing: NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location permission denied"]))
                locationContinuation = nil
            }
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let continuation = locationContinuation {
            continuation.resume(throwing: error)
            locationContinuation = nil
        }
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let best = locations.last, best.horizontalAccuracy > 0 else { return }
        if let continuation = locationContinuation {
            continuation.resume(returning: best)
            locationContinuation = nil
        }
        manager.stopUpdatingLocation()
    }
}
