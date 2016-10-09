//
//  VideoPlayerControl.m
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "VideoPlayerControl.h"
#import <MediaPlayer/MediaPlayer.h>
#import "VideoPlayerProgressView.h"

/**
 *  手势处理方式
 */
typedef NS_ENUM(NSInteger, PlayerPanGestureHandleMode) {
    PlayerPanGestureHandleModeNone,
    /**
     *  音量
     */
    PlayerPanGestureHandleModeVolume,
    /**
     *  亮度
     */
    PlayerPanGestureHandleModeBrightness,
    /**
     *  播放进度
     */
    PlayerPanGestureHandleModePlayProgress
};



@interface VideoPlayerControl ()
{
    NSTimeInterval _tempTime;
}
@property (strong, nonatomic) UIView    *topView;
@property (strong, nonatomic) UIButton  *backButton;    // 返回
@property (strong, nonatomic) UILabel   *titleLabel;    // 标题


@property (strong, nonatomic) UIView    *bottomView;
@property (strong, nonatomic) VideoPlayerProgressView    *progressView;  // 播放进度
@property (strong, nonatomic) UILabel   *currentTimeLabel;  // 当前播放时间
@property (strong, nonatomic) UILabel   *durationLabel; // 总播放时间

@property (strong, nonatomic) UIButton  *playSwitchButton;  // 播放开关

@property (assign, nonatomic) PlayerPanGestureHandleMode panGestureHandleMode; // 手势处理方式

@end

@implementation VideoPlayerControl


- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        [self addSubview:self.playSwitchButton];
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:tapGesture];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - Event
- (void)onClickBack {
    [self.delegate onClickBack];
}

- (void)onClickPlaySwitch {
    [self.delegate onClickPlaySwitch];
}

- (void)refresh {
    
    self.currentPlaybackTime = [self.delegate currentPlaybackTime];
    
    if (_playbackState == IJKMPMoviePlaybackStatePlaying && !_bottomView.hidden) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refresh) object:NULL];
        [self performSelector:@selector(refresh) withObject:NULL afterDelay:0.5];
    }
    
}

- (void)hide {
    _bottomView.hidden = YES;
    _topView.hidden = YES;
    _playSwitchButton.hidden = YES;
}

- (void)show {
    
    _bottomView.hidden = NO;
    _topView.hidden = NO;
    _playSwitchButton.hidden = NO;
    
    [self refresh];
    
    if (_playbackState == IJKMPMoviePlaybackStatePlaying) {
        /// 延时设置隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:NULL];
        [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    }
    
}

#pragma mark - 手势
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint location = [tapGesture locationInView:self];
    if (location.x <= self.titleLabel.frame.origin.x && location.y <= CGRectGetMaxY(self.topView.frame)) {
        [self onClickBack];
        return;
    }
    if (location.y > CGRectGetMaxY(self.topView.frame) && location.y < self.bottomView.frame.origin.y) {
        _bottomView.hidden ? [self show] : [self hide];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self];
    CGPoint location = [panGesture locationInView:self];
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x < 100 && fabs(translation.y) >= fabs(translation.x)) {
            _panGestureHandleMode = PlayerPanGestureHandleModeBrightness;
            NSLog(@"亮度");
        }
        else if (location.x >= self.bounds.size.width-100 && fabs(translation.y) >= fabs(translation.x)) {
            _panGestureHandleMode = PlayerPanGestureHandleModeVolume;
            NSLog(@"音量");
        }
        else {
            _panGestureHandleMode = PlayerPanGestureHandleModePlayProgress;
            _tempTime = [self.delegate currentPlaybackTime];
            NSLog(@"播放进度");
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateChanged) {
        if (_panGestureHandleMode == PlayerPanGestureHandleModePlayProgress) {
            CGFloat offset = translation.x / self.bounds.size.width * _duration;
            CGFloat newTime = _tempTime + offset;
            newTime = newTime < 0 ? 0 : newTime > _duration ? _duration : newTime;
            [VideoPlayerChangeProgressView showProgressViewWith:newTime duration:_duration];
        }
        else {
            CGFloat offset = -translation.y / 200;
            
            if (_panGestureHandleMode == PlayerPanGestureHandleModeBrightness) {
                /// 修改亮度
                [UIScreen mainScreen].brightness += offset;
            }
            else if (_panGestureHandleMode == PlayerPanGestureHandleModeVolume) {
                /// 修改音量
                MPMusicPlayerController *musicPlayer = [MPMusicPlayerController applicationMusicPlayer];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                musicPlayer.volume += offset;
#pragma clang diagnostic pop
            }
            
            [panGesture setTranslation:CGPointZero inView:self];
        }
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded) {
        if (_panGestureHandleMode == PlayerPanGestureHandleModePlayProgress) {
            CGFloat offset = translation.x / self.bounds.size.width * _duration;
            CGFloat newTime = _tempTime + offset;
            newTime = newTime < 0 ? 0 : newTime > _duration ? _duration : newTime;
            [self.delegate changePlayTime:newTime];
            [VideoPlayerChangeProgressView hidden];
        }
        _panGestureHandleMode = PlayerPanGestureHandleModeNone;
    }
}
    
    
#pragma mark - Slider
- (void)didSliderTouchDown; {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:NULL];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refresh) object:NULL];
}
- (void)didSliderTouchCancel; {
    [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    [self refresh];
}
- (void)didSliderTouchUpOutside; {
    [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    [self refresh];
}
- (void)didSliderTouchUpInside; {
    [self.delegate changePlayTime:_progressView.value];
    [VideoPlayerChangeProgressView hidden];
    [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    [self refresh];
}
- (void)didSliderValueChanged; {
    [VideoPlayerChangeProgressView showProgressViewWith:_progressView.value duration:_duration];
}

#pragma mark - Set
- (void)setPlaybackState:(IJKMPMoviePlaybackState)playbackState {
    _playbackState = playbackState;
    if (_playbackState == IJKMPMoviePlaybackStatePlaying) {
        [self.playSwitchButton setImage:[self imageWithName:@"player_pause"] forState:UIControlStateNormal];
        /// 刷新播放进度   【不知道为什么，暂停后立即调用方法，返回的时间不准
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refresh) object:NULL];
        [self performSelector:@selector(refresh) withObject:NULL afterDelay:0.5];
        /// 延时设置隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:NULL];
        [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    }
    else if (_playbackState == IJKMPMoviePlaybackStatePaused) {
        [self.playSwitchButton setImage:[self imageWithName:@"player_play"] forState:UIControlStateNormal];
        /// 取消延时设置隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:NULL];
    }
    else if (_playbackState == IJKMPMoviePlaybackStateStopped) {
        [self.playSwitchButton setImage:[self imageWithName:@"player_play"] forState:UIControlStateNormal];
        self.currentPlaybackTime = 0;
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    _currentPlaybackTime = currentPlaybackTime;
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentPlaybackTime / 60, (int)currentPlaybackTime % 60];
    self.progressView.value = currentPlaybackTime;
}
- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration / 60, (int)duration % 60];
    self.progressView.maximumValue = duration;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark - Get
- (UIView *)topView {
    if (!_topView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _topView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [_topView addSubview:self.backButton];
        [_topView addSubview:self.titleLabel];
    }
    return _topView;
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[self imageWithName:@"hd_idct_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onClickBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _bottomView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [_bottomView addSubview:self.currentTimeLabel];
        [_bottomView addSubview:self.durationLabel];
        [_bottomView addSubview:self.progressView];
    }
    return _bottomView;
}
- (VideoPlayerProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[VideoPlayerProgressView alloc] init];
        [_progressView addTarget:self action:@selector(didSliderTouchDown) forControlEvents:UIControlEventTouchDown];
        [_progressView addTarget:self action:@selector(didSliderTouchCancel) forControlEvents:UIControlEventTouchCancel];
        [_progressView addTarget:self action:@selector(didSliderTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [_progressView addTarget:self action:@selector(didSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_progressView addTarget:self action:@selector(didSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _progressView;
}
- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text = @"00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _currentTimeLabel;
}
- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:12];
        _durationLabel.text = @"00:00";
    }
    return _durationLabel;
}

- (UIButton *)playSwitchButton {
    if (!_playSwitchButton) {
        _playSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playSwitchButton addTarget:self action:@selector(onClickPlaySwitch) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playSwitchButton;
}



#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    /// Top
    self.topView.frame = CGRectMake(0, 0, self.bounds.size.width, 44);
    self.backButton.frame = CGRectMake(10, (44-26)/2, 26, 26);
    self.titleLabel.frame = CGRectMake(10+26+20, 0, self.topView.bounds.size.width - 5-44 -15 -15, 44);
    
    /// Bottom
    self.bottomView.frame = CGRectMake(0, (self.bounds.size.height - 49), self.bounds.size.width, 49);
    self.currentTimeLabel.frame = CGRectMake(15, (49 - 14) / 2, 55, 14);
    self.durationLabel.frame = CGRectMake(self.bottomView.bounds.size.width - 15 - 55, (49 - 14) / 2, 55, 14);
    self.progressView.frame = CGRectMake(15+55+15, (49 - 6) / 2, self.bottomView.bounds.size.width-85-85, 6);
    
    self.playSwitchButton.frame = CGRectMake(self.bounds.size.width - 10 - 55, self.bounds.size.height - 49 - 50, 55, 50);
    
}


#pragma mark - Tool
- (UIImage *)imageWithName:(NSString *)imageName {
    static NSBundle *iconBundle;
    if (!iconBundle) {
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSURL *iconBundleURL = [currentBundle URLForResource:@"Icon" withExtension:@"bundle"];
        iconBundle = [NSBundle bundleWithURL:iconBundleURL];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@@%ldx", imageName, (long)[UIScreen mainScreen].scale];
    NSURL *imageURL = [iconBundle URLForResource:fileName withExtension:@"png"];
    if (!imageURL) {
        imageURL = [iconBundle URLForResource:imageName withExtension:@"png"];
    }
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    return [UIImage imageWithData:imageData];
}


@end
