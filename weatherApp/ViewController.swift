//
//  ViewController.swift
//  weatherApp
//
//  Created by 조영민 on 6/6/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    // 받아온 데이터를 저장할 프로퍼티
    var weather: Weather?
    var main: Main?
    var name: String?
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            showLocationAccessDeniedAlert()
        @unknown default:
            fatalError("Unknown CLLocationManager authorization status")
        }
    }
    
    private func showLocationServicesDisabledAlert() {
        let alert = UIAlertController(title: "위치 서비스 비활성화", message: "위치 서비스를 활성화해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showLocationAccessDeniedAlert() {
        let alert = UIAlertController(title: "위치 접근 거부됨", message: "위치 접근을 허용해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            // 위치 업데이트 중지
            locationManager.stopUpdatingLocation()
            
            // WeatherService를 사용하여 날씨 데이터 가져오기
            WeatherService().getWeather(latitude: latitude, longitude: longitude) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self.weather = weatherResponse.weather.first
                        self.main = weatherResponse.main
                        self.name = weatherResponse.name
                        self.setWeatherUI()
                    }
                case .failure(let error):
                    print("Error fetching weather data: \(error)")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    private func setWeatherUI() {
        guard let urlString = self.weather?.icon,
              let url = URL(string: "https://openweathermap.org/img/wn/\(urlString)@2x.png") else {
            return
        }
        
        // URLSession을 사용한 비동기 이미지 로딩
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.iconImageView.image = UIImage(data: data)
            }
        }
        task.resume()
        
        // 섭씨 변환 로직은 이전과 동일하게 유지
        let tempCelsius = main!.temp - 273.15
        let maxTempCelsius = main!.temp_max - 273.15
        let minTempCelsius = main!.temp_min - 273.15
        
        DispatchQueue.main.async {
            self.tempLabel.text = String(format: "현재: %.1f°C", tempCelsius)
            self.maxTempLabel.text = String(format: "최고 %.1f°C", maxTempCelsius)
            self.minTempLabel.text = String(format: "최저 %.1f°C", minTempCelsius)
        }
    }
}

private var apiKey: String {
    get {
        // 생성한 .plist 파일 경로 불러오기
        guard let filePath = Bundle.main.path(forResource: "KeyList", ofType: "plist") else {
            fatalError("Couldn't find file 'KeyList.plist'.")
        }
        
        // .plist를 딕셔너리로 받아오기
        let plist = NSDictionary(contentsOfFile: filePath)
        
        // 딕셔너리에서 값 찾기
        guard let value = plist?.object(forKey: "OPENWEATHERMAP_KEY") as? String else {
            fatalError("Couldn't find key 'OPENWEATHERMAP_KEY' in 'KeyList.plist'.")
        }
        return value
    }
}
