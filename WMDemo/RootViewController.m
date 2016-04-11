//
//  RootViewController.m
//  WMDemo
//
//  Created by 刘东 on 15/7/7.
//  Copyright (c) 2015年 刘东. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
@interface RootViewController (){
    NSTimer *_timer;
    UILabel *_label;
}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _label = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-100, 150,200, 50)];
    _label.text = @"步数统计";
    _label.textAlignment = 1;
    [self.view addSubview:_label];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(onTimer) userInfo:nil repeats:YES] ;
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
}
-(void)onTimer{
    AppDelegate *app=[UIApplication sharedApplication].delegate;
    _label.text=[NSString stringWithFormat:@"步数:%ld",(long)app.step];
    //采集10条才做一次处理的,即是说步数刷新的间隔是十几步
    NSLog(@"%ld", (long)app.step);
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
