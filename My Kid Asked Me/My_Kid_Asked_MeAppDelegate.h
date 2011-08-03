//
//  My_Kid_Asked_MeAppDelegate.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 16/03/2011.
//  Copyright 2011 Propercomfy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QuestionsNavController;

@interface My_Kid_Asked_MeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {

    IBOutlet QuestionsNavController *qNavController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet QuestionsNavController *qNavController;

@end
