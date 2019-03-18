//
//  WeatherLocation.swift
//  WeatherGift
//
//  Created by Timothy Yang on 3/18/19.
//  Copyright © 2019 Timothy Yang. All rights reserved.
//

import Foundation
import Alamofire

class WeatherLocation {
    var name = ""
    var coordinates = ""
    
    func getWeather(){
        let weatherURL = urlBase + apiKey + coordinates
        print(weatherURL)
        Alamofire.request(weatherURL).responseJSON {response in
            print(response)
        }
    }
}
