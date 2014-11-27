//
//  AAUILoading001.m
//  AAUILoading
//
//  Created by liaa on 11/22/14.
//  Copyright (c) 2014 kidliaa. All rights reserved.
//

#import "AAUILoading001.h"

@implementation AAUILoading001 {
    int floor;
    float padding;
    float aveHeight;
    NSDictionary *stacksLengthDictionary;
    int stackTypeCount;

    float viewWidth;
    float viewHeight;

    NSMutableArray *stackGroup;

    CGPoint frameAbovePoint;
    CGPoint frameFirstPoint;

    // speed
    float durationOfGroupMoveDown;
    float durationOfLayerMoveDown;
    float delayBetweenLayers;
    float delayBetweenGroup;

}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    [self setup];
    [self buildViewHierarchy];
    return self;
}
- (void)loadingStart {
    [self stage1];
}
- (void)stage1 {
    // s1: 将所有layers向下移动
    NSArray *layers = [self.layer sublayers];
    float moveDistance = aveHeight + padding;
    [CATransaction begin];
    [CATransaction setAnimationDuration:durationOfGroupMoveDown];
    [CATransaction setCompletionBlock:^{
        [self stage2];
    }];
    for (CALayer *layer in layers) {
        CGRect originalFrame = layer.frame;
        originalFrame.origin.y += moveDistance;
        [layer setFrame:originalFrame];
    }

    [CATransaction commit];
}

- (void)stage2 {
    // s2: 将最底部组的layers移动到顶部
    NSArray *bottomestLayers = [stackGroup lastObject];

    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    [CATransaction setCompletionBlock:^{
        [self stage3];
    }];
    for (CALayer *layer in bottomestLayers) {
        CGRect frame = layer.frame;
        frame.origin.y = frameAbovePoint.y;
        [layer setFrame:frame];
    }
    [CATransaction commit];
}

- (void) stage3
{
    NSArray *latestGroup = [stackGroup lastObject];
    [stackGroup removeLastObject];
    [stackGroup insertObject:latestGroup atIndex:0];
    CALayer *firstLayer = [latestGroup objectAtIndex:0];
    
    // s3: 分别移动顶部的layers
    [self animateTopmostGroup:firstLayer];

}
- (void) animateTopmostGroup:(CALayer *)layer
{
    layer.actions = @{@"position":[NSNull null] };
    CABasicAnimation *ani = [CABasicAnimation animation];
    ani.keyPath = @"position.y";
    ani.duration = durationOfLayerMoveDown;
    ani.fromValue = [NSNumber numberWithFloat:-layer.frame.size.height/2];
    ani.toValue =[NSNumber numberWithFloat:layer.frame.size.height/2];
    [ani setValue:layer forKey:@"layer"];
    ani.delegate = self;
    [layer addAnimation:ani forKey:nil];
    CGRect frame = layer.frame;
    frame.origin.y = 0;
    [layer setFrame:frame];
    layer.actions = nil;
    
}

-(void)animationDidStart:(CAAnimation *)anim
{
    
    CALayer *layer = [anim valueForKey:@"layer"];
    NSArray *firstGroup = [stackGroup firstObject];
    int idx = (int)[firstGroup indexOfObject:layer];
    if (layer == [firstGroup lastObject]) {
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayBetweenLayers * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self animateTopmostGroup:[firstGroup objectAtIndex:idx + 1]];
        });
    }
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CALayer *layer = [anim valueForKey:@"layer"];
    NSArray *firstGroup = [stackGroup firstObject];
    if (layer == [firstGroup lastObject]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayBetweenGroup * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // s1->s2->s3一个循环完成,下一个循环开始s1
            [self stage1];
        });
    }
    
}


- (void)setup {
    floor = 3;
    stackGroup = [[NSMutableArray alloc] initWithCapacity:floor];
    padding = 5;
    stacksLengthDictionary = @{
            @"stack1" : @[@25, @50, @25],
            @"stack2" : @[@50, @50]
            
    };
    stackTypeCount = (int)[[stacksLengthDictionary allKeys] count];


    viewWidth = self.frame.size.width;
    viewHeight = self.frame.size.height;

    aveHeight = (viewHeight - (floor - 1) * padding) / floor;

    frameAbovePoint = CGPointMake(0, -aveHeight);
    frameFirstPoint = CGPointMake(0, 0);
    self.clipsToBounds = YES;
    
    //speed
    durationOfGroupMoveDown = 0.5;
    durationOfLayerMoveDown = 0.2;
    delayBetweenGroup = 0.0;
    delayBetweenLayers = 0.1;
}

- (void)buildViewHierarchy {
    // 根据 floor 来建立 stackGroup.

    for (int i = 0; i < floor + 1; ++i) {
        NSMutableArray *group = [NSMutableArray array];
        float offsetY = i * (aveHeight + padding);
        float offsetX = 0; //group 中每个 layer offsetX 都会从0开始增加;

        NSArray *lengthArray = [self stackLengthArrayAtStackGroupIndex:i];
        float availableWidth = viewWidth - ([lengthArray count] - 1) * padding;

        for (NSNumber *percent in lengthArray) {
            float x = offsetX;
            float y = offsetY;
            float w = availableWidth * [percent floatValue] / 100;
            float h = aveHeight;

            CALayer *layer = [CALayer layer];
            layer.backgroundColor  = [UIColor colorWithRed:56/255.0 green:168/255.0 blue:234/255.0 alpha:1.0].CGColor;
            layer.frame = CGRectMake(x, y , w, h);
            [group addObject:layer];
            [self.layer addSublayer:layer];

            // 更新数据为下一个 layer
            offsetX += (w + padding);
        }
        [stackGroup addObject:group];
    }

}

- (NSArray *)stackLengthArrayAtStackGroupIndex:(int)i {
    int stackIndex = i % stackTypeCount;
    return [stacksLengthDictionary objectForKey:[[stacksLengthDictionary allKeys] objectAtIndex:stackIndex]];
}
@end
