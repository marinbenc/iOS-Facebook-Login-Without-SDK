//
//  ViewController.swift
//  FacebookLoginwWithoutSDK
//
//  Created by Marin Benčević on 07/05/2020.
//  Copyright © 2020 marinbenc. All rights reserved.
//

import UIKit
import Combine
import AuthenticationServices
import KeychainAccess

class ViewController: UIViewController {
  
  private var session: ASWebAuthenticationSession?
  
  public struct FacebookLoginResponse {
    /// Which permissions has the user granted.
    let grantedPermissionScopes: [String]
    /// An encrypted string unique to each login request. This code must be exchanged for an access token **on your server** using an endpoint.
    /// See [Exchanging Code for an Access Token](https://developers.facebook.com/docs/facebook-login/manually-build-a-login-flow#exchangecode).
    let code: String
    /// The state you sent when initializing the request.
    let state: String
  }
  
  @IBAction func continueWithFacebookTapped(_ sender: Any) {
    #warning("Don't forget to replace this with your Facebook app ID")
    // You can find your app ID on developers.facebook.com
    let facebookAppID = "YOUR_APP_ID"
    // Which permissions you want to access. To see a list of permissions, go to
    // https://developers.facebook.com/docs/facebook-login/permissions/
    let permissionScopes = ["email"]
    
    // Create a URL to the Facebook login website
    let state = UUID().uuidString
    let callbackScheme = "fb" + facebookAppID
    let baseURLString = "https://www.facebook.com/v7.0/dialog/oauth"
    let urlString = "\(baseURLString)"
      + "?client_id=\(facebookAppID)"
      + "&redirect_uri=\(callbackScheme)://authorize"
      + "&scope=\(permissionScopes.joined(separator: ","))"
      + "&response_type=code%20granted_scopes"
      + "&state=\(state)"
    
    let url = URL(string: urlString)!
    
    // Initiate an authenticaiton session
    let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { [weak self] (url, error) in
      guard error == nil else {
        print(error!)
        return
      }
      
      // Try to parse the received URL into FacebookResponse
      guard let receivedURL = url, let response = self?.response(from: receivedURL) else {
        print("Invalid url: \(String(describing: url))")
        return
      }
      
      // Make sure the state hasn't changed
      guard response.state == state else {
        print("State changed during login! Possible security breach.")
        return
      }
      
      print(response.code)
      self?.sendCodeToServer(response.code)
    }
    
    session.presentationContextProvider = self
    session.start()
  }
    
  func getComponent(named name: String, in items: [URLQueryItem]) -> String? {
    items.first(where: { $0.name == name })?.value
  }
  
  func response(from url: URL) -> FacebookLoginResponse? {
    guard
      let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
      let state = getComponent(named: "state", in: items),
      let scope = getComponent(named: "granted_scopes", in: items),
      let code = getComponent(named: "code", in: items)
    else {
      return nil
    }
        
    let grantedPermissions = scope.split(separator: ",").map(String.init)
    return FacebookLoginResponse(
      grantedPermissionScopes: grantedPermissions,
      code: code,
      state: state)
  }
  
  func sendCodeToServer(_ code: String) {
    // Here you'll initiate a request to your backend service to send the code.
    let url = URL(string: "https://example.com/login/facebookCode")!
    var request = URLRequest(url: url)
    request.httpBody = code.data(using: .utf8)
    request.httpMethod = "POST"
    
    URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
      // You got a response from your server, either a custom token or a
      // Facebook access token.
      guard let data = data else {
        print("An error ocurred.")
        return
      }
      
      let receivedToken = String(decoding: data, as: UTF8.self)
      guard !receivedToken.isEmpty else {
        print("An error ocurred.")
        return
      }
      
      // Save the token to the keychain so the app knows the user is logged in.
      self?.store(token: receivedToken)
      
      // ...and you're done with the login flow!
    }
  }
  
  // MARK: - Managing the access token, logging out
  
  let keychain = Keychain(service: "com.marinbenc.FacebookLogin")
  
  /// Saves a token in the keychain.
  func store(token: String) {
    keychain["accessToken"] = token
  }
  
  /// Is the user currently logged in?
  var isLoggedIn: Bool {
    keychain["accessToken"] != nil
  }
  
  func logOut() {
    keychain["accessToken"] = nil
  }
  
  func checkTokenValidity(_ accessToken: String) {
    let url = URL(string: "https://graph.facebook.com/me?access_token=\(accessToken)")!
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let response = response as? HTTPURLResponse else {
        return
      }
      
      if response.statusCode < 200 || response.statusCode >= 300 {
        self.logOut()
      }
    }.resume()
  }
  
}

// The View Controller needs to provide the authentication session its window to present the web view
extension ViewController: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    return view.window!
  }
}

