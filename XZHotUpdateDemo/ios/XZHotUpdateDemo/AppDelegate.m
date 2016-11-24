/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"

#import "XZBundleHelper.h"
#import "XZAPIHelper.h"
#import <SSZipArchive/SSZipArchive.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//  react-native bundle --entry-file index.ios.js --bundle-output ./ios/bundle/index.ios.jsbundle --platform ios --assets-dest ./ios/bundle --dev false
  
  //获取本地存储App当前的版本号
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *jsVersion = [defaults objectForKey:@"jsVersion"];
  
  if (!jsVersion) {
    /*
     *第一次安装启动的时候本地是没有存储任何版本号，所以这里设置一个最初的版本号
     *这里设置的版本号并不是意味着一直是最初的第一个版本号，而是应该是App的原生版本所绑定的最初的RN模块版本号
     *如第一版本App的版本号:1.0 RN模块的版本号:0.1 后来RN模块迭代了几个版本到了0.4 而原生部分没有修改并没有重新上架
     *后来原生做了修改重新上架了 App版本号:2.0 这时候，这里的RN模块的版本号应该从0.4开始了
     */
    jsVersion = @"0.1";
    [defaults setObject:@"0.1" forKey:@"jsVersion"];
    [defaults synchronize];
  }
  
  NSURL *jsCodeLocation = [XZBundleHelper getBundlePath];
  
//  NSURL *jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"XZHotUpdateDemo"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  
  //查服务端最新的版本号，http://188.188.3.4:8080/version是本地搭建的一个服务
  [[XZAPIHelper helper] getWithUrl:@"http://188.188.3.4:8080/version"
                            params:nil
                          callback:^(NSDictionary *response, NSString *error) {
    
    if (error) {
      //网络请求失败
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"查询更新失败"
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:@"确定"
                                            otherButtonTitles:nil, nil];
      [alert show];
      return ;
    }
    //result为服务端最新的版本号
    NSString *result = response[@"result"];

  
  /*
   *result是从服务器接口请求的最新版本号，jsVersion是本地的RN版本号
   *两者相互比较判断是否要进行下载更新
   *版本号的管理需要根据实际情况而定，这边是简单为主所以采用的数字比较的方式
   */
  if (result.floatValue > jsVersion.floatValue) {
    //本地版本低于服务器最新版本,需要进行下载更新
      [[XZAPIHelper helper] downloadWithUrl:[NSString stringWithFormat:@"http://188.188.3.4:8080/images/%@.zip",result] version:result callback:^(NSDictionary *response, NSString *error) {
        
        if (error) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
          [alert show];
        }else{
          
          NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
          NSString *zipPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",result]];
          NSString *destinationPath = documentPath;
          
          //如果之前documents目录下已经有下载解压过旧版的文件需要先删除
          NSString *assetsPath = [documentPath stringByAppendingPathComponent:@"assets"];
          NSString *jsbundlePath = [documentPath stringByAppendingPathComponent:@"index.ios.jsbundle"];
          NSString *metaPath = [documentPath stringByAppendingPathComponent:@"index.ios.jsbundle.meta"];
          
          NSFileManager *fileManager = [NSFileManager defaultManager];
          if ([fileManager fileExistsAtPath:assetsPath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:assetsPath error:&error];
            if (!error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除assets成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
              [alert show];
            }
          }
          if ([fileManager fileExistsAtPath:jsbundlePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:jsbundlePath error:&error];
            if (!error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除jsbundle成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
              [alert show];
            }
          }
          if ([fileManager fileExistsAtPath:metaPath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:metaPath error:&error];
            if (!error) {
              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除meta成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
              [alert show];
            }
          }
          
          NSError *error;
          
          //既要到指定的documents路径下
          [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath overwrite:YES password:nil error:&error];
          if(!error){
            //解压完成后重新加载reactnative模块
            [rootView.bridge reload];
            [defaults setObject:result forKey:@"jsVersion"];
            [defaults synchronize];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解压成功" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            
          }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"解压失败" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
          }
          
        }
        
      }];
    }else {
      
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已经是最新版本" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
  
  
  
  return YES;
}

@end
