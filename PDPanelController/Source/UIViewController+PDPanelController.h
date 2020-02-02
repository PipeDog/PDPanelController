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
 Adds the specified panel view controller as a child of the current view controller.
 
 @param panelController the panel controller to add as a child of the current view controller.
 @param initialGlueLocation The point where the provided `panelController`'s view will be initially placed expressed in screen units of the panel controller coordinate system. If this value is not provided, the `panelController`'s view will be initially placed expressed
 @param animated Pass true to animate the adding; otherwise, pass false.
 */
- (void)pd_addPanelController:(PDPanelController *)panelController
          initialGlueLocation:(CGFloat)initialGlueLocation
                     animated:(BOOL)animated;

/**
 Adds the specified panel view controller as a child of the current view controller.

 @param panelController the panel controller to remove as a child from the current view controller.
 @param animated Pass true to animate the removing; otherwise, pass false.
 */
- (void)pd_removePanelController:(PDPanelController *)panelController animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
