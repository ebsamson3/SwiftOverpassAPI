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

	/*
		A container view controller that enables it's child content view controller to be pulled up from the bottom of the screen. It works for this app but I haven't rigorously tested it in many different use cases. Largely base on the following repo:
		https://github.com/MarioIannotta/PullUpController
	*/

class PullUpContainer: UIViewController {
	
	// The pull up container has two distinct state for when it the device is in portrait and landscape. In portrait mode it is swiped up and down from the bottom of the screen while in landscape mode it is a static square frame.
	enum Status {
		case portrait(height: CGFloat)
		case landscape
	}
	
	// A header view with a handle that can be used to pull up the container when the embedded view controller is fully hidden.
	let headerView: PullUpHeaderView = {
		let view = PullUpHeaderView()
		view.backgroundColor = .white
		return view
	}()
	
	// The contentView provides the frome for the embedded contentViewController
	private let contentView = UIView()
	private let contentViewController: UIViewController
	
	// The pull up container has two sets of contraints that govern it's frame. One for when the device is in portrait and one for when the device is in landscape. When switching between these two states, one set of contraints is deactivated before the other is activated.
	private var portraitConstraints = ConstraintFamily()
	private var landscapeConstraints = ConstraintFamily()
	
	// The height of the header view of the pull up container
	private var headerViewHeightConstraint: NSLayoutConstraint?
	
	// A status variable that returns whether or not the pull up container is in the portrait or landscape state. If it is in portrait the height is stored as an associated value.
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
	
	// A check for whether or not the device is in portrait or landscape orientation
	private var isPortrait: Bool {
		return UIScreen.main.bounds.height > UIScreen.main.bounds.width
	}
	
	// The frame for the pull up container while it is in landscape mode
	var landscapeFrame = CGRect.zero {
		didSet {
			updateLandscapeConstraints()
		}
	}
	
	// The height of the pull up container's header view.
	var headerViewHeight: CGFloat = 40 {
		didSet {
			headerViewHeightConstraint?.constant = headerViewHeight
		}
	}
	
	// Te maximum and minimum heights for the pull up container while in portrait mode
	lazy var maxPortraitHeight: CGFloat = headerViewHeight
	lazy var minPortraitHeight: CGFloat = headerViewHeight
	var bounceOffset: CGFloat = 20
	
	// The coner radius of the pull up container
	var cornerRadius: CGFloat = 16 {
		didSet {
			contentViewBottomConstraint.constant = contentOffset
		}
	}
	
	// The offset between the bottom anchors of the content view and the pull up container's view. In portrait mode the pull up container's bottom anchor is below that of the parent view it is attached to. This is to hide the rounded bottom left and bottom right corners. To compensate for this, the content view has to be shifted up an amount equal to the corner radius so that it's bottom is aligned with the parent view of the pull up container's bottom anchor.
	private var contentOffset: CGFloat {
		return isPortrait ? -cornerRadius : 0
	}
	
	// The contraint between the bottom anchor of the content view and the bottom anchor of the pull up container
	private lazy var contentViewBottomConstraint: NSLayoutConstraint = {
		let constraint = contentView.bottomAnchor.constraint(
			equalTo: view.bottomAnchor,
			constant: contentOffset)
			.withPriority(.defaultHigh)
		return constraint
	}()
	
	weak var delegate: PullUpContainerDelegate?
	
	// Initialize the pull up container with the embedded content view controller
	init(
		contentViewController: UIViewController)
	{
		self.contentViewController = contentViewController
		super.init(nibName: nil, bundle: nil)
		configure()
	}
	
	// Required boilerplate
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Handle configuration changes that occur as a result of view size changes
	override func viewWillTransition(
		to size: CGSize,
		with coordinator: UIViewControllerTransitionCoordinator)
	{
		// Check if device will be in portrait after the size change occurs
		let isNewSizePortrait = size.height > size.width
		
		// Check if the device will change orientation
		guard isNewSizePortrait != isPortrait else {
			return
		}
		
		// Hide the view prior to changing between portrait and landscape mode. I like this better than animating the contriant changes as it looks a lot cleaner.
		view.isHidden = true
		
		// Deactivate the currently active constraints.
		if isPortrait {
			portraitConstraints.deactivate()
		} else {
			landscapeConstraints.deactivate()
		}
		
		// Execuute the following after the size transition animation has completed
		coordinator.animate(alongsideTransition: { _ in }) { _ in
			
			// Activate new contraints and notify the delegate of the change in state
			if isNewSizePortrait {
				// If the new state is portrait, minimize the pull up container.
				let topConstant = -self.minPortraitHeight
				self.portraitConstraints.top?.constant = topConstant
				self.portraitConstraints.activate()
				self.delegate?.pullUpContainer(statusDidChangeTo: .portrait(height: -topConstant))
			} else {
				self.landscapeConstraints.activate()
				self.delegate?.pullUpContainer(statusDidChangeTo: .landscape)
			}
			// Set the content offset from the bottom of the pull up container.
			self.contentViewBottomConstraint.constant = self.contentOffset
			
			// Show the pull up container after all the configuration changes have finished.
			self.view.isHidden = false
		}
	}
	
	// Set the corner radius each time the view lays out it's subviews
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		view.layer.cornerRadius = cornerRadius
	}
	
	// Initial configuration of the pull up container
	private func configure() {
		
		// Set up the appearence of the pull up container's border
		view.clipsToBounds = true
		view.layer.borderColor = UIColor(white: 0.7, alpha: 1).cgColor
		view.layer.borderWidth = 1
		
		// Add a pan gesture to the pull up container
		addMainPanGestureRecognizer()
		
		// Add containts for the header view and content view of the pull up container
		configureSubviewConstraints()
		
		// Embedthe content view controller into the pull up container
		add(childContentViewController: contentViewController)
	}
	
	// Add a pan gesture to the pull up container that enabled the container to be swiped up and down
	private func addMainPanGestureRecognizer() {
		let panGestureRecognizer = UIPanGestureRecognizer(
			target: self,
			action: #selector(handlePan(_:)))
		
		panGestureRecognizer.minimumNumberOfTouches = 1
		panGestureRecognizer.maximumNumberOfTouches = 1
		view.addGestureRecognizer(panGestureRecognizer)
	}
	
	// Embed the content view controller into the pull up container
	private func add(childContentViewController contentViewController: UIViewController) {
		addChild(contentViewController)
		contentViewController.didMove(toParent: self)
		
		guard let viewToAdd = contentViewController.view else {
			return
		}
		
		// Add the content view controller's view as a subview to the content view
		contentView.addSubview(viewToAdd)
		
		// Configure constraints such that the content view controller's view covers the whole extent of the content view.
		viewToAdd.translatesAutoresizingMaskIntoConstraints = false
		viewToAdd.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
		viewToAdd.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
		viewToAdd.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
		viewToAdd.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
		
		// Configure any scroll view that are present in the content view controller
		configureInternalScrollViews()
	}
	
	private func configureInternalScrollViews() {
		// Check the content view controller's subviews for any scroll views
		for subview in contentViewController.view.subviews {
			guard let scrollView = subview as? UIScrollView else {
				continue
			}
			
			// Make sure any scroll view does not adjust it's content below the top anchor of the content view controller's view.
			scrollView.contentInsetAdjustmentBehavior = .never
			
			// Add pan gesture recognizers to each scroll view. This enabled the pull up/down action of the pull up container to work with scroll views.
			scrollView.panGestureRecognizer.addTarget(
			self,
			action: #selector(handleScrollViewPan(sender:)))
		}
	}
	
	// Add the pull up container to a parent view controller
	func add(toParent parent: UIViewController) {
		
		// remove the pull up container from the previous parent if it exists
		if let currentParent = self.parent {
			remove(fromParent: currentParent, animated: false)
		}
		
		// Add the pull up container as a child view controller to the new parent
		parent.addChild(self)
		didMove(toParent: parent)
		parent.view.addSubview(view)
		
		// Configure the constraints between the pull up container and it's parent view
		configureConstraints(withParent: parent)
	}
	
	// Remove the pull up container from it's parent view controller
	func remove(fromParent parent: UIViewController, animated: Bool) {
		
		// Collapse the pull up container if it is in portrait
		if isPortrait {
			portraitConstraints.top?.constant = 0
		}
		
		// Collapse the pull up container if it is in portrait. Otherwise, fade out the pull up container
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
				// Destroy any constraint between the pll up container and it's parent
				self.portraitConstraints = ConstraintFamily()
				self.portraitConstraints = ConstraintFamily()
				
				// Remove the pull up container as a child view controller
				self.willMove(toParent: nil)
				self.view.removeFromSuperview()
				self.removeFromParent()
				
				// Reset the alpha of the pull up container to 1.0
				self.view.alpha = 1.0
			}
		}
	}
	
	// Configure the portrait and landscape constraints between the pull up container and it's parent view controller
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
	
	// Configure the constraints of the subviews within the pull up container.
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
		
		contentViewBottomConstraint
			.isActive = true
	}
	
	// If the landscape frame property is changes, adjust the landscape contraints
	private func updateLandscapeConstraints() {
		
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
	
	// Handle panning the pull up container up and down
	@objc private func handlePan(_ sender: UIPanGestureRecognizer) {
		
		// Return if the pull up container isn't in portraint
		guard
			isPortrait,
			let topConstraint = portraitConstraints.top
		else {
			return
		}
		
		// Get the y translation of the pan
		let yTranslation = sender.translation(in: view).y
		
		switch sender.state {
		case .changed:
			// Change the offset of the pull up container from the bottom of it's parent view
			setTopOffset(topConstraint.constant + yTranslation, allowBounce: true)
			//Reset the y translation to zero
			sender.setTranslation(.zero, in: view)
		case .ended:
			// If the gesture is finished, move the pull up container to it's nearest sticky point
			goToNearestStickyPoint(verticalVelocity: sender.velocity(in: view).y)
		default:
			break
		}
	}
	
	// Setting the height up of the pull up view
	private func setTopOffset(
		_ value: CGFloat,
		animationDuration: TimeInterval? = nil,
		allowBounce: Bool = false)
	{
		
		// How far past the maximum and minimum height extents the pull up container is allowed to be dragged. Once released it will "bounce" back to the nearest extent.
		let bounceOffset = allowBounce ? self.bounceOffset : 0
		let minValue = -maxPortraitHeight - bounceOffset
		let maxValue = -minPortraitHeight + bounceOffset
		
		// The value to set the top offset to
		let targetValue = max(min(value, maxValue), minValue)
		
		// Changing the top contraint of the pull up container to the target value
		portraitConstraints.top?.constant = targetValue
		
		// Animating the height change. One feature that would be nice to add would be being able to perform other animations alongside this height change.
		UIView.animate(
			withDuration: animationDuration ?? 0,
			animations: {
				self.parent?.view.layoutIfNeeded()
		}) { _ in
			self.delegate?.pullUpContainer(statusDidChangeTo: .portrait(height: -targetValue))
		}
	}
	
	//Moving to the nearest sticky point
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
		
		// Finding the nearest stickpoint
		let targetPosition =
		abs(currentPosition - expandedPosition) < abs(currentPosition - contractedPosition) ? expandedPosition : contractedPosition
		
		// Dividing distance to cover b animation duration to get the velocity of height change
		let distanceToCover = currentPosition - targetPosition
		let animationDuration = max(
			0.08,
			min(0.3, TimeInterval(abs(distanceToCover/verticalVelocity))))
		
		// Setting the height to the sticky point's value
		setTopOffset(targetPosition, animationDuration: animationDuration)
	}
}


extension PullUpContainer {
	// Useful class for grouping portrait and landscape constraints.
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
		
		
		// A function for activating and deactivating all constraints
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
		
		// Deactivate constraints before deinitializing.
		deinit {
			deactivate()
		}
	}
}

extension UIViewController {
	// Convinience function for adding a pull up container to a parent view controller
	func addPullUpContainer(_ pullUpContainer: PullUpContainer) {
		pullUpContainer.add(toParent: self)
	}
	
	// Convinience functions for removing a pull up container from a parent view controller
	func removePullUpContainer(_ pullUpContainer: PullUpContainer) {
		pullUpContainer.remove(fromParent: self, animated: true)
	}
}
