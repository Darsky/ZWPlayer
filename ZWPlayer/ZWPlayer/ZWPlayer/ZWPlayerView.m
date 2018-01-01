//
//  ZWPlayerView.m
//  ZWPlayer
//
//  Created by Darsky on 2017/12/27.
//  Copyright © 2017年 Darsky. All rights reserved.
//

#import "ZWPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "ZWPlayerProgressView.h"

#define ToolBarHeight 40

//https://images.apple.com/media/cn/iphone-7/2017/e1d65fb1_eb51_43ca_a7df_87df984a2655/tv-spots/the-city/iphone7-the-city-cn-20170501_960x540.mp4

@interface ZWPlayerView ()
{
#pragma mark - player's Widget
    UIView         *_playerLayerView;
    
    UILabel        *_alertLabel;
    
    UIView         *_topToolView;
    
    UIView         *_bottomToolView;
    
    UIButton       *_playButton;
    
    UIView         *_loadingView;
    
    UILabel        *_cuDurLabel;
    
    UILabel        *_reDurLabel;
    
    ZWPlayerProgressView *_progressView;
    
    int             _relaxTime;
    
    BOOL            _isPortraitVideo;

}
@property (strong, nonatomic) AVPlayer *player;

@property (strong, nonatomic) AVPlayerLayer *playerLayer;

@property (strong, nonatomic) id playerTimeObser;

@property (copy, nonatomic)   NSURL *currentPlayUrl;


@end

@implementation ZWPlayerView

+ (instancetype)sharePlayerView
{
    static dispatch_once_t onceToken;
    static ZWPlayerView *instance;
    dispatch_once(&onceToken, ^{
        instance = [[ZWPlayerView alloc] init];
    });
    return instance;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self layoutSubviews];
}

#pragma mark - resetSubviews Method
- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_playerLayerView == nil)
    {
        self.backgroundColor = [UIColor blackColor];
        _playerLayerView = [[UIView alloc] init];
        [self addSubview:_playerLayerView];
    }
    _playerLayerView.frame = self.bounds;
    if (_playButton == nil)
    {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(0, 0, 68, 68);
        [_playButton setImage:[UIImage imageNamed:@"img_videoplayer_play_big"]
                     forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"img_videoplayer_pause_big"]
                     forState:UIControlStateSelected];
        [_playButton addTarget:self
                        action:@selector(didPlayButtonTouch)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
    }
    _playButton.selected = NO;
    _playButton.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    if (_topToolView == nil)
    {
        _topToolView = [[UIView alloc] init];
        _topToolView.backgroundColor = [UIColor colorWithRed:0
                                                       green:0
                                                        blue:0
                                                       alpha:0.5];
        [self addSubview:_topToolView];
    }
    _topToolView.frame = CGRectMake(0, 0, self.frame.size.width, ToolBarHeight);
    if (_bottomToolView == nil)
    {
        _bottomToolView = [[UIView alloc] init];
        _bottomToolView.backgroundColor = [UIColor colorWithRed:0
                                                       green:0
                                                        blue:0
                                                       alpha:0.5];
        [self addSubview:_bottomToolView];
    }
    _bottomToolView.frame = CGRectMake(0, self.frame.size.height - ToolBarHeight, self.frame.size.width, ToolBarHeight);
    if (_cuDurLabel == nil)
    {
        _cuDurLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, ToolBarHeight/2.0 - 10.0, 45, 20)];
        _cuDurLabel.text = @"00:00";
        _cuDurLabel.textColor = [UIColor whiteColor];
        _cuDurLabel.font = [UIFont systemFontOfSize:12];
        [_bottomToolView addSubview:_cuDurLabel];
        _reDurLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ToolBarHeight/2.0 - 10.0, 45, 20)];
        _reDurLabel.font = [UIFont systemFontOfSize:12];
        _reDurLabel.text = @"00:00";
        _reDurLabel.textColor = [UIColor whiteColor];
        [_bottomToolView addSubview:_reDurLabel];
        _progressView = [[ZWPlayerProgressView alloc] init];
        [_bottomToolView addSubview:_progressView];
    }
    _reDurLabel.frame = CGRectMake(self.frame.size.width - 45 - 13, _reDurLabel.frame.origin.y, _reDurLabel.frame.size.width, _reDurLabel.frame.size.height);

    _progressView.frame = CGRectMake(_cuDurLabel.frame.origin.x + _cuDurLabel.frame.size.width +5,
                                     ToolBarHeight/2.0 - 1.0,
                                     _reDurLabel.frame.origin.x - 5 - _cuDurLabel.frame.origin.x - _cuDurLabel.frame.size.width -5,
                                     2);
    [_progressView setProgress:0];
}

#pragma mark - resetPlayer Method
- (void)resetAVPlayerWithUrl:(NSString*)url
           withProgressBlock:(ZWPlayerStatusBlock)statusBlock
{
    //step 1 TODO://Make sure that can we find this movie in the device by url.
    NSURL *playerUrl = [self createPlayUrl:url];
    if (playerUrl == nil)
    {
        [self showAlertMessageWithString:@"Link Invalid"];
        return;
    }
    else
    {
        _currentPlayUrl = playerUrl;
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_currentPlayUrl];
        if (self.player == nil)
        {
            _player  = [AVPlayer playerWithPlayerItem:playerItem];
            if ([[UIDevice currentDevice] systemVersion].floatValue >= 10)
            {
                self.player.automaticallyWaitsToMinimizeStalling = YES;
            }
            __block AVPlayer       *player       = _player;
            __block UILabel        *leftLabel    = _cuDurLabel;
            __block UILabel        *rightLabel   = _reDurLabel;
            __block ZWPlayerView   *playerView   = self;
            __block ZWPlayerProgressView *progressView = _progressView;
            self.playerTimeObser =  [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1)
                                                                          queue:NULL
                                                                     usingBlock:^(CMTime time)
                                     {
                                         if (player.currentItem.currentTime.value > 0)
                                         {
                                             CMTime ctime = player.currentItem.currentTime;
                                             NSInteger currentSecond = ctime.value/ctime.timescale;
                                             NSInteger duration = player.currentItem.duration.value/player.currentItem.duration.timescale;
                                             leftLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)currentSecond/60,(NSInteger)currentSecond%60];
                                             rightLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)duration/60,(NSInteger)duration%60];
                                             float progress = (float)currentSecond/(float)duration;
                                             if (playerView.statusBlock != nil)
                                             {
                                                 playerView.statusBlock(progress, playerView.status,currentSecond,duration);
                                             }
                                             [progressView setProgress:progress];
                                         }
                                     }];
        }
        else
        {
            [_player replaceCurrentItemWithPlayerItem:playerItem];
        }
        if (_playerLayer == nil)
        {
            _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            [_playerLayerView.layer addSublayer:_playerLayer];
            _playerLayer.frame = self.bounds;
        }
        [self resumeObservers];
        self.status = ZWPlayerViewStatusFree;
    }
}

#pragma mark - Other Method

- (NSURL*)createPlayUrl:(NSString*)urlString
{
    if (urlString == nil ||
        urlString.length == 0 ||
        [urlString isEqualToString:@""] ||
        [urlString rangeOfString:@"http"].location == NSNotFound)
    {
        return nil;
    }
    else
    {
        NSURL *resultUrl = nil;
        
        resultUrl = [NSURL URLWithString:urlString];
        return resultUrl;
    }
    
}

- (void)showAlertMessageWithString:(NSString*)string
{
    if (_alertLabel == nil)
    {
        _alertLabel = [[UILabel alloc] init];
        _alertLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _alertLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_alertLabel];
    }
    _alertLabel.alpha = 1;
    _alertLabel.hidden = NO;
    _alertLabel.text = string;
    [_alertLabel sizeToFit];
    [self bringSubviewToFront:_alertLabel];
    [self performSelector:@selector(dissAlertMessage)
               withObject:nil
               afterDelay:3];
}

- (void)dissAlertMessage
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _alertLabel.alpha = 0;
    }
                     completion:^(BOOL finished)
    {
        if (finished)
        {
            _alertLabel.hidden = YES;
            _alertLabel.alpha  = 1;
        }
    }];
}

- (void)resumeObservers
{
    [_player.currentItem  addObserver:self
                           forKeyPath:@"status"
                              options:NSKeyValueObservingOptionNew
                              context:nil];
    if (![self.currentPlayUrl isFileURL])
    {
        [_player.currentItem addObserver:self
                              forKeyPath:@"loadedTimeRanges"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
        [_player.currentItem addObserver:self
                              forKeyPath:@"playbackBufferEmpty"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    }
    [_player.currentItem addObserver:self
                          forKeyPath:@"playbackLikelyToKeepUp"
                             options:NSKeyValueObservingOptionNew
                             context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackFinished:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChangeListenerCallback:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];//设置通知
}

#pragma mark - ObserverSelector Method

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([object isKindOfClass:[AVPlayerItem class]])
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"status"])
        {
            if ([playerItem status] == AVPlayerStatusReadyToPlay)
            {
                NSArray *tracks = [playerItem.asset tracksWithMediaType:AVMediaTypeVideo];
                if([tracks count] > 0)
                {
                    AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
                    CGAffineTransform t = videoTrack.preferredTransform;
                    CGFloat rotate = acosf(t.a);
                    
                    // 旋转180度后，需要处理弧度的变化
                    if (t.b < 0)
                    {
                        rotate = M_PI -rotate;
                    }
                    // 将弧度转换为角度
                    CGFloat degree = rotate/M_PI * 180;
                    CGFloat duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
                    NSLog(@"准备好播放了，总时间：%.2f", duration);//还可以获得播放的进度，这里可以给播放进度条赋值了
                    if (videoTrack.naturalSize.height > videoTrack.naturalSize.width)
                    {
                        _isPortraitVideo = degree > 0?NO:YES;
                    }
                    else
                    {
                        _isPortraitVideo = degree > 0?YES:NO;
                    }
                    if (self.status == ZWPlayerViewStatusFree)
                    {
                        self.status = ZWPlayerViewStatusLoading;
                        if (self.statusBlock != nil)
                        {
                            CMTime ctime = self.player.currentItem.currentTime;
                            NSInteger currentSecond = ctime.value/ctime.timescale;
                            NSInteger duration = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
                            self.statusBlock(1, self.status,currentSecond,duration);
                        }
                        [self showOrHidePlayerLoadingAnimation:YES];
                    }
                }
            }
            else if ([playerItem status] == AVPlayerStatusFailed)
            {
                [_player pause];
            }
            else if ([playerItem status] == AVPlayerStatusUnknown)
            {
                [_player pause];
            }
        }
        else if ([keyPath isEqualToString:@"loadedTimeRanges"])
        {
            //监听播放器的下载进度
            NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
            CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
             CGFloat duration = playerItem.duration.value / playerItem.duration.timescale;
            [_progressView setBuffer:timeInterval/duration];
        }
        else if ([keyPath isEqualToString:@"playbackBufferEmpty"])
        {
            //监听播放器在缓冲数据的状态
            NSLog(@"playbackBufferEmpty");
            if (self.status == ZWPlayerViewStatusFree)
            {
                self.status = ZWPlayerViewStatusLoading;
                [self showOrHidePlayerLoadingAnimation:YES];
            }
            else if (self.status == ZWPlayerViewStatusPlay)
            {
                NSLog(@"暂停播放，进入缓冲");
                [self playerWaitingToPlayAtSpecifiedRate];
            }
        }
        else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"])
        {
            NSLog(@"playbackLikelyToKeepUp");
            if (self.status == ZWPlayerViewStatusPauseWaiting)
            {
                NSLog(@"恢复因为缓冲导致的暂停状态");
                [self showOrHidePlayerLoadingAnimation:NO];
                [self playerStartPlay];
            }
            else if (self.status == ZWPlayerViewStatusLoading)
            {
                self.status = ZWPlayerViewStatusPrepare;
                [self showOrHidePlayerLoadingAnimation:NO];
            }
        }
    }
}

-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"Player playback finished");
    _playButton.selected = NO;
    self.status = ZWPlayerViewStatusStop;
    if (self.statusBlock != nil)
    {
        CMTime ctime = self.player.currentItem.currentTime;
        NSInteger currentSecond = ctime.value/ctime.timescale;
        NSInteger duration = self.player.currentItem.duration.value/self.player.currentItem.duration.timescale;
        self.statusBlock(1, self.status,currentSecond,duration);
    }
    
}

//User remove or insert earphones will
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    
}

#pragma mark - Function Method

- (void)didPlayButtonTouch
{
    if (_playButton.selected)
    {
        [self playerStartPause];
    }
    else
    {
        [self playerStartPlay];
    }
}

- (void)playerStartPlay
{
    if (self.player.status != AVPlayerStatusFailed && self.status != ZWPlayerViewStatusLoading&& self.status != ZWPlayerViewStatusFree)
    {
        if (self.status == ZWPlayerViewStatusStop)
        {
            self.userInteractionEnabled = NO;
            [_player seekToTime:CMTimeMakeWithSeconds(0, _player.currentItem.duration.timescale)
              completionHandler:^(BOOL finished)
             {
                 if (finished)
                 {
                     self.userInteractionEnabled = YES;
                     [_player play];
                     self.status = ZWPlayerViewStatusPlay;
                     _playButton.selected = YES;
                 }
             }];
        }
        else
        {
            [_player play];
            self.status = ZWPlayerViewStatusPlay;
            _playButton.selected = YES;
        }
        
    }
}

- (void)playerStartPause
{
    [_player pause];
    self.status = ZWPlayerViewStatusPause;
    _playButton.selected = NO;
}

- (void)playerWaitingToPlayAtSpecifiedRate
{
    [_player pause];
    self.status = ZWPlayerViewStatusPauseWaiting;
    [self showOrHidePlayerLoadingAnimation:YES];
}

- (void)showOrHidePlayerLoadingAnimation:(BOOL)shouldShow
{
    if (shouldShow && _loadingView == nil)
    {
        _playButton.hidden = YES;
        _loadingView = [[UIView alloc] initWithFrame:_playButton.frame];
        _loadingView.layer.masksToBounds = YES;
        _loadingView.layer.cornerRadius  = _playButton.frame.size.width/2.0;
        [_loadingView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_loadingView];
        CGFloat radius = _playButton.frame.size.width;
        UIBezierPath* path = [[UIBezierPath alloc] init];
        [path addArcWithCenter:CGPointMake(radius/2, radius/2)
                        radius:(radius/2 - 5)
                    startAngle:0
                      endAngle:M_PI_2 * 2
                     clockwise:YES];
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.lineWidth = 1.5;
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = _loadingView.backgroundColor.CGColor;
        shapeLayer.frame = CGRectMake(0, 0, radius, radius);
        shapeLayer.path = path.CGPath;
        [_loadingView.layer addSublayer:shapeLayer];
        
        //让圆转圈，实现"加载中"的效果
        CABasicAnimation* baseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        baseAnimation.duration = 1;
        baseAnimation.fromValue = @(0);
        baseAnimation.toValue = @(2 * M_PI);
        baseAnimation.repeatCount = MAXFLOAT;
        [_loadingView.layer addAnimation:baseAnimation
                                  forKey:nil];
    }
    else if (!shouldShow && _loadingView != nil)
    {
        _playButton.hidden = NO;
        [_loadingView.layer removeAllAnimations];
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
    
}


- (void)dismiss
{
    [_player pause];
    [_player.currentItem removeObserver:self
                             forKeyPath:@"status"];
    @try
    {
        [_player.currentItem removeObserver:self
                                 forKeyPath:@"loadedTimeRanges"];
        [_player.currentItem removeObserver:self
                                 forKeyPath:@"playbackBufferEmpty"];
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
    
    [_player.currentItem removeObserver:self
                             forKeyPath:@"playbackLikelyToKeepUp"];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:nil];
    [self.player removeTimeObserver:self.playerTimeObser];
    _player = nil;
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    
    
    _cuDurLabel.text  = @"00:00";
    _reDurLabel.text = @"00:00";
    [_progressView setProgress:0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
