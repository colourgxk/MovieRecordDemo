//
//  MovieRecordView.h
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieRecordModel.h"


@protocol MovieRecordViewDelegate <NSObject>

-(void)dismissVC;
-(void)recordFinishWithvideoUrl:(NSURL *)videoUrl;

@end


@interface MovieRecordView : UIView

@property (nonatomic, weak) id <MovieRecordViewDelegate> delegate;

- (instancetype)initWithMovieRecordViewType;
- (void)reset;

@end


