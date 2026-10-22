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
}
