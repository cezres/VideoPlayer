//
//  VideoPlayerControl.h
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaPlayer/IJKMediaPlayer.h>


@protocol VideoPlayerControlDelegate <NSObject>

/// 点击播放开关
- (void)onClickPlaySwitch;

/// 点击返回
- (void)onClickBack;

/// 当前播放时间
- (NSTimeInterval)currentPlaybackTime;

@end


/// 视频播放控制视图
@interface VideoPlayerControl : UIControl

/// 代理
@property (weak, nonatomic) id<VideoPlayerControlDelegate> delegate;

/// 标题
@property (strong, nonatomic) NSString *title;

/// 播放状态
@property (nonatomic, assign) IJKMPMoviePlaybackState playbackState;

/// 当前播放时间
@property (nonatomic, assign) NSTimeInterval currentPlaybackTime;
/// 总播放时间
@property (nonatomic, assign) NSTimeInterval duration;

/// 设置标题
- (void)setTitle:(NSString *)title;



@end


