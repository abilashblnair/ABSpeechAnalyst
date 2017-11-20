//
//  ABSpeechAnalyst.h
//  ABSpeechAnalyst
//
//  Created by Abilash Cumulations on 20/11/17.
//  Copyright © 2017 Abilash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Speech/Speech.h>
#import <UIKit/UIKit.h>

@interface ABSpeechAnalyst : NSObject
- (ABSpeechAnalyst *)initWithSpeechButton:(UIButton *)speechButton;
- (void)startRecording:(void(^)(NSString *responseText, NSError *error))completion;
- (void)startRecordingForInterval:(NSTimeInterval)interval completion:(void(^)(NSString *responseText, NSError *error))completion;
- (void)Stop;

@property (nonatomic,assign) BOOL isRecording;
@property (nonatomic,readonly) UIButton *speechButton;
@property (nonatomic,readonly) SFSpeechRecognizer *speechRecognizer;

@end
