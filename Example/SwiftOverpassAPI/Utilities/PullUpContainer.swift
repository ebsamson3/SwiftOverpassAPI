//
//  PullUpContainer.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/9/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

protocol PullUpContainerDelegate: class {
	func pullUpContainer(statusDidChangeTo status: PullUpContainer.Status)
}

class PullUpContainer: UIViewController {
	
	enum Status {
		case portrait(height: CGFloat)
		case landscape
	}
	
	let headerView: PullUpHeaderView = {
		let view = PullUpHeaderView()
		view.backgroundColor = .white
		return view
	}()
	
	private let contentView = UIView()
	private let contentViewController: UIViewController
	
	private var portraitConstraints = ConstraintFamily()
	private var landscapeConstraints = ConstraintFamily()
	private var headerViewHeightConstraint: NSLayoutConstraint?
	
	var status: Status? {
		if isPortrait {
			guard let height = portraitConstraints.top?.constant else {
				return nil
			}
			return .portrait(height: height)
		} else {
			return .landscape
		}
	}
	
	private var isPortrait: Bool {
		return UIScreen.main.bounds.height > UIScreen.main.bounds.width
	}
	
	var landscapeFrame = CGRect.zero {
		didSet {
			updateLandscapeConstraints()
		}
	}
	
	var headerViewHeight: CGFloat = 40 {
		didSet {
			headerViewHeightConstraint?.constant = headerViewHeight
		}
	}
	
	lazy var maxPortraitHeight: CGFloat = headerViewHeight
	lazy var minPortraitHeight: CGFloat = headerViewHeight
	var bounceOffset: CGFloat = 20
	
	var cornerRadius: CGFloat = 16 {
		didSet {
			contentViewBottomConstraint.constant = contentOffset
		}
	}
	
	var contentOffset: CGFloat {
		return isPortrait ? -cornerRadius : 0
	}
	
	weak var delegate: PullUpContainerDelegate?
	
	private lazy var contentViewBottomConstraint: NSLayoutConstraint = {
		let constraint = contentView.bottomAnchor.constraint(
			equalTo: view.bottomAnchor,
			constant: contentOffset)
			.withPriority(.defaultHigh)
		return constraint
	}()
	
	private var contentBottomOffset: CGFloat {
		return isPortrait ? -cornerRadius : 0
	}
	
	init(
		contentViewController: UIViewController)
	{
		self.contentViewController = contentViewController
		super.init(nibName: nil, bundle: nil)
		view.clipsToBounds = true
		view.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
		view.layer.borderWidth = 1
		addMainPanGestureRecognizer()
		configureSubviewConstraints()
		add(childContentViewController: contentViewController)
	}
	
	override func viewWillTransition(
		to size: CGSize,
		with coordinator: UIViewControllerTransitionCoordinator)
	{
		let isNewSizePortrait = size.height > size.width
		
		guard isNewSizePortrait != isPortrait else {
			return
		}
		
		view.isHidden = true
		
		if isPortrait {
			portraitConstraints.deactivate()
		} else {
			landscapeConstraints.deactivate()
		}
		
		coordinator.animate(alongsideTransition: { _ in }) { _ in
			
			if isNewSizePortrait {
				let topConstant = -self.minPortraitHeight
				self.portraitConstraints.top?.constant = topConstant
				self.portraitConstraints.activate()
				self.delegate?.pullUpContainer(statusDidChangeTo: .portrait(height: -topConstant))
			} else {
				self.landscapeConstraints.activate()
				self.delegate?.pullUpContainer(statusDidChangeTo: .landscape)
			}
			self.contentViewBottomConstraint.constant = self.contentOffset
			self.view.isHidden = false
		}
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		view.layer.cornerRadius = cornerRadius
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func add(toParent parent: UIViewController) {
		if let currentParent = self.parent {
			remove(fromParent: currentParent, animated: false)
		}
		
		parent.addChild(self)
		didMove(toParent: parent)
		parent.view.addSubview(view)
		configureConstraints(withParent: parent)
	}
	
	func remove(fromParent parent: UIViewController, animated: Bool) {
		
		if isPortrait {
			portraitConstraints.top?.constant = 0
		}
		
		if animated {
			UIView.animate(
				withDuration: 0.3,
				animations: {
					if self.isPortrait {
						self.view.layoutIfNeeded()
					} else {
						self.view.alpha = 0.0
					}
			}) { _ in
				self.portraitConstraints = ConstraintFamily()
				self.portraitConstraints = ConstraintFamily()
				self.willMove(toParent: nil)
				self.view.removeFromSuperview()
				self.removeFromParent()
				self.view.alpha = 1.0
			}
		}
	}
	
	private func add(childContentViewController contentViewController: UIViewController) {
		addChild(contentViewController)
		contentViewController.didMove(toParent: self)
		
		guard let viewToAdd = contentViewController.view else {
			return
		}
		
		contentView.addSubview(viewToAdd)
		
		viewToAdd.translatesAutoresizingMaskIntoConstraints = false
		viewToAdd.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		viewToAdd.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		viewToAdd.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		viewToAdd.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		
		configureInternalScrollViews()
	}
	
	private func configureConstraints(withParent parent: UIViewController) {
		
		guard let parentView = parent.view else {
			return
		}
		
		let margins = parentView.layoutMarginsGuide
		
		view.translatesAutoresizingMaskIntoConstraints = false
		
		portraitConstraints.top = view.topAnchor.constraint(
				equalTo: parentView.bottomAnchor,
				constant: -minPortraitHeight)
		portraitConstraints.trailing = view.trailingAnchor.constraint(
			equalTo: parentView.trailingAnchor)
		portraitConstraints.leading = view.leadingAnchor.constraint(
			equalTo: parentView.leadingAnchor)
		portraitConstraints.bottom = view.bottomAnchor.constraint(
			equalTo: parentView.bottomAnchor,
			constant: cornerRadius)
		
		landscapeConstraints.top = view.topAnchor.constraint(
			equalTo: margins.topAnchor,
			constant: landscapeFrame.origin.y)
		landscapeConstraints.trailing = view.trailingAnchor.constraint(
			lessThanOrEqualTo: margins.trailingAnchor)
			.withPriority(.defaultHigh)
		landscapeConstraints.bottom = view.bottomAnchor.constraint(
			lessThanOrEqualTo: margins.bottomAnchor)
			.withPriority(.defaultHigh)
		landscapeConstraints.leading = view.leadingAnchor.constraint(
			equalTo: margins.leadingAnchor,
			constant: landscapeFrame.origin.x)
		landscapeConstraints.height = view.heightAnchor.constraint(
			equalToConstant: landscapeFrame.height)
			.withPriority(.defaultLow)
		landscapeConstraints.width = view.widthAnchor.constraint(
			equalToConstant: landscapeFrame.width)
			.withPriority(.defaultLow)
		
		if isPortrait {
			portraitConstraints.activate()
		} else {
			landscapeConstraints.activate()
		}
	}
	
	private func configureSubviewConstraints() {
		view.addSubview(headerView)
		view.addSubview(contentView)
		
		headerView.translatesAutoresizingMaskIntoConstraints = false
		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		headerView.topAnchor.constraint(
			equalTo: view.topAnchor)
			.isActive = true
		headerView.trailingAnchor.constraint(
			equalTo: view.trailingAnchor)
			.withPriority(.defaultHigh)
			.isActive = true
		headerView.leadingAnchor.constraint(
			equalTo: view.leadingAnchor)
			.isActive = true
		headerViewHeightConstraint = headerView.heightAnchor.constraint(
			equalToConstant: headerViewHeight)
			.withActivitionState(true)
		
		contentView.topAnchor.constraint(
			equalTo: headerView.bottomAnchor)
			.isActive = true
		contentView.trailingAnchor.constraint(
			equalTo: view.trailingAnchor)
			.withPriority(.defaultHigh)
			.isActive = true
		contentView.leadingAnchor.constraint(
			equalTo: view.leadingAnchor)
			.isActive = true
		
//		contentView.bottomAnchor.constraint(
//			equalTo: view.bottomAnchor,
//			constant: bottomAnchorConstant)
//			.withPriority(.defaultHigh)
//			.isActive = true
		
		contentViewBottomConstraint
			.isActive = true
	}
	
	func updateLandscapeConstraints() {
		
		landscapeConstraints.top?.constant = landscapeFrame.origin.y
		landscapeConstraints.leading?.constant = landscapeFrame.origin.x
		landscapeConstraints.height?.constant = landscapeFrame.height
		landscapeConstraints.width?.constant = landscapeFrame.width
		
		guard self.viewIfLoaded?.window != nil else {
			return
		}
		
		UIView.animate(withDuration: 0.1, animations: {
			self.parent?.view.layoutIfNeeded()
		})
	}
	
	private func addMainPanGestureRecognizer() {
		let panGestureRecognizer = UIPanGestureRecognizer(
			target: self,
			action: #selector(handlePan(_:)))
		
		panGestureRecognizer.minimumNumberOfTouches = 1
		panGestureRecognizer.maximumNumberOfTouches = 1
		view.addGestureRecognizer(panGestureRecognizer)
	}
	
	private func configureInternalScrollViews() {
		for subview in contentViewController.view.subviews {
			guard let scrollView = subview as? UIScrollView else {
				continue
			}
			addScrollViewGestureRecognizer(to: scrollView)
		}
	}
	
	private func addScrollViewGestureRecognizer(to scrollView: UIScrollView) {
		scrollView.panGestureRecognizer.addTarget(
			self,
			action: #selector(handleScrollViewPan(sender:)))
	}
	
	private var initialScrollViewContentOffset = CGPoint.zero
	
	@objc private func handleScrollViewPan(sender: UIPanGestureRecognizer) {
		guard
			isPortrait,
			let scrollview = sender.view as? UIScrollView,
			let topConstraint = portraitConstraints.top
		else {
			return
		}
		
		let isExpanded =
			topConstraint.constant <= -maxPortraitHeight
		
		let yTranslation = sender.translation(in: scrollview).y
		let isScrollingDown = sender.velocity(in: scrollview).y > 0
		
		let shouldDragViewDown =
			isScrollingDown && scrollview.contentOffset.y <= 0
		
		let shouldDragViewUp = !isScrollingDown && !isExpanded
		let shouldDragView = shouldDragViewDown || shouldDragViewUp
		
		if shouldDragView {
			scrollview.bounces = false
			scrollview.setContentOffset(.zero, animated: false)
		}
		
		switch sender.state {
		case .began:
			initialScrollViewContentOffset = scrollview.contentOffset
		case .changed:
			guard shouldDragView else {
				break
			}
			setTopOffset(topConstraint.constant + yTranslation - initialScrollViewContentOffset.y)
			
			sender.setTranslation(initialScrollViewContentOffset, in: scrollview)
		case .ended:
			scrollview.bounces = true
			goToNearestStickyPoint(verticalVelocity: sender.velocity(in: view).y)
		default:
			break
		}
	}
	
	@objc private func handlePan(_ sender: UIPanGestureRecognizer) {
		guard
			isPortrait,
			let topConstraint = portraitConstraints.top
		else {
			return
		}
		
		let yTranslation = sender.translation(in: view).y
		
		switch sender.state {
		case .changed:
			setTopOffset(topConstraint.constant + yTranslation, allowBounce: true)
			sender.setTranslation(.zero, in: view)
		case .ended:
			goToNearestStickyPoint(verticalVelocity: sender.velocity(in: view).y)
		default:
			break
		}
	}
	
	private func setTopOffset(
		_ value: CGFloat,
		animationDuration: TimeInterval? = nil,
		allowBounce: Bool = false)
	{
		
		let bounceOffset = allowBounce ? self.bounceOffset : 0
		let minValue = -maxPortraitHeight - bounceOffset
		let maxValue = -minPortraitHeight + bounceOffset
		let targetValue = max(min(value, maxValue), minValue)
		portraitConstraints.top?.constant = targetValue
		
		UIView.animate(
			withDuration: animationDuration ?? 0,
			animations: {
				self.parent?.view.layoutIfNeeded()
		}) { _ in
			self.delegate?.pullUpContainer(statusDidChangeTo: .portrait(height: -targetValue))
		}
	}
	
	private func goToNearestStickyPoint(verticalVelocity: CGFloat) {
		guard
			isPortrait,
			let topConstraint = portraitConstraints.top
		else {
			return
		}
		
		let currentPosition = topConstraint.constant
		let expandedPosition = -maxPortraitHeight
		let contractedPosition = -minPortraitHeight
		
		let targetPosition =
		abs(currentPosition - expandedPosition) < abs(currentPosition - contractedPosition) ? expandedPosition : contractedPosition
		
		let distanceToCover = currentPosition - targetPosition
		let animationDuration = max(
			0.08,
			min(0.3, TimeInterval(abs(distanceToCover/verticalVelocity))))
		
		setTopOffset(targetPosition, animationDuration: animationDuration)
	}
}

extension PullUpContainer {
	private class ConstraintFamily {
		var top: NSLayoutConstraint?
		var trailing: NSLayoutConstraint?
		var bottom: NSLayoutConstraint?
		var leading: NSLayoutConstraint?
		var height: NSLayoutConstraint?
		var width: NSLayoutConstraint?
		
		func activate() {
			setActivationStatus(to: true)
		}
		
		func deactivate() {
			setActivationStatus(to: false)
		}
		
		private func setActivationStatus(to newStatus: Bool) {
			
			let constraints = [
				top,
				trailing,
				bottom,
				leading,
				height,
				width
			].compactMap { $0 }
			
			if newStatus {
				NSLayoutConstraint.activate(constraints)
			} else {
				NSLayoutConstraint.deactivate(constraints)
			}
		}
		
		deinit {
			deactivate()
		}
	}
}

extension UIViewController {
	func addPullUpContainer(_ pullUpContainer: PullUpContainer) {
		pullUpContainer.add(toParent: self)
	}
	
	func removePullUpContainer(_ pullUpContainer: PullUpContainer) {
		pullUpContainer.remove(fromParent: self, animated: true)
	}
	
	func layoutIfNeededAndVisible() {
		if self.viewIfLoaded?.window != nil {
			view.layoutIfNeeded()
		}
	}
}
