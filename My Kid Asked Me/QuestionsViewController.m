//
//  QuestionsViewController.m
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 16/03/2011.
//  Copyright 2011 Propercomfy. All rights reserved.
//

#import "QuestionsViewController.h"
#import "XMLReader.h"
#import "QuestionDetailViewController.h"
#import "QuestionSearchViewController.h"
#import "ASIHTTPRequest.h"


@implementation QuestionsViewController

@synthesize questionsTable;
@synthesize questions;
//@synthesize progressView;

int const perPage = 20;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Questions", @"All Kids' Questions");
    howMany = perPage;
    // button bar
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 88, 44.01)];
    tools.translucent = true;
    tools.tintColor = self.navigationController.navigationBar.tintColor;
    NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
    
    // buttons
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd                                          
                                     target:self 
                                     action:@selector(addClick:)];
    addButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:addButton];
    [addButton release];
    
    // spacer
    UIBarButtonItem* spacer = [[UIBarButtonItem alloc] 
                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace                                         
                               target:nil
                               action:nil];
    [buttons addObject:spacer];
    [spacer release];
    
    // buttons
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] 
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh                                           
                                   target:self 
                                     action:@selector(reloadClick:)];
    reloadButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:reloadButton];
    [reloadButton release];
    
    [tools setItems:buttons animated:NO];
    [buttons release];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    [tools release];
    
    // search button
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] 
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemSearch                                          
                                     target:self 
                                     action:@selector(searchClick:)];
    searchButton.style = UIBarButtonItemStyleBordered;
     self.navigationItem.leftBarButtonItem = searchButton;
    [searchButton release];
    
    [self reloadData];
}

- (void) reloadClick:(id)sender
{
     [self reloadData];
}

- (void) addClick:(id)sender
{

}

- (void) searchClick:(id)sender
{
    QuestionSearchViewController *qSearchView = [[QuestionSearchViewController alloc] initWithNibName:@"QuestionSearchView" bundle:nil];
    qSearchView.title = @"Search";
    
    [self.navigationController pushViewController:qSearchView animated:YES];
    
    [qSearchView release];

}


- (void)reloadData
{
    // Grab some XML data
    NSString* url = [NSString stringWithFormat:@"http://local.kidasked.me/questions/index/page:1/limit:%d/sort:created/direction:asc/.xml",howMany];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    
    //[request setDownloadProgressDelegate:progressView];
    [request setDelegate:self];
    [request startAsynchronous];
    
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    // Use when fetching text data
    NSString *responseString = [request responseString];
    
    // Use when fetching binary data
   // NSData *responseData = [request responseData];
    
    // Parse the XML Data into an NSDictionary
    questions = [[XMLReader dictionaryForXMLString:responseString error:nil] retain];
    
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

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSError *error = [request error];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [questionsTable release];
    [questions release];
  //  [progressView release];
    
    [super dealloc];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return questionCount+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"QuestionCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }
    
    NSString* questionText = @"";
    NSString* questionDetailText = @"";
    
    if(indexPath.row == questionCount)
    {
        questionText = [NSString stringWithFormat:@"Load %d more...", perPage];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
    }else
    {
    
        // Get the 'status' for the relevant row
        NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
        
        if(question == nil)
        {
            question = [questions retrieveForPath:@"questions.question"];
        }
        
        questionText = [question objectForKey:@"@question"];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        questionDetailText = [NSString stringWithFormat:@"Score: %@  Answers: %@", 
                              [question objectForKey:@"@score"],
                              [question objectForKey:@"@explanation_count"]];
    
    }
     
    cell.textLabel.text = questionText;
    cell.detailTextLabel.text = questionDetailText;
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.row == questionCount)
    {
        return 50;
    }else
    {
        // Get the 'status' for the relevant row
        NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
        if(question == nil && indexPath.row < questionCount)
        {
            question = [questions retrieveForPath:@"questions.question"];
        }
        NSString* cellText = [question objectForKey:@"@question"];
        UIFont* cellFont = [UIFont boldSystemFontOfSize:15];
        CGSize maxSize = CGSizeMake(280.0f, MAXFLOAT);
        CGSize cellSize = [cellText sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
        
        return cellSize.height + 40;
    }
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    [self itemClicked:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{  
    [self itemClicked:indexPath];
}

- (void)itemClicked:(NSIndexPath *)indexPath
{
    if(indexPath.row == questionCount)
    {
        howMany = howMany + 2;
        [self reloadData];
        
    }else 
    {
        
        // Get the 'status' for the relevant row
        NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];
        
        
        if(question == nil)
        {
            question = [questions retrieveForPath:@"questions.question"];
        }
        
        // Navigation logic may go here. Create and push another view controller.
        
        QuestionDetailViewController *qDetailView = [[QuestionDetailViewController alloc] initWithNibName:@"QuestionDetailView" bundle:nil];
        
        if(question != nil)
        {
            qDetailView.question = question;
            qDetailView.title = @"Answers";
            
            [self.navigationController pushViewController:qDetailView animated:YES];
            
            [qDetailView release];
        }
    }
}


@end
