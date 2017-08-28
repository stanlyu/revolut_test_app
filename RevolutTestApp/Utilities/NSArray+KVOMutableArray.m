//
//  NSArray+KVOMutableArray.m
//  RevolutTestApp
//
//  Created by Stanislav on 17.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "NSArray+KVOMutableArray.h"
#import <KVOMutableArray/KVOMutableArray.h>

@implementation NSArray (KVOMutableArray)

- (id)kvoMutableCopy {
    return [[KVOMutableArray alloc] initWithMutableArray:[NSMutableArray arrayWithArray:self]];
}

@end
