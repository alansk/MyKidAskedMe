//
//  QuestionsViewController.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 16/03/2011.
//  Copyright 2011 Propercomfy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* questionsTable;
    
    NSArray* questions;
}

@property (nonatomic, retain) UITableView* questionsTable;

@end
