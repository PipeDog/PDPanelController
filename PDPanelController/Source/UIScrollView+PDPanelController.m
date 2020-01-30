//
//  UIScrollView+PDPanelController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "UIScrollView+PDPanelController.h"
#import "PDPanelController+Internal.h"

@implementation UIScrollView (PDPanelController)

- (void)pd_attach:(PDPanelController *)panelController {
    [panelController.internalScrollView pd_detach:panelController];
    panelController.internalScrollView = self;
    [panelController addInternalScrollViewPanGesture];
}

- (void)pd_detach:(PDPanelController *)panelController {
    [panelController removeInternalScrollViewPanGestureRecognizer];
    panelController.internalScrollView = nil;
}

@end
