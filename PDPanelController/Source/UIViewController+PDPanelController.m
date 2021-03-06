//
//  UIViewController+PDPanelController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "UIViewController+PDPanelController.h"
#import "PDPanelController+Internal.h"

@implementation UIViewController (PDPanelController)

- (void)pd_addPanelController:(PDPanelController *)panelController
          initialGlueLocation:(CGFloat)initialGlueLocation
                     animated:(BOOL)animated {    
    [self addChildViewController:panelController];
    [panelController setupWithSuperview:self.view initialGlueLocation:initialGlueLocation];

    if (animated) {
        [panelController animateWithAction:PDPanelControllerActionAdd duration:0.3f animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)pd_removePanelController:(PDPanelController *)panelController animated:(BOOL)animated {
    [panelController hide];
    
    if (animated) {
        [panelController animateWithAction:PDPanelControllerActionRemove duration:0.3f animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [panelController willMoveToParentViewController:nil];
            [panelController.view removeFromSuperview];
            [panelController removeFromParentViewController];
        }];
    } else {
        [self.view layoutIfNeeded];
        [panelController willMoveToParentViewController:nil];
        [panelController.view removeFromSuperview];
        [panelController removeFromParentViewController];
    }
}

@end
