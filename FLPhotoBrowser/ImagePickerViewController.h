//
//  ImagePickerViewController.h
//  DaGeng
//
//  Created by fu on 15/5/14.
//  Copyright (c) 2015年 fu. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ImagePickerViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;

@property (nonatomic,strong)NSMutableArray *imageAssetAray; //照片数组
@property (nonatomic,strong)NSMutableDictionary *selectImageDictionary;//选中照片库中，照片的个数
@property (nonatomic,strong)NSMutableDictionary *onlySelectDictionary;//只能选择9张照片的字典

@property (nonatomic,strong)NSMutableArray *imageUrlArray;
@property (nonatomic,strong)NSMutableArray *selectIndexArray;
@property (nonatomic,assign)BOOL isNotShowSelectBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (strong , nonatomic) UIButton *okBtn;

- (IBAction)okBtnClick:(UIButton *)sender;

@end
