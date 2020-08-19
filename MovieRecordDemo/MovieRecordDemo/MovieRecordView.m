//
//  MovieRecordView.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "MovieRecordView.h"
#import "MovieRecordModel.h"

#define MRScreenWidth [UIScreen mainScreen].bounds.size.width
#define MRScreenHeight [UIScreen mainScreen].bounds.size.height
@interface MovieRecordView()

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *turnCamera;




@property (nonatomic, strong) UIButton *recordBtn;


@property (nonatomic, strong, readwrite) MovieRecordModel *movieRecordModel;

@end

@implementation MovieRecordView

-(instancetype)initWithMovieRecordViewType
{

    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self BuildUIWithType];
    }
    return self;
}

#pragma mark - view
- (void)BuildUIWithType
{
    
    self.movieRecordModel = [[MovieRecordModel alloc] initWithViewTypeAndSuperView:self];
    self.movieRecordModel.delegate = self;
    
    self.topView = [[UIView alloc] init];
    self.topView.frame = CGRectMake(0, 0, MRScreenHeight, 44);
    [self addSubview:self.topView];
    
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.frame = CGRectMake(15, 14, 16, 16);
    [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [self.cancelBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.cancelBtn];
    
    
    self.turnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    self.turnCamera.frame = CGRectMake(MRScreenWidth - 60 - 28, 11, 28, 22);
    [self.turnCamera setImage:[UIImage imageNamed:@"listing_camera_lens"] forState:UIControlStateNormal];
    [self.turnCamera addTarget:self action:@selector(turnCameraAction) forControlEvents:UIControlEventTouchUpInside];
    [self.turnCamera sizeToFit];
    [self.topView addSubview:self.turnCamera];
    
    
    
//    self.progressView = [[FMRecordProgressView alloc] initWithFrame:CGRectMake((kScreenWidth - 62)/2, kScreenHeight - 32 - 62, 62, 62)];
//    self.progressView.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.progressView];
//
//    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.recordBtn addTarget:self action:@selector(startRecord) forControlEvents:UIControlEventTouchUpInside];
//    self.recordBtn.frame = CGRectMake(5, 5, 52, 52);
//    self.recordBtn.backgroundColor = [UIColor redColor];
//    self.recordBtn.layer.cornerRadius = 26;
//    self.recordBtn.layer.masksToBounds = YES;
//    [self.progressView addSubview:self.recordBtn];
//    [self.progressView resetProgress];
}

- (void)updateViewWithRecording
{
    self.topView.hidden = YES;
    [self changeToRecordStyle];
}

- (void)updateViewWithStop
{
    self.topView.hidden = NO;
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
        [self.delegate dismissVC];
    }
}

- (void)turnCameraAction
{
     [self.movieRecordModel turnCameraAction];
}


- (void)startRecord
{
    if (self.movieRecordModel.recordState == MovieRecordStateInit) {
        [self.movieRecordModel startRecord];
    } else if (self.movieRecordModel.recordState == MovieRecordStateRecording) {
        [self.movieRecordModel stopRecord];
    } else if (self.movieRecordModel.recordState == MovieRecordStatePause) {
        
    }
    
}

- (void)reset
{
    [self.movieRecordModel reset];
}

#pragma mark - MovieRecordModelDelegate

- (void)updateRecordState:(MovieRecordState)recordState
{
    if (recordState == MovieRecordStateInit) {
        [self updateViewWithStop];
        [self.progressView resetProgress];
    } else if (recordState == MovieRecordStateRecording) {
        [self updateViewWithRecording];
    } else if (recordState == MovieRecordStatePause) {
         [self updateViewWithStop];
    } else  if (recordState == MovieRecordStateFinish) {
        [self updateViewWithStop];
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordFinishWithvideoUrl:)]) {
            [self.delegate recordFinishWithvideoUrl:self.movieRecordModel.videoUrl];
        }
    }
}

- (void)updateRecordingProgress:(CGFloat)progress
{
    [self.progressView updateProgressWithValue:progress];
 
}


- (NSString *)changeToVideotime:(CGFloat)videocurrent {
    
    return [NSString stringWithFormat:@"%02li:%02li",lround(floor(videocurrent/60.f)),lround(floor(videocurrent/1.f))%60];
    
}
@end



