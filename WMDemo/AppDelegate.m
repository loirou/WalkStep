//
//  AppDelegate.m
//  
//
//  Created by 刘东 on 15/7/7.
//  Copyright (c) 2015年 刘东. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
// 计步器开始计步时间（秒）
#define ACCELERO_START_TIME 2

// 计步器开始计步步数（步）
#define ACCELERO_START_STEP 8

// 数据库存储步数采集间隔（步）
#define DB_STEP_INTERVAL 100
@interface AppDelegate (){
    RootViewController *rvc;
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    rvc = [[RootViewController alloc]init];
    self.window.rootViewController = rvc;
    [self.window makeKeyAndVisible];
    
    [self initAccelerometer];
    [self startAccelerometer];
    
    return YES;
}

- (void)initAccelerometer
{
    //加速度传感器
    self.motionManager = [[CMMotionManager alloc] init];
    // 检查传感器到底在设备上是否可用
    if (!self.motionManager.accelerometerAvailable) {
        return;
    }
    else {
        // 更新频率是100Hz
        //以pull方式获取数据
        self.motionManager.accelerometerUpdateInterval = 1.0/40;
    }
}

- (void)startAccelerometer
{
    @try
    {
        //如果不支持陀螺仪,需要用加速传感器来采集数据
        if (!self.motionManager.isAccelerometerActive) {//  isAccelerometerAvailable方法用来查看加速度器的状态：是否Active（启动）。
            
            // 加速度传感器采集的原始数组
            if (arrAll == nil) {
                arrAll = [[NSMutableArray alloc] init];
            }
            else {
                [arrAll removeAllObjects];
            }
            
            /*
             1.push方式
             这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动获取加速计的数据。
             */
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error){
                
                if (!self.motionManager.isAccelerometerActive) {
                    return;
                }
                
                //三个方向加速度值
                double x = accelerometerData.acceleration.x;
                double y = accelerometerData.acceleration.y;
                double z = accelerometerData.acceleration.z;
                //g是一个double值 ,根据它的大小来判断是否计为1步.
                double g = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2)) - 1;
                
                //将信息保存在步数模型中
                VHSSteps *stepsAll = [[VHSSteps alloc] init];
                
                stepsAll.date = [NSDate date];
                
                //日期
                NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
                df.dateFormat  = @"yyyy-MM-dd HH:mm:ss";
                NSString *strYmd = [df stringFromDate:stepsAll.date];
                df = nil;
                stepsAll.record_time =strYmd;
                
                stepsAll.g = g;
                // 加速度传感器采集的原始数组
                [arrAll addObject:stepsAll];
                
                // 每采集10条，大约1.2秒的数据时，进行分析
                if (arrAll.count == 10) {
                    
                    // 步数缓存数组
                    NSMutableArray *arrBuffer = [[NSMutableArray alloc] init];
                    
                    arrBuffer = [arrAll copy];
                    [arrAll removeAllObjects];
                    
                    // 踩点数组
                    NSMutableArray *arrCaiDian = [[NSMutableArray alloc] init];
                    
                    //遍历步数缓存数组
                    for (int i = 1; i < arrBuffer.count - 2; i++) {
                        //如果数组个数大于3,继续,否则跳出循环,用连续的三个点,要判断其振幅是否一样,如果一样,然并卵
                        if (![arrBuffer objectAtIndex:i-1] || ![arrBuffer objectAtIndex:i] || ![arrBuffer objectAtIndex:i+1])
                        {
                            continue;
                        }
                        VHSSteps *bufferPrevious = (VHSSteps *)[arrBuffer objectAtIndex:i-1];
                        VHSSteps *bufferCurrent = (VHSSteps *)[arrBuffer objectAtIndex:i];
                        VHSSteps *bufferNext = (VHSSteps *)[arrBuffer objectAtIndex:i+1];
                        //控制震动幅度,,,,,,根据震动幅度让其加入踩点数组,
                        if (bufferCurrent.g < -0.12 && bufferCurrent.g < bufferPrevious.g && bufferCurrent.g < bufferNext.g) {
                            [arrCaiDian addObject:bufferCurrent];
                        }
                    }
                    
                    //如果没有步数数组,初始化
                    if (nil == self.arrSteps) {
                        self.arrSteps = [[NSMutableArray alloc] init];
                        self.arrStepsSave = [[NSMutableArray alloc] init];
                    }
                    
                    // 踩点过滤
                    for (int j = 0; j < arrCaiDian.count; j++) {
                        VHSSteps *caidianCurrent = (VHSSteps *)[arrCaiDian objectAtIndex:j];
                        
                        //如果之前的步数为0,则重新开始记录
                        if (self.arrSteps.count == 0) {
                            //上次记录的时间
                            lastDate = caidianCurrent.date;
                            
                            // 重新开始时，纪录No初始化
                            record_no = 1;
                            record_no_save = 1;
                            
                            // 运动识别号
                            NSTimeInterval interval = [caidianCurrent.date timeIntervalSince1970];
                            NSNumber *numInter = [[NSNumber alloc] initWithDouble:interval*1000];
                            long long llInter = numInter.longLongValue;
                            //运动识别id
                            self.actionId = [NSString stringWithFormat:@"%lld",llInter];
                            
                            self.distance = 0.00f;
                            self.second = 0;
                            self.calorie = 0;
                            self.step = 0;
                            
                            self.gpsDistance = 0.00f;
                            self.agoGpsDistance = 0.00f;
                            self.agoActionDistance = 0.00f;
                            
                            caidianCurrent.record_no = record_no;
                            caidianCurrent.step = self.step;
                            
                            [self.arrSteps addObject:caidianCurrent];
                            [self.arrStepsSave addObject:caidianCurrent];
                            
                        }
                        else {
                            
                            int intervalCaidian = [caidianCurrent.date timeIntervalSinceDate:lastDate] * 1000;
                            
                            // 步行最大每秒2.5步，跑步最大每秒3.5步，超过此范围，数据有可能丢失
                            int min = 259;
                            if (intervalCaidian >= min) {
                                
                                if (self.motionManager.isAccelerometerActive) {
                                    
                                    //存一下时间
                                    lastDate = caidianCurrent.date;
                                    
                                    if (intervalCaidian >= ACCELERO_START_TIME * 1000) {// 计步器开始计步时间（秒)
                                        self.startStep = 0;
                                    }
                                    
                                    if (self.startStep < ACCELERO_START_STEP) {//计步器开始计步步数 (步)
                                        
                                        self.startStep ++;
                                        break;
                                    }
                                    else if (self.startStep == ACCELERO_START_STEP) {
                                        self.startStep ++;
                                        // 计步器开始步数
                                        // 运动步数（总计）
                                        self.step = self.step + self.startStep;
                                    }
                                    else {
                                        self.step ++;
                                    }
                                
                                    //步数在这里
                                    NSLog(@"步数%d",self.step);
                                    
                                    int intervalMillSecond = [caidianCurrent.date timeIntervalSinceDate:[[self.arrSteps lastObject] date]] * 1000;
                                    if (intervalMillSecond >= 1000) {
                                        
                                        record_no++;
                                        
                                        caidianCurrent.record_no = record_no;
                                        
                                        caidianCurrent.step = self.step;
                                        [self.arrSteps addObject:caidianCurrent];
                                    }
                                    
                                    // 每隔100步保存一条数据（将来插入DB用）
                                    VHSSteps *arrStepsSaveVHSSteps = (VHSSteps *)[self.arrStepsSave lastObject];
                                    int intervalStep = caidianCurrent.step - arrStepsSaveVHSSteps.step;
                                    
                                    // DB_STEP_INTERVAL 数据库存储步数采集间隔（步） 100步
                                    if (self.arrStepsSave.count == 1 || intervalStep >= DB_STEP_INTERVAL) {
                                        //保存次数
                                        record_no_save++;
                                        caidianCurrent.record_no = record_no_save;
                                        [self.arrStepsSave addObject:caidianCurrent];
                                        
                                        // 备份当前运动数据至文件中，以备APP异常退出时数据也不会丢失
                                        // [self bkRunningData];
                                        
                                    }
                                }
                            }
                            
                            // 运动提醒检查
                            // [self checkActionAlarm];
                        }
                    }
                }
            }];
            
        }
    }@catch (NSException * e) {
        NSLog(@"Exception: %@", e);
        return;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //播放一段无声音乐,避免被kill
    [[MMPDeepSleepPreventer sharedSingleton] startPreventSleep];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
