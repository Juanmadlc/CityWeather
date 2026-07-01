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

    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

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
            Task { @MainActor in
                resumeOnce(throwing: NSError(domain: "LocationManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Location permission denied or restricted"]))
            }
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
        // Ensure authorization on main thread
        await MainActor.run { [weak self] in
            self?.requestLocationAuthorization()
        }

        // If a previous request is in flight, cancel it by throwing and clearing
        if locationContinuation != nil {
            // Prevent overlapping requests
            throw NSError(domain: "LocationManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Location request already in progress"])
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, Error>) in
            // Store continuation to resume from delegate callbacks
            self.locationContinuation = continuation

            // Start updating location
            self.locationManager.startUpdatingLocation()

            // Add a timeout to avoid leaking the continuation
            Task { [weak self] in
                try? await Task.sleep(nanoseconds: 10 * 1_000_000_000)
                await self?.timeoutIfNeeded()
            }
        }
    }

    @MainActor
    private func resumeOnce(returning location: CLLocation) {
        guard let cont = locationContinuation else { return }
        locationContinuation = nil
        locationManager.stopUpdatingLocation()
        cont.resume(returning: location)
    }

    @MainActor
    private func resumeOnce(throwing error: Error) {
        guard let cont = locationContinuation else { return }
        locationContinuation = nil
        locationManager.stopUpdatingLocation()
        cont.resume(throwing: error)
    }

    @MainActor
    private func timeoutIfNeeded() {
        guard let _ = locationContinuation else { return }
        resumeOnce(throwing: NSError(domain: "LocationManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Location request timed out"]))
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationActivated = true
            case .denied, .restricted:
                locationActivated = false
                resumeOnce(throwing: NSError(domain: "LocationManager", code: 4, userInfo: [NSLocalizedDescriptionKey: "Location permission denied or restricted"]))
            case .notDetermined:
                locationActivated = false
            @unknown default:
                break
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            // If someone is awaiting nextLocation, resume it
            resumeOnce(returning: location)
            self.userLocation = location
            self.userCoordinateRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: Constants.Location.deltaZoom, longitudeDelta: Constants.Location.deltaZoom)
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            resumeOnce(throwing: error)
            Log.error("Location error: \(error.localizedDescription)")
        }
    }
}

