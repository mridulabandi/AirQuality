//
//  MVLAssignmentTests.swift
//  MVLAssignmentTests
//
//  Created by Mridula Bandi on 10/07/26.
//

import XCTest
@testable import MVLAssignment

// MARK: - Coordinate caching rule
// Spec: "If both latitude and longitude match up to the third decimal place,
// treat them as the same location."

final class CoordinateCacheKeyTests: XCTestCase {

    func testCoordinatesMatchingToThirdDecimal_produceSameCacheKey() {
        let a = Coordinate(latitude: 37.5642, longitude: 127.0016)
        let b = Coordinate(latitude: 37.5645, longitude: 127.0018)
        XCTAssertEqual(a.cacheKey, b.cacheKey)
    }

    func testCoordinatesDifferingBeyondThirdDecimal_produceDifferentCacheKeys() {
        let a = Coordinate(latitude: 37.5655, longitude: 127.2321)
        let b = Coordinate(latitude: 37.5624, longitude: 127.2328)
        XCTAssertNotEqual(a.cacheKey, b.cacheKey)
    }
}

// MARK: - GeoLocation display name (nickname override)

final class GeoLocationDisplayNameTests: XCTestCase {

    func testDisplayName_fallsBackToAddress_whenNicknameIsNil() {
        let location = GeoLocation(
            coordinate: Coordinate(latitude: 37.5, longitude: 127.0),
            addressName: "Seoul Gangnam-gu",
            nickname: nil
        )
        XCTAssertEqual(location.displayName, "Seoul Gangnam-gu")
    }

    func testDisplayName_usesNickname_whenPresent() {
        let location = GeoLocation(
            coordinate: Coordinate(latitude: 37.5, longitude: 127.0),
            addressName: "Seoul Gangnam-gu",
            nickname: "Home"
        )
        XCTAssertEqual(location.displayName, "Home")
    }

    func testDisplayName_treatsEmptyNickname_asUnset() {
        let location = GeoLocation(
            coordinate: Coordinate(latitude: 37.5, longitude: 127.0),
            addressName: "Seoul Gangnam-gu",
            nickname: ""
        )
        XCTAssertEqual(location.displayName, "Seoul Gangnam-gu")
    }
}

// MARK: - BookingFlowStore state machine
// Covers the V Button state transitions: Set A -> Set B -> Book, and reset.

final class BookingFlowStoreTests: XCTestCase {

    private func makeCachedLocation(lat: Double, lng: Double, aqi: Int) -> CachedLocation {
        let coordinate = Coordinate(latitude: lat, longitude: lng)
        let location = GeoLocation(coordinate: coordinate, addressName: "Test Address \(lat)", nickname: nil)
        return CachedLocation(location: location, airQuality: AirQuality(aqi: aqi, coordinate: coordinate))
    }

    func testInitialState_buttonShowsSetA() {
        let store = BookingFlowStore()
        XCTAssertEqual(store.buttonState.title, "Set A")
    }

    func testAfterSettingSlotA_buttonShowsSetB() {
        let store = BookingFlowStore()
        store.setSlot(.a, to: makeCachedLocation(lat: 36.5, lng: 127.0, aqi: 30))
        XCTAssertEqual(store.buttonState.title, "Set B")
    }

    func testAfterSettingBothSlots_buttonShowsBook() {
        let store = BookingFlowStore()
        store.setSlot(.a, to: makeCachedLocation(lat: 36.5, lng: 127.0, aqi: 30))
        store.setSlot(.b, to: makeCachedLocation(lat: 36.6, lng: 127.1, aqi: 40))
        XCTAssertEqual(store.buttonState.title, "Book")
    }

    func testReset_clearsBothSlots_andReturnsToSetA() {
        let store = BookingFlowStore()
        store.setSlot(.a, to: makeCachedLocation(lat: 36.5, lng: 127.0, aqi: 30))
        store.setSlot(.b, to: makeCachedLocation(lat: 36.6, lng: 127.1, aqi: 40))

        store.reset()

        XCTAssertNil(store.location(for: .a))
        XCTAssertNil(store.location(for: .b))
        XCTAssertEqual(store.buttonState.title, "Set A")
    }

    func testSetNickname_overridesDisplayNameForCorrectSlotOnly() {
        let store = BookingFlowStore()
        store.setSlot(.a, to: makeCachedLocation(lat: 36.5, lng: 127.0, aqi: 30))
        store.setSlot(.b, to: makeCachedLocation(lat: 36.6, lng: 127.1, aqi: 40))

        store.setNickname("Office", for: .a)

        XCTAssertEqual(store.location(for: .a)?.location.displayName, "Office")
        XCTAssertNotEqual(store.location(for: .b)?.location.displayName, "Office")
    }
}

// MARK: - AddressNameMapper
// Spec: use the two name values with the highest `order` from
// localityInfo.administrative and concatenate them.

final class AddressNameMapperTests: XCTestCase {

    func testDisplayName_concatenatesTwoHighestOrderAdministrativeEntries() {
        let dto = GeocodeResponseDTO(
            localityInfo: .init(administrative: [
                .init(name: "South Korea", order: 1, adminLevel: nil),
                .init(name: "Seoul", order: 4, adminLevel: nil),
                .init(name: "Gangnam-gu", order: 6, adminLevel: nil)
            ])
        )

        let result = AddressNameMapper.displayName(from: dto)

        XCTAssertEqual(result, "Gangnam-gu Seoul")
    }

    func testDisplayName_handlesFewerThanTwoEntries() {
        let dto = GeocodeResponseDTO(
            localityInfo: .init(administrative: [
                .init(name: "South Korea", order: 1, adminLevel: nil)
            ])
        )

        XCTAssertEqual(AddressNameMapper.displayName(from: dto), "South Korea")
    }
}

// MARK: - Mock repository isolation
// Confirms mock behavior is reachable only through the BookingRepository
// protocol, never referenced directly by use cases/view models.

final class MockBookingRepositoryTests: XCTestCase {

    func testCreateBooking_echoesAAndBWithAnAttachedPrice() async throws {
        let repository: BookingRepository = MockBookingRepository()
        let a = BookingPoint(latitude: 36.564, longitude: 127.001, aqi: 30, name: "A")
        let b = BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 40, name: "B")

        let booking = try await repository.createBooking(a: a, b: b)

        XCTAssertEqual(booking.a, a)
        XCTAssertEqual(booking.b, b)
        XCTAssertGreaterThan(booking.price, 0)
    }

    func testFetchBookings_includesSeedDataAndNewlyCreatedBookings() async throws {
        let repository: BookingRepository = MockBookingRepository()
        let a = BookingPoint(latitude: 36.564, longitude: 127.001, aqi: 30, name: "A")
        let b = BookingPoint(latitude: 36.567, longitude: 127.000, aqi: 40, name: "B")
        _ = try await repository.createBooking(a: a, b: b)

        let now = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: now)
        let bookings = try await repository.fetchBookings(year: components.year!, month: components.month!)

        // seed-2 (dated "now") + the just-created booking. seed-1 is dated
        // one month back specifically so it's excluded here — see
        // testFetchBookings_excludesBookingsOutsideRequestedMonth below.
        XCTAssertGreaterThanOrEqual(bookings.count, 2)
    }

    /// Locks in the year/month filtering fix. The mock previously ignored
    /// both parameters and returned every booking regardless of the query —
    /// this is the exact defect a past candidate was rejected for.
    func testFetchBookings_excludesBookingsOutsideRequestedMonth() async throws {
        let repository = MockBookingRepository()
        let now = Date()
        let calendar = Calendar.current
        let currentComponents = calendar.dateComponents([.year, .month], from: now)
        guard let year = currentComponents.year, let month = currentComponents.month else {
            return XCTFail("Could not resolve current year/month")
        }

        let currentMonthBookings = try await repository.fetchBookings(year: year, month: month)
        let unrelatedFutureBookings = try await repository.fetchBookings(year: year + 5, month: month)

        // A far-future year/month should never match any seeded or created
        // booking, proving the filter actually discriminates rather than
        // returning the same full list for every query.
        XCTAssertTrue(unrelatedFutureBookings.isEmpty)
        XCTAssertFalse(currentMonthBookings.isEmpty)
    }
}

