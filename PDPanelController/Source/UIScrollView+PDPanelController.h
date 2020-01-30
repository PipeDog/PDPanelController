//
//  UIScrollView+PDPanelController.h
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PDPanelController;

@interface UIScrollView (PDPanelController)

/**
 Attach the scroll view to the provided pull up controller in order to move it with the scroll view content.
 @param panelController the panel controller to move with the current scroll view content.
 */
- (void)pd_attach:(PDPanelController *)panelController;

/**
 Remove the scroll view from the pull up controller so it no longer moves with the scroll view content.
 @param panelController the panel controller to be removed from controlling the scroll view.
 */
- (void)pd_detach:(PDPanelController *)panelController;

@end

NS_ASSUME_NONNULL_END
