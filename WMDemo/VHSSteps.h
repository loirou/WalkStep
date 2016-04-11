//
//  VHSSteps.h
//  
//
//  Created by 刘东 on 15-7-7.
//  Copyright (c) 2015年 刘东. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VHSSteps : NSObject
//步数模型
@property(nonatomic,strong) NSDate *date;

@property(nonatomic,assign) int record_no;

@property(nonatomic, strong) NSString *record_time;

@property(nonatomic,assign) int step;

//g是一个震动幅度的系数,通过一定的判断条件来判断是否计做一步
@property(nonatomic,assign) double g;

@end
