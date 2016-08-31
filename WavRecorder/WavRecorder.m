//
//  WavRecorder.m
//  WavRecord
//
//  Created by Teplot_03 on 16/5/10.
//  Copyright © 2016年 Teplot_03. All rights reserved.
//

#import "WavRecorder.h"
#import "AmrFileCodec.h"
#import "EMAudioRecorderUtil.h"

@interface WavRecorder ()
{
    NSDate              *_recorderStartDate;
    NSDate              *_recorderEndDate;
}
@property (nonatomic, assign) double cTime;
@property (nonatomic, copy) NSString *wavName;


/**
 *  @brief wyc录音缓存路径
 */
@property (nonatomic ,strong) NSString *recordCachPathWav;
@property (nonatomic ,strong) NSString *recordCachPathAmr;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@end

@implementation WavRecorder


+ (id)recorderWithDelegate:(id<WavRecorderDeleagte>)delegate {
    
    WavRecorder *wavRecorder = [[self alloc] init];
    
    wavRecorder.delegate = delegate;
    
    return wavRecorder;
    
}

#pragma mark - new（王耀昌） 测试OK(这个是支持断点录音的)
#pragma mark - public method
#pragma mark -- 开始录音
- (void)startRecord{
    
    if (![self canRecord]) {
        [self stopRecord];
        return;
    }
    
    _wavName = [self timeString];
    //生成路径   这个时间可以根据时间字符串直接拼接为带有后缀的文件名
    self.recordCachPathWav=[self getWavFilePathWithWavName:_wavName];
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:self.recordCachPathWav]
                                               settings:self.getAudioRecorderSettingDict
                                                  error:nil];
    
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    if ([self.recorder prepareToRecord]) {
        _recorderStartDate = [NSDate date];
        [self.recorder record];
    }else{
        
        [self stopRecord];
    }
}

#pragma mark -- 停止录音
- (void)stopRecord
{
    //停止录音
    if (self.recorder.isRecording) {
        [self.recorder stop];
        _recorderEndDate = [NSDate date];
        _cTime = [_recorderEndDate timeIntervalSinceDate:_recorderStartDate];
        //如果时间少于1s，那么，失败
        if (_cTime > 1) {
            
            //将路径通过代理传出去
            if ([self.delegate respondsToSelector:@selector(finishRecordWithWavFileName:)]) {
                [self.delegate finishRecordWithWavFileName:[NSString stringWithFormat:@"%@.wav",_wavName]];
            }
            
        }else {
            //删除文件，发送失败
            [self.recorder deleteRecording];
            
            if ([_delegate respondsToSelector:@selector(failRecord)]) {
                [_delegate failRecord];
            }
        }
    }
}

- (void)cancleRecord {
    //上滑取消录音
    if (self.recorder.isRecording) {
        [self.recorder stop];
        [self.recorder deleteRecording];
    }
}

#pragma mark -- 暂停录音,暂时不用
- (void)pauseRecord
{
    if (self.recorder.isRecording) {
        [self.recorder pause];
    }
}

//  暂时不用
- (void)resumeRecord
{
    if (!self.recorder.isRecording) {
        [self.recorder record];
    }
}
#pragma mark - private method

#pragma mark-- 判断录音权限
- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                bCanRecord = YES;
            } else {
                bCanRecord = NO;
            }
        }];
    }
    
    return bCanRecord;
}
/**
	获取录音设置
	@returns 录音设置
 */
- (NSDictionary*)getAudioRecorderSettingDict
{
    static NSDictionary *recordSetting = nil;
    if (recordSetting==nil) {
        recordSetting = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                          AVSampleRateKey: @8000.00f,
                          AVNumberOfChannelsKey: @1,
                          AVLinearPCMBitDepthKey: @16,
                          AVLinearPCMIsNonInterleaved: @NO,
                          AVLinearPCMIsFloatKey: @NO,
                          AVLinearPCMIsBigEndianKey: @NO};
    }
    return recordSetting;
}


#pragma mark - 沙盒管理

- (NSString *)getWavFilePathWithWavName:(NSString *)wavName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *docDir = [self getDocumentPath];
    
    NSString *wavDir = [docDir stringByAppendingPathComponent:@"voice"];
    
    if (![fileManager fileExistsAtPath:wavDir]) {
        [fileManager createDirectoryAtPath:wavDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *wavPath = [wavDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",wavName]];
    
    return wavPath;
}

//得到沙盒doc文件夹
- (NSString *)getDocumentPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    
    return docDir;
}

#pragma mark - timeString

- (NSString *)timeString {
    NSDate *now = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    
    NSString *timeString = [formatter stringFromDate:now];
    
    return timeString;
    
}

#pragma mark - old 真机失败
//- (void)startRecord {
//    
//    
//    _wavName = [self timeString];
//    
//    [EMAudioRecorderUtil asyncStartRecordingWithPreparePath:[self getWavFilePathWithWavName:_wavName] completion:^(NSError *error) {
//        _recorderStartDate = [NSDate date];
//    }];
//    
//}
//
//- (void)stopRecord {
//    
//    
//    
//    [EMAudioRecorderUtil asyncStopRecordingWithCompletion:^(NSString *recordPath) {
//        
//        _recorderEndDate = [NSDate date];
//        _cTime = [_recorderEndDate timeIntervalSinceDate:_recorderStartDate];
//        
//        if (_cTime > 1) {
//            
//            //将路径通过代理传出去
//            if ([self.delegate respondsToSelector:@selector(finishRecordWithWavFileName:)]) {
//                [self.delegate finishRecordWithWavFileName:[NSString stringWithFormat:@"%@.wav",_wavName]];
//            }
//            
//        }else {
//            //删除文件，发送失败
//            [_currentRecoder deleteRecording];
//            
//            if ([_delegate respondsToSelector:@selector(failRecord)]) {
//                [_delegate failRecord];
//            }
//        }
//    }];
//    
//    
//}
//
//- (void)cancelRecord {
//    [EMAudioRecorderUtil cancelCurrentRecording];
//    [_currentRecoder deleteRecording];
//}




@end
