//
//  ZWPlayerViewController.m
//  ZWPlayer
//
//  Created by Darsky on 2018/1/1.
//  Copyright © 2018年 Darsky. All rights reserved.
//

#import "ZWPlayerViewController.h"
#import "ZWPlayerView.h"


@interface ZWPlayerViewController ()

@property (strong, nonatomic) ZWPlayerView *playerView;

@end

@implementation ZWPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_playerView == nil)
    {
        _playerView = [ZWPlayerView sharePlayerView];
        _playerView.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.width*9.0/16.0);
        [_playerView resetAVPlayerWithUrl:self.playUrlString
                        withProgressBlock:^(float progress, ZWPlayerViewStatus status, NSInteger currentSecond, NSInteger duration)
         {
             
         }];
        
        [self.view addSubview:_playerView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
