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

@class PDPanelController;

@protocol PDPanelContentViewControllerDelegate;
@protocol PDPanelControllerDelegate, PDPanelControllerLayoutDelegate, PDPanelControllerAnimationDelegate;

typedef NS_ENUM(NSUInteger, PDPanelControllerAction) {
    PDPanelControllerActionAdd      = 1, ///< The action used when the panel controller's view is added to its parent view.
    PDPanelControllerActionRemove   = 2, ///< The action used when the panel controller's view is removed to its parent view.
    PDPanelControllerActionMove     = 3, ///< The action used when the panel controller's view position change.
};


@interface PDPanelController : UIViewController

@property (nonatomic, strong, nullable) UIViewController<PDPanelContentViewControllerDelegate> *contentViewController;

@property (nonatomic, weak, nullable) id<PDPanelControllerDelegate> delegate;
@property (nonatomic, weak, nullable) id<PDPanelControllerLayoutDelegate> layoutDelegate;
@property (nonatomic, weak, nullable) id<PDPanelControllerAnimationDelegate> animationDelegate;

@property (nonatomic, readonly) CGFloat currentLocation;
@property (nonatomic, readonly) NSArray<NSNumber *> *allGlueLocations;

- (void)moveToVisibleLocation:(CGFloat)location
                  animated:(BOOL)animated
                completion:(void (^__nullable)(void))completion;

- (void)updatePreferredFrameIfNeeded:(BOOL)animated;
- (void)updatePreferredFrameIfNeeded:(BOOL)animated withLocation:(CGFloat)location;

@end

@protocol PDPanelContentViewControllerDelegate <NSObject>

@optional
- (void)willAddToPanelController:(PDPanelController *)panelController;
// Attach scrollView here if needed.
- (void)didAddToPanelController:(PDPanelController *)panelController;

// Detach scrollView in the following methods if needed.
- (void)willRemoveFromPanelController:(PDPanelController *)panelController;
- (void)didRemoveFromPanelController:(PDPanelController *)panelController;

@end

@protocol PDPanelControllerDelegate <NSObject>

@optional
- (NSArray<NSNumber *> *)middleGlueLocationsInPanelController:(PDPanelController *)panelController;
- (CGFloat)bounceOffsetInPanelController:(PDPanelController *)panelController;
- (CGFloat)skipLocationVerticalVelocityThresholdInPanelController:(PDPanelController *)panelController;

- (void)panelController:(PDPanelController *)panelController willMoveToLocation:(CGFloat)location;
- (void)panelController:(PDPanelController *)panelController didMoveToLocation:(CGFloat)location;
- (void)panelController:(PDPanelController *)panelController didDragToLocation:(CGFloat)location;

@end

@protocol PDPanelControllerLayoutDelegate <NSObject>

@optional
- (CGSize)preferredSizeForPanelController:(PDPanelController *)panelController;
- (CGRect)preferredLandscapeFrameForPanelController:(PDPanelController *)panelController;

@end

@protocol PDPanelControllerAnimationDelegate <NSObject>

@optional
- (void)animateForPanelController:(PDPanelController *)panelController
                           action:(PDPanelControllerAction)action
                         duration:(NSTimeInterval)duration
                       animations:(void (^)(void))animations
                       completion:(void (^ __nullable)(BOOL finished))completion;

/* This method is called when the view controller's view's size is changed by its
    parent (i.e. for the root view controller when its window rotates or is resized). */
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
              forPanelController:(PDPanelController *)panelController;

@end

NS_ASSUME_NONNULL_END
