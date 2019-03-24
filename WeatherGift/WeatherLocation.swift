//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Timothy Yang on 3/18/19.
//  Copyright © 2019 Timothy Yang. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherLocation {
    var name = ""
    var coordinates = ""
    var temperature = "--"
    var summary = ""
    var icon = ""
    var currentTime = 0.0
    var timeZone = ""
    
    
    func getWeather(completed: @escaping () -> ()){
        let weatherURL = urlBase + apiKey + coordinates
        print(weatherURL)
        Alamofire.request(weatherURL).responseJSON {response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if let jsonTemperature = json["currently"]["temperature"].double {
                    let roundedTemp = String(format: "%3.f", jsonTemperature)
                    self.temperature = roundedTemp + "°"
                    print(roundedTemp)
                } else {
                    print("Didnt get temp")
                }
                
                if let jsonSummary = json["daily"]["summary"].string {
                    self.summary = jsonSummary
                } else {
                    print("didnt get summary")
                }
                
                if let jsonIcon = json["daily"]["icon"].string {
                    self.icon = jsonIcon
                } else {
                    print("didnt get icon")
                }
                
                if let timeZone = json["timezone"].string {
                    //print("timezone for \(self.name) is \(timeZone)")
                    self.timeZone = timeZone
                } else {
                    print("didnt get timezone")
                }
                
                if let time = json["currently"]["time"].double{
                    self.currentTime = time
                    //print("time for \(self.name) is \(time)")
                } else {
                    print("didnt get time")
                }
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
}
