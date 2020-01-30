//
//  PDPanelController.h
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+PDPanelController.h"
#import "UIScrollView+PDPanelController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDPanelControllerAction) {
    PDPanelControllerActionAdd      = 1, ///< The action used when the pull up controller's view is added to its parent view.
    PDPanelControllerActionRemove   = 2, ///< The action used when the pull up controller's view is removed to its parent view.
    PDPanelControllerActionMove     = 3, ///< The action used when the pull up controller's view position change.
};

@interface PDPanelController : UIViewController

#pragma mark - Properties Can Override
/**
  The desired size of the pull up controller’s view, in screen units.
  The default value is width: [UIScreen mainScreen].bounds.size.width, height: [UIScreen mainScreen].bounds.size.height - 100.f.
 */
@property (readonly) CGSize preferredSize;

/**
  The desired size of the pull up controller’s view, in screen units when the device is in landscape mode.
  The default value is (x: 40, y: 40, width: 300, height: [UIScreen mainScreen].bounds.size.height - 40).
 */
@property (readonly) CGRect preferredLandscapeFrame;

/**
 A list of y values, in screen units expressed in the pull up controller coordinate system.
 At the end of the gestures the pull up controller will scroll to the nearest point in the list.

 Please keep in mind that this array should contains only sticky points in the middle of the pull up controller's view;
 There is therefore no need to add the fist one (pullUpControllerPreviewOffset), and/or the last one (pullUpControllerPreferredSize.height).

 For a complete list of all the sticky points you can use `pullUpControllerAllStickyPoints`.
 
 @return CGFloat value list
 */
@property (readonly) NSArray<NSNumber *> *middleStickyPoints;

/**
  A CGFloat value that determines how much the pull up controller's view can bounce outside it's size.
  The default value is 0 and that means the the view cannot expand beyond its size.
 */
@property (readonly) CGFloat bounceOffset;

/**
 A CGFloat value that represent the current point, expressed in the pull up controller coordinate system,
 where the pull up controller's view is positioned.
 */
@property (readonly) CGFloat currentPointOffset;

/**
  A CGFloat value that represent the vertical velocity threshold (expressed in points/sec) beyond wich
  the target sticky point is skippend and the view is positioned to the next one.
 */
@property (readonly) CGFloat skipPointVerticalVelocityThreshold;

#pragma mark - Public Properties
/**
  A list of y values, in screen units expressed in the pull up controller coordinate system.
  At the end of the gesture the pull up controller will scroll at the nearest point in the list.
 */
@property (readonly) NSArray<NSNumber *> *allStickyPoints;

#pragma mark - Methods Can Override
/**
  This method is called before the pull up controller's view move to a point.
  The default implementation of this method does nothing.
 
  @param point The target point, expressed in the pull up controller coordinate system
 */
- (void)willMoveToPoint:(CGFloat)point;

/**
 This method is called after the pull up controller's view move to a point.
 The default implementation of this method does nothing.
 
 @param point The target point, expressed in the pull up controller coordinate system
 */
- (void)didMoveToPoint:(CGFloat)point;

/**
 This method is called after the pull up controller's view is dragged to a point.
 The default implementation of this method does nothing.
 
 @param point The target sticky point, expressed in the pull up controller coordinate system
 */
- (void)didDragToPoint:(CGFloat)point;

/**
  This method will move the pull up controller's view in order to show the provided visible point.
  You may use on of `pullUpControllerAllStickyPoints` item to provide a valid visible point.
 
  @param visiblePoint the y value to make visible, in screen units expressed in the pull up controller coordinate system.
  @param animated Pass true to animate the move; otherwise, pass false.
  @param completion The closure to execute after the animation is completed. This block has no return value and takes no parameters. You may specify nil for this parameter.
 */
- (void)moveToVisiblePoint:(CGFloat)visiblePoint
                  animated:(BOOL)animated
                completion:(void (^__nullable)(void))completion;

/**
  This method update the pull up controller's view size according to `pullUpControllerPreferredSize` and `pullUpControllerPreferredLandscapeFrame`.
  If the device is in portrait, the pull up controller's view will be attached to the nearest sticky point after the resize.
  - parameter animated: Pass true to animate the resize; otherwise, pass false.
 */
- (void)updatePreferredFrameIfNeeded:(BOOL)animated;

/**
  This method will be called when an animation needs to be performed.
  You can consider override this method and customize the animation using the method
  `UIView.animate(withDuration:, delay:, usingSpringWithDamping:, initialSpringVelocity:, options:, animations:, completion:)`
 
  @param action The action that is about to be performed, see `PullUpController.Action` for more info
  @param duration The total duration of the animations, measured in seconds. If you specify a negative value or 0, the changes are made without animating them.
  @param animations A block object containing the changes to commit to the views.
  @param completion A block object to be executed when the animation sequence ends.
 */
- (void)animate:(PDPanelControllerAction)action
       duration:(NSTimeInterval)duration
     animations:(void (^)(void))animations
     completion:(void (^ __nullable)(BOOL finished))completion;

/**
 Note: System method
 
 This method is called when the view controller's view's size is changed by its parent (i.e. for the root view controller when its window rotates or is resized).
 
 If you override this method, you should either call super to propagate the change to children or manually forward the change to children.
 */
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

NS_ASSUME_NONNULL_END
