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

enum StatusType: String {
    case Pending = "pending"
    case Accepted = "accepted"
    case Arrived = "arrived"
    case PickedUp = "pickedUp"
    case DroppedOff = "droppedOff"
    case Canceled = "canceled"
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
    let startLat: Float
    let startLng: Float
    let endLat: Float
    let endLng: Float
    let rideType: RideType

    init(startLat: Float, startLng: Float, endLat: Float = 0, endLng: Float = 0, rideType: RideType = .All) {
        self.startLat = startLat
        self.startLng = startLng
        self.endLat = endLat
        self.endLng = endLng
        self.rideType = rideType
    }
}

struct NearbyDriversQuery {
    let lat: Float
    let lng: Float
}

struct RequestRideQuery {
    let origin: Address
    let destination: Address
    let rideType: RideType
    let primetimeConfirmationToken: String

    init(originLat: Float, originLng: Float, originAddress: String, destinationLat: Float, destinationLng: Float, destinationAddress: String, rideType: RideType, primetimeConfirmationToken: String = "") {
        self.origin = Address(lat: originLat, lng: originLng, address: originAddress)
        self.destination = Address(lat: destinationLat, lng: destinationLng, address: destinationAddress)
        self.rideType = rideType
        self.primetimeConfirmationToken = primetimeConfirmationToken
    }
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

struct ETAEstimate {
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
    let firstName: String
    let phoneNumber: String
    let rating: Float
    let imageURL: String
    let locations: [Location]

    init(locations: [Location] = [], firstName: String = "", phoneNumber: String = "", rating: Float = 0, imageURL: String = "") {
        self.firstName = firstName
        self.phoneNumber = phoneNumber
        self.rating = rating
        self.imageURL = imageURL
        self.locations = locations
    }
}

struct Location {
//    let bearing: String
    let lat: Float
    let lng: Float
}

struct Address {
    let lat: Float
    let lng: Float
    let address: String
    let ETASeconds: Int
    let time: String

    init(lat: Float, lng: Float, address: String = "", ETASeconds: Int = 0, time: String = "") {
        self.lat = lat
        self.lng = lng
        self.address = address
        self.ETASeconds = ETASeconds
        self.time = time
    }
}

struct Passenger {
    let firstName: String
//    let lastName: String
//    let phoneNumber: String
//    let imageURL: String
//    let rating: String
}

struct Ride {
    let rideId: String
    let status: StatusType
    let origin: Address
    let destination: Address
    let passenger: Passenger
}

struct CancelConfirmationToken {
    let amount: Int
    let currency: String
    let token: String
    let tokenDuration: Int
}

struct Tip {
    let amount: Int
    let currency: String

    init(amount: Int = 0, currency: String = "") {
        self.amount = amount
        self.currency = currency
    }
}

struct RateAndTipQuery {
    let rating: Int
    let tip: Tip
    let feedback: String

    init(rating: Int, tipAmount: Int = 0, tipCurrency: String = "", feedback: String = "") {
        self.rating = rating
        self.tip = Tip(amount: tipAmount, currency: tipCurrency)
        self.feedback = feedback
    }
}

struct Price {
    let amount: Int
    let currency: String
    let description: String
}

struct LineItem {
    let amount: Int
    let currency: String
    let type: String
}

struct Charge {
    let amount: Int
    let currency: String
    let paymentMethod: String
}

struct RideReceipt {
    let rideId: String
    let price: Price
    let lineItems: [LineItem]
    let charge: [Charge]
    let requestedAt: String
}

struct RidesHistoryQuery {
    let startTime: String
    let endTime: String
    let limit: String

    init(startTime: String, endTime: String = "", limit: String = "") {
        self.startTime = startTime
        self.endTime = endTime
        self.limit = limit
    }
}

struct Vehicle {
    let make: String
    let model: String
    let licensePlate: String
    let color: String
    let imageURL: String
}

struct RideHistory {
    let rideId: String
    let status: StatusType
    let rideType: RideType
    let passenger: Passenger
    let driver: Driver
    let vehicle: Vehicle
    let origin: Address
    let destination: Address
    let pickup: Address
    let dropoff: Address
    let location: Address
    let primetimePercentage: String
    let price: Price
    let lineItems: [LineItem]
    let ETAseconds: Int
    let requestedAt: String
}
