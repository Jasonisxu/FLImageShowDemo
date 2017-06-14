//
//  ViewController.m
//  FLImageShowDemo
//
//  Created by Wicrenet_Jason on 2017/6/13.
//  Copyright © 2017年 Wicrenet_Jason. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sendNext:(UIButton *)sender {
    NSLog(@"相册图片");
    ImagePickerViewController *ivc = [[ImagePickerViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ivc];
    nav.navigationBar.barTintColor = [UIColor redColor];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
