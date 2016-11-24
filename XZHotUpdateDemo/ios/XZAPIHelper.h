//
//  XZAPIHelper.h
//  XZHotUpdateDemo
//
//  Created by 徐章 on 2016/11/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completion)(NSDictionary *response, NSString *error);

@interface XZAPIHelper : NSObject

+(XZAPIHelper *)helper;

/**
 *  get请求
 *
 *  @param url        请求URL
 *  @param params     请求参数
 *  @param completion 请求完成回调
 */
- (void)getWithUrl:(NSString *)url params:(NSDictionary *)params callback:(completion)completion;

- (void)downloadWithUrl:(NSString *)url version:(NSString *)version callback:(completion)completion;

@end
