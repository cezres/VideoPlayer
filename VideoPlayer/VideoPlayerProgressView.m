//
//  VideoPlayerProgressView.m
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/29.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import "VideoPlayerProgressView.h"

@implementation VideoPlayerProgressView

- (instancetype)init {
    if (self = [super init]) {
        
        self.minimumTrackTintColor = [UIColor colorWithRed:219/255.0 green:92/255.0 blue:92/255.0 alpha:1];
        self.maximumTrackTintColor = [UIColor colorWithWhite:86/255.0 alpha:1.0];
        self.minimumValue = 0;
        self.maximumValue = 1;
        self.value = 0;
        
        CGFloat width = 10;
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(10, 10), NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor *bgColor = [UIColor clearColor];
        CGContextSetStrokeColorWithColor(context, bgColor.CGColor);
        CGContextSetFillColorWithColor(context, bgColor.CGColor);
        CGRect bgRect = CGRectMake(0, 0, width, width);
        CGContextAddRect(context, bgRect);
        CGContextDrawPath(context, kCGPathFillStroke);
        
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextAddArc(context, width/2, width/2, width/2, 0, 2*M_PI, 0);
        CGContextDrawPath(context, kCGPathFill);
        UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self setThumbImage:thumb forState:UIControlStateNormal];
    }
    return self;
}

- (CGRect)trackRectForBounds:(CGRect)bounds; {
    return CGRectMake(0, (bounds.size.height-4)/2, bounds.size.width, 4);
}

@end


@interface VideoPlayerChangeProgressView ()

@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIProgressView *progressView;

@end

@implementation VideoPlayerChangeProgressView

+ (instancetype)showProgressViewWith:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration {
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    VideoPlayerChangeProgressView *progressView = [window viewWithTag:6846541];
    if (!progressView) {
        progressView = [[VideoPlayerChangeProgressView alloc] init];
        progressView.tag = 6846541;
        [window addSubview:progressView];
        progressView.frame = CGRectMake(0, 0, 100, 50);
        progressView.center = window.center;
    }
    
    progressView.progressView.progress = currentTime / duration;
    progressView.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d / %02d:%02d", (int)currentTime / 60, (int)currentTime % 60, (int)duration / 60, (int)duration % 60];
    
    return progressView;
}

+ (void)hidden {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    VideoPlayerChangeProgressView *progressView = [window viewWithTag:6846541];
    [progressView hidden];
}


- (instancetype)init {
    if (self = [super initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]) {
        self.layer.cornerRadius = 6;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)hidden {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _timeLabel.frame = CGRectMake(0, (self.bounds.size.height - 16) / 2, self.bounds.size.width, 16);
    _progressView.frame = CGRectMake(10, CGRectGetMaxY(_timeLabel.frame) + 5, self.bounds.size.width-20, 2);
}

#pragma mark - get / set

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UIProgressView *)progressView; {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor colorWithRed:219/255.0 green:92/255.0 blue:92/255.0 alpha:1];
        _progressView.trackTintColor = [UIColor colorWithWhite:86/255.0 alpha:1.0];
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end

