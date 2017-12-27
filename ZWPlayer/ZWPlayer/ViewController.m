//
//  ViewController.m
//  ZWPlayer
//
//  Created by Darsky on 2017/12/27.
//  Copyright © 2017年 Darsky. All rights reserved.
//

#import "ViewController.h"
#import "ZWPlayerView.h"


@interface ViewController ()

@property (strong, nonatomic) ZWPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_playerView == nil)
    {
        _playerView = [ZWPlayerView sharePlayerView];
        _playerView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.width*9.0/16.0);
        [_playerView resetAVPlayerWithUrl:@"https://images.apple.com/media/cn/iphone-7/2017/e1d65fb1_eb51_43ca_a7df_87df984a2655/tv-spots/the-city/iphone7-the-city-cn-20170501_960x540.mp4" withProgressBlock:^(float progress, ZWPlayerViewStatus status, NSInteger currentSecond, NSInteger duration)
         {
            
        }];
        
        [self.view addSubview:_playerView];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
