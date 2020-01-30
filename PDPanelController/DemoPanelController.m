//
//  DemoPanelController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "DemoPanelController.h"

@interface DemoPanelController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *grabberHandleView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation DemoPanelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self commitInit];
    [self createViewHierarchy];
    [self layoutContentViews];
    [self.tableView pd_attach:self];
}

- (void)commitInit {
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = 15.f;
    self.view.clipsToBounds = YES;
    self.view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    
    self.portraitWidth = [UIScreen mainScreen].bounds.size.width;
}

- (void)createViewHierarchy {
    [self.view addSubview:self.grabberHandleView];
    [self.view addSubview:self.tableView];
}

- (void)layoutContentViews {
    self.grabberHandleView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        [self.grabberHandleView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.grabberHandleView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:10.f],
        [self.grabberHandleView.widthAnchor constraintEqualToConstant:36.f],
        [self.grabberHandleView.heightAnchor constraintEqualToConstant:5.f],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.grabberHandleView.bottomAnchor constant:10.f],
        [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor],
    ]];
}

#pragma mark - Override Methods
- (NSArray<NSNumber *> *)middleStickyPoints {
    return @[@(260.f)];
}

- (void)willMoveToPoint:(CGFloat)point {
    // NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (void)didMoveToPoint:(CGFloat)point {
    // NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (void)didDragToPoint:(CGFloat)point {
    // NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (CGFloat)bounceOffset {
    return 20.f;
}

- (CGSize)preferredSize {
    return CGSizeMake(self.portraitWidth, 500.f);
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"section : %zd, row: %zd", indexPath.section, indexPath.row];
    return cell;
}

#pragma mark - Getter Methods
- (UIView *)grabberHandleView {
    if (!_grabberHandleView) {
        _grabberHandleView = [[UIView alloc] init];
        _grabberHandleView.layer.masksToBounds = YES;
        _grabberHandleView.layer.cornerRadius = 2.5f;
        _grabberHandleView.backgroundColor = [UIColor colorWithDisplayP3Red:0.76f green:0.77f blue:0.76f alpha:1.f];
    }
    return _grabberHandleView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
