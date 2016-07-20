//
//  ViewController.m
//  Live
//
//  Created by user on 16/7/15.
//  Copyright © 2016年 Li. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureDevice *audioDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioInput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) NSMutableArray *capturedAudioArray;
@property (nonatomic, strong) UIButton *stopBtn;
@property (nonatomic, assign) BOOL start;
@property (nonatomic, strong) UIButton *devicePosition;
@property (nonatomic, strong) UIButton *clearBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _start = YES;
    _capturedAudioArray = [NSMutableArray array];
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.recordButton.frame = CGRectMake(100, self.view.frame.size.height - 60, 60, 40);
    [_recordButton addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton setTitle:@"开始录制" forState:UIControlStateNormal];
    _recordButton.titleLabel.font = [UIFont systemFontOfSize:13];
//    [_recordButton addTarget:self action:@selector(recordButtonTouchUp:) forControlEvents:UIControlEventTouchDown];
    _recordButton.backgroundColor = [UIColor redColor];
    self.previewView = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.previewView];
    [self.view addSubview:_recordButton];
    [self setupCaptureSession];
    [self startSession];
     self.previewLayer.frame = self.previewView.bounds;
    
    self.stopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.stopBtn.frame = CGRectMake(200, self.view.frame.size.height - 60, 60, 40);
    _stopBtn.backgroundColor = [UIColor redColor];
    
    [_stopBtn setTitle:@"合并录制" forState:UIControlStateNormal];
    [_stopBtn addTarget:self action:@selector(stopRecod:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopBtn];
    _stopBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.devicePosition = [UIButton buttonWithType:UIButtonTypeCustom];
    self.devicePosition.frame = CGRectMake(self.view.frame.size.width - 100, 20, 60, 40);
    _devicePosition.backgroundColor = [UIColor redColor];
    [_devicePosition setTitle:@"转换" forState:UIControlStateNormal];
    [_devicePosition addTarget:self action:@selector(transformPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    
    //[self.view addSubview:_devicePosition];

    
    self.clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clearBtn.frame = CGRectMake(300, self.view.frame.size.height - 60, 60, 40);
    _clearBtn.backgroundColor = [UIColor redColor];
    _clearBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_clearBtn setTitle:@"清除缓存" forState:UIControlStateNormal];
    [_clearBtn addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_clearBtn];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)clear{
     NSFileManager *fileMger = [NSFileManager defaultManager];
      NSString *xiaoXiPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    [fileMger removeItemAtPath:xiaoXiPath error:nil];
}
- (void) transformPhoto{
    
}
- (void)stopRecod:(UIButton *)sender{
    [self mergeAndExportVideos:_capturedAudioArray withOutPath:[self videoPath]];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopSession];
}

-(void)viewWillLayoutSubviews {
    
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}


#pragma mark - Setup

- (void)setupCaptureSession {
    // 1.获取视频设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.videoDevice = device;
            break;
        }
        
    }
    // 2.获取音频设备
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    // 3.创建视频输入
    NSError *error = nil;
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
    if (error) {
        return;
    }
    // 4.创建音频输入
    self.audioInput = [AVCaptureDeviceInput deviceInputWithDevice:self.audioDevice error:&error];
    if (error) {
        return;
    }
    // 5.创建视频输出
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    // 6.建立会话
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
   
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:self.videoInput];
    }
    if ([self.captureSession canAddInput:self.audioInput]) {
        [self.captureSession addInput:self.audioInput];
    }
    if ([self.captureSession canAddOutput:self.movieFileOutput]) {
        [self.captureSession addOutput:self.movieFileOutput];
    }
    // 7.预览画面
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    [self.previewView.layer addSublayer:self.previewLayer];
}
#pragma mark - Action

- (void)recordButtonTouchDown:(id)sender {
    NSLog(@"touch down");
   
    if (_start) {
         [self startRecord];
         [_recordButton setTitle:@"正在录制" forState:UIControlStateNormal];
    }
    if (!_start) {
         [self stopRecord];
        [_recordButton setTitle:@"暂停录制" forState:UIControlStateNormal];
    }
    _start = !_start;
}
- (void)recordButtonTouchUp:(id)sender {
    NSLog(@"touch up");
   
    
}
#pragma mark - Tool

- (NSString *)videoPath {
    NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *moviePath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%f.mov",[NSDate date].timeIntervalSince1970]];
    return moviePath;
}

- (AVCaptureDevice *)deviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}
#pragma mark - Session

- (void)startSession {
    if(![self.captureSession isRunning]) {
        [self.captureSession startRunning];
    }
}

- (void)stopSession {
    if([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
    }
}

#pragma mark - Record

- (void)startRecord {
    if (self.videoDevice.isSmoothAutoFocusSupported) {
        NSError *error = nil;
        if ([self.videoDevice lockForConfiguration:&error]) {
            self.videoDevice.smoothAutoFocusEnabled = YES;
            [self.videoDevice unlockForConfiguration];
        }
    }
    NSString *url = [self videoPath];
    [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:url] recordingDelegate:self];
    [_capturedAudioArray addObject:url];
}

- (void)stopRecord {
    if ([self.movieFileOutput isRecording]) {
        [self.movieFileOutput stopRecording];
    }
}
- (void)mergeAndExportVideos:(NSArray*)videosPathArray withOutPath:(NSString*)outpath{
    if (videosPathArray.count == 0) {
        return;
    }
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
    videoTrack.preferredTransform = CGAffineTransformMake(0, 1, -1, 0, 0, 0);
    CMTime totalDuration = kCMTimeZero;
    for (int i = 0; i < videosPathArray.count; i++) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videosPathArray[i]]];
        NSError *erroraudio = nil;
        //获取AVAsset中的音频 或者视频
        AVAssetTrack *assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //向通道内加入音频或者视频
         [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetAudioTrack
                                       atTime:totalDuration
                                        error:&erroraudio];
        
        NSLog(@"erroraudio:%@",erroraudio);
        NSError *errorVideo = nil;
        AVAssetTrack *assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo]firstObject];
       [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)
                                      ofTrack:assetVideoTrack
                                       atTime:totalDuration
                                        error:&errorVideo];
        
        NSLog(@"errorVideo:%@",errorVideo);
        totalDuration = CMTimeAdd(totalDuration, asset.duration);
    }
    NSLog(@"%@",NSHomeDirectory());
    
    NSURL *mergeFileURL = [NSURL fileURLWithPath:outpath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = mergeFileURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"exporter%@",exporter.error);
        UISaveVideoAtPathToSavedPhotosAlbum([mergeFileURL path], nil, nil, nil);
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:nil message:@"合并完成" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alter show];
    }];
}
#pragma mark - Delegate

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections{
    NSLog(@"record start");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    NSLog(@"record finish");
    UISaveVideoAtPathToSavedPhotosAlbum([outputFileURL path], nil, nil, nil);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
