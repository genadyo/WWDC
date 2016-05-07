//
//  ServerManager.swift
//  SFParties
//
//  Created by Genady Okrain on 3/3/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

class ServerManager {
    static func load(url: String, completion: ((results: ([[Party]], [Banner])?, JSON: AnyObject?) -> Void)?) {
        if let url = NSURL(string: url) {
            let request = NSURLRequest(URL: url, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            let task = session.dataTaskWithRequest(request) { data, _, _ in
                dispatch_async(dispatch_get_main_queue()) {
                    if let data = data {
                        do {
                            let response = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                            completion?(results: processJSON(response), JSON: response)
                        } catch {
                            completion?(results: nil, JSON: nil)
                        }
                    } else {
                        completion?(results: nil, JSON: nil)
                    }
                }
            }
            task.resume()
        } else {
            completion?(results: nil, JSON: nil)
        }
    }

    static func hourForDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.stringFromDate(date)
    }

    static func dateForString(string: String) -> NSDate? {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(string)
    }

    static func dateForDate(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.stringFromDate(date)
    }

    static func processJSON(JSON: AnyObject?) -> ([[Party]], [Banner]) {
        var allParties = [Party]()
        if let json = JSON as? [String: AnyObject], parties = json["parties"] as? [AnyObject] {
            for party in parties {
                if let p = party as? [String: AnyObject],
                    objectId = p["objectId"] as? String,
                    icon = p["icon"] as? String, iconURL = NSURL(string: icon),
                    logo = p["logo"] as? String, logoURL = NSURL(string: logo),
                    title = p["title"] as? String,
                    startD = p["startDate"] as? String, startDate = dateForString(startD),
                    endD = p["endDate"] as? String, endDate = dateForString(endD),
                    details = p["details"] as? String,
                    address1 = p["address1"] as? String,
                    address2 = p["address2"] as? String,
                    address3 = p["address3"] as? String,
                    latitude = p["latitude"] as? Double,
                    longitude = p["longitude"] as? Double,
                    url = p["url"] as? String, URL = NSURL(string: url)
                {
                    allParties.append(Party(objectId: objectId, icon: iconURL, logo: logoURL, title: title, startDate: startDate, endDate: endDate, details: details, address1: address1, address2: address2, address3: address3, latitude: latitude, longitude: longitude, url: URL, date: dateForDate(startDate), hours: hourForDate(startDate) + " to " + hourForDate(endDate)))
                }
            }
        }

        allParties.sortInPlace({ $0.startDate.compare($1.startDate) == NSComparisonResult.OrderedAscending })

        var lastDate: NSDate?
        var partiesForDay = [[Party]]()
        var parties = [Party]()
        for party in allParties {
            if let lastDate = lastDate where NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!.isDate(lastDate, inSameDayAsDate: party.startDate) == false {
                partiesForDay.append(parties.sort({ $0.title < $1.title }))
                parties = []
            }
            parties.append(party)
            lastDate = party.startDate
        }
        partiesForDay.append(parties.sort({ $0.title < $1.title }))

        var banners = [Banner]()
        if let json = JSON as? [String: AnyObject], bns = json["banners"] as? [AnyObject] {
            for banner in bns {
                if let b = banner as? [String: AnyObject],
                    imageurl = b["\(Int(UIScreen.mainScreen().bounds.width))"] as? String, imageURL = NSURL(string: imageurl),
                    url = b["url"] as? String, URL = NSURL(string: url),
                    objectId = b["objectId"] as? String
                {
                    banners.append(Banner(objectId: objectId, imageURL: imageURL, url: URL))
                }
            }
        }

        return (partiesForDay, banners)
    }
}