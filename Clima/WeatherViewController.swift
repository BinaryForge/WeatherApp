//  ViewController.swift
//  WeatherApp
//
//  Created by Alexey Kuznetsov

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate{
    
    //Constants for Alamofire
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "34aec5bbeee8f6012899f778f3130be8"
    
    //CLLocationManager Object
    //WeatherDataModel Object
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    //Grabbing weatherData
    //method: .get (HTTP method)
    //respone is package with info
    //.REQUEST requests the information
    func getWeatherData(url: String, parameters: [String:String]){
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                let weatherJSON: JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
            }else{
                //print("No internet connection")
                self.cityLabel.text = "Unable to connect"
            }
        }
    }
    
    //updateWeatherData using JSON
    func updateWeatherData(json: JSON){
        if let tempResult = json["main"]["temp"].double {
            weatherDataModel.temperature = Int(tempResult * 9/5 - 459.67)
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather not found"
        }
    }
    
    //updateUIWithWeatherData
    //Updates ViewController labels and images
    //in accordance with data from weatherDataModel
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    //Location Manager grabbing location value
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude  = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String : String] = ["lat": latitude, "lon" : longitude, "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //LocationManager notifies if error occurs
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Can't grab location"
    }
    
    //Change City Delegate
    func userInputCity(city: String) {
        let params: [String: String] = ["q":city, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    //PrepareForSegue ensure we choose right ViewController for information grabbing.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
    
}


