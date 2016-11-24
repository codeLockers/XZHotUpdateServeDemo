//
//  XZAPIHelper.m
//  XZHotUpdateDemo
//
//  Created by 徐章 on 2016/11/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "XZAPIHelper.h"
#import <AFNetworking/AFNetworking.h>


@implementation XZAPIHelper{
  AFHTTPSessionManager *_manager;
}


+ (XZAPIHelper *)helper{

  static XZAPIHelper *helper = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    helper = [[XZAPIHelper alloc] init];
  });
  
  return helper;
}

- (id)init{

  self = [super init];
  if (self) {
    _manager = [AFHTTPSessionManager manager];
    _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", nil];
    
  }
  return self;
}

- (void)getWithUrl:(NSString *)url params:(NSDictionary *)params callback:(completion)completion{
  
  if (!params) {
    params = [NSDictionary dictionary];
  }
  
  [_manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    
    NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    
    completion(@{@"result":result},nil);

  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    
    completion(@{@"result":@"0"},@"error");
  }];
  
}

- (void)downloadWithUrl:(NSString *)url version:(NSString *)version callback:(completion)completion{
  
  NSURL *URL = [NSURL URLWithString:url];
  NSURLRequest *request = [NSURLRequest requestWithURL:URL];
  
  NSURLSessionDownloadTask *downloadTask = [_manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];

    return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",version]];
    
  } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {

    if (error) {
      completion(nil,@"下载失败");
    }else{
      completion(@{@"result":filePath.absoluteString},nil);
    }
  }];
  [downloadTask resume];
}




@end
