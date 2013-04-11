     //
//  CalculatorBrain.h
//  Calculator
//
//  Created by Stephen Heuzey on 8/29/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;
- (void)pushVariableOrOperatorToStack:(NSString *)variable;
- (double)performOperation:(NSString *)operation;
- (void)clearOperands;

//  program is always guaranteed to be a Property List
@property (readonly) id program;

+ (double)runProgram:(id)program;
+ (double)runProgram:(id)program
 usingVariableValues:(NSDictionary *)variableValues;

+ (NSSet *) variablesUsedInProgram:(id)program;
+ (NSString *)descriptionOfProgram:(id)program;

@end
