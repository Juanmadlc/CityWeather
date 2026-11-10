//
//  LocationManagerTest.swift
//  CityWeather
//
//  Created by Juan Manuel de la Cruz on 09/11/2026.
//

import CoreLocation
import MapKit
import Testing
@testable import CityWeather

@Suite(.serialized)
struct LocationManagerTest {
    @Test
    @MainActor
    func `Location manager starts with location deactivated`() {
        let sut = LocationManager()

        #expect(sut.locationActivated == false)
    }

    @Test
    @MainActor
    func `Coordinate region uses the default location when no user location is available`() {
        let sut = LocationManager()
        let region = sut.userCoordinateRegion

        #expect(region.center.latitude == Constants.Location.defaultLatitude)
        #expect(region.center.longitude == Constants.Location.defaultLongitude)
        #expect(region.span.latitudeDelta == Constants.Location.deltaZoom)
        #expect(region.span.longitudeDelta == Constants.Location.deltaZoom)
    }

    @Test
    @MainActor
    func `Coordinate region uses the current user location`() {
        let sut = LocationManager()
        let location = CLLocation(latitude: 40.4168, longitude: -3.7038)
        sut.userLocation = location

        let region = sut.userCoordinateRegion

        #expect(region.center.latitude == location.coordinate.latitude)
        #expect(region.center.longitude == location.coordinate.longitude)
        #expect(region.span.latitudeDelta == Constants.Location.deltaZoom)
        #expect(region.span.longitudeDelta == Constants.Location.deltaZoom)
    }

    @Test
    @MainActor
    func `Location update stores the most recent location`() async {
        let sut = LocationManager()
        let manager = CLLocationManager()
        let firstLocation = CLLocation(latitude: 40.4168, longitude: -3.7038)
        let mostRecentLocation = CLLocation(latitude: 41.3874, longitude: 2.1686)

        sut.locationManager(manager, didUpdateLocations: [firstLocation, mostRecentLocation])
        await Task.yield()

        #expect(sut.userLocation?.coordinate.latitude == mostRecentLocation.coordinate.latitude)
        #expect(sut.userLocation?.coordinate.longitude == mostRecentLocation.coordinate.longitude)
    }

    @Test
    @MainActor
    func `Location update changes the coordinate region to the most recent location`() async {
        let sut = LocationManager()
        let manager = CLLocationManager()
        let location = CLLocation(latitude: 37.3891, longitude: -5.9845)

        sut.locationManager(manager, didUpdateLocations: [location])
        await Task.yield()

        let region = sut.userCoordinateRegion
        #expect(region.center.latitude == location.coordinate.latitude)
        #expect(region.center.longitude == location.coordinate.longitude)
        #expect(region.span.latitudeDelta == Constants.Location.deltaZoom)
        #expect(region.span.longitudeDelta == Constants.Location.deltaZoom)
    }

    @Test
    @MainActor
    func `Empty location update preserves the current location`() async {
        let sut = LocationManager()
        let manager = CLLocationManager()
        let existingLocation = CLLocation(latitude: 43.2630, longitude: -2.9350)
        sut.userLocation = existingLocation

        sut.locationManager(manager, didUpdateLocations: [])
        await Task.yield()

        #expect(sut.userLocation?.coordinate.latitude == existingLocation.coordinate.latitude)
        #expect(sut.userLocation?.coordinate.longitude == existingLocation.coordinate.longitude)
    }

    @Test
    @MainActor
    func `Location failures do not replace the current location`() async {
        let sut = LocationManager()
        let manager = CLLocationManager()
        let existingLocation = CLLocation(latitude: 39.4699, longitude: -0.3763)
        sut.userLocation = existingLocation

        sut.locationManager(manager, didFailWithError: CLError(.network))
        await Task.yield()

        #expect(sut.userLocation?.coordinate.latitude == existingLocation.coordinate.latitude)
        #expect(sut.userLocation?.coordinate.longitude == existingLocation.coordinate.longitude)
    }
}
