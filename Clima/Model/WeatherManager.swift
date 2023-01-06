//
//  WeatherManager.swift
//  Clima
//
//  Created by joao cardoso on 04/01/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=72c63f0e6daceb2d5c3bddb4aebff9ac&units=metric"

    var delegate: WeatherManagerDelegate?

    func fetchWeather(cityName: String) {
        let locationUrlString = "\(weatherUrl)&q=\(cityName)"

        performRequest(with: locationUrlString)
    }

    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let locationUrlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"

        performRequest(with: locationUrlString)
    }

    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, _, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }

    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name

            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
