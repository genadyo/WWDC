//
//  LyftModel.swift
//  SFParties
//
//  Created by Genady Okrain on 5/10/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

enum RideType: String {
    case All = ""
    case Line = "lyft_line"
    case Lyft = "lyft"
    case Plus = "lyft_plus"
}

struct RideTypesQuery {
    let lat: Float
    let lng: Float
    let rideType: RideType

    init(lat: Float, lng: Float, rideType: RideType = .All) {
        self.lat = lat
        self.lng = lng
        self.rideType = rideType
    }
}

struct ETAQuery {
    let lat: Float
    let lng: Float
    let rideType: RideType

    init(lat: Float, lng: Float, rideType: RideType = .All) {
        self.lat = lat
        self.lng = lng
        self.rideType = rideType
    }
}

struct CostQuery {
    let start_lat: Float
    let start_lng: Float
    let end_lat: Float
    let end_lng: Float
    let rideType: RideType

    init(start_lat: Float, start_lng: Float, end_lat: Float = 0, end_lng: Float = 0, rideType: RideType = .All) {
        self.start_lat = start_lat
        self.start_lng = start_lng
        self.end_lat = end_lat
        self.end_lng = end_lng
        self.rideType = rideType
    }
}

struct NearbyDriversQuery {
    let lat: Float
    let lng: Float
}

struct PricingDetails {
    let baseCharge: Int
    let costPerMile: Int
    let costPerMinute: Int
    let costMinimum: Int
    let trustAndService: Int
    let currency: String
    let cancelPenaltyAmount: Int
}

struct RideTypesResponse {
    let pricingDetails: PricingDetails
    let rideType: RideType
    let displayName: String
    let imageURL: String
    let seats: Int
}

struct EtaEstimate {
    let displayName: String
    let rideType: RideType
    let etaSeconds: Int
}

struct CostEstimate {
    let rideType: RideType
    let displayName: String
    let currency: String
    let estimatedCostCentsMin: Int
    let estimatedCostCentsMax: Int
    let estimatedDurationSeconds: Int
    let estimatedDistanceMiles: Float
    let primetimeConfirmationToken: String?
    let primetimePercentage: String
}

struct NearbyDrivers {
    let drivers: [Driver]
    let rideType: RideType
}

struct Driver {
//    let bearing: Int
    let locations: [Location]
}

struct Location {
//    let bearing: String
    let lat: Float
    let lng: Float
}