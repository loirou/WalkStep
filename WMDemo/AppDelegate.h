//
//  AppDelegate.h
//
//
//  Created by 刘东 on 15/7/7.
//  Copyright (c) 2015年 刘东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import "VHSSteps.h"
#import "MMPDeepSleepPreventer.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

{
    NSMutableArray *arrAll;                 // 加速度传感器采集的原始数组
    int record_no_save;
    int record_no;
    NSDate *lastDate;
    
}
@property (nonatomic) NSInteger startStep;                          // 计步器开始步数


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) CMMotionManager *motionManager;   // 加速度传感器
@property (nonatomic, retain) NSMutableArray *arrSteps;         // 步数数组
@property (nonatomic, retain) NSMutableArray *arrStepsSave;     // 数据库纪录步数数组

@property (nonatomic) CGFloat gpsDistance;                  // GPS轨迹的移动距离（总计）
@property (nonatomic) CGFloat agoGpsDistance;               // GPS轨迹的移动距离（之前）
@property (nonatomic) CGFloat agoActionDistance;            // 实际运动的移动距离（之前）

@property (nonatomic, retain) NSString *actionId;           // 运动识别ID
@property (nonatomic) CGFloat distance;                     // 运动里程（总计）
@property (nonatomic) NSInteger calorie;                    // 消耗卡路里（总计）
@property (nonatomic) NSInteger step;                       // 运动步数（总计）
@property (nonatomic) NSInteger second;                     // 运动用时（总计）

@end

