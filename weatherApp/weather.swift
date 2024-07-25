//
//  weather.swift
//  weatherApp
//
//  Created by 조영민 on 6/6/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Main: Decodable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
