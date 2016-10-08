//
//  VideoPlayerControl.h
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>


@protocol VideoPlayerControlDelegate <NSObject>

/// 点击播放开关
- (void)onClickPlaySwitch;

/// 点击返回
- (void)onClickBack;

/// 当前播放时间
- (NSTimeInterval)currentPlaybackTime;

/// 更改播放时间
- (void)changePlayTime:(NSTimeInterval)newTime;

@end


/// 视频播放控制视图
@interface VideoPlayerControl : UIControl

/// 代理
@property (weak, nonatomic) id<VideoPlayerControlDelegate> delegate;

/// 播放状态
@property (assign, nonatomic) IJKMPMoviePlaybackState playbackState;

/// 当前播放时间
@property (assign, nonatomic) NSTimeInterval currentPlaybackTime;
/// 总播放时间
@property (assign, nonatomic) NSTimeInterval duration;

/// 设置标题
- (void)setTitle:(NSString *)title;



@end


