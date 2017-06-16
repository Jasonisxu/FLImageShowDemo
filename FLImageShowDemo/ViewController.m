//
//  ViewController.m
//  FLImageShowDemo
//
//  Created by Wicrenet_Jason on 2017/6/13.
//  Copyright © 2017年 Wicrenet_Jason. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerViewController.h"
#import <Photos/Photos.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /**
     *1.如果用户还没有做过选择，这个方法就会弹框让用户做出选择是否允许访问相册
     *1.1 用户做出选择以后才会回调block
     *2.如果用户之前已经做过选择，这个方法就不会再弹框，直接回调block，传递现在的授权状态给block
     
     安全提示按钮选择
     // PHAuthorizationStatusNotDetermined
     // 用户还没有对当前App授权过(用户从未点击过Don't Allow或者OK按钮)
     
     // PHAuthorizationStatusRestricted
     // 因为一些系统原因导致无法访问相册（比如家长控制）
     
     // PHAuthorizationStatusDenied
     // 用户已经明显拒绝过当前App访问相片数据（用户已经点击过Don't Allow按钮）
     
     // PHAuthorizationStatusAuthorized
     // 用户已经允许过当前App访问相片数据（用户已经点击过OK按钮）

     */
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
    }];

}
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
