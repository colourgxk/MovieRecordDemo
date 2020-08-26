//
//  MovieRecordView.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "MovieRecordView.h"
#import "RecordProgressView.h"

#define MRScreenWidth [UIScreen mainScreen].bounds.size.width
#define MRScreenHeight [UIScreen mainScreen].bounds.size.height


@interface MovieRecordView()<MovieRecordModelDelegate>

@property (nonatomic, strong) UIView *buttomLeftView;
@property (nonatomic, strong) UIButton *turnCamera;
@property (nonatomic, strong) UIView *buttomRightView;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) UIView *buttomCenterView;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *cancelBtn;


@property (nonatomic, strong) RecordProgressView *progressView;

@property (nonatomic, strong, readwrite) MovieRecordModel *movieRecordModel;

@end

@implementation MovieRecordView

-(instancetype)initWithMovieRecordViewType
{

    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self buildUIWithType];
    }
    return self;
}

#pragma mark - view
- (void)buildUIWithType
{
    
    self.movieRecordModel = [[MovieRecordModel alloc] initWithViewTypeAndSuperView:self];
    self.movieRecordModel.delegate = self;
    
    self.topView = [[UIView alloc] init];
    self.topView.frame = CGRectMake(0, 0, MRScreenWidth, 44);
    [self addSubview: self.topView];
    
    self.buttomLeftView = [[UIView alloc] init];
    self.buttomLeftView.frame = CGRectMake(0, MRScreenHeight-44, MRScreenWidth/3, 44);
    [self addSubview: self.buttomLeftView];
    
    self.buttomCenterView = [[UIView alloc] init];
    self.buttomCenterView.frame = CGRectMake(MRScreenWidth/3, MRScreenHeight-44, MRScreenWidth/3, 44);
    [self addSubview: self.buttomCenterView];
    
    
    self.buttomRightView = [[UIView alloc] init];
    self.buttomRightView.frame = CGRectMake(2*MRScreenWidth/3, MRScreenHeight-44, MRScreenWidth/3, 44);
    [self addSubview: self.buttomRightView];
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(15, 14, 16, 16);
    [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn sizeToFit];
    [self.topView addSubview: self.cancelBtn];
    
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCamera.frame = CGRectMake(MRScreenWidth - 28, MRScreenHeight - 38, 28, 22);
    [self.turnCamera setImage:[UIImage imageNamed:@"turncamera"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.turnCamera sizeToFit];
    [self.buttomLeftView addSubview: self.turnCamera];
    
    
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordBtn.frame = CGRectMake(5, 5, 52, 52);
    [self.recordBtn setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    [self.recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn sizeToFit];
    [self.buttomCenterView addSubview: self.recordBtn];
    
    
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.completeBtn.frame = CGRectMake(MRScreenWidth - 60 - 28, MRScreenHeight -38, 28, 22);
    [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttomRightView addSubview: self.completeBtn];
    
    //进度条
    self.progressView = [[RecordProgressView alloc] initWithFrame:CGRectMake(1, MRScreenHeight - 28, MRScreenWidth-2, 28)];
    //进度条边框宽度
    self.progressView.progressStokeWidth=1.0f;
    //进度条未加载背景
    self.progressView.progressBackgroundColor=[UIColor lightGrayColor];
    //进度条已加载 颜色
    self.progressView.progressColor=[UIColor blueColor];
    //背景边框颜色
    self.progressView.progressStokeBackgroundColor=[UIColor grayColor];
    [self addSubview:self.progressView];
    [self.progressView resetProgress];

}

- (void)updateViewWithInit
{
    self.topView.hidden = YES;
    self.buttomLeftView.hidden=NO;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=YES;
    [self changeToStopStyle];
}

- (void)updateViewWithRecording
{
    self.topView.hidden = YES;
    self.buttomLeftView.hidden=YES;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=NO;
    [self changeToRecordStyle];
}

- (void)updateViewWithPause
{
    self.topView.hidden = YES;
    self.buttomLeftView.hidden=YES;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=NO;
    [self changeToStopStyle];
}

- (void)updateViewWithFinish
{
    self.topView.hidden = NO;
    self.buttomLeftView.hidden=YES;
    self.buttomCenterView.hidden=YES;
    self.buttomRightView.hidden=YES;
}

- (void)changeToRecordStyle
{
    [self.recordBtn setImage:[UIImage imageNamed:@"on"] forState:UIControlStateNormal];
}

- (void)changeToStopStyle
{
    [self.recordBtn setImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
}

#pragma mark - action

- (void)dismissVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissVC)]) {
        [self.delegate dismissVC];
    }
}

- (void)turnCameraAction
{
     [self.movieRecordModel turnCameraAction];
}



//- (void)startRecord
//{
//    if (self.movieRecordModel.recordState == MovieRecordStateInit) {
//        [self.movieRecordModel startRecord];
//    } else if (self.movieRecordModel.recordState == MovieRecordStateRecording) {
//        [self.movieRecordModel stopRecord];
//    } else if (self.movieRecordModel.recordState == MovieRecordStatePause) {
//        [self.movieRecordModel pauseRecord];
//    } else{
//
//    }
//
//}


- (void)startRecord
{
    if (self.movieRecordModel.recordState == MovieRecordStateInit) {
        [self.movieRecordModel startRecord];
    } else if (self.movieRecordModel.recordState == MovieRecordStateRecording) {
        [self.movieRecordModel stopRecord];
    } else if (self.movieRecordModel.recordState == MovieRecordStatePause) {
        
    }
    
}

-(void)completeAction
{
    //todo 提前结束录制 进入播放界面
}

- (void)reset
{
    [self.movieRecordModel reset];
}

#pragma mark - MovieRecordModelDelegate

- (void)updateRecordState:(MovieRecordState)recordState
{
    if (recordState == MovieRecordStateInit) {
        [self updateViewWithInit];
        [self.progressView resetProgress];
    } else if (recordState == MovieRecordStateRecording) {
        [self updateViewWithRecording];
    } else if (recordState == MovieRecordStatePause) {
         [self updateViewWithPause];
    } else  if (recordState == MovieRecordStateFinish) {
        [self updateViewWithFinish];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithvideoUrl:)]) {
            [self.delegate recordFinishWithvideoUrl:self.movieRecordModel.videoUrl];
        }
    }
}

- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
 
}



@end



