//
//  ViewController.m
//  ABSpeechAnalyst
//
//  Created by Abilash Cumulations on 20/11/17.
//  Copyright © 2017 Abilash. All rights reserved.
//

#import "ViewController.h"
#import "ABSpeechAnalyst.h"

@interface ViewController ()
{
    ABSpeechAnalyst *speechAnalyst;
}
@property (weak, nonatomic) IBOutlet UIButton *startStopBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    speechAnalyst = [[ABSpeechAnalyst alloc]initWithSpeechButton:self.startStopBtn];
}




- (IBAction)didClickOnABSpeechAnalyst:(id)sender {
    if (speechAnalyst.isRecording) {
        [speechAnalyst Stop];
        [_startStopBtn setTitle:@"Start" forState:UIControlStateNormal];
    }else
    {
    dispatch_async(dispatch_get_main_queue(), ^{
        [_startStopBtn setTitle:@"Stop" forState:UIControlStateNormal];
        [speechAnalyst startRecording:^(NSString *responseText, NSError *error) {
            
        }];
    });
    }
    

}

@end
