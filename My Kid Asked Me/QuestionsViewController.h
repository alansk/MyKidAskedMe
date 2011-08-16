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
            //IBOutlet UIProgressView* progressView;
    
            NSDictionary* questions;
            int questionCount;
            int howMany;

}

@property (nonatomic, retain) UITableView* questionsTable;
@property (nonatomic, retain) NSDictionary* questions;
//@property (nonatomic, retain) UIProgressView* progressView;

extern int const perPage;

- (void)reloadData;
- (void)itemClicked:(NSIndexPath *)indexPath;


@end
