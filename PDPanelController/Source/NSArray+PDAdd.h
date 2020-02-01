//
//  NSArray+PDAdd.h
//  PDPanelController
//
//  Created by liang on 2020/1/30.
//  Copyright © 2020 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (PDAdd)

- (NSArray *)filter:(BOOL (^)(id obj, NSUInteger idx))block;

- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block;

@end

NS_ASSUME_NONNULL_END
