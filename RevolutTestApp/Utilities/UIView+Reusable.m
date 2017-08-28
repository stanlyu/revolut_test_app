//
//  UIView+Reusable.m
//  RevolutTestApp
//
//  Created by Stanislav on 07.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import "UIView+Reusable.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIView (Reusable)

+ (NSString *)defaultReuseIdentifier {
    return NSStringFromClass(self.class);
}

+ (NSString *)defaultNibName {
    return NSStringFromClass(self.class);
}

@end

NS_ASSUME_NONNULL_END
