//
//  ViewController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "ViewController.h"
#import "DemoPanelController.h"

@interface ViewController ()

@property (nonatomic, strong) UISlider *widthSlider;
@property (nonatomic, strong) DemoPanelController *panelController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];

    self.widthSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 100, 150, 40)];
    self.widthSlider.minimumValue = 0.7f;
    self.widthSlider.maximumValue = 1.f;
    self.widthSlider.value = self.widthSlider.maximumValue;
    [self.widthSlider addTarget:self action:@selector(widthSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.widthSlider];
    
    self.panelController = [[DemoPanelController alloc] init];
    [self pd_addPanelController:self.panelController initialStickyPointOffset:50.f animated:YES];
}

- (void)widthSliderValueChanged:(UISlider *)slider {
    CGFloat width = CGRectGetWidth(self.view.bounds) * slider.value;
    self.panelController.portraitWidth = width;
    [self.panelController updatePreferredFrameIfNeeded:YES];
}

@end
