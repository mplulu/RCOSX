//
//  RCServerInputViewController.m
//  RemoteControl
//
//  Created by Gia on 3/29/13.
//  Copyright (c) 2013 gravity. All rights reserved.
//

#import "RCServerInputViewController.h"
#import "RCViewController.h"

@interface RCServerInputViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *textField;

@end

@implementation RCServerInputViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    self.textField.delegate =self;
    [self.view addSubview:self.textField];
    self.textField.backgroundColor = [UIColor whiteColor];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    RCViewController *vc= [[RCViewController alloc] initWithIpAddress:textField.text];
    [self.navigationController pushViewController: vc animated:YES];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
