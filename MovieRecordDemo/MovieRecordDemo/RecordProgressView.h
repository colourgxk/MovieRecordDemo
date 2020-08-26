//
//  RecordProgressView.h
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/21.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
//进度条颜色
@property(nonatomic,strong) UIColor *progressColor;
//进度条背景颜色
@property(nonatomic,strong) UIColor *progressBackgroundColor;
//进度条边框的颜色
@property(nonatomic,strong) UIColor *progressStokeBackgroundColor;
//进度条边框的宽度
@property(nonatomic,assign) CGFloat progressStokeWidth;


-(void)setProgressColor:(UIColor *)progressColor;
-(void)setProgressStokeWidth:(CGFloat)progressStokeWidth;
-(void)setProgressStokeBackgroundColor:(UIColor *)progressStokeBackgroundColor;
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor;
- (instancetype)initWithFrame:(CGRect)frame;
-(void)updateProgressWithValue:(CGFloat)progress;
-(void)resetProgress;


@end

NS_ASSUME_NONNULL_END

