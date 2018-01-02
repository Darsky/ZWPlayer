//
//  ZWPlayerRequest.h
//  ZWPlayer
//
//  Created by Darsky on 2018/1/2.
//  Copyright © 2018年 Darsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


typedef enum
{
    ZWPlayerRequestTypeVideo,
    ZWPlayerRequestTypeAudio
}ZWPlayerRequestType;

typedef enum
{
    ZWPlayerRequestStatusLoading,
    ZWPlayerRequestStatusLoaded
}ZWPlayerRequestStatus;

@protocol ZWPlayerRequestDelegate;

@interface ZWPlayerRequest : NSObject

@property (assign, nonatomic) ZWPlayerRequestType mediaType;

@property (copy, nonatomic) NSURL *url;

@property (assign, nonatomic) NSInteger offset;

@property (assign, nonatomic) NSInteger  length;

@property (assign, nonatomic) ZWPlayerRequestStatus  status;

@property (weak, nonatomic) id <ZWPlayerRequestDelegate> delegate;


- (void)setupUrl:(NSURL*)url withOffset:(NSInteger)offset;

- (void)cancel;

- (void)resumeLoading;

- (void)clearData;

@end

@protocol ZWPlayerRequestDelegate <NSObject>



@end
