//
//  LocationManager.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 01/07/2026.
//

import Foundation
import CoreLocation
import MapKit

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var userLocation: CLLocation?

    var userCoordinateRegion: MKCoordinateRegion {
        get {
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: userLocation?.coordinate.latitude ?? Constants.Location.defaultLatitude,
                    longitude: userLocation?.coordinate.longitude ?? Constants.Location.defaultLongitude
                ),
                span: MKCoordinateSpan(latitudeDelta: Constants.Location.deltaZoom, longitudeDelta: Constants.Location.deltaZoom)
            )
        }
        set { /* no-op setter to keep same API surface if used with @State */ }
    }

    @Published var locationActivated: Bool = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        // Do not start updating until authorized; request on demand
        self.userLocation = locationManager.location
    }

    // Call from UI to request permission and possibly kick off updates
    func requestLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            // Keep state updated; UI can guide user to Settings
            self.locationActivated = false
        @unknown default:
            break
        }
    }

    // Convenience to explicitly request a one-shot location
    func requestLocation() {
        requestLocationAuthorization()
        locationManager.requestLocation()
    }

    // Async API to obtain the current city name. Falls back to cached reverse-geocode if available.
    func currentCity() async throws -> String {
        // If we already have a recent location, use it; otherwise request one
        let location: CLLocation
        if let existing = self.userLocation, existing.timestamp > Date(timeIntervalSinceNow: -60) {
            location = existing
        } else {
            location = try await nextLocation()
        }

        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        guard let placemark = placemarks.first else {
            throw NSError(domain: "LocationManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No placemark found for location"])
        }
        // Choose the best available component to represent a city
        return placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "Unknown"
    }

    // MARK: - Private helpers
    private func nextLocation() async throws -> CLLocation {
        // Ensure we have authorization and start updates
        await MainActor.run { [weak self] in
            self?.requestLocationAuthorization()
        }
        return try await withCheckedThrowingContinuation { continuation in
            var resumed = false
            let resumeOnce: (Result<CLLocation, Error>) -> Void = { result in
                guard !resumed else { return }
                resumed = true
                continuation.resume(with: result)
            }

            // Temporary delegate proxy via closure
            let originalDelegate = self.locationManager.delegate

            class DelegateProxy: NSObject, CLLocationManagerDelegate {
                let onLocation: (Result<CLLocation, Error>) -> Void
                init(onLocation: @escaping (Result<CLLocation, Error>) -> Void) { self.onLocation = onLocation }
                func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                    if let last = locations.last { onLocation(.success(last)) }
                    manager.stopUpdatingLocation()
                }
                func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                    onLocation(.failure(error))
                    manager.stopUpdatingLocation()
                }
            }

            let proxy = DelegateProxy(onLocation: resumeOnce)
            self.locationManager.delegate = proxy
            self.locationManager.startUpdatingLocation()

            // Restore the original delegate after we resume
            Task { @MainActor in
                _ = try? await Task.sleep(nanoseconds: 1_000_000_000) // safety timeout to restore delegate later if needed
                if !resumed {
                    // If not resumed yet, keep proxy; otherwise restore
                } else {
                    self.locationManager.delegate = originalDelegate
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationActivated = true
        case .denied, .restricted:
            locationActivated = false
        case .notDetermined:
            locationActivated = false
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
        // NOTE: Fix longitude bug (was using latitude twice)
        self.userCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
            span: MKCoordinateSpan(latitudeDelta: Constants.Location.deltaZoom, longitudeDelta: Constants.Location.deltaZoom)
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("Location error: \(error.localizedDescription)")
    }
}
