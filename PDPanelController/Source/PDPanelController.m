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

@interface PDPanelController () {
    struct {
        unsigned middleGlueLocationsInPanelController : 1;
        unsigned bounceOffsetInPanelController : 1;
        unsigned skipLocationVerticalVelocityThresholdInPanelController : 1;
        unsigned willMoveToLocation : 1;
        unsigned didMoveToLocation : 1;
        unsigned didDragToLocation : 1;
    } _delegateHas;
    
    struct {
        unsigned preferredSizeForPanelController : 1;
        unsigned preferredLandscapeFrameForPanelController : 1;
    } _layoutDelegateHas;
    
    struct {
        unsigned animateForPanelController : 1;
        unsigned viewWillTransitionToSize : 1;
    } _animationDelegateHas;
}

@property (nonatomic, readonly) BOOL isPortrait;
@property (nonatomic, readonly) NSInteger currentGlueLocationIndex;
@property (nonatomic, assign) NSInteger portraitPreviousGlueLocationIndex;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint initialInternalScrollViewContentOffset;
@property (nonatomic, assign) CGFloat initialGlueLocation;

@end

@implementation PDPanelController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    UIViewController *controller;
    return [self initWithContentViewController:controller];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    UIViewController *controller;
    return [self initWithContentViewController:controller];
}

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController {
    NSAssert(contentViewController, @"The argument `contentViewController` can not be nil!");
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _contentViewController = contentViewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commitInit];
    [self createViewHierarchy];
    [self layoutContentViews];
}

- (void)commitInit {
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self addChildViewController:self.contentViewController];
}

- (void)createViewHierarchy {
    [self.view addSubview:self.contentViewController.view];
}

- (void)layoutContentViews {
    UIViewController *controller = self.contentViewController;
    [NSLayoutConstraint activateConstraints:@[
        [controller.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [controller.view.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [controller.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [controller.view.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    ]];
}

#pragma mark - Internal Methods
- (void)setupWithSuperview:(UIView *)superview initialGlueLocation:(CGFloat)initialGlueLocation {
    self.initialGlueLocation = initialGlueLocation;
    [superview addSubview:self.view];

    self.view.frame = CGRectMake(self.view.frame.origin.x,
                                 superview.bounds.size.height,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    [self setupPanGestureRecognizer];
    [self setupConstraints];
    [self refreshConstraints:superview.frame.size customTopOffset:superview.frame.size.height - initialGlueLocation];
}

- (void)addInternalScrollViewPanGesture {
    [self removeInternalScrollViewPanGestureRecognizer];
    [self.internalScrollView.panGestureRecognizer addTarget:self action:@selector(handleScrollViewGestureRecognizer:)];
}

- (void)removeInternalScrollViewPanGestureRecognizer {
    [self.internalScrollView.panGestureRecognizer removeTarget:self action:@selector(handleScrollViewGestureRecognizer:)];
}

- (void)hide {
    if (!self.parentViewController) { return; }
    
    self.topConstraint.constant = self.parentViewController.view.frame.size.height;
}

- (void)animateWithAction:(PDPanelControllerAction)action
                 duration:(NSTimeInterval)duration
               animations:(void (^)(void))animations
               completion:(void (^)(BOOL))completion {
    if (_animationDelegateHas.animateForPanelController) {
        [self.animationDelegate animateForPanelController:self action:action duration:duration animations:animations completion:completion];
        return;
    }
    [UIView animateWithDuration:duration animations:animations completion:completion];
}

#pragma mark - Gesture Methods
- (void)handleScrollViewGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!self.isPortrait) { return; }
    if (!self.internalScrollView) { return; }
    if (!self.topConstraint) { return; }
    if (!self.allGlueLocations.count) { return; }
    if (!self.parentViewController.view) { return; }
    
    UIScrollView *scrollView = self.internalScrollView;
    NSLayoutConstraint *topConstraint = self.topConstraint;
    CGFloat lastGlueLocation = [self.allGlueLocations.lastObject doubleValue];
    CGFloat parentViewHeight = self.parentViewController.view.bounds.size.height;

    BOOL isFullOpened = topConstraint.constant <= parentViewHeight - lastGlueLocation;
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
     - the PullUpController's view is fully opened. (`topConstraint.constant <= parentViewHeight - lastGlueLocation`)
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
            [self gotoNearestGlueLocation:[gestureRecognizer velocityInView:self.view].y];
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
            [self gotoNearestGlueLocation:[gestureRecognizer velocityInView:self.view].y];
        } break;
        default: break;
    }
}

#pragma mark - Setup Methods
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

- (CGFloat)nearestGlueLocation:(CGFloat)yVelocity {
    NSInteger currentGlueLocationIndex = self.currentGlueLocationIndex;
    if (fabs(yVelocity) > [self skipLocationVerticalVelocityThreshold]) {
        if (yVelocity > 0.f) {
            currentGlueLocationIndex = MAX(currentGlueLocationIndex - 1, 0);
        } else {
            currentGlueLocationIndex = MIN(currentGlueLocationIndex + 1, self.allGlueLocations.count - 1);
        }
    }
    return self.parentViewController.view.frame.size.height - [self.allGlueLocations[currentGlueLocationIndex] doubleValue];
}

- (void)gotoNearestGlueLocation:(CGFloat)verticalVelocity {
    if (!self.isPortrait) { return; }
    if (!self.topConstraint) { return; }
    
    CGFloat targetTopOffset = [self nearestGlueLocation:verticalVelocity]; // v = px/s
    CGFloat distanceToConver = self.topConstraint.constant - targetTopOffset; // px
    NSTimeInterval animationDuration = MAX(0.08f, MIN(0.3f, fabs(distanceToConver / verticalVelocity))); // s = px/v
    [self setTopOffset:targetTopOffset animationDuration:animationDuration allowBounce:NO];
}

- (void)setTopOffset:(CGFloat)value animationDuration:(NSTimeInterval)animationDuration allowBounce:(BOOL)allowBounce {
    if (!self.parentViewController) { return; }
    
    CGFloat parentViewHeight = self.parentViewController.view.bounds.size.height;
    
    // Apply right value bounding for the provided bounce offset if needed
    CGFloat topOffset = value;
    
    if (self.allGlueLocations.count > 0) {
        CGFloat firstGlueLocation = [self.allGlueLocations.firstObject doubleValue];
        CGFloat lastGlueLocation = [self.allGlueLocations.lastObject doubleValue];
        
        CGFloat bounceOffset = allowBounce ? self.bounceOffset : 0.f;
        CGFloat minValue = parentViewHeight - lastGlueLocation - bounceOffset;
        CGFloat maxValue = parentViewHeight - firstGlueLocation + bounceOffset;
        
        topOffset = MAX(MIN(value, maxValue), minValue);
    }
    
    CGFloat targetPoint = parentViewHeight - topOffset;
    
    /** `willMoveToLocation` and `didMoveToLocation` should be called only if the user has ended the
        gesture (The argument `animationDuration` shoule be 0.f when you do not need notify someone.) */
    CGFloat shouldNotifyObserver = animationDuration > 0.f;
    self.topConstraint.constant = topOffset;

    if (_delegateHas.didDragToLocation) {
        [self.delegate panelController:self didDragToLocation:targetPoint];
    }
    
    if (shouldNotifyObserver && _delegateHas.willMoveToLocation) {
        [self.delegate panelController:self willMoveToLocation:targetPoint];
    }
    
    [self animateWithAction:PDPanelControllerActionMove duration:animationDuration animations:^{
        [self.parentViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (shouldNotifyObserver && self->_delegateHas.didMoveToLocation) {
            [self.delegate panelController:self didMoveToLocation:targetPoint];
        }
    }];
}

- (void)setPortraitConstraints:(CGSize)parentViewSize customTopOffset:(CGFloat)customTopOffset {
    if (customTopOffset) {
        self.topConstraint.constant = customTopOffset;
    } else {
        self.topConstraint.constant = [self nearestGlueLocation:0.f];
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

#pragma mark - Public Methods
- (void)moveToVisibleLocation:(CGFloat)location animated:(BOOL)animated completion:(void (^)(void))completion {
    if (!self.isPortrait) { return; }
    if (!self.parentViewController) { return; }
    
    CGFloat parentViewHeight = self.parentViewController.view.frame.size.height;
    self.topConstraint.constant = parentViewHeight - location;
    
    if (_delegateHas.willMoveToLocation) {
        [self.delegate panelController:self willMoveToLocation:location];
    }
    
    [self animateWithAction:PDPanelControllerActionMove duration:animated ? 0.3f : 0.f animations:^{
        [self.parentViewController.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self->_delegateHas.didMoveToLocation) {
            [self.delegate panelController:self didMoveToLocation:location];
        }
        !completion ?: completion();
    }];
}

- (void)updatePreferredFrameIfNeeded:(BOOL)animated {
    CGFloat location = [self.allGlueLocations.firstObject doubleValue];
    [self updatePreferredFrameIfNeeded:animated withLocation:location];
}

- (void)updatePreferredFrameIfNeeded:(BOOL)animated withLocation:(CGFloat)location {
    if (!self.parentViewController) { return; }
    
    UIView *parentView = self.parentViewController.view;
    
    [self refreshConstraints:parentView.frame.size
             customTopOffset:parentView.frame.size.height - location];
        
    [self animateWithAction:PDPanelControllerActionMove duration:animated ? 0.3f : 0.f animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - Override Methods
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (_animationDelegateHas.viewWillTransitionToSize) {
        [self.animationDelegate viewWillTransitionToSize:size withTransitionCoordinator:coordinator forPanelController:self];
        return;
    }

    BOOL isNewSizePortrait = size.height > size.width;
    CGFloat targetGlueLocation = DBL_MIN;
    NSInteger portraitPreviousGlueLocationIndex = self.portraitPreviousGlueLocationIndex;
    
    if (!isNewSizePortrait) {
        self.portraitPreviousGlueLocationIndex = self.currentGlueLocationIndex;
    } else if (portraitPreviousGlueLocationIndex < self.allGlueLocations.count) {
        targetGlueLocation = [self.allGlueLocations[portraitPreviousGlueLocationIndex] doubleValue];
        self.portraitPreviousGlueLocationIndex = 0;
    }

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self refreshConstraints:size customTopOffset:0.f];
        if (targetGlueLocation != DBL_MIN) {
            [self moveToVisibleLocation:targetGlueLocation animated:YES completion:nil];
        }
    } completion:nil];
}

#pragma mark - Convenience Methods
- (CGSize)preferredSize {
    if (_layoutDelegateHas.preferredSizeForPanelController) {
        return [self.layoutDelegate preferredSizeForPanelController:self];
    }
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 100.f);
}

- (CGRect)preferredLandscapeFrame {
    if (_layoutDelegateHas.preferredLandscapeFrameForPanelController) {
        return [self.layoutDelegate preferredLandscapeFrameForPanelController:self];
    }
    return CGRectMake(40.f, 40.f, 300.f, [UIScreen mainScreen].bounds.size.height - 40.f);
}

- (NSArray<NSNumber *> *)middleGlueLocations {
    if (_delegateHas.middleGlueLocationsInPanelController) {
        return [self.delegate middleGlueLocationsInPanelController:self];
    }
    return @[];
}

- (CGFloat)bounceOffset {
    if (_delegateHas.bounceOffsetInPanelController) {
        return [self.delegate bounceOffsetInPanelController:self];
    }
    return 0.f;
}

- (CGFloat)currentLocation {
    if (!self.parentViewController) { return 0.f; }
    
    CGFloat parentViewHeight = self.parentViewController.view.frame.size.height;
    return parentViewHeight - self.topConstraint.constant;
}

- (CGFloat)skipLocationVerticalVelocityThreshold {
    if (_delegateHas.skipLocationVerticalVelocityThresholdInPanelController) {
        return [self.delegate skipLocationVerticalVelocityThresholdInPanelController:self];
    }
    return FLT_MAX;
}

#pragma mark - Setter Methods
- (void)setDelegate:(id<PDPanelControllerDelegate>)delegate {
    _delegate = delegate;

    _delegateHas.middleGlueLocationsInPanelController = [_delegate respondsToSelector:@selector(middleGlueLocationsInPanelController:)];
    _delegateHas.bounceOffsetInPanelController = [_delegate respondsToSelector:@selector(bounceOffsetInPanelController:)];
    _delegateHas.skipLocationVerticalVelocityThresholdInPanelController = [_delegate respondsToSelector:@selector(skipLocationVerticalVelocityThresholdInPanelController:)];
    _delegateHas.willMoveToLocation = [_delegate respondsToSelector:@selector(panelController:willMoveToLocation:)];
    _delegateHas.didMoveToLocation = [_delegate respondsToSelector:@selector(panelController:didMoveToLocation:)];
    _delegateHas.didDragToLocation = [_delegate respondsToSelector:@selector(panelController:didDragToLocation:)];
}

- (void)setLayoutDelegate:(id<PDPanelControllerLayoutDelegate>)layoutDelegate {
    _layoutDelegate = layoutDelegate;
    
    _layoutDelegateHas.preferredSizeForPanelController = [_layoutDelegate respondsToSelector:@selector(preferredSizeForPanelController:)];
    _layoutDelegateHas.preferredLandscapeFrameForPanelController = [_layoutDelegate respondsToSelector:@selector(preferredLandscapeFrameForPanelController:)];
}

- (void)setAnimationDelegate:(id<PDPanelControllerAnimationDelegate>)animationDelegate {
    _animationDelegate = animationDelegate;

    _animationDelegateHas.animateForPanelController = [_animationDelegate respondsToSelector:@selector(animateForPanelController:action:duration:animations:completion:)];
    _animationDelegateHas.viewWillTransitionToSize = [_animationDelegate respondsToSelector:@selector(viewWillTransitionToSize:withTransitionCoordinator:forPanelController:)];
}

#pragma mark - Getter Methods
- (NSArray<NSNumber *> *)allGlueLocations {
    NSMutableSet *allGlueLocations = [NSMutableSet set];
    [allGlueLocations addObject:@(self.initialGlueLocation)];
    [allGlueLocations addObjectsFromArray:[self middleGlueLocations]];
    [allGlueLocations addObject:@(self.preferredSize.height)];

    NSArray *sortedLocations = [[allGlueLocations allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSNumber * _Nonnull obj1, NSNumber * _Nonnull obj2) {
        return ([obj1 doubleValue] < [obj2 doubleValue] ? NSOrderedAscending : NSOrderedDescending);
    }];
    return sortedLocations;
}

- (BOOL)isPortrait {
    return [UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width;
}

- (NSInteger)currentGlueLocationIndex {
    CGFloat glueLocationThreshold = self.parentViewController.view.frame.size.height - self.topConstraint.constant;
    
    NSArray<NSNumber *> *diffs = [[self allGlueLocations] map:^id _Nonnull(NSNumber * _Nonnull obj, NSUInteger idx) {
        return @(ABS([obj doubleValue] - glueLocationThreshold));
    }];

    CGFloat minDiff = 0.f;
    if (diffs.count > 0) {
        minDiff = [diffs.firstObject doubleValue];
        for (NSInteger i = 1; i < diffs.count; i++) {
            NSNumber *curDiff = diffs[i];
            minDiff = MIN(minDiff, [curDiff doubleValue]);
        }
    }
    
    for (NSInteger i = 0; i < diffs.count; i++) {
        NSNumber *curDiff = diffs[i];
        if (fabs([curDiff doubleValue] - minDiff) < kPanelControllerFloatLeeway) {
            return i;
        }
    }
    return 0;
}

@end
