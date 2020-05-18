//
//  AppDelegate.swift
//  FacebookLoginwWithoutSDK
//
//  Created by Marin Benčević on 07/05/2020.
//  Copyright © 2020 marinbenc. All rights reserved.
//

import UIKit
import KeychainAccess

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let keychain = Keychain(service: "com.marinbenc.FacebookLogin")
    print("User already logged in, validating token...")
    if let storedToken = keychain["accessToken"] {
      checkTokenValidity(storedToken)
    }
    
    return true
  }
  
  func checkTokenValidity(_ accessToken: String) {
    let url = URL(string: "https://graph.facebook.com/me?access_token=\(accessToken)")!
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let response = response as? HTTPURLResponse else {
        return
      }
      
      if response.statusCode < 200 || response.statusCode >= 300 {
        print("Token invalid, loggin out...")
        self.logOut()
      }
    }.resume()
  }
  
  func logOut() {
    let keychain = Keychain(service: "com.marinbenc.FacebookLogin")
    keychain["accessToken"] = nil
  }

}

