//
//  QuestionSearchViewController.m
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 05/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionSearchViewController.h"
#import "XMLReader.h"
#import "QuestionDetailViewController.h"

@implementation QuestionSearchViewController

@synthesize questionsTable;
@synthesize questions;
@synthesize searchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Search", @"Search Kids' Questions");
    
    //search bar
    searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    searching = NO;
    letUserSelectRow = YES;
    CGRect bounds = self.questionsTable.bounds;
    bounds.origin.y = bounds.origin.y + 44;
    self.questionsTable.bounds = bounds;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [questionsTable release];
    [questions release];
    [searchBar release];
    
    [super dealloc];
}

- (void)loadData
{
    // Grab some XML data 
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://local.kidasked.me/questions.xml"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Synchronous isn't ideal, but simplifies the code for the Demo
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Parse the XML Data into an NSDictionary
    questions = [[XMLReader dictionaryForXMLData:xmlData error:&error] retain];
    
    [self.questionsTable reloadData];
}

# pragma mark - Search bar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searching = YES;
    letUserSelectRow = NO;
    self.questionsTable.scrollEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self
                                              action:@selector(doneSearching_Clicked:)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchTableView];
}

- (void)doneSearching_Clicked:(id)sender
{
    
}

- (void) searchTableView
{
    NSString *searchText = searchBar.text;
    // TODO
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    // empty our search dictionary
    questions = [[NSDictionary alloc] init];
    
    if([searchText length] > 0)
    {
        searching = YES;
        letUserSelectRow = YES;
        self.questionsTable.scrollEnabled = YES;
        [self searchTableView];
        
    }else
    {
        searching = NO;
        letUserSelectRow = NO;
        self.questionsTable.scrollEnabled = NO;        
    }
    
    [self.questionsTable reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[questions retrieveForPath:@"questions.question"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"QuestionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    // Get the 'status' for the relevant row
    NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
    
    cell.textLabel.text = [question objectForKey:@"@question"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ answers", 
                                 [question objectForKey:@"@explanation_count"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get the 'status' for the relevant row
    NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
    NSString* cellText = [question objectForKey:@"@question"];
    UIFont* cellFont = [UIFont systemFontOfSize:14];
    CGSize maxSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize cellSize = [cellText sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    return cellSize.height + 30;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(letUserSelectRow)
    {
        return indexPath;
    }else
    {
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    QuestionDetailViewController *qDetailView = [[QuestionDetailViewController alloc] initWithNibName:@"QuestionDetailView" bundle:nil];
    
    
    // Get the 'status' for the relevant row
    NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
    
    qDetailView.question = question;
    qDetailView.title = @"Answers";
    
    [self.navigationController pushViewController:qDetailView animated:YES];
    
    [qDetailView release];
}





@end
