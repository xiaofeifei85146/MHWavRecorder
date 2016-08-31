//
//  WavRecorder.h
//  WavRecord
//
//  Created by Teplot_03 on 16/5/10.
//  Copyright © 2016年 Teplot_03. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AVAudioRecorder;

@protocol WavRecorderDeleagte <NSObject>

- (void)failRecord;

- (void)finishRecordWithWavFileName:(NSString *)fileName;

@end

@interface WavRecorder : NSObject

@property (nonatomic, weak) id<WavRecorderDeleagte> delegate;


+ (id)recorderWithDelegate:(id<WavRecorderDeleagte>)delegate;

- (void)startRecord;

- (void)stopRecord;

- (void)cancleRecord;


@end
