
import UIKit

final class CellAnimator: NSObject {
    
    enum TransitionMode {
        case present
        case dismiss
    }
    
    private let transitionMode: TransitionMode
    private let duration: CGFloat
    private let startingPoint: CGPoint
    
    init(duration: CGFloat, transitionMode: TransitionMode, startingPoint: CGPoint) {
        self.duration = duration
        self.transitionMode = transitionMode
        self.startingPoint = startingPoint
    }
}

extension CellAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        switch self.transitionMode {
        case .present:
            guard let presentedView = transitionContext.view(forKey: UITransitionContextViewKey.to) else {
                transitionContext.completeTransition(false)
                return
            }
            
            let viewCenter = presentedView.center
            presentedView.center = self.startingPoint
            
            presentedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            containerView.addSubview(presentedView)
            
            UIView.animate(withDuration: self.duration) {
                presentedView.center = viewCenter
                presentedView.transform = CGAffineTransform.identity
            } completion: { finished in
                transitionContext.completeTransition(finished)
            }
        case .dismiss:
            guard let dissmisedView = transitionContext.view(forKey: UITransitionContextViewKey.from) else {
                transitionContext.completeTransition(false)
                return
            }
            
            containerView.addSubview(dissmisedView)
            
            UIView.animate(withDuration: self.duration) {
                dissmisedView.center = self.startingPoint
                dissmisedView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            } completion: { finished in
                dissmisedView.removeFromSuperview()
                transitionContext.completeTransition(finished)
            }
        }
    }
}
