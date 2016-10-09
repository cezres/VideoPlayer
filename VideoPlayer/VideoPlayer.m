//
//  VideoPlayer.m
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/24.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "VideoPlayer.h"
#import "VideoPlayerControl.h"
#import <IJKMediaFramework/IJKMediaFramework.h>


@interface VideoPlayer ()
<VideoPlayerControlDelegate>

@property (strong, nonatomic) NSURL *URL;

@property(strong, nonatomic) id<IJKMediaPlayback> player;

@property (strong, nonatomic) VideoPlayerControl *controlView;

@end

@implementation VideoPlayer


+ (instancetype)playVideoWithURL:(NSURL *)URL title:(NSString *)title inController:(UIViewController *)controller {
    VideoPlayer *player = [[VideoPlayer alloc] init];
    player.URL = URL;
    player.title = title;
    [controller presentViewController:player animated:YES completion:NULL];
    return player;
}


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.controlView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayLoadStateDidChange:) name:IJKMPMoviePlayerLoadStateDidChangeNotification object:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player shutdown];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation; {
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}


#pragma mark - VideoPlayerControlDelegate
/// 关闭播放器
- (void)onClickBack {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
/// 点击播放开关
- (void)onClickPlaySwitch {
    if (self.player.playbackState == IJKMPMoviePlaybackStatePlaying) {
        [self.player pause];
    }
    else if (self.player.playbackState == IJKMPMoviePlaybackStatePaused) {
        [self.player play];
    }
    else if (self.player.playbackState == IJKMPMoviePlaybackStateStopped) {
        self.player.currentPlaybackTime = 0;
        [self.player play];
    }
}
- (NSTimeInterval)currentPlaybackTime {
    return [self.player currentPlaybackTime];
}
- (void)changePlayTime:(NSTimeInterval)newTime {
    [self.player setCurrentPlaybackTime:newTime];
}


#pragma mark - Notification
/// 播放状态发生改变
- (void)moviePlayBackStateDidChange:(NSNotification*)notification {
    NSLog(@"PlayBackState: %ld", (long)[self.player playbackState]);
    self.controlView.playbackState = [self.player playbackState];
}
/// 加载状态发生改变
- (void)moviePlayLoadStateDidChange:(NSNotification*)notification {
    NSLog(@"PlayLoadState: %ld", (unsigned long)[self.player loadState]);
    if ([self.player loadState] & IJKMPMovieLoadStatePlayable) {
        self.controlView.duration = [self.player duration];
    }
}

#pragma mark - Get

- (id<IJKMediaPlayback>)player {
    if (!_player) {
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
        
        IJKFFOptions *options = [IJKFFOptions optionsByDefault];
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURL:_URL withOptions:options];
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _player.view.frame = self.view.bounds;
        _player.scalingMode = IJKMPMovieScalingModeAspectFit;
        _player.shouldAutoplay = YES;
    }
    return _player;
}

- (VideoPlayerControl *)controlView {
    if (!_controlView) {
        _controlView = [[VideoPlayerControl alloc] init];
        _controlView.frame = self.view.bounds;
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.title = self.title;
        _controlView.delegate = self;
    }
    return _controlView;
}

@end
