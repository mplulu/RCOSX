//
//  RCKeyboardInput.m
//  RemoteControl
//
//  Created by Gia on 3/29/13.
//  Copyright (c) 2013 gravity. All rights reserved.
//

#import "RCKeyboardInput.h"

@implementation RCKeyboardInput
- (void)insertText:(NSString *)text{
    if ([self.delegate respondsToSelector:@selector(input:)]) {
        [self.delegate input:text];
    }
}

- (BOOL)hasText{
    return NO;
}

- (void)deleteBackward{
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
@end
