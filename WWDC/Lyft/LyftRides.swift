//
//  LyftRides.swift
//  SFParties
//
//  Created by Genady Okrain on 5/10/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

//  Examples:
//
//  Lyft.requestRide(requestRideQuery: RequestRideQuery(originLat: 34.305658, originLng: -118.8893667, originAddress: "123 Main St, Anytown, CA", destinationLat: 36.9442175, destinationLng: -123.8679133, destinationAddress: "123 Main St, Anytown, CA", rideType: .Lyft)) { result, response, error in
//
//  }
//
//  Lyft.requestRideDetails(rideId: "123456789") { result, response, error in
//
//  }
//
//  Lyft.cancelRide(rideId: "123456789") { result, response, error in
//
//  }

import Foundation

extension Lyft {
    static func requestRide(requestRideQuery requestRideQuery: RequestRideQuery, completionHandler: ((result: Ride?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.POST, path: "/rides", params: [
            "origin": ["lat": "\(requestRideQuery.origin.lat)", "lng": "\(requestRideQuery.origin.lng)", "address": "\(requestRideQuery.origin.address)"],
            "destination": ["lat": "\(requestRideQuery.destination.lat)", "lng": "\(requestRideQuery.destination.lng)", "address": "\(requestRideQuery.destination.address)"],
            "ride_type": requestRideQuery.rideType.rawValue,
            "primetime_confirmation_token": requestRideQuery.primetimeConfirmationToken]
        ) { response, error in
            if let response = response {
                if let passenger = response["passenger"] as? [String: AnyObject],
                    firstName = passenger["first_name"] as? String,
                    origin = response["origin"] as? [String: AnyObject],
                    originAddress = origin["address"] as? String,
                    originLat = origin["lat"] as? Float,
                    originLng = origin["lng"] as? Float,
                    destination = response["destination"] as? [String: AnyObject],
                    destinationAddress = destination["address"] as? String,
                    destinationLat = destination["lat"] as? Float,
                    destinationLng = destination["lng"] as? Float,
                    status = response["status"] as? String,
                    rideId = response["ride_id"] as? String  {
                    let origin = Address(lat: originLat, lng: originLng, address: originAddress)
                    let destination = Address(lat: destinationLat, lng: destinationLng, address: destinationAddress)
                    let passenger = Passenger(firstName: firstName)
                    let ride = Ride(rideId: rideId, status: status, origin: origin, destination: destination, passenger: passenger)
                    completionHandler?(result: ride, response: response, error: nil)
                } else {
                    completionHandler?(result: nil, response: response, error: error)
                }
            }
        }
    }

    static func requestRideDetails(rideId rideId: String, completionHandler: ((result: Ride?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.GET, path: "/rides/\(rideId)", params: nil) { response, error in
            if let response = response {
                if let passenger = response["passenger"] as? [String: AnyObject],
                    firstName = passenger["first_name"] as? String,
                    origin = response["origin"] as? [String: AnyObject],
                    originAddress = origin["address"] as? String,
                    originLat = origin["lat"] as? Float,
                    originLng = origin["lng"] as? Float,
                    destination = response["destination"] as? [String: AnyObject],
                    destinationAddress = destination["address"] as? String,
                    destinationLat = destination["lat"] as? Float,
                    destinationLng = destination["lng"] as? Float,
                    status = response["status"] as? String,
                    rideId = response["ride_id"] as? String  {
                    let origin = Address(lat: originLat, lng: originLng, address: originAddress)
                    let destination = Address(lat: destinationLat, lng: destinationLng, address: destinationAddress)
                    let passenger = Passenger(firstName: firstName)
                    let ride = Ride(rideId: rideId, status: status, origin: origin, destination: destination, passenger: passenger)
                    completionHandler?(result: ride, response: response, error: nil)
                } else {
                    completionHandler?(result: nil, response: response, error: error)
                }
            }
        }
    }

    static func cancelRide(rideId rideId: String, cancelConfirmationToken: String? = nil, completionHandler: ((result: CancelConfirmationToken?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.POST, path: "/rides/\(rideId)/cancel", params: (cancelConfirmationToken != nil) ? ["cancel_confirmation_token": cancelConfirmationToken!] : nil) { response, error in
            if let response = response {
                if let amount = response["amount"] as? Int,
                    currency = response["currency"] as? String,
                    token = response["token"] as? String,
                    tokenDuration = response["token_duration"] as? Int {
                    completionHandler?(result: CancelConfirmationToken(amount: amount, currency: currency, token: token, tokenDuration: tokenDuration), response: response, error: nil)
                } else {
                    completionHandler?(result: nil, response: response, error: error)
                }
            }
        }
    }

    static func rateAndTipRide(rideId rideId: String, rateAndTipQuery: RateAndTipQuery, completionHandler: ((result: CancelConfirmationToken?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.POST, path: "/rides/\(rideId)/rating", params: [
            "rating": rateAndTipQuery.rating,
            "tip": ["amount": rateAndTipQuery.tip.amount, "currency": rateAndTipQuery.tip.currency],
            "feedback": rateAndTipQuery.feedback])
        { response, error in
            completionHandler?(result: nil, response: response, error: error)
        }
    }
}
