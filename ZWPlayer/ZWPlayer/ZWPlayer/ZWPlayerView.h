//
//  ZWPlayerView.h
//  ZWPlayer
//
//  Created by Darsky on 2017/12/27.
//  Copyright © 2017年 Darsky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ZWPlayerViewStatusFree = 0,//Free ,default status
    ZWPlayerViewStatusLoading,//WaitingToPlayAtSpecifiedRate
    ZWPlayerViewStatusPrepare,//准备就绪
    ZWPlayerViewStatusPlay,//播放中
    ZWPlayerViewStatusPause,//暂停
    ZWPlayerViewStatusPauseWaiting,//WaitingToPlayAtSpecifiedRate
    ZWPlayerViewStatusSeeking,//拖拽
    ZWPlayerViewStatusStop,//停止
    ZWPlayerViewStatusError//错误
}ZWPlayerViewStatus;

typedef void (^ZWPlayerStatusBlock)(float progress, ZWPlayerViewStatus status,NSInteger currentSecond
                                          ,NSInteger duration);

@interface ZWPlayerView : UIView

@property (assign, nonatomic) ZWPlayerViewStatus status;

@property (weak, nonatomic)   ZWPlayerStatusBlock statusBlock;

+ (instancetype)sharePlayerView;

- (void)resetAVPlayerWithUrl:(NSString*)url
           withProgressBlock:(ZWPlayerStatusBlock)statusBlock;

@end
