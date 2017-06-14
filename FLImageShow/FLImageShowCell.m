//
//  FLImageShowCell.m
//  FLImageShowDemo
//
//  Created by fuliang on 16/2/25.
//  Copyright © 2016年 fuliang. All rights reserved.
//

#import "FLImageShowCell.h"
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation FLImageShowCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    //设置实现缩放
    //设置代理scrollview的代理对象
    _scrollView.delegate=self;
    //设置最大伸缩比例
    _scrollView.maximumZoomScale = 3.0;
    //设置最小伸缩比例
    _scrollView.minimumZoomScale = 1;
    
    _imageView = [[UIImageView alloc] init];
    _scrollView.childView = _imageView;
    
    //添加检测旋转通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotWithIentationChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)updateImageViewFrame:(UIImage *)image
{
    CGFloat mainScreenWidth;
    CGFloat mainScreenHeight;
    
    UIDeviceOrientation orient = [[[NSUserDefaults standardUserDefaults] objectForKey:DeviceOrientationKey] integerValue];
    if (orient == DeviceOrientationHorizontal)
    {
        //横屏
        mainScreenWidth = [UIScreen mainScreen].bounds.size.height;
        mainScreenHeight = [UIScreen mainScreen].bounds.size.width;
    }
    else
    {
        //竖屏
        mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
        mainScreenHeight = [UIScreen mainScreen].bounds.size.height;
    }
    
    CGSize imageSize = image.size;
    NSLog(@"imageSize:%@", NSStringFromCGSize(image.size));
    CGSize imageViewSize;
    if (imageSize.width > mainScreenWidth)
    {
        imageViewSize = CGSizeMake(mainScreenWidth, imageSize.height / imageSize.width * mainScreenWidth);
        if (imageViewSize.height > mainScreenHeight)
        {
            imageViewSize = CGSizeMake(imageSize.width / imageSize.height * mainScreenHeight, mainScreenHeight);
        }
    }
    else
    {
        if (imageSize.height > mainScreenHeight)
        {
            imageViewSize = CGSizeMake(imageSize.width / imageSize.height * mainScreenHeight, mainScreenHeight);
        }
        else
        {
            imageViewSize = imageSize;
        }
    }
    _imageView.frame = CGRectMake(0, 0, imageViewSize.width, imageViewSize.height);
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    _imageView.center = CGPointMake(screenWidth / 2, screenHeight / 2);
    _scrollView.childView = _imageView;
}
#pragma mark--重写
- (void)setLocalImageName:(NSString *)localImageName
{
    _localImageName = localImageName;
    _imageView.image = [UIImage imageNamed:localImageName];
    [self updateImageViewFrame:_imageView.image];
}
- (void)setNetImageUrl:(NSString *)netImageUrl
{
    _netImageUrl = netImageUrl;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:netImageUrl] placeholderImage:[UIImage imageNamed:@"image_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error)
        {
            _imageView.image = [UIImage imageNamed:@"image_default"];
            [self updateImageViewFrame:_imageView.image];
        }
        else
        {
            [self updateImageViewFrame:image];
        }
    }];
}

- (void)addAlbumImageUrl:(NSArray *)imageAssetAray index:(NSInteger)index
{
    
    PHAsset *asset = imageAssetAray[index];
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        _imageView.image = result;
        [self updateImageViewFrame:_imageView.image];
    }];
}

#pragma mark--UIScrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    // 让UIImageView在UIScrollView缩放后居中显示
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    
    
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    
    
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                            
                            
                            scrollView.contentSize.height * 0.5 + offsetY);
    
}

#pragma mark--通知
- (void)getNotWithIentationChange:(NSNotification *)not
{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    if (orient == UIDeviceOrientationPortrait || orient == UIDeviceOrientationPortraitUpsideDown || orient == UIDeviceOrientationLandscapeLeft || orient == UIDeviceOrientationLandscapeRight)
    {
        [self updateImageViewFrame:_imageView.image];
    }
}
@end
