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
#import "AnswersViewController.h"

@implementation QuestionSearchViewController

@synthesize questionsTable;
@synthesize questions;
@synthesize question;
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
    
    //self.title = NSLocalizedString(@"Search", @"Search Kids' Questions");
    
    //search bar
    searchBar.autocorrectionType = UITextAutocorrectionTypeYes;
    searching = NO;
    letUserSelectRow = YES;
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
    [question release];
    [searchBar release];
    
    [super dealloc];
}

- (void)loadData:(NSString*)keyword
{
    // Grab some XML data 
    NSString* url = [NSString stringWithFormat:@"http://local.kidasked.me/questions/searchfor/%@/.xml",keyword];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Synchronous isn't ideal, but simplifies the code for the Demo
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Parse the XML Data into an NSDictionary
    questions = [[XMLReader dictionaryForXMLData:xmlData error:&error] retain];
    
    id questionArray = [questions retrieveForPath:@"questions.question"];
    // Return the number of rows in the section.
    if([questionArray respondsToSelector:@selector(allKeys)])
    {
        questionCount = 1;
    }else
    {
        questionCount = [questionArray count];
    }
    
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
    [self searchTableView];
}

- (void)searchTableView
{
    [self.searchBar resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    searching = NO;
    letUserSelectRow = YES;
    self.questionsTable.scrollEnabled = YES;
    [self loadData:self.searchBar.text];
    

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return questionCount;
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
    NSDictionary *q = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
    
    // maybe there's just one
    if(q == nil)
    {
        q = [questions retrieveForPath:@"questions.question"];
    }

    
    cell.textLabel.text = [q objectForKey:@"@question"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ answers", 
                                 [q objectForKey:@"@explanation_count"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get the 'status' for the relevant row
    NSDictionary *q = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
    // maybe there's just one
    if(q == nil)
    {
        q = [questions retrieveForPath:@"questions.question"];
    }
    NSString* cellText = [q objectForKey:@"@question"];
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
    NSDictionary* q = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];

    NSString* questionId;
    
    if(question == nil)
    {
        question = [q retrieveForPath:@"questions.question"];
    }

    questionId = [question objectForKey:@"@id"];
    
    // Grab some XML data 
    NSString* url = [NSString stringWithFormat:@"http://local.kidasked.me/questions/view/%@/.xml",questionId];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Synchronous isn't ideal, but simplifies the code for the Demo
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    question = [[XMLReader dictionaryForXMLData:xmlData error:&error] retain];
    question = [questions retrieveForPath:@"questions.question"];
    
    
    qDetailView.question = question;
    qDetailView.title = @"Answers";
    
    [self.navigationController pushViewController:qDetailView animated:YES];
    
    [qDetailView release];
    
    
}





@end
