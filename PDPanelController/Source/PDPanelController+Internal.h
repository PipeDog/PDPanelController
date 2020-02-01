//
//  PDPanelController+Internal.h
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDPanelController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDPanelController ()

@property (nonatomic, weak) UIScrollView *internalScrollView;

- (void)setupWithSuperview:(UIView *)superview initialGlueLocation:(CGFloat)initialGlueLocation;
- (void)addInternalScrollViewPanGesture;
- (void)removeInternalScrollViewPanGestureRecognizer;
- (void)hide;
- (void)animateWithAction:(PDPanelControllerAction)action
                 duration:(NSTimeInterval)duration
               animations:(void (^)(void))animations
               completion:(void (^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
