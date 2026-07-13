//
//  AppDIContainer.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

final class AppDIContainer {
    static let shared = AppDIContainer()

    // MARK: Repositories (singletons — cache must be shared across screens)
    lazy var locationCacheRepository: LocationCacheRepository = InMemoryLocationCacheRepository()

    lazy var airQualityRepository: AirQualityRepository =
        AirQualityRepositoryImpl(apiService: AirQualityAPIService())

    lazy var geocodingRepository: GeocodingRepository =
        GeocodingRepositoryImpl(apiService: GeocodingAPIService())

    /// The assignment provides no live /books backend, so this is mocked by
    /// default. The switch is explicit and centralized here — flipping
    /// `useMockBooking` to false (once a real backend exists) is the only
    /// change needed anywhere in the app, because every use case and view
    /// model depends on the `BookingRepository` protocol, never the concrete
    /// type.
    private let useMockBooking = true

    lazy var bookingRepository: BookingRepository = {
        if useMockBooking {
            return MockBookingRepository()
        }

        return LiveBookingRepository(baseURL: APIConstants.bookingBaseURL)
    }()

    // MARK: Use Cases
    func makeResolveLocationUseCase() -> ResolveLocationUseCase {
        DefaultResolveLocationUseCase(
            geocodingRepository: geocodingRepository,
            airQualityRepository: airQualityRepository,
            cacheRepository: locationCacheRepository
        )
    }

    func makeFetchAirQualityUseCase() -> FetchAirQualityUseCase {
        DefaultFetchAirQualityUseCase(repository: airQualityRepository)
    }

    func makeCreateBookingUseCase() -> CreateBookingUseCase {
        DefaultCreateBookingUseCase(repository: bookingRepository)
    }

    func makeFetchBookingHistoryUseCase() -> FetchBookingHistoryUseCase {
        DefaultFetchBookingHistoryUseCase(repository: bookingRepository)
    }

    func makeFetchCachedLocationsUseCase() -> FetchCachedLocationsUseCase {
        DefaultFetchCachedLocationsUseCase(repository: locationCacheRepository)
    }

    // MARK: View Models
    func makeMapViewModel(flowStore: BookingFlowStore) -> MapViewModel {
        MapViewModel(
            resolveLocationUseCase: makeResolveLocationUseCase(),
            fetchAirQualityUseCase: makeFetchAirQualityUseCase(),
            flowStore: flowStore
        )
    }

    func makeNicknameViewModel(slot: SlotIdentifier, flowStore: BookingFlowStore) -> NicknameViewModel {
        NicknameViewModel(slot: slot, flowStore: flowStore)
    }

    func makeBookingResultViewModel(flowStore: BookingFlowStore) -> BookingResultViewModel {
        BookingResultViewModel(createBookingUseCase: makeCreateBookingUseCase(), flowStore: flowStore)
    }

    func makeHistoryViewModel() -> HistoryViewModel {
        HistoryViewModel(fetchBookingHistoryUseCase: makeFetchBookingHistoryUseCase())
    }

    func makeCachedLocationsViewModel(flowStore: BookingFlowStore) -> CachedLocationsViewModel {
        CachedLocationsViewModel(
            fetchCachedLocationsUseCase: makeFetchCachedLocationsUseCase(),
            flowStore: flowStore
        )
    }
}

