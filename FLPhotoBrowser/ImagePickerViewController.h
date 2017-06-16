//
//  ImagePickerViewController.h
//  DaGeng
//
//  Created by fu on 15/5/14.
//  Copyright (c) 2015年 fu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ImagePickerViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic)  UICollectionView *myCollectionView;
@property (strong, nonatomic) UIImage *pickingImage;

@property (nonatomic,strong)NSMutableArray *imageAssetAray; //照片分类数组
//@property (nonatomic,strong)NSMutableDictionary *selectImageDictionary;//选中照片库中，照片的个数
@property (nonatomic,strong)NSMutableDictionary *onlySelectDictionary;//只能选择9张照片的字典

@property (nonatomic,strong)NSMutableArray *imageUrlArray;
@property (nonatomic,assign)BOOL isNotShowSelectBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong , nonatomic) UIButton *okBtn;

- (IBAction)okBtnClick:(UIButton *)sender;

// 在interface中写方法的声明，是为了点语法有智能提示
- (PHFetchResult<PHAsset *> *)createdAssets;
- (PHAssetCollection *)createdCollection;

@end
