import UIKit

class FullTicketCustomTransitionManager: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

    var isPresenting = false
    var interactiveDismiss = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    weak var viewController: UIViewController?
    var transitionContext: UIViewControllerContextTransitioning?
    var initialCenter: CGPoint = .zero
    var percentComplete: CGFloat = 0.0

    // Declare dimView as a property of the class
    var dimView: UIView?

    // Set up the gesture recognizer to track the swipe-down gesture
    func setupGestureRecognizer(in viewController: UIViewController) {
        self.viewController = viewController
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        viewController.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = viewController?.view else { return }
        let translation = gesture.translation(in: view)
        let verticalMovement = translation.y / view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let progress = fminf(downwardMovement, 1.0)
        percentComplete = CGFloat(progress)  // Store the progress

        switch gesture.state {
        case .began:
            interactiveDismiss = true
            viewController?.dismiss(animated: true, completion: nil)
        case .changed:
            if translation.y >= 0 {
                let newCenterY = initialCenter.y + translation.y
                view.center = CGPoint(x: initialCenter.x, y: newCenterY)
                transitionContext?.updateInteractiveTransition(percentComplete)
                dimView?.alpha = 1 - percentComplete
            } else {
                // Prevent the view from moving upwards
                view.center = initialCenter
                percentComplete = 0
                transitionContext?.updateInteractiveTransition(0)
                dimView?.alpha = 1
            }
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            if percentComplete > 0.1 || velocity.y > 300 {
                finishInteractiveTransition()
            } else {
                cancelInteractiveTransition()
            }
            interactiveDismiss = false
        default:
            break
        }
    }

    private func finishInteractiveTransition() {
        guard let transitionContext = transitionContext, let view = viewController?.view else { return }

        // Create spring timing parameters
        let mass: CGFloat = 1.0
        let stiffness: CGFloat = 200.0
        let damping: CGFloat = 20.0
        let initialVelocity = CGVector(dx: 0, dy: 0)
        let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

        animator.addAnimations {
            view.center = CGPoint(x: self.initialCenter.x, y: self.initialCenter.y + view.bounds.height)
            self.dimView?.alpha = 0
        }

        animator.addCompletion { _ in
            view.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.transitionContext = nil
            view.isUserInteractionEnabled = true  // Re-enable user interaction
        }

        animator.startAnimation()
    }

    private func cancelInteractiveTransition() {
        guard let transitionContext = transitionContext, let view = viewController?.view else { return }

        // Create spring timing parameters
        let mass: CGFloat = 1.0
        let stiffness: CGFloat = 200.0
        let damping: CGFloat = 20.0
        let initialVelocity = CGVector(dx: 0, dy: 0)
        let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

        animator.addAnimations {
            view.center = self.initialCenter
            self.dimView?.alpha = 1
        }

        animator.addCompletion { _ in
            transitionContext.completeTransition(false)
            self.transitionContext = nil
            view.isUserInteractionEnabled = true  // Re-enable user interaction
        }

        animator.startAnimation()
    }

    // MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismiss ? self : nil
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    // Create dimView if not already created, and animate it during transitions
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        if isPresenting {
            guard let toView = transitionContext.view(forKey: .to) else { return }

            // Disable user interaction on the toView during the animation
            toView.isUserInteractionEnabled = false

            // Create dimView if it doesn't exist
            if dimView == nil {
                dimView = UIView(frame: containerView.bounds)
                dimView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimView?.alpha = 0  // Start invisible
            }

            // Add dimView and toView to the container
            if let dimView = dimView {
                containerView.addSubview(dimView)
            }
            containerView.addSubview(toView)
            toView.frame = CGRect(x: 0, y: containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)

            // Create spring timing parameters
            let mass: CGFloat = 1.0
            let stiffness: CGFloat = 400.0
            let damping: CGFloat = 40.0
            let initialVelocity = CGVector(dx: 0, dy: 0)
            let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

            animator.addAnimations {
                toView.frame = containerView.bounds
                self.dimView?.alpha = 1  // Fade in dimView
            }

            animator.addCompletion { _ in
                transitionContext.completeTransition(true)
                toView.isUserInteractionEnabled = true  // Re-enable user interaction
            }

            animator.startAnimation()
        } else {
            guard let fromView = transitionContext.view(forKey: .from) else { return }

            // Disable user interaction on the fromView during the animation
            fromView.isUserInteractionEnabled = false

            // Use existing dimView
            let mass: CGFloat = 1.0
            let stiffness: CGFloat = 200.0
            let damping: CGFloat = 20.0
            let initialVelocity = CGVector(dx: 0, dy: 0)
            let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

            let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

            animator.addAnimations {
                fromView.frame = CGRect(x: 0, y: containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)
                self.dimView?.alpha = 0  // Fade out dimView
            }

            animator.addCompletion { _ in
                fromView.removeFromSuperview()
                self.dimView?.removeFromSuperview()
                self.dimView = nil  // Clean up dimView
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                // No need to re-enable user interaction on fromView since it's being removed
            }

            animator.startAnimation()
        }
    }

    // MARK: - UIViewControllerInteractiveTransitioning
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        guard let view = viewController?.view else { return }
        initialCenter = view.center
        view.isUserInteractionEnabled = false  // Disable user interaction during interactive transition
    }
}
