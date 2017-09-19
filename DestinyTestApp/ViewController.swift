//
//  ViewController.swift
//  DestinyTestApp
//
//  Created by Etienne Martin on 2017-08-29.
//  Copyright © 2017 EtienneMartin. All rights reserved.
//

import UIKit
import WebKit
import Foundation

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
	private struct Constants {
		static let applicationHeaderKey = "X-API-Key"
		
		// The following values need to be specified for your application that is registered with Bungie. You
		// can do so here: https://www.bungie.net/en/application. Note that you will need your API key to
		// contain a secret. If it's missing create a new one.
		//
		// Finally make sure the OAuth Client Type is set to confidencial.
		static let applicationAPIKey = "" 						// <<< SETUP REQUIRED
		static let authenticationCodeURL = URL(string: "")! 	// <<< SETUP REQUIRED
		static let clientId = "" 								// <<< SETUP REQUIRED
		static let clientSecret = "" 							// <<< SETUP REQUIRED

		// URLs
		static let authenticationURL = URL(string: "https://www.bungie.net/en/OAuth/Authorize?client_id=\(clientId)&response_type=code")!
		static let oauthTokenURL = URL(string: "https://www.bungie.net/Platform/App/OAuth/Token/")!
	}
	
	private var webView: WKWebView?
	private var userCodes: TokenCache!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		userCodes = TokenCache()
		
		// Add API Key
		URLSessionConfiguration.default.httpAdditionalHeaders = [Constants.applicationHeaderKey : Constants.applicationAPIKey]

		// Need a fresh web view to avoid being auto logged in again.
		let config = WKWebViewConfiguration.init()
		config.websiteDataStore = WKWebsiteDataStore.nonPersistent()

		let webView = WKWebView(frame: view.frame, configuration: config)
		webView.navigationDelegate = self
		view = webView
		self.webView = webView

		let request = URLRequest(url: Constants.authenticationURL)
		webView.load(request)
	}
	
	//MARK: WKNavigationDelegate methods
	
	// Monitor the web view for redirections if the url matches the redirection URL specified by your bungie
	// application, it will attempt to parse out the code, and move on from there.
	func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation: WKNavigation!) {
		guard let url = webView.url else {
			return
		}
		
		// Attemp to parse out the code from the URL.
		if let code = extractAccessToken(url) {
			print(">>> Extracted Autentication code: \(code)")
			userCodes.authCode = code
			fetchApiTokens() { [weak self] in
				self?.showAuthenticationView()
			}
		}
	}
	
	// Hides the webview and shows the details of your authentication
	private func showAuthenticationView() {
		let viewController = DetailsViewController(userCodes: userCodes, authorizationCode: generateAuthorizationString())
		present(viewController, animated: false, completion: nil)
	}
	
	//MARK: Helpers
	
	// Given an access code, will attempt to fetch api and refresh code for the user.
	private func fetchApiTokens(completion: @escaping () -> ()) {
		guard let authCode = userCodes.authCode else {
			return
		}
		
		let session = URLSession(configuration: URLSessionConfiguration.default)
		
		// Build the request
		var request = URLRequest(url: Constants.oauthTokenURL)
		request.httpMethod = "POST"
		request.addValue(Constants.applicationAPIKey, forHTTPHeaderField: Constants.applicationHeaderKey)
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.addValue("Basic \(generateAuthorizationString())", forHTTPHeaderField: "Authorization")
		request.httpBody = "grant_type=authorization_code&code=\(authCode)".data(using: .utf8)
		
		// Execute the request to fetch the access token and refresh tokens.
		session.dataTask(with: request) { [weak self] (data, response, error) in
			guard error == nil else {
				print(">>> Error while attempting to login: \(String(describing: error))")
				return
			}
			
			if let data = data {
				do {
					let json = try JSONSerialization.jsonObject(with: data)
					self?.userCodes.populateWith(json as? [String:Any])
					DispatchQueue.main.async {
						completion()
					}
				} catch {
					print(">>> Error: Failed to parse incoming data into JSON Format.")
				}
			} else {
				// No data in response. Should have an error in this case
				print(">>> Error: Unexpected error, no error and no data. Should have one of either.")
			}
		}.resume()
	}
	
	// Create a base 64 encoded version of the client ID and client secret.
	private func generateAuthorizationString() -> String {
		let authString = "\(Constants.clientId):\(Constants.clientSecret)"
		let utf8str = authString.data(using: .utf8)
		if let encoding = utf8str?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) {
			return encoding
		}
		return ""
	}
	
	// Pull the access code from the redirections URL. The Code is a url parameter
	private func extractAccessToken(_ url: URL) -> String? {
		guard url.absoluteString.hasPrefix(Constants.authenticationCodeURL.absoluteString) else {
			return nil
		}
		
		let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
		let firstCode = urlComponents?.queryItems?.filter { $0.name == "code" }.first
		if let code = firstCode?.value {
			return code
		}
		return nil
	}
}
