//
//  CCClientRequest.h
//  WoZaiXianChang
//
//  Created by lcc on 13-9-17.
//  Copyright (c) 2013年 lcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMClientRequestDelegate.h"

@interface CCClientRequest : NSObject <MMClientRequestDelegate>

@property (weak) id c_delegate;

//初始化信息
- (void)appUrlInit;

@end
