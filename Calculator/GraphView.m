//
//  GraphView.m
//  Calculator
//
//  Created by Stephen Heuzey on 10/4/12.
//  Copyright (c) 2012 Stephen Heuzey. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (void) initialSetup{
    //  Set Default Scale
    self.scale = 10.0;
    self.originOffSet = CGPointMake(0, 0);
    self.contentMode = UIViewContentModeRedraw;    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initialSetup];
    return self;
}

- (void)awakeFromNib{
    [self initialSetup];
}

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self setNeedsDisplay];
}

- (void)setOriginOffSet:(CGPoint)originOffSet
{
    _originOffSet = originOffSet;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    // Draw Axes
    CGPoint originPoint;
    originPoint.x = self.frame.size.width/2 + self.originOffSet.x;
    originPoint.y = self.frame.size.height/2 + self.originOffSet.y;
    
    //  Draws a gray axis...because @property (nonatomic) BOOL theShadeOfGrayIsAwesome = YES;
    [[UIColor grayColor] setStroke];
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:originPoint scale:self.scale*self.contentScaleFactor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    
    for (CGFloat i = 0; i <= self.bounds.size.width; i++) {
        CGPoint pointInViewCoordinates;
        pointInViewCoordinates.x = i;
        
        CGPoint pointInGraphCoordinates;
        pointInGraphCoordinates.x = (pointInViewCoordinates.x - originPoint.x)/(self.scale * self.contentScaleFactor);
                
        pointInGraphCoordinates.y = ([self.delegate functionForXValue:pointInGraphCoordinates.x from:self]);
                
        pointInViewCoordinates.y = originPoint.y - (pointInGraphCoordinates.y * self.scale * self.contentScaleFactor);
        
        if(i == 0){
            CGContextMoveToPoint(context, pointInViewCoordinates.x, pointInViewCoordinates.y);
        } else {
            CGContextAddLineToPoint(context, pointInViewCoordinates.x, pointInViewCoordinates.y);
        }
    }
    
    //  Draws a green line...because @property (nonatomic) BOOL theColorGreenIsWayAwesomerThanTheShadeOfGray = YES;
    [[UIColor greenColor] setStroke];
    CGContextDrawPath(context, kCGPathStroke);
}

- (void)pinch:(UIPinchGestureRecognizer *)sender {
    if((sender.state == UIGestureRecognizerStateChanged ||
        sender.state == UIGestureRecognizerStateEnded)) {
        self.scale = self.scale * sender.scale;
        sender.scale = 1.0;
    }
}

- (void)pan:(UIPanGestureRecognizer *)sender {
    if ((sender.state == UIGestureRecognizerStateChanged ||
         sender.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [sender translationInView:self];
        CGPoint newOffSet = CGPointMake(self.originOffSet.x + translation.x,
                                          self.originOffSet.y + translation.y);
        self.originOffSet = newOffSet;
        [sender setTranslation:CGPointZero inView:self];
    }
}

- (void)reset
{
    self.originOffSet = CGPointMake(0, 0);
    self.scale = 10.0;
}


@end
