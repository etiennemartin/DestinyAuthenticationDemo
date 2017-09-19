//
//  AuthenticationView.swift
//  DestinyTestApp
//
//  Created by Etienne Martin on 2017-09-15.
//  Copyright © 2017 EtienneMartin. All rights reserved.
//

import Foundation
import UIKit

protocol AuthenticationViewDelegate {
	func refreshToken(with userCodes: TokenCache)
}

class AuthenticationView: UIView {
	
	private var userCodes: TokenCache
	private var stackView: UIStackView!
	
	var delegate: AuthenticationViewDelegate?
	
	init(userCodes: TokenCache) {
		self.userCodes = userCodes
		super.init(frame: .zero)
		backgroundColor = .black
		buildViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func update(with userCodes: TokenCache) {
		self.userCodes = userCodes
		stackView.removeFromSuperview()
		buildViews()
	}
	
	private func buildViews() {
	 stackView = UIStackView()
		stackView.axis = .vertical
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.spacing = 10
		
		self.addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
			stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
		])
		
		let titleLabel = UILabel()
		titleLabel.text = "Auth Info"
		titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
		titleLabel.textColor = .white
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		stackView.addArrangedSubview(titleLabel)
		
		stackView.addArrangedSubview(label(title: "Access Token", text: userCodes.accessToken))
		stackView.addArrangedSubview(label(title: "Refresh Token", text: userCodes.refreshToken))
		stackView.addArrangedSubview(label(title: "Auth Code", text: userCodes.authCode))
		stackView.addArrangedSubview(label(title: "Token Type", text: userCodes.tokenType))
		stackView.addArrangedSubview(label(title: "Creation Time", text: userCodes.creationTime.description))
		stackView.addArrangedSubview(label(title: "Membership Id", text: userCodes.membershipId))
		
		let button = UIButton()
		button.setTitle("Refresh Token", for: .normal)
		button.setTitleColor(.black, for: .normal)
		button.backgroundColor = .green
		button.translatesAutoresizingMaskIntoConstraints = false
		button.addTarget(self, action: #selector(refreshTokens), for: .touchUpInside)
		stackView.addArrangedSubview(button)
	}
	
	private func label(title: String, text: String?) -> UILabel {
		let label = UILabel()
		label.textColor = .white
		let text = text ?? "nil"
		label.text = "\(title): \(text)"
		label.sizeToFit()
		return label
	}
	
	@objc func refreshTokens() {
		delegate?.refreshToken(with: userCodes)
	}
}
