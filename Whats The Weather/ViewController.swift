//
//  ViewController.swift
//  Whats The Weather
//
//  Created by Cody Deckard on 11/18/18.
//  Copyright © 2018 Cody Deckard. All rights reserved.
//

import UIKit
import SwiftSoup


class ViewController: UIViewController {
    
    
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var weatherOutput: UILabel!
    @IBOutlet weak var weatherTitle: UILabel!
    
    var state: State? {
        didSet {
            guard let state = state else { return }
            switch state {
            case .darkBackground:
                weatherOutput.textColor = .white
                weatherTitle.textColor = .white
            case .loading:
                weatherOutput.text = "Loading Weather Data..."
            case .lightBackground:
                weatherOutput.textColor = .black
                weatherTitle.textColor = .black
            
            }
        }
    }
    
    var weatherType: Weather? {
        didSet {
            guard let weatherType = weatherType else {return}
            switch weatherType {
            case .rain:
                weatherImage.image = UIImage(named: "rain")
                self.state = .darkBackground
            case .clear:
                weatherImage.image = UIImage(named: "clear")
                self.state = .darkBackground
            case .snow:
                weatherImage.image = UIImage(named: "snow")
                self.state = .darkBackground
            case .lightening:
                weatherImage.image = UIImage(named: "lightening")
                self.state = .darkBackground
            case .cloudy:
                weatherImage.image = UIImage(named: "cloudy")
                self.state = .darkBackground
            case .sun:
                weatherImage.image = UIImage(named: "sunny")
                self.state = .lightBackground
            case .defaultWeather:
                weatherImage.image = UIImage(named: "cloudy")
                self.state = .lightBackground
            }
        }
    }
    
   

    

    @IBAction func retrieveWeather(_ sender: Any) {
        
        guard var city = cityTextField.text else {
            weatherOutput.text = "Please enter a city above"
            return
        }
        
        city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if city.contains(" ") {
            city = city.replacingOccurrences(of: " ", with: "-")
        }
        
        
        guard let url = URL(string: "https://www.weather-forecast.com/locations/\(city)/forecasts/latest") else {
            print("Invalid URL")
            
            self.update(text: "Error! Unable to determine city.")
       
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {
            data, response, error in
                
            if let _ = error {
                self.update(text: "Error! Unable to download weather data.")
                return
            }
                
                
            guard let dataResponse = data else {
                print("No Data Received")
                return
            }
                
            let dataString = NSString(data: dataResponse, encoding: String.Encoding.utf8.rawValue)!
                    
            var weatherData = ""
            do {
                
                let doc: Document = try SwiftSoup.parse(dataString as String)
                let weather = try doc.select("p.b-forecast__table-description-content").first()?.text() ?? "Unable to retrieve weather data"
                print(weather)
                weatherData = weather
                
            } catch {
                print("Errors occurred!!")
                    
            }
            
            self.update(text: weatherData)

        }
        
        self.state = .loading
        task.resume()
        
    }
    
    func update(text txt: String) {
        DispatchQueue.main.sync {
            weatherOutput.text = txt
            
            if txt.lowercased().contains("rain") {
                weatherType = .rain
            } else if txt.lowercased().contains("sun") {
                weatherType = .sun
            } else if txt.lowercased().contains("snow") {
                weatherType = .snow
            } else if txt.lowercased().contains("lightening") {
                weatherType = .lightening
            } else if txt.lowercased().contains("clear") {
                weatherType = .clear
            } else if txt.lowercased().contains("cloud") {
                weatherType = .cloudy
            } else {
                weatherType = .defaultWeather
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        weatherOutput.text = nil
    }


}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

extension ViewController {
    
    enum State {
        case lightBackground
        case darkBackground
        case loading
    }
    
    enum Weather {
        case clear
        case sun
        case rain
        case lightening
        case cloudy
        case snow
        case defaultWeather
    }
    
}


