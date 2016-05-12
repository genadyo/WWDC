//
//  LyftAvailability.swift
//  SFParties
//
//  Created by Genady Okrain on 5/10/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

//  Examples:
//
//  Lyft.requestRideTypes(rideTypesQuery: RideTypesQuery(lat: 37.7833, lng: -122.4167)) { result, response, error in
//
//  }
//
//  Lyft.requestETA(etaQuery: ETAQuery(lat: 37.7833, lng: -122.4167)) { result, response, error in
//
//  }
//
//  Lyft.requestCost(costQuery: CostQuery(startLat: 37.7833, startLng: -122.4167, endLat: 37.7972, endLng: -122.4533)) { result, response, error in
//
//  }
//
//  Lyft.requestNearbyDrivers(nearbyDriversQuery: NearbyDriversQuery(lat: 37.7789, lng: -122.45690)) { result, response, error in
//
//  }

import Foundation

extension Lyft {
    static func requestRideTypes(rideTypesQuery rideTypesQuery: RideTypesQuery, completionHandler: ((result: [RideTypesResponse]?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.GET, path: "/ridetypes", params: ["lat": "\(rideTypesQuery.lat)", "lng": "\(rideTypesQuery.lng)", "ride_type": rideTypesQuery.rideType.rawValue]) { response, error in
            var rideTypesResponse = [RideTypesResponse]()
            if let response = response {
                if let rideTypes = response["ride_types"] as? [AnyObject] {
                    for r in rideTypes {
                        if let r = r as? [String: AnyObject],
                            pricingDetails = r["pricing_details"] as? [String: AnyObject],
                            baseCharge = pricingDetails["base_charge"] as? Int,
                            costPerMile = pricingDetails["cost_per_mile"] as? Int,
                            costPerMinute = pricingDetails["cost_per_minute"] as? Int,
                            costMinimum = pricingDetails["cost_minimum"] as? Int,
                            trustAndService = pricingDetails["trust_and_service"] as? Int,
                            currency = pricingDetails["currency"] as? String ,
                            cancelPenaltyAmount = pricingDetails["cancel_penalty_amount"] as? Int,
                            rType = r["ride_type"] as? String,
                            rideType = RideType(rawValue: rType),
                            displayName = r["display_name"] as? String,
                            imageURL = r["image_url"] as? String,
                            seats = r["seats"] as? Int {
                            let pricingDetails = PricingDetails(baseCharge: baseCharge,
                                                                costPerMile: costPerMile,
                                                                costPerMinute: costPerMinute,
                                                                costMinimum: costMinimum,
                                                                trustAndService: trustAndService,
                                                                currency: currency,
                                                                cancelPenaltyAmount: cancelPenaltyAmount)
                            rideTypesResponse.append(
                                RideTypesResponse(
                                    pricingDetails: pricingDetails,
                                    rideType: rideType,
                                    displayName: displayName,
                                    imageURL: imageURL,
                                    seats: seats
                                )
                            )
                        }
                    }
                }
            }
            completionHandler?(result: rideTypesResponse, response: response, error: error)
        }
    }

    static func requestETA(etaQuery etaQuery: ETAQuery, completionHandler: ((result: [ETAEstimate]?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.GET, path: "/eta", params: ["lat": "\(etaQuery.lat)", "lng": "\(etaQuery.lng)", "ride_type": etaQuery.rideType.rawValue]) { response, error in
            var etaEstimatesResponse = [ETAEstimate]()
            if let response = response {
                if let etaEstimates = response["eta_estimates"] as? [AnyObject] {
                    for e in etaEstimates {
                        if let e = e as? [String: AnyObject],
                            displayName = e["display_name"] as? String,
                            rType = e["ride_type"] as? String,
                            rideType = RideType(rawValue: rType),
                            etaSeconds = e["eta_seconds"] as? Int {
                            etaEstimatesResponse.append(
                                ETAEstimate(
                                    displayName: displayName,
                                    rideType: rideType,
                                    etaSeconds: etaSeconds
                                )
                            )
                        }
                    }
                }
            }
            completionHandler?(result: etaEstimatesResponse, response: response, error: error)
        }
    }

    static func requestCost(costQuery costQuery: CostQuery, completionHandler: ((result: [CostEstimate]?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.GET, path: "/cost", params: [
            "start_lat": "\(costQuery.startLat)",
            "start_lng": "\(costQuery.startLng)",
            "end_lat": costQuery.endLat == 0 ? "" : "\(costQuery.endLat)",
            "end_lng": costQuery.endLng == 0 ? "" : "\(costQuery.endLng)",
            "ride_type": costQuery.rideType.rawValue]
        ) { response, error in
            var costEstimateResponse = [CostEstimate]()
            if let response = response {
                if let costEstimates = response["cost_estimates"] as? [AnyObject] {
                    for c in costEstimates {
                        if let c = c as? [String: AnyObject],
                            rType = c["ride_type"] as? String,
                            rideType = RideType(rawValue: rType),
                            displayName = c["display_name"] as? String,
                            currency = c["currency"] as? String,
                            estimatedCostCentsMin = c["estimated_cost_cents_min"] as? Int,
                            estimatedCostCentsMax = c["estimated_cost_cents_max"] as? Int,
                            estimatedDurationSeconds = c["estimated_duration_seconds"] as? Int,
                            estimatedDistanceMiles = c["estimated_distance_miles"] as? Float,
                            primetimeConfirmationToken = c["primetime_confirmation_token"] as? String?,
                            primetimePercentage = c["primetime_percentage"] as? String {
                            costEstimateResponse.append(
                                CostEstimate(
                                    rideType: rideType,
                                    displayName: displayName,
                                    currency: currency,
                                    estimatedCostCentsMin: estimatedCostCentsMin,
                                    estimatedCostCentsMax: estimatedCostCentsMax,
                                    estimatedDurationSeconds: estimatedDurationSeconds,
                                    estimatedDistanceMiles: estimatedDistanceMiles,
                                    primetimeConfirmationToken: primetimeConfirmationToken,
                                    primetimePercentage: primetimePercentage
                                )
                            )
                        }
                    }
                }
            }
            completionHandler?(result: costEstimateResponse, response: response, error: error)
        }
    }

    static func requestNearbyDrivers(nearbyDriversQuery nearbyDriversQuery: NearbyDriversQuery, completionHandler: ((result: [NearbyDrivers]?, response: [String: AnyObject]?, error: NSError?) -> ())?) {
        request(.GET, path: "/drivers", params: ["lat": "\(nearbyDriversQuery.lat)", "lng": "\(nearbyDriversQuery.lng)"]) { response, error in
            var nearbyDriversResponse = [NearbyDrivers]()
            if let response = response {
                if let nearbyDrivers = response["nearby_drivers"] as? [AnyObject] {
                    for n in nearbyDrivers {
                        if let driver = n["drivers"] as? [AnyObject] {
                            var drivers = [Driver]()
                            for d in driver {
                                var locs = [Location]()
                                if let locations = d["locations"] as? [AnyObject] {
                                    for l in locations {
                                        if let l = l as? [String: AnyObject], lat = l["lat"] as? Float, lng = l["lng"] as? Float {
                                            locs.append(Location(lat: lat, lng: lng))
                                        }
                                    }
                                }
                                drivers.append(Driver(locations: locs))
                            }
                            if let rType = n["ride_type"] as? String,
                                rideType = RideType(rawValue: rType) {
                                nearbyDriversResponse.append(NearbyDrivers(drivers: drivers, rideType: rideType))
                            }
                        }
                    }
                }
            }
            completionHandler?(result: nearbyDriversResponse, response: response, error: error)
        }
    }
}
