//
//  ABSpeechAnalyst.m
//  ABSpeechAnalyst
//
//  Created by Abilash Cumulations on 20/11/17.
//  Copyright © 2017 Abilash. All rights reserved.
//

#import "ABSpeechAnalyst.h"

typedef void(^SpeechRecognizerCompletion)(NSString *responseText, NSError *error);
@interface ABSpeechAnalyst()<SFSpeechRecognizerDelegate>
{
    SFSpeechAudioBufferRecognitionRequest *regRequest;
    SFSpeechRecognitionTask *regTask;
    AVAudioEngine *avEngine;
    SpeechRecognizerCompletion completionHandler;
}
@property (nonatomic,strong) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic,strong) AVAudioSession *avAudioSession;
@property (nonatomic,strong) UIButton *speechButton;
@property (nonatomic,assign) BOOL isAuthorized;

@end

@implementation ABSpeechAnalyst

- (AVAudioSession *)avAudioSession
{
    if (!_avAudioSession) {
        _avAudioSession = [AVAudioSession sharedInstance];
    }
    return _avAudioSession;
}

- (ABSpeechAnalyst *)initWithSpeechButton:(UIButton *)speechButton
{
    self = [super init];
    if (self) {
        self.speechButton = speechButton;
        self.speechRecognizer = [[SFSpeechRecognizer alloc]initWithLocale:[NSLocale localeWithLocaleIdentifier:@"en-US"]];
        [self getSpeechAuthorizationPermission];
        self.speechRecognizer.delegate = self;
        avEngine = [AVAudioEngine new];
    }
    return self;
}
- (void)getSpeechAuthorizationPermission
{
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        if(status == SFSpeechRecognizerAuthorizationStatusAuthorized)
        {
            self.isAuthorized = true;

        }else
        {
            self.isAuthorized = false;
        }
    }];
}

- (void)startRecording:(void(^)(NSString *responseText, NSError *error))completion
{
    self.isRecording = true;
    [self.avAudioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    [self.avAudioSession setMode:AVAudioSessionModeMeasurement error:nil];
    [self.avAudioSession setActive:true withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if ([self isNewInput]) {
        regTask = [self.speechRecognizer recognitionTaskWithRequest:regRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
            BOOL isComplete = false;
            if (error == nil) {
                if (result != nil) {
                    isComplete = result.isFinal;
                    NSString *resposeTest = result.bestTranscription.formattedString;
                    if ( isComplete) {
                        [self validateSpeech:resposeTest];
                    }
                }
            }else
            {
                if (completionHandler != nil) {
                    completionHandler(nil,error);
                }
            }
            if (isComplete || error != nil) {
                [avEngine stop];
                [avEngine.inputNode removeTapOnBus:0];
                regRequest = nil;
                regTask = nil;
                
            }
        }];
        
        AVAudioFormat *recordingFormat = [avEngine.inputNode outputFormatForBus:0];
        [avEngine.inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
            if (buffer) {
                [regRequest appendAudioPCMBuffer:buffer];
            }
        }];
        [avEngine prepare];
        NSError *error =  nil;
        if (![avEngine startAndReturnError:&error]) {
            NSLog(@"Error happens during avaudio engine starts == %@",error);
        }
        
    }
    
}

- (void)Stop
{
    self.isRecording = false;
    if([avEngine isRunning]) {
        [avEngine stop];
        [regRequest endAudio];
    }
}
                      
- (BOOL)isNewInput
{
    if(regTask != nil) {
        [regTask cancel];
        regTask = nil;
    }
//    if (avEngine.inputNode) {
//        return false;
//    }
    regRequest = [[SFSpeechAudioBufferRecognitionRequest alloc]init];
    regRequest.shouldReportPartialResults = true;
    return true;
}

- (void)validateSpeech:(NSString *)responseText
{
    [ABSpeechAnalyst showAlertTitle:@"" withMessage:@"Please edit or confirm the speech response text" withFieldext:responseText withCompletionBlock:^(NSString *finalText) {
        if (completionHandler != nil) {
            completionHandler(finalText,nil);
        }
    }];
 
}

#pragma mark -  Speech recognizer delegate
- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available
{
    
}


+ (void)showAlertTitle:(NSString *)title withMessage:(NSString *)message withFieldext:(NSString *)text withCompletionBlock:(void(^)(NSString*))completion
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertVC addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Enter text";
            textField.text = text;
            textField.textColor = [UIColor blackColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textfield = [[alertVC textFields] firstObject];
            completion([textfield text]);
        }]];
        
        [[[UIApplication sharedApplication]keyWindow].rootViewController presentViewController:alertVC animated:true completion:nil];
    });
    
}
@end
