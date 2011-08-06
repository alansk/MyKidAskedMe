//
//  QuestionsViewController.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 16/03/2011.
//  Copyright 2011 Propercomfy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuestionsViewController : UIViewController 
        <UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView* questionsTable;
    
    NSDictionary* questions;
    NSDictionary* searchQuestions;

}

@property (nonatomic, retain) UITableView* questionsTable;
@property (nonatomic, retain) NSDictionary* questions;

- (void)reloadData;


@end
