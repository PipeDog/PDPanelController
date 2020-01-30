//
//  NSArray+PDAdd.m
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import "NSArray+PDAdd.h"

@implementation NSArray (PDAdd)

- (NSArray *)filter:(BOOL (^)(id _Nonnull, NSUInteger))block {
    NSMutableArray *objs = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL effect = block(obj, idx);
        if (effect) [objs addObject:obj];
    }];
    return [objs copy];
}

- (NSArray *)map:(id _Nonnull (^)(id _Nonnull, NSUInteger))block {
    NSMutableArray *objs = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id tmpObj = block(obj, idx);
        if (tmpObj) [objs addObject:tmpObj];
    }];
    return [objs copy];
}

@end
