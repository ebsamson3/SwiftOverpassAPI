//
//  HandleView.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

class PullUpHeaderView: UIView {
	
	lazy var handleView: UIView = {
		
		let handleWidth: CGFloat = 50
		let handleHeight: CGFloat = 8
		let cornerRadius: CGFloat = handleHeight / 2
		let originX: CGFloat = bounds.midX - handleWidth / 2
		let originY: CGFloat = 8
		
		let handleRect = CGRect(
			x: originX,
			y: originY,
			width: handleWidth,
			height: handleHeight)
	
		let view = UIView(frame: handleRect)
		view.backgroundColor = UIColor(white: 0.93, alpha: 1.0)
		view.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
		view.layer.borderWidth = 1
		view.addInnerShadow(to: [.top, .right], radius: 4, opacity: 0.6)
		view.clipsToBounds = true
		
		return view
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		handleView.layer.cornerRadius = handleView.bounds.height / 2
	}
	
	private func configure() {
		addSubview(handleView)
		handleView.translatesAutoresizingMaskIntoConstraints = false
		
		handleView.centerXAnchor.constraint(
			equalTo: centerXAnchor)
			.isActive = true
		handleView.topAnchor.constraint(
			equalTo: topAnchor,
			constant: 8)
			.isActive = true
		handleView.bottomAnchor.constraint(
			lessThanOrEqualTo: bottomAnchor,
			constant: -8)
			.withPriority(.defaultHigh)
			.isActive = true
		handleView.heightAnchor.constraint(equalToConstant: 8)
			.isActive = true
		handleView.widthAnchor.constraint(equalToConstant: 50)
			.isActive = true
	}
}


