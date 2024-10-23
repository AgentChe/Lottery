import UIKit

class FullTicketCustomTransitionManager: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

    var isPresenting = false
    var interactiveDismiss = false
    var panGestureRecognizer: UIPanGestureRecognizer!
    weak var viewController: UIViewController?
    var transitionContext: UIViewControllerContextTransitioning?
    var initialCenter: CGPoint = .zero
    var percentComplete: CGFloat = 0.0  // Add this property to store progress

    // Set up the gesture recognizer to track the swipe-down gesture
    func setupGestureRecognizer(in viewController: UIViewController) {
        self.viewController = viewController
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        viewController.view.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = viewController?.view else { return }
        let translation = gesture.translation(in: view)
        let progress = max(0, min(translation.y / view.bounds.height, 1))
        percentComplete = progress  // Store the progress

        switch gesture.state {
        case .began:
            interactiveDismiss = true
            viewController?.dismiss(animated: true, completion: nil)
        case .changed:
            view.center = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            transitionContext?.updateInteractiveTransition(progress)
        case .ended, .cancelled:
            let velocity = gesture.velocity(in: view)
            if progress > 0.5 || velocity.y > 1000 {
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
        
        // Calculate the initial velocity based on the gesture's velocity
        let velocity = panGestureRecognizer.velocity(in: view)
        let initialVelocity = CGVector(dx: velocity.x / view.bounds.width, dy: velocity.y / view.bounds.height)
        
        // Create spring timing parameters
        let mass: CGFloat = 1.0
        let stiffness: CGFloat = 200.0
        let damping: CGFloat = 20.0
        let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
        
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)
        
        animator.addAnimations {
            view.center = CGPoint(x: self.initialCenter.x, y: self.initialCenter.y + view.bounds.height)
        }
        
        animator.addCompletion { _ in
            view.removeFromSuperview()
            transitionContext.completeTransition(true)
            self.transitionContext = nil
        }
        
        animator.startAnimation()
    }


    private func cancelInteractiveTransition() {
        guard let transitionContext = transitionContext, let view = viewController?.view else { return }
        
        // Calculate the initial velocity based on the gesture's velocity
        let velocity = panGestureRecognizer.velocity(in: view)
        let initialVelocity = CGVector(dx: velocity.x / view.bounds.width, dy: velocity.y / view.bounds.height)
        
        // Create spring timing parameters
        let mass: CGFloat = 1.0
        let stiffness: CGFloat = 200.0
        let damping: CGFloat = 20.0
        let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)
        
        let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)
        
        animator.addAnimations {
            view.center = self.initialCenter
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(false)
            self.transitionContext = nil
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

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
           let containerView = transitionContext.containerView

           if isPresenting {
               guard let toView = transitionContext.view(forKey: .to) else { return }
               containerView.addSubview(toView)
               toView.frame = CGRect(x: 0, y: containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)

               // Create spring timing parameters
               let mass: CGFloat = 1.0
               let stiffness: CGFloat = 200.0
               let damping: CGFloat = 20.0
               let initialVelocity = CGVector(dx: 0, dy: 0)
               let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

               // Create a property animator with the spring timing parameters
               let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

               animator.addAnimations {
                   toView.frame = containerView.bounds
               }

               animator.addCompletion { _ in
                   transitionContext.completeTransition(true)
               }

               animator.startAnimation()
           } else {
               guard let fromView = transitionContext.view(forKey: .from) else { return }

               // Create spring timing parameters
               let mass: CGFloat = 1.0
               let stiffness: CGFloat = 200.0
               let damping: CGFloat = 20.0
               let initialVelocity = CGVector(dx: 0, dy: 0)
               let springTimingParameters = UISpringTimingParameters(mass: mass, stiffness: stiffness, damping: damping, initialVelocity: initialVelocity)

               // Create a property animator with the spring timing parameters
               let animator = UIViewPropertyAnimator(duration: 0, timingParameters: springTimingParameters)

               animator.addAnimations {
                   fromView.frame = CGRect(x: 0, y: containerView.frame.height, width: containerView.frame.width, height: containerView.frame.height)
               }

               animator.addCompletion { _ in
                   fromView.removeFromSuperview()
                   transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
               }

               animator.startAnimation()
           }
       }


    // MARK: - UIViewControllerInteractiveTransitioning
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        guard let view = viewController?.view else { return }
        initialCenter = view.center
    }
}
