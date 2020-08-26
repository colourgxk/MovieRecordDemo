//
//  MovieRecordModel.m
//  MovieRecordDemo
//
//  Created by 关晓珂 on 2020/8/19.
//  Copyright © 2020 TencentIOS. All rights reserved.
//

#import "MovieRecordModel.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "SandBoxManager.h"



#define RECORD_MAX_TIME 10.0           //最长录制时间
#define TIMER_INTERVAL 0.05         //计时器刷新频率
#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹


@interface MovieRecordModel ()<AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) AVCaptureSession *session; //负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewlayer; //相机拍摄预览图层
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput; //负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *FileOutput; //视频输出流
@property (nonatomic, strong, readwrite) NSURL *videoUrl;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat recordTime;


@end

@implementation MovieRecordModel


- (instancetype)initWithViewTypeAndSuperView:(UIView *)superView
{
    self = [super init];
    if (self) {
        _superView = superView;
        [self setUpWithType];
    }
    return self;
}

#pragma mark - load
- (AVCaptureSession *)session
{
    // 录制5秒钟视频 高画质10M,压缩成中画质 0.5M
    // 录制5秒钟视频 中画质0.5M,压缩成中画质 0.5M
    // 录制5秒钟视频 低画质0.1M,压缩成中画质 0.1M
    // 只有高分辨率的视频才是全屏的，如果想要自定义长宽比，就需要先录制高分辨率，再剪裁，如果录制低分辨率，剪裁的区域不好控制
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {//设置分辨率
            _session.sessionPreset=AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}

- (AVCaptureVideoPreviewLayer *)previewlayer
{
    if (!_previewlayer) {
        _previewlayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewlayer;
}

- (void)setRecordState:(MovieRecordState)recordState
{
    if (_recordState != recordState) {
        _recordState = recordState;
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateRecordState:)]) {
            [self.delegate updateRecordState:_recordState];
        }
    }
}


#pragma mark - setup
- (void)setUpWithType
{
    ///0. 初始化捕捉会话，数据的采集都在会话中处理
    [self setUpInit];
    
    ///1. 设置视频的输入
    [self setUpVideo];
    
    ///2. 设置音频的输入
    [self setUpAudio];
    
    ///3.添加写入文件的fileoutput
    [self setUpFileOut];
    
    ///4. 视频的预览层
    [self setUpPreviewLayerWithType];
    
    ///5. 开始采集画面
    [self.session startRunning];
    
    /// 6. 将采集的数据写入文件（用户点击按钮即可将采集到的数据写入文件）

}


//初始化设置
///0. 初始化捕捉会话，数据的采集都在会话中处理
- (void)setUpInit
{
//    当程序被推送到后台时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBack)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
//    当程序从后台将要重新回到前台时
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [self clearFile];
    _recordTime = 0;
    _recordState = MovieRecordStateInit;
    
}

- (void)setUpVideo
{
    // 1.1 获取视频输入设备(摄像头)
    AVCaptureDevice *videoCaptureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
    
    // 1.2 创建视频输入源
    NSError *error=nil;
    self.videoInput= [[AVCaptureDeviceInput alloc] initWithDevice:videoCaptureDevice error:&error];
    if (error) {
           NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
           return;
       }
    // 1.3 将视频输入源添加到会话
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
        
    }
}

- (void)setUpAudio
{
    // 2.1 获取音频输入设备
    AVCaptureDevice *audioCaptureDevice=[[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    NSError *error=nil;
    // 2.2 创建音频输入源
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCaptureDevice error:&error];
    if (error) {
           NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
           return;
       }
    // 2.3 将音频输入源添加到会话
    if ([self.session canAddInput:self.audioInput]) {
        [self.session addInput:self.audioInput];
    }
}

- (void)setUpFileOut
{
    // 3.1初始化设备输出对象，用于获得输出数据
    self.FileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    // 3.2设置输出对象的一些属性
    AVCaptureConnection *captureConnection=[self.FileOutput connectionWithMediaType:AVMediaTypeVideo];
    //设置防抖
    //视频防抖 是在 iOS 6 和 iPhone 4S 发布时引入的功能。到了 iPhone 6，增加了更强劲和流畅的防抖模式，被称为影院级的视频防抖动。相关的 API 也有所改动 (目前为止并没有在文档中反映出来，不过可以查看头文件）。防抖并不是在捕获设备上配置的，而是在 AVCaptureConnection 上设置。由于不是所有的设备格式都支持全部的防抖模式，所以在实际应用中应事先确认具体的防抖模式是否支持：
    if ([captureConnection isVideoStabilizationSupported ]) {
        captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
    }
    //预览图层和视频方向保持一致
    captureConnection.videoOrientation = [self.previewlayer connection].videoOrientation;
    
    // 3.3将设备输出添加到会话中
    if ([_session canAddOutput:_FileOutput]) {
        [_session addOutput:_FileOutput];
    }
}

- (void)setUpPreviewLayerWithType
{
    CGRect rect = CGRectZero;
    rect = [UIScreen mainScreen].bounds;
    self.previewlayer.frame = rect;
    [_superView.layer insertSublayer:self.previewlayer atIndex:0];
}

//开始录制
- (void)writeDataTofile
{
    NSString *videoPath = [self createVideoFilePath];
    self.videoUrl = [NSURL fileURLWithPath:videoPath];
    [self.FileOutput startRecordingToOutputFileURL:self.videoUrl recordingDelegate:self];
    
}


-(void)changeDeviceProperty:(void(^)(AVCaptureDevice *captureDevice))propertyChange
{
    AVCaptureDevice *captureDevice = [self.videoInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark - public method
//切换摄像头
- (void)turnCameraAction
{
    [self.session stopRunning];
    // 1. 获取当前摄像头
    AVCaptureDevicePosition position = self.videoInput.device.position;
    
    //2. 获取当前需要展示的摄像头
    if (position == AVCaptureDevicePositionBack) {
        position = AVCaptureDevicePositionFront;
    } else {
        position = AVCaptureDevicePositionBack;
    }
    
    // 3. 根据当前摄像头创建新的device
    AVCaptureDevice *device = [self getCameraDeviceWithPosition:position];
    
    // 4. 根据新的device创建input
    AVCaptureDeviceInput *newInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    //5. 在session中切换input
    [self.session beginConfiguration];
    [self.session removeInput:self.videoInput];
    [self.session addInput:newInput];
    [self.session commitConfiguration];
    self.videoInput = newInput;
    
    [self.session startRunning];
    
}


- (void)startRecord
{
    [self writeDataTofile];
}

//to do why?//to do why?//to do why?//to do why?//to do why?//to do why?
-(void)pauseRecord
{
    [self.FileOutput stopRecording];
    [self.session stopRunning];
}

- (void)stopRecord
{
    [self.FileOutput stopRecording];
    [self.session stopRunning];
    
    //todo
    [self.timer invalidate];
    self.timer = nil;
}

///录制状态
- (void)reset
{
    self.recordState = MovieRecordStateInit;
    _recordTime = 0;
    [self.session startRunning];
}


#pragma mark - private method

//存放视频的文件夹
- (NSString *)videoFolder
{
    NSString *cacheDir = [SandBoxManager cachesDir];
    NSString *direc = [cacheDir stringByAppendingPathComponent:VIDEO_FOLDER];
    if (![SandBoxManager isExistsAtPath:direc]) {
        [SandBoxManager createDirectoryAtPath:direc];
    }
    return direc;
}


//写入的视频路径
- (NSString *)createVideoFilePath
{
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
}


//清空文件夹
- (void)clearFile
{
    [SandBoxManager removeItemAtPath:[self videoFolder]];
    
}


#pragma mark - 获取摄像头
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}


//to do
- (void)refreshTimeProgress
{
    _recordTime += TIMER_INTERVAL;
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateRecordingProgress:)]) {
        
        //todo  todo
        [self.delegate updateRecordingProgress:_recordTime/RECORD_MAX_TIME];
    }
    if (_recordTime >= RECORD_MAX_TIME) {
        [self stopRecord];
    }
}


#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL  fromConnections:(NSArray *)connections
{
    self.recordState = MovieRecordStateRecording;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(refreshTimeProgress) userInfo:nil repeats:YES];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if ([SandBoxManager isExistsAtPath:[self.videoUrl path]]) {
        self.recordState = MovieRecordStateFinish;
    }
}


#pragma mark - notification
- (void)enterBack
{
    self.videoUrl = nil;
    [self stopRecord];
}

- (void)becomeActive
{
    [self reset];
}

- (void)dealloc
{
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end

