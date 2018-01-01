//
//  ViewController.m
//  ZWPlayer
//
//  Created by Darsky on 2017/12/27.
//  Copyright © 2017年 Darsky. All rights reserved.
//

#import "ViewController.h"
#import "ZWPlayerViewController.h"

/*
 https://images.apple.com/media/cn/macbook/2015/98474cad-63d2-443a-9125-a1a80bc150dc/tour/design/macbook-design-cn-20150309_1280x720h.mp4
 https://images.apple.com/media/cn/iphone-7/2017/e1d65fb1_eb51_43ca_a7df_87df984a2655/tv-spots/the-city/iphone7-the-city-cn-20170501_960x540.mp4
 https://images.apple.com/media/cn/ipad-pro/2017/ceca813f_2d7f_43e9_a867_9a24f93f01c3/tv-spots/scout/ipad-pro-scout-cn-20171118_1280x720h.mp4
 https://images.apple.com/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4
 */


@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    __weak IBOutlet UITableView *_listTableView;
    
    NSArray                     *_dataArray;
}


@end

@implementation ViewController

static NSString *ZWPlayerListCellIdentifier = @"ZWPlayerListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataArray = @[@{@"name":@"macbook ADV",
                     @"url":@"https://images.apple.com/media/cn/macbook/2015/98474cad-63d2-443a-9125-a1a80bc150dc/tour/design/macbook-design-cn-20150309_1280x720h.mp4"},
                   @{@"name":@"iPhone 7 ADV",
                     @"url":@" https://images.apple.com/media/cn/iphone-7/2017/e1d65fb1_eb51_43ca_a7df_87df984a2655/tv-spots/the-city/iphone7-the-city-cn-20170501_960x540.mp4"},
                   @{@"name":@"iPad ADV",
                     @"url":@" https://images.apple.com/media/cn/ipad-pro/2017/ceca813f_2d7f_43e9_a867_9a24f93f01c3/tv-spots/scout/ipad-pro-scout-cn-20171118_1280x720h.mp4"},
                   @{@"name":@"iPhone X",
                     @"url":@"https://images.apple.com/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4"}
                   ];
    [_listTableView reloadData];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ZWPlayerListCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:ZWPlayerListCellIdentifier];
    }
    
    cell.textLabel.text = _dataArray[indexPath.row][@"name"];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    ZWPlayerViewController *viewController = nil;
    viewController = [[ZWPlayerViewController alloc] initWithNibName:@"ZWPlayerViewController"
                                                              bundle:nil];
    
    viewController.playUrlString = _dataArray[indexPath.row][@"url"];
    [self.navigationController pushViewController:viewController
                                         animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
