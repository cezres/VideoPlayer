//
//  VideoPlayerControl.m
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "VideoPlayerControl.h"

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

@property (strong, nonatomic) UIView    *topView;
@property (strong, nonatomic) UIButton  *backButton;    // 返回
@property (strong, nonatomic) UILabel   *titleLabel;    // 标题


@property (strong, nonatomic) UIView    *bottomView;
@property (strong, nonatomic) UIView    *progressView;  // 播放进度
@property (strong, nonatomic) UILabel   *currentTimeLabel;  // 当前播放时间
@property (strong, nonatomic) UILabel   *durationLabel; // 总播放时间

@property (strong, nonatomic) UIButton  *playSwitchButton;  // 播放开关

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
    
    NSInteger currentPlaybackTime = [self.delegate currentPlaybackTime];
    
    NSLog(@"%ld\t\t%lf", currentPlaybackTime, [self.delegate currentPlaybackTime]);
    
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", currentPlaybackTime / 60, currentPlaybackTime % 60];
    
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
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refresh) object:NULL];
    [self performSelector:@selector(refresh) withObject:NULL afterDelay:0.5];
    
    
    if (_playbackState == IJKMPMoviePlaybackStatePlaying) {
        /// 延时设置隐藏
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:NULL];
        [self performSelector:@selector(hide) withObject:NULL afterDelay:5];
    }
    
}

#pragma mark - 手势
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    _bottomView.hidden ? [self show] : [self hide];
}
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self];
    CGPoint location = [panGesture locationInView:self];
    
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
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    _currentPlaybackTime = currentPlaybackTime;
    _currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)currentPlaybackTime / 60, (int)currentPlaybackTime % 60];
}
- (void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    _durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)duration / 60, (int)duration % 60];
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
        [_backButton setImage:[self imageWithName:@"player_back"] forState:UIControlStateNormal];
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
    }
    return _bottomView;
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
    self.backButton.frame = CGRectMake(5, 0, 44, 44);
    self.titleLabel.frame = CGRectMake(5+44+15, 0, self.topView.bounds.size.width - 5-44 -15 -15, 44);
    
    /// Bottom
    self.bottomView.frame = CGRectMake(0, (self.bounds.size.height - 49), self.bounds.size.width, 49);
    self.currentTimeLabel.frame = CGRectMake(15, (49 - 14) / 2, 55, 14);
    self.durationLabel.frame = CGRectMake(self.bottomView.bounds.size.width - 15 - 55, (49 - 14) / 2, 55, 14);
    
    
    self.playSwitchButton.frame = CGRectMake(self.bounds.size.width - 10 - 55, self.bounds.size.height - 49 - 50, 55, 50);
    
}


#pragma mark - Tool
- (UIImage *)imageWithName:(NSString *)imageName {
    static NSBundle *iconBundle;
    if (!iconBundle) {
        NSParameterAssert(imageName);
        NSBundle *currentBundle = [NSBundle bundleForClass:[self class]];
        NSParameterAssert(currentBundle);
        NSURL *iconBundleURL = [currentBundle URLForResource:@"Icon" withExtension:@"bundle"];
        NSParameterAssert(iconBundleURL);
        iconBundle = [NSBundle bundleWithURL:iconBundleURL];
        NSParameterAssert(iconBundle);
    }
    imageName = [NSString stringWithFormat:@"%@@%ldx", imageName, (NSInteger)[UIScreen mainScreen].scale];
    NSURL *imageURL = [iconBundle URLForResource:imageName withExtension:@"png"];
    NSParameterAssert(imageURL);
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    NSParameterAssert(imageData);
    return [UIImage imageWithData:imageData];
}


@end
