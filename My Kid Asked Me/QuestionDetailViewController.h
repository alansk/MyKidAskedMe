//
//  QuestionDetailViewController.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionDetailViewController : UIViewController {
    IBOutlet UILabel* testLabel;
    
    NSDictionary* question;
}

@property (nonatomic, retain) NSDictionary* question;

@end
