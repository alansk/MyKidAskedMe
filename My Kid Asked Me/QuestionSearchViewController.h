//
//  QuestionSearchViewController.h
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 05/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionSearchViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    IBOutlet UITableView* questionsTable;
    IBOutlet UISearchBar* searchBar;
    
    NSDictionary* questions;
    
    BOOL searching;
    BOOL letUserSelectRow;
    
}

@property (nonatomic, retain) UITableView* questionsTable;
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) NSDictionary* questions;

- (void)loadData;

- (void)searchTableView;

- (void)doneSearching_Clicked:(id)sender;


@end
