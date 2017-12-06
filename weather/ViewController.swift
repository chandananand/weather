//
//  ViewController.swift
//  weather
//
//  Created by Chandan Anand on 12/6/17.
//  Copyright © 2017 Chandan Anand. All rights reserved.
//

import UIKit
import AVKit

    class ViewController: UIViewController, UISearchBarDelegate {
        
        
        @IBOutlet weak var searchBar: UISearchBar!
        @IBOutlet weak var movieView: UIView!
        @IBOutlet weak var cityLbl: UILabel!
        @IBOutlet weak var conditionLbl: UILabel!
        @IBOutlet weak var degreeLbl: UILabel!
        @IBOutlet weak var imgView: UIImageView!
        
        var degree: Int!
        var condition: String!
        var imgURL: String!
        var city: String!
        
        var avPlayer: AVPlayer!
        var avPlayerLayer: AVPlayerLayer!
        var paused: Bool = false
        
        var exists: Bool = true
        override func viewDidLoad() {
            super.viewDidLoad()
            
            let theURL = Bundle.main.url(forResource:"giphy", withExtension: "mp4")
            
            avPlayer = AVPlayer(url: theURL!)
            avPlayerLayer = AVPlayerLayer(player: avPlayer)
            avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            avPlayer.volume = 0
            avPlayer.actionAtItemEnd = .none
            avPlayerLayer.frame = self.movieView.bounds
            movieView.backgroundColor = .clear
            movieView.layer.addSublayer(avPlayerLayer)

            //avPlayer.play()
            //paused = false
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerItemDidReachEnd(notification:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: avPlayer.currentItem)
            // Do any additional setup after loading the view, typically from a nib.
            
            searchBar.delegate = self
        }
        
        @objc func playerItemDidReachEnd(notification: Notification) {
            let p: AVPlayerItem = notification.object as! AVPlayerItem
            p.seek(to: kCMTimeZero)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            avPlayer.play()
            paused = false
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            avPlayer.pause()
            paused = true
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            let urlRequest = URLRequest(url: URL(string: "http://api.apixu.com/v1/current.json?key=44e6e25f13f64c23b4f171032170512&q=\(searchBar.text!.replacingOccurrences(of: " ", with: "%20"))")!)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                if error == nil {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : AnyObject]
                        
                        if let current = json["current"] as? [String : AnyObject] {
                            
                            if let temp = current["temp_c"] as? Int {
                                self.degree = temp
                            }
                            if let condition = current["condition"] as? [String : AnyObject] {
                                self.condition = condition["text"] as! String
                                let icon = condition["icon"] as! String
                                self.imgURL = "http:\(icon)"
                            }
                        }
                        if let location = json["location"] as? [String : AnyObject] {
                            self.city = location["name"] as! String
                        }
                        
                        if let _ = json["error"] {
                            self.exists = false
                        }
                        
                        DispatchQueue.main.async {
                            if self.exists{
                                self.degreeLbl.isHidden = false
                                self.conditionLbl.isHidden = false
                                self.imgView.isHidden = false
                                self.degreeLbl.text = "\(self.degree.description)°"
                                self.cityLbl.text = self.city
                                self.conditionLbl.text = self.condition
                                self.imgView.downloadImage(from: self.imgURL!)
                            }else {
                                self.degreeLbl.isHidden = true
                                self.conditionLbl.isHidden = true
                                self.imgView.isHidden = true
                                self.cityLbl.text = "No matching city found"
                                self.exists = true
                            }
                        }
                        
                        
                    } catch let jsonError {
                        print(jsonError.localizedDescription)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    extension UIImageView {
        
        func downloadImage(from url: String) {
            let urlRequest = URLRequest(url: URL(string: url)!)
            
            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data!)
                    }
                }
            }
            task.resume()
        }
        
}

