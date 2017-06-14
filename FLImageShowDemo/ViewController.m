//
//  ViewController.m
//  FLImageShowDemo
//
//  Created by Wicrenet_Jason on 2017/6/13.
//  Copyright © 2017年 Wicrenet_Jason. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerViewController.h"

@interface ViewController ()<ImagePickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sendNext:(UIButton *)sender {
    NSLog(@"相册图片");
    ImagePickerViewController *ivc = [[ImagePickerViewController alloc] init];
    ivc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ivc];
    nav.navigationBar.barTintColor = [UIColor redColor];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark--ImagePickerViewControllerDelegate
//- (void)imagePickerViewController:(ImagePickerViewController *)ivc everyImageClick:(ALAsset *)asset index:(NSInteger)index imageUrlArray:(NSArray *)imageUrlArray
//{
//    //    ALAssetRepresentation *representation = [asset defaultRepresentation];
//    
//    //    //获取全屏图
//    //    UIImage *fullScreenImage = [UIImage imageWithCGImage:representation.fullScreenImage];
//    //
//    //    //获取高清图
//    //    UIImage *fullResolutionImage = [UIImage imageWithCGImage:representation.fullResolutionImage];
//    //
//    //    //获取缩略图
//    //    UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
//    
//    FLImageShowVC *fvc = [[FLImageShowVC alloc] init];
//    fvc.albumImageUrlArray = imageUrlArray;
//    fvc.currentIndex = index;
//    [ivc.navigationController pushViewController:fvc animated:YES];
//}

- (void)imagePickerViewController:(ImagePickerViewController *)ivc finishClick:(NSArray *)assetArray
{
    NSLog(@"选中的所有相片的url，可以通过上面注释的方法获取图片:%@",assetArray);
}

- (void)imagePickerViewController:(ImagePickerViewController *)ivc firstImageClick:(UIImage *)image
{
    NSLog(@"调用相机拍出的图片:%@",image);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
