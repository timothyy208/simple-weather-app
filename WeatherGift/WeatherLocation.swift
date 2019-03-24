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
    
    struct HourlyForecast {
        var hourlyTime: Double
        var hourlyTemperature: Double
        var hourlyPrecipProb: Double
        var hourlyIcon: String
    }
    
    struct DailyForecast {
        var dailyMaxTemp: Double
        var dailyMinTemp: Double
        var dailySummary: String
        var dailyDate: Double
        var dailyIcon: String
        
    }
    
    var name = ""
    var coordinates = ""
    var temperature = "--"
    var summary = ""
    var icon = ""
    var currentTime = 0.0
    var timeZone = ""
    var dailyForecastArray = [DailyForecast]()
    var hourlyForecastArray = [HourlyForecast]()
    
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
                    //print(roundedTemp)
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

                let dailyDataArray = json["daily"]["data"]
                self.dailyForecastArray = []
                let days = min(7, dailyDataArray.count-1)
                for day in 1...days {
                    let maxTemp = json["daily"]["data"][day]["temperatureHigh"].doubleValue
                    let minTemp = json["daily"]["data"][day]["temperatureLow"].doubleValue
                    let dateValue = json["daily"]["data"][day]["time"].doubleValue
                    let icon = json["daily"]["data"][day]["icon"].stringValue
                    let dailySummary = json["daily"]["data"][day]["summary"].stringValue
                    //print(dailySummary)
                    let newDailyForecast = DailyForecast(dailyMaxTemp: maxTemp, dailyMinTemp: minTemp, dailySummary: dailySummary, dailyDate: dateValue, dailyIcon: icon)
                    self.dailyForecastArray.append(newDailyForecast)
                }
                
                let hourlyDataArray = json["hourly"]["data"]
                self.hourlyForecastArray = []
                let hours = min(24, hourlyDataArray.count-1)
                for hour in 1...hours {
                    let hourlyTime = json["hourly"]["data"][hour]["time"].doubleValue
                    let hourlyTemperature = json["hourly"]["data"][hour]["temperature"].doubleValue
                    let hourlyPrecipProb = json["hourly"]["data"][hour]["precipProbability"].doubleValue
                    let hourlyIcon = json["hourly"]["data"][hour]["icon"].stringValue
                    let newHourlyForecast = HourlyForecast(hourlyTime: hourlyTime, hourlyTemperature: hourlyTemperature, hourlyPrecipProb: hourlyPrecipProb, hourlyIcon: hourlyIcon)
                    self.hourlyForecastArray.append(newHourlyForecast)
                }
                
            case .failure(let error):
                print(error)
            }
            completed()
        }
    }
}
