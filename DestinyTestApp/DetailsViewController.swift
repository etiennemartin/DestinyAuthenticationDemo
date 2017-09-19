//
//  DetailsViewController.swift
//  DestinyTestApp
//
//  Created by Etienne Martin on 2017-09-17.
//  Copyright © 2017 EtienneMartin. All rights reserved.
//

import Foundation
import UIKit

class DetailsViewController: UIViewController, AuthenticationViewDelegate {
	private struct Constants {
		static let tokenRefreshURL = URL(string: "https://www.bungie.net/Platform/App/OAuth/Token/")!
	}
	
	private var userCodes: TokenCache
	private var authorizationCode: String
	private var authenticationView: AuthenticationView!
	
	init(userCodes: TokenCache, authorizationCode: String) {
		self.userCodes = userCodes
		self.authorizationCode = authorizationCode
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		buildView()
	}
	
	func buildView() {
		authenticationView = AuthenticationView(userCodes: userCodes)
		authenticationView.delegate = self
		authenticationView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(authenticationView)
		NSLayoutConstraint.activate([
			authenticationView.topAnchor.constraint(equalTo: view.topAnchor),
			authenticationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			authenticationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			authenticationView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
			])
	}
	
	func refreshToken(with userCodes: TokenCache) {
		guard let refreshToken = userCodes.refreshToken else {
			print(">>> Error: Failed to udpdate token due to missing refresh token")
			return
		}
		
		print(">>> Requesting fresh tokens!")
		
		let session = URLSession(configuration: URLSessionConfiguration.default)
		
		// Build the request
		var request = URLRequest(url: Constants.tokenRefreshURL)
		request.httpMethod = "POST"
		request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
		request.addValue("Basic \(authorizationCode)", forHTTPHeaderField: "Authorization")
		request.httpBody = "grant_type=refresh_token&refresh_token=\(refreshToken)".data(using: .utf8)
		
		// Execute the request that will fetch new access token and refresh token.
		session.dataTask(with: request) { [weak self] (data, _, error) in
			guard error == nil else {
				print(">>>v Error while attempting to refresh token: \(String(describing: error))")
				return
			}

			if let data = data {
				do {
					let json = try JSONSerialization.jsonObject(with: data)
					// Update the codes locally
					self?.userCodes.populateWith(json as? [String:Any])
					DispatchQueue.main.async { [weak self] in
						if let view = self?.authenticationView,
						   let codes = self?.userCodes
						{
							view.update(with: codes)
						}
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
}
