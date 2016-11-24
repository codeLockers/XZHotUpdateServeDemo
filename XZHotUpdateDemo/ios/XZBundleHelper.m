//
//  XZBundleHelper.m
//  XZHotUpdateDemo
//
//  Created by 徐章 on 2016/11/24.
//  Copyright © 2016年 Facebook. All rights reserved.
//

#import "XZBundleHelper.h"
#import "RCTBundleURLProvider.h"


@implementation XZBundleHelper

+ (NSURL *)getBundlePath{
  //沙盒路径
  NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//  NSLog(@"%@",documentPath);
  
  NSString *jsBundlePath = [documentPath stringByAppendingPathComponent:@"index.ios.jsbundle"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  
  if (![fileManager fileExistsAtPath:jsBundlePath]) {
    //documets目录下不存在index.ios.jsbundle文件，则将工程里面的main.jsbundle文件拷到该路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"main" ofType:@"jsbundle"];
    [fileManager copyItemAtPath:path toPath:jsBundlePath error:nil];
  }
  
  NSString *assetsPath = [documentPath stringByAppendingPathComponent:@"assets"];
  
  if (![fileManager fileExistsAtPath:assetsPath]) {
    //documets目录下不存在assets文件，则将工程里面的assets文件拷到该路径
      NSString *assetsBundlePath = [[NSBundle mainBundle] pathForResource:@"assets" ofType:nil];
      [[NSFileManager defaultManager] copyItemAtPath:assetsBundlePath toPath:assetsPath error:nil];
  }

  return [NSURL URLWithString:jsBundlePath];
  
}

@end
