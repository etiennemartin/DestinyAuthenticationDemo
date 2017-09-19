//
//  UserCodes.swift
//  DestinyTestApp
//
//  Created by Etienne Martin on 2017-09-15.
//  Copyright © 2017 EtienneMartin. All rights reserved.
//

import Foundation

struct TokenCache {
	// Code retreived from user authentication
	var authCode: String?
	
	// Authentication tokens (for API use)
	var accessToken: String?
	var expiresIn: Int = 0
	var refreshToken: String?
	var refreshExpiresIn: Int = 0
	
	// Additional Authentication info
	var tokenType: String = "Unknown"
	var membershipId: String = "Unknown"
	
	// Time when the access token was created.
	var creationTime: Date = Date(timeIntervalSince1970: 0)
	
	// Takes in the JSON response from the API call and populates the cache.
	mutating func populateWith(_ json: [String:Any]?) {
		guard let json = json else {
			return
		}
		
		if let accessToken = json["access_token"] { self.accessToken = accessToken as? String }
		if let refreshToken = json["refresh_token"] { self.refreshToken = refreshToken as? String }
		if let tokenType = json["token_type"] { self.tokenType = tokenType as? String ?? "" }
		if let membershipId = json["membership_id"] { self.membershipId = membershipId as? String ?? "Unknown" }
		if let expiresIn = json["expires_in"] { self.expiresIn = expiresIn as? Int ?? -1 }
		if let refreshExpiresIn = json["refresh_expires_in"] { self.refreshExpiresIn = refreshExpiresIn as? Int ?? -1 }
		
		creationTime = Date()
		
		print(">>> Authentication information:")
		print(self)
	}
}
