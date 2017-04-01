//
//  ServerManager.swift
//  SFParties
//
//  Created by Genady Okrain on 3/3/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

import Foundation

class ServerManager {
    static func load(_ url: String, completion: ((_ results: (parties: [[Party]], banners: [Banner], promotion: Bool)?, _ JSON: AnyObject?) -> Void)?) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: request, completionHandler: { data, _, _ in
                DispatchQueue.main.async {
                    if let data = data {
                        do {
                            let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                            completion?(processJSON(response), response)
                        } catch {
                            completion?(nil, nil)
                        }
                    } else {
                        completion?(nil, nil)
                    }
                }
            }) 
            task.resume()
        } else {
            completion?(nil, nil)
        }
    }

    static func hourForDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }

    static func dateForString(_ string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: string)
    }

    static func dateForDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: date)
    }

    static func processJSON(_ JSON: AnyObject?) -> (parties: [[Party]], banners: [Banner], promotion: Bool) {
        var allParties = [Party]()
        if let json1 = JSON as? [String: AnyObject], let parties = json1["parties"] as? [AnyObject] {
            for party in parties {
                if let p = party as? [String: AnyObject],
                    let objectId = p["objectId"] as? String,
                    let icon = p["icon"] as? String, let iconURL = URL(string: icon),
                    let logo = p["logo"] as? String, let logoURL = URL(string: logo),
                    let title = p["title"] as? String,
                    let startD = p["startDate"] as? String, let startDate = dateForString(startD),
                    let endD = p["endDate"] as? String, let endDate = dateForString(endD),
                    let details = p["details"] as? String,
                    let address1 = p["address1"] as? String,
                    let address2 = p["address2"] as? String,
                    let address3 = p["address3"] as? String,
                    let latitude = p["latitude"] as? Double,
                    let longitude = p["longitude"] as? Double,
                    let url = p["url"] as? String, let u = URL(string: url)
                {
                    allParties.append(Party(objectId: objectId, icon: iconURL, logo: logoURL, title: title, startDate: startDate, endDate: endDate, details: details, address1: address1, address2: address2, address3: address3, latitude: latitude, longitude: longitude, url: u, date: dateForDate(startDate), hours: hourForDate(startDate) + " to " + hourForDate(endDate)))
                }
            }
        }

        allParties.sort(by: { $0.startDate.compare($1.startDate) == .orderedSame ? $0.title < $1.title : $0.startDate.compare($1.startDate) == .orderedAscending })

        var lastDate: Date?
        var partiesForDay = [[Party]]()
        var parties = [Party]()
        for party in allParties {
            if let lastDate = lastDate, Calendar(identifier: Calendar.Identifier.gregorian).isDate(lastDate, inSameDayAs: party.startDate) == false {
                partiesForDay.append(parties)
                parties = []
            }
            parties.append(party)
            lastDate = party.startDate
        }
        partiesForDay.append(parties)

        var banners = [Banner]()
        if let json2 = JSON as? [String: AnyObject], let bns = json2["banners"] as? [AnyObject] {
            for banner in bns {
                if let b = banner as? [String: AnyObject],
                    let imageurl = b["\(Int(UIScreen.main.bounds.width))"] as? String, let imageURL = URL(string: imageurl),
                    let url = b["url"] as? String, let u = URL(string: url),
                    let objectId = b["objectId"] as? String
                {
                    banners.append(Banner(objectId: objectId, imageURL: imageURL, url: u))
                }
            }
        }

        var promotion = false
        if let json = JSON as? [String: AnyObject], let p = json["promotion"] as? Bool {
            promotion = p
        }

        return (partiesForDay, banners, promotion)
    }
}
