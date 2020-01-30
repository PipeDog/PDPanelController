//
//  DemoPanelController.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "DemoPanelController.h"

@interface DemoPanelController () <UITableViewDelegate, UITableViewDataSource>

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
    
    _portraitWidth = [UIScreen mainScreen].bounds.size.width;
}

- (void)createViewHierarchy {
    [self.view addSubview:self.tableView];
}

- (void)layoutContentViews {
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *topConstraint = [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor];
    NSLayoutConstraint *leftConstraint = [self.tableView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor];
    NSLayoutConstraint *bottomConstraint = [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor];
    NSLayoutConstraint *rightConstraint = [self.tableView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor];
    
    NSArray *constraints = @[
        topConstraint, leftConstraint, bottomConstraint, rightConstraint,
    ];
    
    [NSLayoutConstraint activateConstraints:constraints];
}

#pragma mark - Override Methods
- (NSArray<NSNumber *> *)middleStickyPoints {
    return @[@(260.f)];
}

- (void)willMoveToPoint:(CGFloat)point {
    NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (void)didMoveToPoint:(CGFloat)point {
    NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (void)didDragToPoint:(CGFloat)point {
    NSLog(@"%s, point = %lf", __FUNCTION__, point);
}

- (CGFloat)bounceOffset {
    return 0.f;
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
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
