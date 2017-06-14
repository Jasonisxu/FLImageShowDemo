//
//  ImagePickerViewController.m
//  DaGeng
//
//  Created by fu on 15/5/14.
//  Copyright (c) 2015年 fu. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "MyCollectionViewCell.h"
#import "FLImageShowVC.h"
#import "PhotoAlbumTableViewCell.h"

#import <Photos/Photos.h>
#import "FLImageShowVC.h"

#define Cellidentifier @"PhotoAlbumTableViewCell"
#define WIDTH(a) [UIScreen mainScreen].bounds.size.width / 320 * a
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ImagePickerViewController ()
{
    NSMutableArray *_groupArray;
    UILabel *_titleLabel;
    UITableView *_titleTabelView;
    UIView *_titleTableBackgroundView;
    UIImageView *_titleViewImageView;
    UIView *_titleView;

    //是否是Camera Roll
    BOOL _isCameraRoll;
}
@end

@implementation ImagePickerViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _okBtn.frame = CGRectMake(0, 0, 70, 30);
    [_okBtn setTitle:@"下一步" forState:UIControlStateNormal];
    _okBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_okBtn];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    _okBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    _selectAssetArray = [NSMutableArray array];
    _thumbnailArray = [NSMutableArray array];
    
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:Cellidentifier];
    _imageAssetAray = [NSMutableArray array];
    _imageUrlArray = [NSMutableArray array];
    _selectIndexArray = [NSMutableArray array];
    _myCollectionView.backgroundColor = [UIColor whiteColor];
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(WIDTH(70), WIDTH(70));
    layout.minimumLineSpacing = WIDTH(1);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(WIDTH(1), WIDTH(1), WIDTH(1), WIDTH(1));
    _myCollectionView.collectionViewLayout = layout;
    
    
    //导航栏自定义
    [self leftBarButtonItem:@"取消" image:nil action:@selector(back)];
    
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 44)];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_titleView addSubview:_titleLabel];
    _titleViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_titleLabel.frame.size.width + _titleLabel.frame.origin.x + 5, 17, 10, 10)];
    _titleViewImageView.image = [UIImage imageNamed:@"ico_向下箭头"];
    [_titleView addSubview:_titleViewImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTapAction:)];
    [_titleView addGestureRecognizer:tap];
    self.navigationItem.titleView = _titleView;
    
    [self createTitleTableView];
    [self getAlbumList];
}


//获取相册列表
- (void)getAlbumList
{
    _groupArray = [NSMutableArray array];
    
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
//        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
        if (assetCollection)
        {
            _titleLabel.text = assetCollection.localizedTitle;
            [_groupArray insertObject:assetCollection atIndex:0];
            [_titleTabelView reloadData];
            
            [_titleLabel sizeToFit];
            _titleLabel.center = CGPointMake(_titleView.frame.size.width / 2, 22);
            
            _titleViewImageView.center = CGPointMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + _titleViewImageView.frame.size.width / 2 + 5, _titleViewImageView.center.y);
            
            
        }
    }
    
    
    //默认是：相机胶卷
    _isCameraRoll = YES;
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    if (assetCollection)
    {
        _titleLabel.text = assetCollection.localizedTitle;
        [_groupArray insertObject:assetCollection atIndex:0];
        [_titleTabelView reloadData];
        
        [_titleLabel sizeToFit];
        _titleLabel.center = CGPointMake(_titleView.frame.size.width / 2, 22);
        
        _titleViewImageView.center = CGPointMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + _titleViewImageView.frame.size.width / 2 + 5, _titleViewImageView.center.y);
        
    }
    [_imageAssetAray removeAllObjects];
    
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    
    if (assets.count == 0) {
        [_myCollectionView reloadData];
    }else {
        for (PHAsset *asset in assets) {
            
            [_imageAssetAray insertObject:asset atIndex:0];
            
            if ([assets.lastObject isEqual:asset])
            {
                [_myCollectionView reloadData];
            }
        }
    }
}

#pragma mark--UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (_isCameraRoll) {
        return _imageAssetAray.count + 1;
    } else {
        return _imageAssetAray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Cellidentifier forIndexPath:indexPath];
    cell.imageView.image = nil;
    cell.imageView.backgroundColor = [UIColor clearColor];
    if (_isNotShowSelectBtn)
    {
        cell.selectBtn.hidden = YES;
    }
    else
    {
        cell.selectBtn.hidden = NO;
        cell.selectBtn.selected = NO;
        cell.selectBtn.tag = indexPath.row;
        [cell.selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if (_isCameraRoll) {
        if (indexPath.row !=0)
        {
            
            PHAsset *asset = _imageAssetAray[indexPath.row - 1];
            
            // 从asset中获得图片
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                
                cell.imageView.image = result;
            }];
            
            for (int i =0; i < _selectIndexArray.count; i++)
            {
                NSString *selectIndex = _selectIndexArray[i];
                if (indexPath.row == [selectIndex integerValue])
                {
                    cell.selectBtn.selected = YES;
                }
            }
            
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"ico_相机"];
            cell.selectBtn.hidden = YES;
        }
    } else {
        PHAsset *asset = _imageAssetAray[indexPath.row];
        
        // 从asset中获得图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            cell.imageView.image = result;
        }];
        
        for (int i =0; i < _selectIndexArray.count; i++)
        {
            NSString *selectIndex = _selectIndexArray[i];
            if (indexPath.row == [selectIndex integerValue])
            {
                cell.selectBtn.selected = YES;
            }
        }
    }
    
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCameraRoll) {
        if (indexPath.row == 0) {
            [self callSystemCamera];
        } else {
            NSLog(@"点击了%li",indexPath.row);

            FLImageShowVC *fvc = [[FLImageShowVC alloc] init];
            fvc.albumImageUrlArray = _imageAssetAray;
            fvc.currentIndex = indexPath.row - 1;
            [self.navigationController pushViewController:fvc animated:YES];
        }
    } else {
        NSLog(@"点击了%li",indexPath.row);
        FLImageShowVC *fvc = [[FLImageShowVC alloc] init];
        fvc.albumImageUrlArray = _imageAssetAray;
        fvc.currentIndex = indexPath.row;
        [self.navigationController pushViewController:fvc animated:YES];
    }
}

#pragma mark --调用系统相机--
- (void)callSystemCamera {
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"亲，您的设备不支持照相机功能" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
    }
}


- (void)titleTapAction:(UITapGestureRecognizer *)tap
{
    CGFloat titleTabelY = _titleTableBackgroundView.frame.origin.y;
    if (titleTabelY <= - SCREENHEIGHT)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _titleTableBackgroundView.frame  =CGRectMake(0, 64, _titleTableBackgroundView.frame.size.width,_titleTableBackgroundView.frame.size.height);
            _titleViewImageView.image = [UIImage imageNamed:@"ico_向上箭头"];
        }];
        
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            _titleTableBackgroundView.frame  =CGRectMake(0, - SCREENHEIGHT, _titleTableBackgroundView.frame.size.width,_titleTableBackgroundView.frame.size.height);
            _titleViewImageView.image = [UIImage imageNamed:@"ico_向下箭头"];
        }];
    }
    
}

- (void)createTitleTableView
{
    _titleTableBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -SCREENHEIGHT, SCREENWIDTH, SCREENHEIGHT)];
    _titleTableBackgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    _titleTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 300) style:UITableViewStylePlain];
    _titleTabelView.delegate = self;
    _titleTabelView.dataSource  = self;
    _titleTabelView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_titleTableBackgroundView];
    [_titleTableBackgroundView addSubview:_titleTabelView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (PhotoAlbumTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = Cellidentifier;
    PhotoAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PhotoAlbumTableViewCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
    }
    PHAssetCollection *assetCollection = _groupArray[indexPath.row];
    
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    // 从asset中获得图片
    [[PHImageManager defaultManager] requestImageForAsset:assets.lastObject targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        cell.photoImageView.image = result;
    }];
    
    cell.photoTextLabel.text = [NSString stringWithFormat:@"%@（%ld）",assetCollection.localizedTitle,(long)assets.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断是否点击了相册
    if (indexPath.row == 0) {
        _isCameraRoll = YES;
    } else {
        _isCameraRoll = NO;
    }
    
    [_okBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [_selectAssetArray removeAllObjects];
    [_selectIndexArray removeAllObjects];
    
    PHAssetCollection *assetCollection = _groupArray[indexPath.row];
    _titleLabel.text =assetCollection.localizedTitle;
    
    
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(_titleView.frame.size.width / 2, 22);
    
    _titleViewImageView.center = CGPointMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + _titleViewImageView.frame.size.width / 2 + 5, _titleViewImageView.center.y);
    
    [_imageAssetAray removeAllObjects];
    [_imageUrlArray removeAllObjects];
    [self getImageWithGroup:assetCollection];
    [UIView animateWithDuration:0.5 animations:^{
        
        _titleTableBackgroundView.frame  =CGRectMake(0, - SCREENHEIGHT, _titleTableBackgroundView.frame.size.width, _titleTableBackgroundView.frame.size.height);
        _titleViewImageView.image = [UIImage imageNamed:@"ico_向下箭头"];
    }];
}

//根据相册获取下面的图片
- (void)getImageWithGroup:(PHAssetCollection *)assetCollection
{
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if (assets.count == 0) {
        [_myCollectionView reloadData];
    }else {
        for (PHAsset *asset in assets) {
            
            [_imageAssetAray insertObject:asset atIndex:0];
            
            if ([assets.lastObject isEqual:asset])
            {
                [_myCollectionView reloadData];
            }
        }
    }
    
    
}



- (void)selectBtnClick:(UIButton *)btn
{
    //    btn.selected = !btn.selected;
    //    MyCollectionViewCell *cell = (MyCollectionViewCell *)[[btn superview] superview];
    //    NSIndexPath *indexPath = [_myCollectionView indexPathForCell:cell];
    //    ALAsset *asset = _imageAssetAray[indexPath.row - 1];
    //
    //    if (btn.selected)
    //    {
    //        [_selectAssetArray addObject:asset];
    //        [_selectIndexArray addObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //    }
    //    else
    //    {
    //        [_selectAssetArray removeObject:asset];
    //        [_selectIndexArray removeObject:[NSString stringWithFormat:@"%ld",(long)btn.tag]];
    //    }
    //
    //    if (_selectAssetArray.count == 0)
    //    {
    //        [_okBtn setTitle:@"下一步" forState:UIControlStateNormal];
    //    }
    //    else
    //    {
    //        [_okBtn setTitle:[NSString stringWithFormat:@"下一步(%lu)",(unsigned long)[_selectAssetArray count]] forState:UIControlStateNormal];
    //    }
    //    NSLog(@"%@",_selectIndexArray);
    //    NSLog(@"%@",_selectAssetArray);
    //
}


- (void)leftBarButtonItem:(NSString *)titles image:(UIImage *)image action:(SEL)action
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [UIImageView new];
    imageView.image = image;
    CGSize imgSize = image.size;
    imageView.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
    imageView.center = CGPointMake(imageView.center.x,22);
    [view addSubview:imageView];
    
    UILabel *lbl = [UILabel new];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:16];
    lbl.text = titles;
    CGSize lblSize = [lbl sizeThatFits:lbl.frame.size];
    lbl.frame = CGRectMake(imgSize.width + 5, 0, lblSize.width, lblSize.height);
    lbl.center = CGPointMake(lbl.center.x, 22);
    [view addSubview:lbl];
    view.frame = CGRectMake(0, 0, 44, 44.0f);
    view.userInteractionEnabled = YES;
    UITapGestureRecognizer *handle = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    [view addGestureRecognizer:handle];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:view];
}


- (void)back
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
}

- (IBAction)okBtnClick:(UIButton *)sender
{
    NSLog(@"下一步");
    if ([_delegate respondsToSelector:@selector(imagePickerViewController:finishClick:)])
    {
        [_delegate imagePickerViewController:self finishClick:_selectAssetArray];
    }
    
}

#pragma mark--UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"----调用相机拍出的图片:%@",image);
        
        //        if ([_delegate respondsToSelector:@selector(imagePickerViewController:firstImageClick:)])
        //        {
        //            [_delegate imagePickerViewController:self firstImageClick:image];
        //        }
    }];
    
}
@end
