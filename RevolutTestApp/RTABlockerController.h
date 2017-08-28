//
//  RTABlockerController.h
//  RevolutTestApp
//
//  Created by Stanislav on 10.09.17.
//  Copyright © 2017 LSV. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RTALoaderControllerCompletionHandler)(void);

@interface RTABlockerController : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)sharedInstance;
- (void)show;
- (void)hide;
- (void)hideWithCompletionHandler:(nullable RTALoaderControllerCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
