//
//  PDPanelController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "PDPanelController.h"
#import "PDPanelController+Internal.h"
#import "NSArray+PDAdd.h"

static CGFloat const kPanelControllerFloatLeeway = 0.01f;

@interface PDPanelController ()

@property (readonly) BOOL isPortrait;
@property (readonly) NSInteger currentStickyPointIndex;
@property (nonatomic, assign) NSInteger portraitPreviousStickyPointIndex;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint initialInternalScrollViewContentOffset;
@property (nonatomic, assign) CGFloat initialStickyPointOffset;

@end

@implementation PDPanelController

#pragma mark - Setup Methods
- (void)setupWithSuperview:(UIView *)superview initialStickyPointOffset:(CGFloat)initialStickyPointOffset {
    self.initialStickyPointOffset = initialStickyPointOffset;
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [superview addSubview:self.view];

    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 superview.bounds.size.height,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    [self setupPanGestureRecognizer];
    [self setupConstraints];
    [self refreshConstraints:superview.frame.size customTopOffset:superview.frame.size.height - initialStickyPointOffset];
}

- (void)addInternalScrollViewPanGesture {
    [self removeInternalScrollViewPanGestureRecognizer];
    [self.internalScrollView.panGestureRecognizer addTarget:self action:@selector(handleScrollViewGestureRecognizer:)];
}

- (void)removeInternalScrollViewPanGestureRecognizer {
    [self.internalScrollView.panGestureRecognizer removeTarget:self action:@selector(handleScrollViewGestureRecognizer:)];
}

- (void)setupPanGestureRecognizer {
    [self addInternalScrollViewPanGesture];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    _panGestureRecognizer.minimumNumberOfTouches = 1;
    _panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.view addGestureRecognizer:_panGestureRecognizer];
}

- (void)setupConstraints {
    UIView *parentView = self.parentViewController.view;
    if (!parentView) { return; }
    
    self.topConstraint = [self.view.topAnchor constraintEqualToAnchor:parentView.topAnchor];
    self.leftConstraint = [self.view.leftAnchor constraintEqualToAnchor:parentView.leftAnchor];
    self.widthConstraint = [self.view.widthAnchor constraintEqualToConstant:self.preferredSize.width];
    self.heightConstraint = [self.view.heightAnchor constraintEqualToConstant:self.preferredSize.height];
    self.heightConstraint.priority = UILayoutPriorityDefaultLow;
    self.bottomConstraint = [parentView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    
    NSMutableArray *constraints = [NSMutableArray array];
    if (self.topConstraint) { [constraints addObject:self.topConstraint]; }
    if (self.leftConstraint) { [constraints addObject:self.leftConstraint]; }
    if (self.widthConstraint) { [constraints addObject:self.widthConstraint]; }
    if (self.heightConstraint) { [constraints addObject:self.heightConstraint]; }
    if (self.bottomConstraint) { [constraints addObject:self.bottomConstraint]; }
    [NSLayoutConstraint activateConstraints:[constraints copy]];
}

- (void)refreshConstraints:(CGSize)newSize customTopOffset:(CGFloat)customTopOffset {
    if (newSize.height > newSize.width) {
        [self setPortraitConstraints:newSize customTopOffset:customTopOffset];
    } else {
        [self setLandscapeConstraints];
    }
}

- (CGFloat)nearestStickyPointY:(CGFloat)yVelocity {
    NSInteger currentStickyPointIndex = self.currentStickyPointIndex;
    if (fabs(yVelocity) > self.skipPointVerticalVelocityThreshold) {
        if (yVelocity > 0.f) {
            currentStickyPointIndex = MAX(currentStickyPointIndex - 1, 0);
        } else {
            currentStickyPointIndex = MIN(currentStickyPointIndex + 1, self.allStickyPoints.count - 1);
        }
    }
    return self.parentViewController.view.frame.size.height - [self.allStickyPoints[currentStickyPointIndex] doubleValue];
}

- (void)goToNearestStickyPoint:(CGFloat)verticalVelocity {
    if (!self.isPortrait) { return; }
    if (!self.topConstraint) { return; }
    
    CGFloat targetTopOffset = [self nearestStickyPointY:verticalVelocity]; // v = px/s
    CGFloat distanceToConver = self.topConstraint.constant - targetTopOffset; // px
    NSTimeInterval animationDuration = MAX(0.08f, MIN(0.3f, fabs(distanceToConver / verticalVelocity))); // s = px/v
    [self setTopOffset:targetTopOffset animationDuration:animationDuration allowBounce:NO];
}

- (void)setTopOffset:(CGFloat)value animationDuration:(NSTimeInterval)animationDuration allowBounce:(BOOL)allowBounce {
    if (!self.parentViewController) { return; }
    
    CGFloat parentViewHeight = self.parentViewController.view.bounds.size.height;
    
    // Apply right value bounding for the provided bounce offset if needed
    CGFloat topOffset = value;
    
    if (self.allStickyPoints.count > 0) {
        CGFloat firstStickyPoint = [self.allStickyPoints.firstObject doubleValue];
        CGFloat lastStickyPoint = [self.allStickyPoints.lastObject doubleValue];
        
        CGFloat bounceOffset = allowBounce ? self.bounceOffset : 0.f;
        CGFloat minValue = parentViewHeight - lastStickyPoint - bounceOffset;
        CGFloat maxValue = parentViewHeight - firstStickyPoint + bounceOffset;
        
        topOffset = MAX(MIN(value, maxValue), minValue);
    }
    
    CGFloat targetPoint = parentViewHeight - topOffset;
    
    /** `willMoveToStickyPoint` and `didMoveToStickyPoint` should be called only if the user has ended the gesture */
    CGFloat shouldNotifyObserver = animationDuration > 0.f;
    self.topConstraint.constant = topOffset;
    [self didDragToPoint:targetPoint];
    
    if (shouldNotifyObserver) {
        [self willMoveToPoint:targetPoint];
    }
    
    [self animate:PDPanelControllerActionMove duration:animationDuration animations:^{
        [self.parentViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (shouldNotifyObserver) {
            [self didMoveToPoint:targetPoint];
        }
    }];
}

- (void)setPortraitConstraints:(CGSize)parentViewSize customTopOffset:(CGFloat)customTopOffset {
    if (customTopOffset) {
        self.topConstraint.constant = customTopOffset;
    } else {
        self.topConstraint.constant = [self nearestStickyPointY:0.f];
    }
    self.leftConstraint.constant = (parentViewSize.width - MIN(self.preferredSize.width, parentViewSize.width)) / 2.f;
    self.widthConstraint.constant = self.preferredSize.width;
    self.heightConstraint.constant = self.preferredSize.height;
    self.heightConstraint.priority = UILayoutPriorityDefaultLow;
    self.bottomConstraint.constant = 0.f;
}

- (void)setLandscapeConstraints {
    if (!self.parentViewController) { return; }

    CGFloat parentViewHeight = self.parentViewController.view.frame.size.height;
    CGRect landscapeFrame = self.preferredLandscapeFrame;

    self.topConstraint.constant = landscapeFrame.origin.y;
    self.leftConstraint.constant = landscapeFrame.origin.x;
    self.widthConstraint.constant = landscapeFrame.size.width;
    self.heightConstraint.constant = landscapeFrame.size.height;
    self.heightConstraint.priority = UILayoutPriorityDefaultHigh;
    self.bottomConstraint.constant = parentViewHeight - landscapeFrame.size.height - landscapeFrame.origin.y;
}

- (void)hide {
    if (!self.parentViewController) { return; }
    
    self.topConstraint.constant = self.parentViewController.view.frame.size.height;
}

#pragma mark - Gesture Methods
- (void)handleScrollViewGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.isPortrait) { return; }
    if (!self.internalScrollView) { return; }
    if (!self.topConstraint) { return; }
    if (!self.allStickyPoints.count) { return; }
    if (!self.parentViewController.view) { return; }
    
    UIScrollView *scrollView = self.internalScrollView;
    NSLayoutConstraint *topConstraint = self.topConstraint;
    CGFloat lastStickyPoint = [self.allStickyPoints.lastObject doubleValue];
    CGFloat parentViewHeight = self.parentViewController.view.bounds.size.height;

    BOOL isFullOpened = topConstraint.constant <= parentViewHeight - lastStickyPoint;
    CGFloat yTranslation = [gestureRecognizer translationInView:scrollView].y;
    BOOL isScrollingDown = [gestureRecognizer velocityInView:scrollView].y > 0;
    
    /**
     The user should be able to drag the view down through the internal scroll view when
     - the scroll direction is down (`isScrollingDown`)
     - the internal scroll view is scrolled to the top (`scrollView.contentOffset.y <= 0`)
     */
    BOOL shouldDragViewDown = isScrollingDown && scrollView.contentOffset.y <= 0.f;
    
    /**
     The user should be able to drag the view up through the internal scroll view when
     - the scroll direction is up (`!isScrollingDown`)
     - the PullUpController's view is fully opened. (`topConstraint.constant <= parentViewHeight - lastStickyPoint`)
     */
    BOOL shouldDragViewUp = !isScrollingDown && !isFullOpened;
    BOOL shouldDragView = shouldDragViewDown || shouldDragViewUp;
    
    if (shouldDragView) {
        scrollView.bounces = NO;
        [scrollView setContentOffset:CGPointZero animated:NO];
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.initialInternalScrollViewContentOffset = scrollView.contentOffset;
        } break;
        case UIGestureRecognizerStateChanged: {
            if (!shouldDragView) { break; }

            CGFloat topOffset = (self.topConstraint.constant + yTranslation - self.initialInternalScrollViewContentOffset.y);
            [self setTopOffset:topOffset animationDuration:0.f allowBounce:NO];
            [gestureRecognizer setTranslation:self.initialInternalScrollViewContentOffset inView:scrollView];
        } break;
        case UIGestureRecognizerStateEnded: {
            scrollView.bounces = YES;
            [self goToNearestStickyPoint:[gestureRecognizer velocityInView:self.view].y];
        } break;
        default: break;
    }
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.isPortrait) { return; }
    if (!self.topConstraint) { return; }
    
    CGFloat yTranslation = [gestureRecognizer translationInView:self.view].y;
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateChanged: {
            CGFloat topOffset = self.topConstraint.constant + yTranslation;
            [self setTopOffset:topOffset animationDuration:0.f allowBounce:YES];
            [gestureRecognizer setTranslation:CGPointZero inView:self.view];
        } break;
        case UIGestureRecognizerStateEnded: {
            [self goToNearestStickyPoint:[gestureRecognizer velocityInView:self.view].y];
        } break;
        default: break;
    }
}

#pragma mark - Methods Can Override
- (void)willMoveToPoint:(CGFloat)point {}
- (void)didMoveToPoint:(CGFloat)point {}
- (void)didDragToPoint:(CGFloat)point {}

- (void)moveToVisiblePoint:(CGFloat)visiblePoint animated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.isPortrait) { return; }
    if (!self.parentViewController) { return; }
    
    CGFloat parentViewHeight = self.parentViewController.view.frame.size.height;
    self.topConstraint.constant = parentViewHeight - visiblePoint;
    
    [self willMoveToPoint:visiblePoint];
    
    [self animate:PDPanelControllerActionMove duration:animated ? 0.3f : 0.f animations:^{
        [self.parentViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self didMoveToPoint:visiblePoint];
        !completion ?: completion();
    }];
}

- (void)updatePreferredFrameIfNeeded:(BOOL)animated {
    if (!self.parentViewController) { return; }
    
    UIView *parentView = self.parentViewController.view;
    
    [self refreshConstraints:parentView.frame.size
             customTopOffset:parentView.frame.size.height - [self.allStickyPoints.firstObject doubleValue]];
        
    [self animate:PDPanelControllerActionMove duration:animated ? 0.3f : 0.f animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)animate:(PDPanelControllerAction)action
       duration:(NSTimeInterval)duration
     animations:(void (^)(void))animations
     completion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:duration animations:animations completion:completion];
}

#pragma mark - Override Methods
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    BOOL isNewSizePortrait = size.height > size.width;
    CGFloat targetStickyPoint = 0.f;
    NSInteger portraitPreviousStickyPointIndex = self.portraitPreviousStickyPointIndex;
    
    if (!isNewSizePortrait) {
        self.portraitPreviousStickyPointIndex = self.currentStickyPointIndex;
    } else if (portraitPreviousStickyPointIndex < self.allStickyPoints.count) {
        targetStickyPoint = [self.allStickyPoints[portraitPreviousStickyPointIndex] doubleValue];
        self.portraitPreviousStickyPointIndex = 0;
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self refreshConstraints:size customTopOffset:0.f];
        if (targetStickyPoint) {
            [self moveToVisiblePoint:targetStickyPoint animated:YES completion:nil];
        }
    } completion:nil];
}

#pragma mark - Properties Can Override
- (CGSize)preferredSize {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100.f);
}

- (CGRect)preferredLandscapeFrame {
    return CGRectMake(40.f, 40.f, 300.f, [UIScreen mainScreen].bounds.size.height - 40.f);
}

- (NSArray<NSNumber *> *)middleStickyPoints {
    return @[];
}

- (CGFloat)bounceOffset {
    return 0.f;
}

- (CGFloat)currentPointOffset {
    if (!self.parentViewController) { return 0.f; }
    
    CGFloat parentViewHeight = self.parentViewController.view.frame.size.height;
    return parentViewHeight - self.topConstraint.constant;
}

- (CGFloat)skipPointVerticalVelocityThreshold {
    return FLT_MAX;
}

#pragma mark - Getter Methods

- (NSArray<NSNumber *> *)allStickyPoints {
    NSMutableSet *allStickyPoints = [NSMutableSet set];
    [allStickyPoints addObject:@(self.initialStickyPointOffset)];
    [allStickyPoints addObjectsFromArray:[self middleStickyPoints]];
    [allStickyPoints addObject:@(self.preferredSize.height)];

    NSArray *sortedPoints = [[allStickyPoints allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
        return ([obj1 doubleValue] < [obj2 doubleValue] ? NSOrderedAscending : NSOrderedDescending);
    }];
    return sortedPoints;
}

- (BOOL)isPortrait {
    return [UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width;
}

- (NSInteger)currentStickyPointIndex {
    CGFloat stickyPointTreshold = self.parentViewController.view.frame.size.height - self.topConstraint.constant;
    
    NSArray<NSNumber *> *stickyPointsLessCurrentPosition = [[self allStickyPoints] map:^id _Nonnull(NSNumber * _Nonnull obj, NSUInteger idx) {
        return @(ABS([obj doubleValue] - stickyPointTreshold));
    }];

    CGFloat minStickyPointDifference = 0.f;
    if (stickyPointsLessCurrentPosition.count > 0) {
        minStickyPointDifference = [stickyPointsLessCurrentPosition.firstObject doubleValue];
        for (NSInteger i = 1; i < stickyPointsLessCurrentPosition.count; i++) {
            NSNumber *number = stickyPointsLessCurrentPosition[i];
            minStickyPointDifference = MIN(minStickyPointDifference, [number doubleValue]);
        }
    }
    
    for (NSInteger i = 0; i < stickyPointsLessCurrentPosition.count; i++) {
        NSNumber *number = stickyPointsLessCurrentPosition[i];
        if (fabs([number doubleValue] - minStickyPointDifference) < kPanelControllerFloatLeeway) {
            return i;
        }
    }
    return 0;
}

@end
