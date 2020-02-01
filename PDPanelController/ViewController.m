//
//  ViewController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "ViewController.h"
#import "PDPanelController.h"
#import "PDContentViewController.h"

@interface ViewController () <PDPanelControllerDelegate, PDPanelControllerLayoutDelegate, PDPanelControllerAnimationDelegate>

@property (nonatomic, strong) UISlider *widthSlider;
@property (nonatomic, strong) PDPanelController *panelController;
@property (nonatomic, assign) CGFloat panelWidth;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.panelWidth = [UIScreen mainScreen].bounds.size.width;

    self.widthSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 100, 150, 40)];
    self.widthSlider.minimumValue = 0.7f;
    self.widthSlider.maximumValue = 1.f;
    self.widthSlider.value = self.widthSlider.maximumValue;
    [self.widthSlider addTarget:self action:@selector(widthSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.widthSlider];
    
    PDContentViewController *contentViewController = [[PDContentViewController alloc] init];
    
    self.panelController = [[PDPanelController alloc] initWithContentViewController:contentViewController];
    self.panelController.delegate = self;
    self.panelController.layoutDelegate = self;
    self.panelController.animationDelegate = self;
    
    [self pd_addPanelController:self.panelController initialGlueLocation:50.f animated:YES];
    
    // You should attch scrollView after addPanelController.
    [contentViewController.scrollView pd_attach:self.panelController];
}

- (void)widthSliderValueChanged:(UISlider *)slider {
    CGFloat width = CGRectGetWidth(self.view.bounds) * slider.value;
    self.panelWidth = width;
    
    CGFloat currentLocation = self.panelController.currentLocation;
    [self.panelController updatePreferredFrameIfNeeded:NO withLocation:currentLocation];
}

#pragma mark - PDPanelControllerDelegate
- (NSArray<NSNumber *> *)middleGlueLocationsInPanelController:(PDPanelController *)panelController {
    return @[@130, @500.f];
}

- (CGFloat)bounceOffsetInPanelController:(PDPanelController *)panelController {
    return 20.f;
}

- (CGFloat)skipLocationVerticalVelocityThresholdInPanelController:(PDPanelController *)panelController {
    return FLT_MAX;
}

#pragma mark - PDPanelControllerLayoutDelegate
- (CGSize)preferredSizeForPanelController:(PDPanelController *)panelController {
    return CGSizeMake(self.panelWidth, 700.f);
}

- (CGRect)preferredLandscapeFrameForPanelController:(PDPanelController *)panelController {
    return CGRectMake(30.f, 40.f, 350.f, [UIScreen mainScreen].bounds.size.height - 40.f);
}

#pragma mark - PDPanelControllerAnimationDelegate
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator forPanelController:(nonnull PDPanelController *)panelController {
    /* This method is called when the view controller's view's size is changed by its
    parent (i.e. for the root view controller when its window rotates or is resized). */
}

- (void)animateForPanelController:(PDPanelController *)panelController
                           action:(PDPanelControllerAction)action
                         duration:(NSTimeInterval)duration
                       animations:(void (^)(void))animations
                       completion:(void (^)(BOOL))completion {
    switch (action) {
        case PDPanelControllerActionMove: {
            [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:animations completion:completion];
        } break;
        default: {
            [UIView animateWithDuration:duration animations:animations completion:completion];
        } break;
    }
}

@end
