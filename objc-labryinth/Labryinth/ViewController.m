//
//  ViewController.m
//  Labryinth
//
//  Created by Justin Schneck on 9/27/15.
//  Copyright © 2015 PhoenixFramework. All rights reserved.
//

#import "ViewController.h"
#import <PhoenixClient/PhoenixClient.h>
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UITextField *urlField;
@property (nonatomic, retain) PhxSocket *socket;
@property (nonatomic, retain) PhxChannel *gameChannel;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (nonatomic, retain) CADisplayLink *motionDisplayLink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)connect:(id)sender {
    if (self.socket != nil) {
        [self.socket disconnect];
        self.socket = nil;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"ws://%@/socket/websocket", self.urlField.text]];
    self.socket = [[PhxSocket alloc] initWithURL:url heartbeatInterval:20];
    [self.socket connect];
}

- (IBAction)startGame:(id)sender {
    self.motionManager = [[CMMotionManager alloc] init];
    if (self.gameChannel != nil) {
        [self.gameChannel leave];
        self.gameChannel = nil;
    }
    self.gameChannel = [[PhxChannel alloc] initWithSocket:self.socket topic:@"game" params:@{}];
    [self.gameChannel join];
    //Gyroscope
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.05;  // 50 Hz
    
//    self.motionDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(motionRefresh:)];
//    [self.motionDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        // to avoid using more CPU than necessary we use `CMAttitudeReferenceFrameXArbitraryZVertical`
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            double x = self.motionManager.deviceMotion.attitude.roll;
            double y = self.motionManager.deviceMotion.attitude.pitch *1.5;
            
            CGFloat const inMin = -1.5;
            CGFloat const inMax = 1.5;
            
            CGFloat const outMin = 900000;
            CGFloat const outMax = 2100000;
            
            CGFloat xout = outMin + (outMax - outMin) * (x - inMin) / (inMax - inMin);
            CGFloat yout = outMin + (outMax - outMin) * (y - inMin) / (inMax - inMin);
            
            [self.gameChannel pushEvent:@"update" payload:@{
                                                            @"x":[NSNumber numberWithInt:yout],
                                                            @"y":[NSNumber numberWithInt:xout]
                                                            }];
        }];
    }
    
    
//    if([self.motionManager isGyroAvailable])
//    {
//        /* Start the gyroscope if it is not active already */
//        if([self.motionManager isGyroActive] == NO)
//        {
//            /* Update us 2 times a second */
//            [self.motionManager setGyroUpdateInterval:0.02f];
//            
//            /* Add on a handler block object */
//            
//            /* Receive the gyroscope data on this block */
//            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue]
//                                            withHandler:^(CMGyroData *gyroData, NSError *error)
//             {
//                 [self.gameChannel pushEvent:@"update" payload:@{
//                                                                 @"x":[NSNumber numberWithFloat:gyroData.rotationRate.x],
//                                                                 @"y":[NSNumber numberWithFloat:gyroData.rotationRate.y]
//                                                                 }];
//             }];
//        }
//    }
//    else
//    {
//        NSLog(@"Gyroscope not Available!");
//    }
}


- (IBAction)stopGame:(id)sender {
    [self.gameChannel leave];
    [self.motionManager stopDeviceMotionUpdates];
}

@end
