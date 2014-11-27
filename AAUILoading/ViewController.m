//
//  ViewController.m
//  AAUILoading
//
//  Created by liaa on 11/22/14.
//  Copyright (c) 2014 kidliaa. All rights reserved.
//

#import "ViewController.h"
#import "AAUILoading001.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet AAUILoading001 *loading1;

@end

@implementation ViewController
-(void)viewDidAppear:(BOOL)animated
{
    [self.loading1 loadingStart];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
