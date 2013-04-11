//
//  CalculatorGraphViewController.h
//  Calculator
//
//  Created by Stephen Heuzey on 10/4/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "CalculatorBrain.h"
#import "SplitViewBarButtonItemPresenter.h"

@interface GraphViewController : UIViewController <UISplitViewControllerDelegate, SplitViewBarButtonItemPresenter>
@property (nonatomic) id function;
@end
