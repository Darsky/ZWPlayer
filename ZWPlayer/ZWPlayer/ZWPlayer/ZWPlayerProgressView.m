//
//  ZWPlayerProgressView.m
//  ZWPlayer
//
//  Created by Darsky on 2017/12/28.
//  Copyright © 2017年 Darsky. All rights reserved.
//

#import "ZWPlayerProgressView.h"

@interface ZWPlayerProgressView ()
{
    UIView *_trackView;
    
    UIView *_bufferView;
}

@end

@implementation ZWPlayerProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius  = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor  = [UIColor colorWithRed:240/255.0
                                                green:240/255.0
                                                 blue:240/255.0
                                                alpha:1.0];

    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_bufferView == nil)
    {
        _bufferView = [[UIView alloc] init];
        _bufferView.backgroundColor  = [UIColor greenColor];
        [self addSubview:_bufferView];
    }
    _bufferView.frame =CGRectMake(0, 0, 0, self.frame.size.width);
    if (_trackView == nil)
    {
        _trackView = [[UIView alloc] init];
        _trackView.backgroundColor  = [UIColor blueColor];
        [self addSubview:_trackView];
    }
    _trackView.frame =CGRectMake(0, 0, 0, self.frame.size.width);
}

- (void)setProgress:(float)progress
{
    _progress = progress;
    _trackView.frame = CGRectMake(0, 0, self.frame.size.width*progress, _trackView.frame.size.height);
}

- (void)setBuffer:(float)buffer
{
    _buffer = buffer;
    _bufferView.frame = CGRectMake(0, 0, self.frame.size.width*_buffer, _bufferView.frame.size.height);

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
