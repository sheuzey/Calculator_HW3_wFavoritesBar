//
//  CalculatorViewController.h
//  Calculator
//
//  Created by Stephen Heuzey on 8/28/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphViewController.h"

@interface CalculatorViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *sentToBrain;

@end
