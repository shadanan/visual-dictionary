//
//  main.m
//  GraphVisualizer
//
//  Created by Shad Sharma on 2/9/14.
//  Copyright (c) 2014 Shad Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SJSAppDelegate.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        @try {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([SJSAppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
        }
    }
}
