//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Stephen Heuzey on 8/29/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
+ (BOOL)isOperation:(NSString *)operation;
+ (BOOL)isDoubleOperation:(NSString *)operation;
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)program;
@end

@implementation CalculatorBrain

- (NSMutableArray *) programStack
{
    if (!_programStack){
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}


- (void) pushOperand:(double)operand
{
    NSNumber *operandObject = [NSNumber numberWithDouble:operand]; 
    [self.programStack addObject:operandObject];
}

- (void)pushVariableOrOperatorToStack:(NSString *)variable
{
    [self.programStack addObject:variable]; 
}

- (double) performOperation:(NSString *)operation
{
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
    //return [CalculatorBrain runProgram:self.program];
}

- (void) clearOperands
{
    [self.programStack removeAllObjects];
}

- (id) program
{
    return [self.programStack copy];
}

+ (BOOL)isOperation:(NSString *)operation
{
    BOOL isOperation = NO;
    NSArray *operationArray = [NSArray arrayWithObjects:@"-",@"+",@"*",@"/",@"sin",@"cos",@"√",@"π", nil];
    if([operationArray indexOfObject:operation] != NSNotFound) isOperation = YES;
    return isOperation;
}

+ (BOOL)isDoubleOperation:(NSString *)operation
{
    BOOL isDoubleOperation = NO;
    NSArray *operationArray = [NSArray arrayWithObjects:@"-",@"+",@"/",@"*", nil];
    if([operationArray indexOfObject:operation] != NSNotFound) isDoubleOperation = YES;
    return isDoubleOperation; 
}

//  descriptionOfProgram helper method
+ (NSString *)descriptionOfTopOfStack:(NSMutableArray *)program
{
    NSString *descriptionOfTopOfStack = @"";
    id topOfStack = [program lastObject];
    if (topOfStack) [program removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) descriptionOfTopOfStack = [NSString stringWithFormat:@"%@", topOfStack];
    
    else if([topOfStack isKindOfClass:[NSString class]]){
        if([self isOperation:topOfStack]){
            if([self isDoubleOperation:topOfStack]){
                id rightOperand = [self descriptionOfTopOfStack:program];
                id leftOperand = [self descriptionOfTopOfStack:program];
                descriptionOfTopOfStack = [NSString stringWithFormat:@"(%@ %@ %@)", leftOperand, topOfStack, rightOperand];
            } else {
                if([topOfStack isEqualToString:@"π"]){
                    descriptionOfTopOfStack = [NSString stringWithFormat:@"%@", topOfStack];
                } else {
                    if([self isDoubleOperation:[program lastObject]]){
                        descriptionOfTopOfStack = [NSString stringWithFormat:@"%@%@", topOfStack, [self descriptionOfTopOfStack:program]];
                    } else{
                        id lastOperand = [self descriptionOfTopOfStack:program];
                        descriptionOfTopOfStack = [NSString stringWithFormat:@"%@ (%@)", topOfStack, lastOperand];
                    }
                }
            }
        } else {
            descriptionOfTopOfStack = [NSString stringWithFormat:@"%@", topOfStack];
        }
    }
    return descriptionOfTopOfStack; 
}

+ (NSString *)descriptionOfProgram:(id)program
{
    NSString *result = @"";
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) stack = [program mutableCopy];
    
    result = [self descriptionOfTopOfStack:stack];
    
    if([result hasPrefix:@"("] && [result hasSuffix:@")"]){
        NSString *okResult = [result substringToIndex:[result length]-1];
        NSString *anEvenBetterResult = [okResult substringFromIndex:1];
        result = [NSString stringWithFormat:@"%@", anEvenBetterResult];
    }
    
    while ([stack count] > 0) {
        result = [result stringByAppendingString:[NSString stringWithFormat:@", %@",[self descriptionOfTopOfStack:stack]]];
    }
    return result;
}

+ (double) popOperandOffStack:(NSMutableArray *)stack
{
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if([topOfStack isKindOfClass:[NSNumber class]]){
        result = [topOfStack doubleValue];
    }
    else if([topOfStack isKindOfClass:[NSString class]]){
        NSString *operation = topOfStack;
        
        //Code from old instance method "popOperand", but now uses
        //recursion...yay...
        
        if ([operation isEqualToString:@"+"]){
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([@"*" isEqualToString:operation]){
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"-"]){
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]){
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]){
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]){
            result = cos([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"√"]){
            result = sqrt([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"π"]){
            result = M_PI;
        }
    }
    return result; 
}

+ (double)runProgram:(id)program
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}
    
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if ([program isKindOfClass:[NSArray class]]){
        stack = [program mutableCopy];
    }
    //  Replaces variables in program with associated values
    for (int x = 0; x < [stack count]; x++) {
        if(![self isOperation:[stack objectAtIndex:x]] && [[stack objectAtIndex:x] isKindOfClass:[NSString class]]){
            if([variableValues objectForKey:[stack objectAtIndex:x]]){
                [stack replaceObjectAtIndex:x withObject:[variableValues objectForKey:[stack objectAtIndex:x]]];
            }
            else {
                NSNumber *defaultNum = [NSNumber numberWithDouble:0];
                [stack replaceObjectAtIndex:x withObject:defaultNum];
            }
        }
    }
    return [self popOperandOffStack:stack];
}

+ (NSSet *)variablesUsedInProgram:(id)program
{
    NSMutableSet *variablesUsed = [[NSMutableSet alloc]init];
    NSMutableArray *stack = [[NSMutableArray alloc]init];
    if([program isKindOfClass:[NSArray class]]) stack = [program mutableCopy];
    for (int x = 0; x < [stack count]; x++) {
        if (![self isOperation:[stack objectAtIndex:x]] && [[stack objectAtIndex:x] isKindOfClass:[NSString class]]){
            [variablesUsed addObject:[stack objectAtIndex:x]];
        }
    }
    return variablesUsed;
}

@end
