//
//  MovieRecordModel.h
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import <Foundation/Foundation.h>

//录制状态
typedef NS_ENUM(NSInteger, MovieRecordState) {
    MovieRecordStateInit = 0,
    MovieRecordStateRecording,
    MovieRecordStatePause,
    MovieRecordStateFinish,
};

@protocol MovieRecordModelDelegate <NSObject>

- (void)updateRecordingProgress:(CGFloat)progress;
- (void)updateRecordState:(MovieRecordState)recordState;

@end

@interface  MovieRecordModel : NSObject

@property (nonatomic, weak  ) id<MovieRecordModelDelegate> delegate;
@property (nonatomic, assign) MovieRecordState recordState;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
- (instancetype)initWithViewTypeAndSuperView:(UIView *)superView;

- (void)turnCameraAction;
- (void)startRecord;
- (void)stopRecord;
- (void)reset;

@end
