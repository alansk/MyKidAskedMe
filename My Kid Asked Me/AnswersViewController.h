//
//  AnswersViewController.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 16/03/2011.
//  Copyright 2011 Propercomfy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnswersViewController : UIViewController  <UITableViewDataSource> {
    IBOutlet UITableView* answers;
    
    NSDictionary* question;
}

@property (nonatomic, retain) NSDictionary* question;
@property (nonatomic, retain) UITableView* answers;
@end
