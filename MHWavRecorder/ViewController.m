//
//  ViewController.m
//  MHWavRecorder
//
//  Created by Teplot_03 on 16/8/31.
//  Copyright © 2016年 Teplot_03. All rights reserved.
//

#import "ViewController.h"
#import "WavRecorder.h"

@interface ViewController ()<WavRecorderDeleagte>

@property (nonatomic, strong) WavRecorder *recoder;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _recoder = [WavRecorder recorderWithDelegate:self];
    
}

- (IBAction)touchDown:(id)sender {
    [sender setBackgroundColor:[UIColor lightGrayColor]];

    [_recoder startRecord];
}

- (IBAction)touchUp:(id)sender {

    
    [_recoder stopRecord];
}

- (void)failRecord {
    NSLog(@"录音失败");
}

- (void)finishRecordWithWavFileName:(NSString *)fileName {
    //文件存放地址：document/wav
    NSLog(@"文件名：%@",fileName);
}


@end
