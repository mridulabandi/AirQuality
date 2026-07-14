//
//  APIConstants.swift
//  MVLAssignment
//
//  Created by Mridula Bandi on 10/07/26.
//

import Foundation

enum APIConstants {
    
    /// See README.md "API Key Setup" for the one-time Xcode configuration.
    static let aqicnToken = infoPlistValue(for: "AQICN_TOKEN")
    static let bigDataCloudKey = infoPlistValue(for: "BIGDATACLOUD_KEY")

    static let aqicnBaseURL = "https://api.waqi.info"
    static let bigDataCloudBaseURL = "https://api.bigdatacloud.net/data"
    /// No live backend was provided for this assignment. This is where it
    /// would point once one exists — see DI/AppDIContainer.useMockBooking.
    static let bookingBaseURL = "https://api.example.com"

    private static func infoPlistValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty else {
            assertionFailure(
                "Missing \(key) in Info.plist. Add it to Config.xcconfig — see README.md."
            )
            return ""
        }
        return value
    }
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case decodingFailed
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid response from server."
        case .decodingFailed: return "Failed to decode server response."
        case .server(let message): return message
        }
    }
}

