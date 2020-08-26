//
//  RecordProgressView.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/21.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "RecordProgressView.h"

#define KProgressPadding 1.0f

@interface RecordProgressView ()
@property (nonatomic, weak) UIView *tView;
@property (nonatomic, weak) UIView *borderView;

@end

@implementation RecordProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //边框
        UIView *borderView = [[UIView alloc] initWithFrame:self.bounds];
        borderView.layer.cornerRadius = self.bounds.size.height * 0.5;
        borderView.layer.masksToBounds = YES;
        borderView.backgroundColor = [UIColor whiteColor];
        borderView.layer.borderColor = [[UIColor blueColor] CGColor];
        borderView.layer.borderWidth = 2.0f;
        self.borderView=borderView;
        [self addSubview:borderView];

        //进度
        UIView *tView = [[UIView alloc] init];
        tView.backgroundColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1];
        tView.layer.cornerRadius = (self.bounds.size.height - (2.0f + 1.0f) * 2) * 0.5;
        tView.layer.masksToBounds = YES;
        [self addSubview:tView];
        self.tView = tView;
    }

    return self;
}

//更新进度
-(void)updateProgressWithValue:(CGFloat)progress
{
    _progress = progress;

    CGFloat margin = self.progressStokeWidth + KProgressPadding;
    CGFloat maxWidth = self.bounds.size.width - margin * 2;
    CGFloat heigth = self.bounds.size.height - margin * 2;

    _tView.frame = CGRectMake(margin, margin, maxWidth * progress, heigth);
}


-(void)resetProgress
{
    [self updateProgressWithValue:0];
}

-(void)setProgressColor:(UIColor *)progressColor{
    _progressColor=progressColor;
    _tView.backgroundColor=progressColor;
}

-(void)setProgerStokeWidth:(CGFloat)progressStokeWidth{
    _progressStokeWidth=progressStokeWidth;
    _borderView.layer.borderWidth = progressStokeWidth;

}
-(void)setProgressStokeBackgroundColor:(UIColor *)progressStokeBackgroundColor{
    _progressStokeBackgroundColor=progressStokeBackgroundColor;
     _borderView.layer.borderColor = [progressStokeBackgroundColor CGColor];
}
-(void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor{
    _progressBackgroundColor = progressBackgroundColor;
    _borderView.backgroundColor=progressBackgroundColor;
}

@end
