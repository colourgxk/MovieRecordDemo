//
//  MovieRecordController.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "MovieRecordController.h"
#import "MovieRecordView.h"
#import "MoviePlayController.h"

@interface MovieRecordController ()<MovieRecordViewDelegate>
@property (nonatomic, strong) MovieRecordView *movieRecordView;
@end

@implementation MovieRecordController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - 控制器视图方法
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    _movieRecordView = [[MovieRecordView alloc] initWithMovieRecordViewType];
    _movieRecordView.delegate = self;
    [self.view addSubview:_movieRecordView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_movieRecordView.movieRecordModel.recordState == MovieRecordStateFinish) {
        [_movieRecordView reset];
    }
}

#pragma mark - MovieRecordViewDelegate
- (void)dismissVC
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)recordFinishWithvideoUrl:(NSURL *)videoUrl
{
    MoviePlayController *playController = [[MoviePlayController alloc] init];
    playController.videoUrl =  videoUrl;

//    todo navigationController
    [self.navigationController pushViewController:playController animated:YES];
}

@end

