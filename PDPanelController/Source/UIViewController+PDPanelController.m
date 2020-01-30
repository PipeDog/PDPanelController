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
     initialStickyPointOffset:(CGFloat)initialStickyPointOffset
                     animated:(BOOL)animated {
    NSAssert(![self isKindOfClass:[UITableViewController class]], @"It's not possible to attach a PullUpController to a UITableViewController.");
    [self addChildViewController:panelController];
    [panelController setupWithSuperview:self.view initialStickyPointOffset:initialStickyPointOffset];

    if (animated) {
        [panelController animate:PDPanelControllerActionAdd duration:0.3f animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

- (void)pd_removePanelController:(PDPanelController *)panelController animated:(BOOL)animated {
    [panelController hide];
    
    if (animated) {
        [panelController animate:PDPanelControllerActionRemove duration:0.3f animations:^{
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
