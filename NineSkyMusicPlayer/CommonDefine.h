//
//  CommonDefine.h
//  NineSkyMusicPlayer
//
//  Created by LiDaHai on 16/5/27.
//  Copyright © 2016年 LiDaHai. All rights reserved.
//


#import "AppDelegate.h"


#define MMAppDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define iPhone4       ([[UIScreen mainScreen] bounds].size.height == 480)
#define iPhone5       ([[UIScreen mainScreen] bounds].size.height == 568)
#define iPhone6       ([[UIScreen mainScreen] bounds].size.height == 667)
#define iPhone6p      ([[UIScreen mainScreen] bounds].size.height == 736)

#define ScreenWidth   [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight  [[UIScreen mainScreen] bounds].size.height

#define ScreenScale   ScreenWidth/320.0




