//
//  UIView+HorizontalView.m
//
//  Created by David Martinez Lebron on 5/12/15.
//  Copyright (c) 2015 Davaur_David Martinez. All rights reserved.
//

#import "UIView+HorizontalView.h"

//  Size between wallet views in userWalletCell
static const CGFloat kPaddingBetweenSubviews = 16;
static const CGFloat kOverlappedValue = 0.8;
static const CGFloat kVerticalMargin = 1.0;

@implementation UIView (HorizontalView)

//TODO: Finish imlementing this function to calculate if views are to be added
//-(CGFloat) isLastView:(BOOL) isLastView in: (HorizontalDistribution) horizontalDistribution {
//    switch (horizontalDistribution) {
//        case HorizontalDistributionFill:
//            return 1.0;
//
//        case HorizontalDistributionNormal:
//
//            return 1.0;
//
//        case HorizontalDistributionOverlapped:
//
//            return 1.0;
//
//        default:
//            return 0.0;
//    }
//}

-(void) horizontalViewWithViewsArray:(NSArray<UIView *> *) viewsArray withHorizontalDistribution:(HorizontalDistribution) horizontalDistribution andVerticalLocation:(VerticalLocation) verticalLocation {
    
    
    // views array must contain at least one value
    if (viewsArray.count < 1)
        return;
    
    /*
     Subviews height must not be larger than superview height.
     Subviews width must not be larger than superview width.
     */
    
    const CGSize subviewSize = [viewsArray[0] frame].size;
    
    if (subviewSize.width > self.frame.size.width || subviewSize.height > self.frame.size.height)
        return;
    
    NSAssert(subviewSize.width < self.frame.size.width, @"Subviews width can't be bigger than superview");
    NSAssert(subviewSize.height <= self.frame.size.height, @"Subviews height can't be bigger than superview");
    
    [self removeAllSubviews];
    
    CGFloat originY = 0;
    
    // prepare vertival location
    switch (verticalLocation) {
        case VerticalLocationTop:
            originY = kVerticalMargin;
            break;
            
        case VerticalLocationCentered:
            originY = [CalculationsUtils centerForSuperView:CGRectGetHeight(self.frame) withSize:subviewSize.height];
            break;
            
        case VerticalLocationBottom:
            originY = (CGRectGetHeight(self.frame) - subviewSize.height) - kVerticalMargin;
            break;
            
        default:
            break;
    }
    
    
    // prepare horizontal distribution
    switch (horizontalDistribution) {
        case HorizontalDistributionFill:
            
            [self prepareDistrutionFill:viewsArray withOriginY:originY];
            
            break;
            
        case HorizontalDistributionOverlapped:
            
            [self preparDistributionOverlapped:viewsArray withOriginY:originY];
            
            break;
            
        case HorizontalDistributionNormal:
            
            [self prepareDistributionNormal:viewsArray withOriginY:originY];
            
            break;
            
        default:
            break;
    }
    
    
    [self layoutIfNeeded];
}

#pragma Mark- Distribution Normal
-(void) prepareDistributionNormal: (NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    const CGFloat kHorizontalDistributionNormalPadding = 5.0f;

    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    CGFloat lastSubviewOriginX = 0.0;
    
    
    for (UIView *subview in viewsArray) {
        
        if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:kHorizontalDistributionNormalPadding]) {
            return;
        }
        
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (CGRectGetWidth(subview.frame));
            originX += kHorizontalDistributionNormalPadding;
        }
        
        else{
            originX = 1;
        }
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        lastSubviewOriginX = subview.frame.origin.x;
        
        [self addSubview:subview];
    }
}

#pragma Mark- Distribution Overlapped
-(void) preparDistributionOverlapped:(NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    CGFloat lastSubviewOriginX = 0.0;
    
    //  Calculates View location to be centered if horizontalDistribution == true else, sets initial x = 0
    CGFloat originX = 0;
    
    for (UIView *subview in viewsArray) {
        if (lastSubviewOriginX > 0.0) {
            originX = lastSubviewOriginX + (kOverlappedValue * CGRectGetWidth(subview.frame));
        }
        
        else{
            originX = 1;
        }
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        lastSubviewOriginX = subview.frame.origin.x;
        
         [self addSubview:subview];
        
    }

}

#pragma Mark- Distribution Fill
-(void) prepareDistrutionFill: (NSArray<UIView *>*) viewsArray withOriginY:(CGFloat) originY {
    
    const CGSize viewSize = [viewsArray[0] frame].size;
    
    CGFloat padding = 2.0f;
    
    int numberOfViews = [CalculationsUtils numberThatFitInScreen:viewSize.width withWidthBetweenViews:padding];
    
    if (viewsArray.count < numberOfViews) {// re-distribute separation
        padding = [CalculationsUtils paddingBetweenViewsArray:viewsArray inSuperView:self];
    }
 
    CGFloat originX = 0;

    for (UIView *subview in viewsArray) {
        
        originX += padding;
        
        if (subview != viewsArray.lastObject) {
            if (![self canAddSubview:subview.frame withOrigin:CGPointMake(originX, originY) withSeparation:padding]) {
                break;
            }
        }
        
        [subview setFrame:CGRectMake(originX, originY, CGRectGetWidth(subview.frame), CGRectGetHeight(subview.frame))];
        
        
        originX += padding; // add separation between subviews
        originX += (CGRectGetWidth(subview.frame)); // add the width of the subview
        
        [self addSubview:subview];
    }
    
}


-(BOOL) canAddSubview:(CGRect) subviewFrame withOrigin:(CGPoint) origin withSeparation: (CGFloat) separation {
    
    CGFloat originX = origin.x + separation;
    CGFloat nextOriginX = originX + CGRectGetWidth(subviewFrame);
    CGFloat originY = origin.y;
    
    if (nextOriginX + CGRectGetWidth(subviewFrame) > CGRectGetWidth(self.frame)) {
        
        UILabel *treeDots = [UILabel labelForLastSubviewWithFrame:CGRectMake(originX, originY, CGRectGetWidth(subviewFrame), CGRectGetHeight(subviewFrame))];
        [self addSubview:treeDots];
        
        return false;
    }
    
    return true;
}

-(CGFloat) divideIntoNumberOfSegments:(NSInteger) numberOfSegments withObjects:(NSArray *) objectsArray {
    
    void (^addSubViewInSegment)(id, CGRect) = ^(id object, CGRect rect){
        
        [object setFrame:rect];
        
        [self addSubview:object];
        
        object = nil;
    };
    
    NSInteger divisors = numberOfSegments - 1;
    
    NSInteger screenSize = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat viewWidth = (CGFloat)screenSize;
    
    const CGFloat distance = (viewWidth - kPaddingBetweenSubviews)/numberOfSegments;
    
    CGFloat originX = distance;
    
    for (int i=0; i < numberOfSegments; i++){
        
        if (i == 0){
            [self addLineFromX:originX];
        }
        
        else if (i < divisors){
            [self addLineFromX:originX];
        }
        
        //
        //  Asserts that the number of images in the array are equal to the number of segments
        //
        if (objectsArray){
            NSAssert(objectsArray.count == numberOfSegments, @"The number of objects in the array must be equivalent to the number of segments");
            //
            //  Takes the first xLocation = distance + 0
            //
            //  and substract distance/2 to get the center of the previous segment
            //
            
            id object = objectsArray[i];
            
            addSubViewInSegment(object, CGRectMake((originX - (distance/2)) - (CGRectGetWidth([object frame])/2), 2, CGRectGetWidth([object frame]), CGRectGetHeight([object frame])));
        }
        
        originX += distance;
    }
    
    return distance;
}

-(void) addLineFromX:(CGFloat) xLocation{
    
    CGFloat viewHeight = self.bounds.size.height;
    
    static CGFloat startingY = 10.0;
    
    CGFloat endingY = viewHeight - 10.0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(xLocation, startingY)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.strokeColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    shapeLayer.lineWidth = 1.5;
    
    [self.layer addSublayer:shapeLayer];
    
    [path addLineToPoint:CGPointMake(xLocation, endingY)];
    
    shapeLayer.path = path.CGPath;
    
    path = nil;
    
    shapeLayer = nil;
    
    //
    //  This code only works inside a drawRect
    //
    
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //
    //    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    //
    //    // Draw them with a 2.0 stroke width so they are a bit more visible.
    //    CGContextSetLineWidth(context, 2.0f);
    //
    //    CGContextMoveToPoint(context, xLocation, startingY); //start at this point
    //
    //    CGContextAddLineToPoint(context, xLocation, endingY); //draw to this point
    //
    //    // and now draw the Path!
    //    CGContextStrokePath(context);
    
    //
    //  Ends
    //
}


@end