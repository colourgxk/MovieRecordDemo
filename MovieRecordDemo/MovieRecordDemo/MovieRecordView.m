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

    
    self.buttomLeftView = [[UIView alloc] init];
    self.buttomLeftView.frame = CGRectMake(0, MRScreenHeight-77, MRScreenWidth/3, 44);
    [self addSubview: self.buttomLeftView];
    
    self.buttomCenterView = [[UIView alloc] init];
    self.buttomCenterView.frame = CGRectMake(MRScreenWidth/3, MRScreenHeight-77, MRScreenWidth/3, 44);
    [self addSubview: self.buttomCenterView];
    
    
    self.buttomRightView = [[UIView alloc] init];
    self.buttomRightView.frame = CGRectMake(2*MRScreenWidth/3, MRScreenHeight-77, MRScreenWidth/3, 44);
    [self addSubview: self.buttomRightView];
    
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCamera.frame = CGRectMake(10, 0, 44, 44);
    [self.turnCamera setImage:[UIImage imageNamed:@"turncamera"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttomLeftView addSubview: self.turnCamera];
    
  
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
    self.recordBtn.frame = CGRectMake(10, 0, 50, 50);
    self.recordBtn.backgroundColor = [UIColor redColor];
    self.recordBtn.layer.cornerRadius = 26;
    self.recordBtn.layer.masksToBounds = YES;
    [self.buttomCenterView addSubview: self.recordBtn];
    
    
    self.completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.completeBtn.frame = CGRectMake(10, 0, 44, 44);
    [self.completeBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.completeBtn addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
    [self.buttomRightView addSubview: self.completeBtn];
    self.buttomRightView.hidden=YES;
    
    
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
    self.buttomLeftView.hidden=NO;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=YES;
    [self changeToStopStyle];
}

- (void)updateViewWithRecording
{
    self.buttomLeftView.hidden=YES;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=NO;
    [self changeToRecordStyle];
}

- (void)updateViewWithPause
{
    self.buttomLeftView.hidden=YES;
    self.buttomCenterView.hidden=NO;
    self.buttomRightView.hidden=NO;
    [self changeToStopStyle];
}


- (void)changeToRecordStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(28, 28);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 4;
        self.recordBtn.center = center;
    }];
}

- (void)changeToStopStyle
{
    [UIView animateWithDuration:0.2 animations:^{
        CGPoint center = self.recordBtn.center;
        CGRect rect = self.recordBtn.frame;
        rect.size = CGSizeMake(52, 52);
        self.recordBtn.frame = rect;
        self.recordBtn.layer.cornerRadius = 26;
        self.recordBtn.center = center;
    }];
}


#pragma mark - action

- (void)dismissVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissVC)]) {
        //代理MovieRecordController
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
//        [self.movieRecordModel pauseRecord];
//    } else if (self.movieRecordModel.recordState == MovieRecordStateFinish){
//        [self.movieRecordModel stopRecord];
//    }else if (self.movieRecordModel.recordState == MovieRecordStatePause) {
//        [self.movieRecordModel stopRecord];
//    }
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
    self.movieRecordModel.recordState = MovieRecordStateFinish;
    [self.movieRecordModel stopRecord];
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
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithvideoUrl:)]) {
            //代理MovieRecordController，push播放器
            [self.delegate recordFinishWithvideoUrl:self.movieRecordModel.videoUrl];
        }
    }
}

- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
 
}



@end


    
