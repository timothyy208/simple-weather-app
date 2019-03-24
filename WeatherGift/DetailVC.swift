//
//  DetailVC.swift
//  WeatherGift
//
//  Created by Timothy Yang on 3/10/19.
//  Copyright © 2019 Timothy Yang. All rights reserved.
//

import UIKit
import CoreLocation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM dd, y"
    return dateFormatter
}()

class DetailVC: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var currentPage = 0
    var locationsArray = [WeatherLocation]()
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if currentPage != 0 {
            locationsArray[currentPage].getWeather {
                self.updateUserInterface()
            }
          
        }
        
    } 
    
    override func viewDidAppear(_ animated: Bool) {
        if currentPage == 0 {
            getLocation()
        }
    }
    
    func updateUserInterface() {
        let location = locationsArray[currentPage]
        locationLabel.text = location.name
        //let dateString = formatTimeForTimeZone(unixDate: location.currentTime, timeZone: location.timeZone)
        let dateString = location.currentTime.format(timeZone: location.timeZone, dateFormatter: dateFormatter)
        dateLabel.text = dateString
        temperatureLabel.text = location.temperature
        summaryLabel.text = location.summary
        currentImage.image = UIImage(named: location.icon)
        tableView.reloadData()
    }
    
//    func formatTimeForTimeZone(unixDate: TimeInterval, timeZone: String) -> String{
//        let usableDate = Date(timeIntervalSince1970: unixDate)
//        dateFormatter.timeZone = TimeZone(identifier: timeZone)
//        let dateString = dateFormatter.string(from: usableDate)
//        return dateString
//    }

}

extension DetailVC: CLLocationManagerDelegate {
    func getLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
    
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            print("access denied")
        case .restricted:
            print("access denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let geoCoder = CLGeocoder()
        var place = " "
        currentLocation = locations.last
        let lat = currentLocation.coordinate.latitude
        let lon = currentLocation.coordinate.longitude
        let currCoord = "\(lat),\(lon)"
        //print(currCoord)
        //dateLabel.text = currCoord
        geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: {
            placemarks, error in
            if placemarks != nil {
                let placemark = placemarks!.last
                place = (placemark?.name)!
            } else {
                print("error retrieving place")
                place = "Unknown Weather Location"
            }
            self.locationsArray[0].name = place
            self.locationsArray[0].coordinates = currCoord
            self.locationsArray[0].getWeather() {
            self.updateUserInterface()
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("failed to get user location")
    }
}

extension DetailVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray[currentPage].dailyForecastArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayWeatherCell", for: indexPath) as! DayWeatherCell
        let dailyForecast = locationsArray[currentPage].dailyForecastArray[indexPath.row]
        let timeZone = locationsArray[currentPage].timeZone
        cell.update(with: dailyForecast, timeZone: timeZone)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
