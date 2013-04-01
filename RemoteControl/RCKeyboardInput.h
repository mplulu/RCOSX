//
//  RCKeyboardInput.h
//  RemoteControl
//
//  Created by Gia on 3/29/13.
//  Copyright (c) 2013 gravity. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RCKeyboardInputDelegate <NSObject>

- (void)input:(NSString *)key;

@end

@interface RCKeyboardInput : UIView<UIKeyInput>

@property (nonatomic, strong) id<RCKeyboardInputDelegate> delegate;



@end
