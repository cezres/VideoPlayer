//
//  VideoPlayerProgressView.h
//  VideoPlayer
//
//  Created by 翟泉 on 2016/9/29.
//  Copyright © 2016年 云之彼端. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerProgressView : UISlider

@end

@interface VideoPlayerChangeProgressView : UIVisualEffectView

+ (instancetype)showProgressViewWith:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;

+ (void)hidden;

@end

