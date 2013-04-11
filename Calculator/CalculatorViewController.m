//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Stephen Heuzey on 8/28/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userUsedAPeriod;
@property (nonatomic, strong) CalculatorBrain *brain;
@property (nonatomic) NSDictionary *testVariableValues;
@end

@implementation CalculatorViewController
@synthesize display;
@synthesize sentToBrain;
@synthesize userIsInTheMiddleOfEnteringANumber;
@synthesize userUsedAPeriod;
@synthesize brain = _brain;

- (CalculatorBrain *) brain
{
    if(!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

//Number is pressed
- (IBAction)digitPressed:(UIButton *)sender
{
    if (self.userIsInTheMiddleOfEnteringANumber){
        self.display.text = [self.display.text stringByAppendingString:sender.currentTitle];
    } else {
        self.display.text = sender.currentTitle;
        self.userIsInTheMiddleOfEnteringANumber = YES;
        }
}

- (IBAction)variablePressed:(UIButton *)sender {
    if(!self.userIsInTheMiddleOfEnteringANumber){        
        [self.brain pushVariableOrOperatorToStack:sender.currentTitle];
        self.display.text = sender.currentTitle;
        self.sentToBrain.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    }
}


//"Enter" is pressed
- (IBAction)enterPressed {
    
    [self.brain pushOperand:[self.display.text doubleValue]];
    
    //Output to Top Label
    self.sentToBrain.text = [CalculatorBrain descriptionOfProgram:[self.brain.program mutableCopy]];
    
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userUsedAPeriod = NO;
    self.display.text = @"0";
}

//An operation button is pressed
- (IBAction)operationPressed:(UIButton *)sender {
    if (self.userIsInTheMiddleOfEnteringANumber){
        [self enterPressed];
    }
    [self.brain pushVariableOrOperatorToStack:sender.currentTitle];
    id stack = self.brain.program;
    id result = [NSNumber numberWithDouble:[CalculatorBrain runProgram:stack usingVariableValues:self.testVariableValues]];
    self.display.text = [NSString stringWithFormat:@"%@", result];
    self.sentToBrain.text = [CalculatorBrain descriptionOfProgram:stack];
}


//The period button is pressed
- (IBAction)periodPressed {
    if(!self.userUsedAPeriod){
        self.display.text = [self.display.text stringByAppendingString:@"."];
        self.userIsInTheMiddleOfEnteringANumber = YES;
        self.userUsedAPeriod = YES; 
    }
}

//Clear button is pressed
- (IBAction)clearButton {
    self.display.text = @"0";
    self.sentToBrain.text = @"";
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userUsedAPeriod = NO;
    [self.brain clearOperands];
}

- (NSString *)outputVariables:(NSSet *)variableSet
{
    NSString *variableTextFormat;
    NSString *finalText = @"";
    NSArray *variableArray = [variableSet allObjects];
    for (int x = 0; x < [variableArray count]; x++) {
        variableTextFormat = [NSString stringWithFormat:@"%@ = %@   ", [variableArray objectAtIndex:x], [self.testVariableValues valueForKey:[variableArray objectAtIndex:x]]];
        finalText = [finalText stringByAppendingString:variableTextFormat];
    }
    return finalText;
}

- (GraphViewController *)splitViewGraphViewController
{
    id gvc = [self.splitViewController.viewControllers lastObject];
    if(![gvc isKindOfClass:[GraphViewController class]]) gvc = nil;
    return gvc;
}

- (IBAction)graphButtonPressed {
    if([self splitViewGraphViewController]) {
        [self splitViewGraphViewController].function = self.brain.program;
    }
    else{
        [self performSegueWithIdentifier:@"graph" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"graph"]){
        id stack = self.brain.program;
        [segue.destinationViewController setFunction:stack];
    }
}


@end
