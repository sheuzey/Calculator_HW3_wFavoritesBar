//
//  CalculatorGraphViewController.m
//  Calculator
//
//  Created by Stephen Heuzey on 10/4/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//
// **************************************************************************
//         THIS FILE CONTAINS CODE FOR ROTATING CAPABILITES FOR THE IPAD
// **************************************************************************


#import "GraphViewController.h"
#import "CalculatorProgramsTableViewController.h"

@interface GraphViewController () <GraphViewDelegate, CalculatorProgramsTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toolBarTitleItem;
@property (weak, nonatomic) IBOutlet GraphView *graphView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@end

@implementation GraphViewController

@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

#define FAVORITES_KEY @"GraphViewController.Favorites"

- (IBAction)addToFavorites:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [[defaults objectForKey:FAVORITES_KEY] mutableCopy];
    if(!favorites) favorites = [NSMutableArray array];
    [favorites addObject:self.function];
    [defaults setObject:favorites forKey:FAVORITES_KEY];
    [defaults synchronize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Favorites Graphs"]) {
        NSArray *programs = [[NSUserDefaults standardUserDefaults] objectForKey:FAVORITES_KEY];
        [segue.destinationViewController setPrograms:programs];
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)CalculatorProgramsTableViewController:(CalculatorProgramsTableViewController *)sender
                                 choseProgram:(id)program
{
    self.function = program; 
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem) {
        NSMutableArray *toolbarItems = [self.toolBar.items mutableCopy];
        if(_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
        self.toolBar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (void)viewDidLoad
{
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)];
    [self.graphView addGestureRecognizer:pinchRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[ UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)];
    [self.graphView addGestureRecognizer:panRecognizer];
    
    self.title = [CalculatorBrain descriptionOfProgram:self.function];
    self.graphView.delegate = self;
    self.splitViewController.delegate = self;
}


- (void)setFunction:(id)function
{
    _function = function;
    self.toolBarTitleItem.title = [CalculatorBrain descriptionOfProgram:self.function];
    [self.graphView reset];
    [self.graphView setNeedsDisplay];
}

- (double)functionForXValue:(CGFloat)x
                       from:(GraphView *)sender
{
    NSDictionary *variableValues = [NSDictionary dictionaryWithObject:[NSNumber numberWithDouble:x] forKey:@"x"];
    return [CalculatorBrain runProgram:self.function usingVariableValues:variableValues];
}

- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if(![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]){
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void) splitViewController:(UISplitViewController *)svc
      willHideViewController:(UIViewController *)aViewController
           withBarButtonItem:(UIBarButtonItem *)barButtonItem
        forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"Calculator";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

@end
