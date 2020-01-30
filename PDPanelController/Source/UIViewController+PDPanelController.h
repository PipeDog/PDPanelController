//
//  UIViewController+PDPanelController.h
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDPanelController;

@interface UIViewController (PDPanelController)

/**
 Adds the specified pull up view controller as a child of the current view controller.
 
 @param panelController the pull up controller to add as a child of the current view controller.
 @param initialStickyPointOffset The point where the provided `pullUpController`'s view will be initially placed expressed in screen units of the pull up controller coordinate system. If this value is not provided, the `pullUpController`'s view will be initially placed expressed
 @param animated Pass true to animate the adding; otherwise, pass false.
 */
- (void)pd_addPanelController:(PDPanelController *)panelController
     initialStickyPointOffset:(CGFloat)initialStickyPointOffset
                     animated:(BOOL)animated;

/**
 Adds the specified pull up view controller as a child of the current view controller.

 @param panelController the pull up controller to remove as a child from the current view controller.
 @param animated Pass true to animate the removing; otherwise, pass false.
 */
- (void)pd_removePanelController:(PDPanelController *)panelController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
