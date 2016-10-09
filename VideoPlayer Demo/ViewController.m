//
//  ViewController.m
//  VideoPlayer Demo
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSURL *videoURL = [[NSBundle mainBundle] URLForResource:@"6282404" withExtension:@"mp4"];
    [VideoPlayer playVideoWithURL:videoURL title:@"【2016拜年祭单品】Travel" inController:self];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
