//
//  ViewController.swift
//  weather
//
//  Created by Moritz Leitner on 05.08.18.
//  Copyright © 2018 Sternwarte St. Ottilien. All rights reserved.
//

import UIKit
import SwiftyJSON

class ViewController: UIViewController {
    
    //MARK: Properties
    
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var allskyImage: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //parse json
        guard let url = URL(string: "http://api.sternwarte-ottilien.de/weather/current/") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                let json = JSON(jsonResponse)
                let urlAllSky =  json["allSkyImage"].stringValue
                print(urlAllSky)
                
                //URL containing the image
                let URL_IMAGE = URL(string: urlAllSky)
                let session = URLSession(configuration: .default)
                
                //display image: creating a dataTask
                let getImageFromUrl = session.dataTask(with: URL_IMAGE!) { (data, response, error) in
                    
                    //if there is any error
                    if let e = error {
                        //displaying the message
                        print("Error Occurred: \(e)")
                        
                    } else {
                        //in case of now error, checking wheather the response is nil or not
                        if (response as? HTTPURLResponse) != nil {
                            
                            //checking if the response contains an image
                            if let imageData = data {
                                
                                //getting the image
                                let image = UIImage(data: imageData)
                                
                                //displaying the image
                                self.allskyImage.image = image
                                
                            } else {
                                print("Image file is currupted")
                            }
                        } else {
                            print("No response from server")
                        }
                    }
                }
                
                //starting the download task
                getImageFromUrl.resume()
                
                
                //set lables
                let humidity = json["weatherData"]["humidity"].doubleValue
                let temperature = json["weatherData"]["temperature"].doubleValue
                let humidityAsString = String(format:"%.1f", humidity)
                let temperatureAsString = String(format:"%.1f", temperature)
                self.temperatureLabel.text = temperatureAsString
                self.humidityLabel.text = humidityAsString
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

