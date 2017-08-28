//
//  UIView+Reusable.h
//  RevolutTestApp
//
//  Created by Stanislav on 07.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Reusable)

@property (class, nonatomic, readonly) NSString *defaultReuseIdentifier;
@property (class, nonatomic, readonly) NSString *defaultNibName;

@end

NS_ASSUME_NONNULL_END
