//
//  MovieRecordController.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "MovieRecordController.h"
#import "MovieRecordView.h"

// #import "FMVideoPlayController.h"
@interface MovieRecordController ()<MovieRecordViewDelegate>
@property (nonatomic, strong) MovieRecordView *videoView;
@end

@implementation MovieRecordController

- (BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _videoView = [[MovieRecordView alloc] initWithFMVideoViewType:TypeFullScreen];
    _videoView.delegate = self;
    [self.view addSubview:_videoView];
    
    
}
//TODO
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_videoView.movieRecordModel.recordState == MovieRecordStateFinish) {
        [_videoView reset];
    }
    
}
#pragma mark - FMFVideoViewDelegate
- (void)dismissVC
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)recordFinishWithvideoUrl:(NSURL *)videoUrl
{
    FMVideoPlayController *playVC = [[FMVideoPlayController alloc] init];
    playVC.videoUrl =  videoUrl;
    [self.navigationController pushViewController:playVC animated:YES];
}

@end

