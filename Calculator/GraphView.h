//
//  GraphView.h
//  Calculator
//
//  Created by Stephen Heuzey on 10/4/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AxesDrawer.h"

@class GraphView;

@protocol GraphViewDelegate
- (double) functionForXValue:(CGFloat)x
                        from:(GraphView *)sender;
@end

@interface GraphView : UIView

@property (nonatomic) id <GraphViewDelegate> delegate;
@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint originOffSet;

- (void) reset;


@end
