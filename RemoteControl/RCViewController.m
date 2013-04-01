//
//  RCViewController.m
//  RemoteControl
//
//  Created by Gia on 3/29/13.
//  Copyright (c) 2013 gravity. All rights reserved.
//

#import "RCViewController.h"
#import "AFNetworking.h"
#import "RCKeyboardInput.h"

#define kActionMove @"mov"
#define kActionStart @"str"
#define kActionClick @"clk"
#define kActionPress @"prs"
#define kActionRelease @"rls"

#define kBtnLeft 1
#define kBtnRight 2
#define kBtnCenter 3
#define kBtnNone 0



@interface RCViewController ()<NSStreamDelegate,RCKeyboardInputDelegate>{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}
@property (weak, nonatomic) IBOutlet UIView *mousePadView;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic) CGPoint translatePoint;
@property (nonatomic, strong) AFHTTPRequestOperation *mouseMoveOperation;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UIButton *btnCenter;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (nonatomic, strong) NSString *action;
@property (nonatomic) int btnNum;
@property (nonatomic, strong) RCKeyboardInput *input;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *ipAddress;

@end

@implementation RCViewController


- (id)initWithIpAddress:(NSString *)ipAddress{
    self = [super init];
    if (self) {
        _ipAddress = ipAddress;
    }
    return self;
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.ipAddress, 8999, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initNetworkCommunication];
	// Do any additional setup after loading the view, typically from a nib.
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(mousePanHandler:)];
    [self.mousePadView addGestureRecognizer:panGes];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    tapGes.numberOfTapsRequired = 2;
    [self.mousePadView addGestureRecognizer:tapGes];
    self.action = @"";self.btnNum = kBtnNone;
    self.date = [NSDate date];
    
    self.input = [[RCKeyboardInput alloc] init];
    self.input.delegate = self;
    [self.view addSubview:self.input];
}

- (void)doubleTapHandler:(UIGestureRecognizer *)ges{
    [self leftPressed:nil];
    [self leftRelease:nil];
}

- (void)mousePanHandler:(UIPanGestureRecognizer *)panGes{
        self.date = [NSDate date];
        switch (panGes.state) {
            case UIGestureRecognizerStateBegan:
                self.action = kActionStart;
                break;
            case UIGestureRecognizerStateChanged:
                self.translatePoint = [panGes translationInView:self.mousePadView];
                break;
            case UIGestureRecognizerStateEnded:
                break;
            default:
                break;
        }
        [self requestMouseAction];
}

- (void)input:(NSString *)key{
    NSString *response  = [NSString stringWithFormat:@"%@::%@end",@"key",key];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

- (void)requestMouseAction{
    NSString *response  = [NSString stringWithFormat:@"%@::%d::%f::%fend",self.action,self.btnNum,self.translatePoint.x,self.translatePoint.y];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
    if ([self.action isEqualToString:kActionStart]) {
        if (self.btnNum ==0) {
            self.action = kActionMove;
        }else{
            self.action = kActionPress;
        }
    }else if([self.action isEqualToString:kActionRelease]){
        self.action = kActionMove;
        self.btnNum = kBtnNone;
    }
}


- (IBAction)refreshPressed:(id)sender {
    [self initNetworkCommunication];
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)keyboardPressed:(id)sender {
    [self.input becomeFirstResponder];
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-216-44, 320, 44)];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelPressed:)];
    [toolbar setItems:@[cancelBtn]];
    [self.view addSubview:toolbar];
}

- (void)cancelPressed:(id)sender{
    [self.input resignFirstResponder];
    for (UIToolbar *toolbar in self.view.subviews) {
        if ([toolbar isKindOfClass:[UIToolbar class]]) {
            [toolbar removeFromSuperview];
        }
    }
}

- (IBAction)leftPressed:(id)sender {
    self.action = kActionPress;
    self.btnNum = kBtnLeft;
    [self requestMouseAction];
    
}
- (IBAction)leftRelease:(id)sender {
    self.action = kActionRelease;
    self.btnNum = kBtnLeft;
    [self requestMouseAction];
}
- (IBAction)centerRelease:(id)sender {
    self.action = kActionRelease;
    self.btnNum = kBtnCenter;
    [self requestMouseAction];
}
- (IBAction)centerPressed:(id)sender {
    self.action = kActionPress;
    self.btnNum = kBtnCenter;
    [self requestMouseAction];
}


- (IBAction)rightPressed:(id)sender {
    self.action = kActionPress;
    self.btnNum = kBtnRight;
    [self requestMouseAction];
}

- (IBAction)rightRelease:(id)sender {
    self.action = kActionRelease;
    self.btnNum = kBtnRight;
    [self requestMouseAction];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
