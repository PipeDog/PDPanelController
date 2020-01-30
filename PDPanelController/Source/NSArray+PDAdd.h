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

/**
 Select the qualifying elements to form a new array.
 */
- (NSArray *)filter:(BOOL (^)(id obj, NSUInteger idx))block;

/**
 Map the elements in an array into other types of elements and form new arrays.
 */
- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block;

@end

NS_ASSUME_NONNULL_END
