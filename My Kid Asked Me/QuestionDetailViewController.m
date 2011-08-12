//
//  QuestionDetailViewController.m
//  My Kid Asked Me
//
//  Created by Alan Skerrett on 01/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "XMLReader.h"

@implementation QuestionDetailViewController

@synthesize question;
@synthesize answers;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                     target:self 
                                     action:@selector(addClick:)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

- (void) addClick:(id)sender
{
    
}

- (void)dealloc
{
    [question release];
    [answers release];
    
    [super dealloc];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSDictionary* explanations = [question retrieveForPath:@"explanation"];
    if([explanations respondsToSelector:@selector(allKeys)])
    {
        return 1;
    }else
    {
        return [explanations count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [question objectForKey:@"@question"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"AnswerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Get the 'status' for the relevant row
    NSDictionary *answer = [question retrieveForPath:[NSString stringWithFormat:@"explanation.%d", indexPath.row]];
    
    // maybe there's just one
    if(answer == nil)
    {
        answer = [question retrieveForPath:@"explanation"];
    }
    
    NSDictionary* user = [answer retrieveForPath:@"user"];
    
    cell.textLabel.text = [answer objectForKey:@"@answer"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Score: %@   by %@", 
                                 [answer objectForKey:@"@score"],
                                 [user objectForKey:@"@username"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // Get the 'status' for the relevant row
    NSDictionary *answer = [question retrieveForPath:[NSString stringWithFormat:@"explanation.%d", indexPath.row]];
    
    // maybe there's just one
    if(answer == nil)
    {
        answer = [question retrieveForPath:@"explanation"];
    }
    
    NSString* cellText = [answer objectForKey:@"@answer"];
    UIFont* cellFont = [UIFont systemFontOfSize:14];
    CGSize maxSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize cellSize = [cellText sizeWithFont:cellFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
    
    
    return cellSize.height + 30;
}

@end
