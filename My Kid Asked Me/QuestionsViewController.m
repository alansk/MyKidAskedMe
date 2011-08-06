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


@implementation QuestionsViewController

@synthesize questionsTable;
@synthesize questions;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Questions", @"All Kids' Questions");
  
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
    
    [self.navigationController pushViewController:qSearchView animated:YES];
    
    [qSearchView release];

}


- (void)reloadData
{
    // Grab some XML data 
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://local.kidasked.me/questions/index/page:1/sort:created/direction:asc/.xml"]];
    
    NSError *error = nil;
    NSURLResponse *response = nil;
    
    // Synchronous isn't ideal, but simplifies the code for the Demo
    NSData *xmlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Parse the XML Data into an NSDictionary
    questions = [[XMLReader dictionaryForXMLData:xmlData error:&error] retain];
    
    [self.questionsTable reloadData];
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
    // Return the number of rows in the section.
    return [[questions retrieveForPath:@"questions.question"] count] + 1;
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
    if(question == nil)
    {
        cell.textLabel.text = @"Load more...";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else
    {
        cell.textLabel.text = [question objectForKey:@"@question"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ answers", 
                                 [question objectForKey:@"@explanation_count"]];
    }
    
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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    QuestionDetailViewController *qDetailView = [[QuestionDetailViewController alloc] initWithNibName:@"QuestionDetailView" bundle:nil];
       
    
    // Get the 'status' for the relevant row
    NSDictionary *question = [questions retrieveForPath:[NSString stringWithFormat:@"questions.question.%d", indexPath.row]];

    if(question != nil)
    {
        qDetailView.question = question;
        qDetailView.title = @"Answers";
    
        [self.navigationController pushViewController:qDetailView animated:YES];
    
        [qDetailView release];
    }
}


@end
