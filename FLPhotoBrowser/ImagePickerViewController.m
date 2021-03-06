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

#import "FLImageShowVC.h"

#define Cellidentifier @"PhotoAlbumTableViewCell"
#define WIDTH(a) [UIScreen mainScreen].bounds.size.width / 320 * a
#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface ImagePickerViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSMutableArray *_groupArray;  //相册数组
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
    [_okBtn addTarget:self action:@selector(okBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_okBtn];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    _okBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
//    _selectImageDictionary = [NSMutableDictionary dictionary];
    _onlySelectDictionary = [NSMutableDictionary dictionary];
    
    
    _imageAssetAray = [NSMutableArray array];
    _imageUrlArray = [NSMutableArray array];
    
    /**
     *http://www.cnblogs.com/leo-92/p/4311379.html
     *iOS UICollectionView 缝隙修复
     */
    
    
    
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(WIDTH(79), WIDTH(79));
    layout.minimumLineSpacing = WIDTH(1);
    layout.minimumInteritemSpacing = WIDTH(1);
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(WIDTH(0), WIDTH(0), WIDTH(0), WIDTH(0));
    
    double offsetWidth = (NSUInteger)SCREENWIDTH % 5;
    CGFloat pointX = offsetWidth == 0 ? 0 : (4- offsetWidth)/2;
    _myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-pointX, 0, SCREENWIDTH + pointX * 2 , SCREENHEIGHT) collectionViewLayout:layout];
    _myCollectionView.delegate = self;
    _myCollectionView.dataSource = self;
    [self.view addSubview:_myCollectionView];
    _myCollectionView.backgroundColor = [UIColor whiteColor];
    
    [self.myCollectionView registerNib:[UINib nibWithNibName:@"MyCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:Cellidentifier];

    
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
        if (assetCollection)
        {
//            [_selectImageDictionary setObject:[NSMutableDictionary dictionary] forKey:assetCollection.localizedTitle];
            
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
//        [_selectImageDictionary setObject:[NSMutableDictionary dictionary] forKey:assetCollection.localizedTitle];

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
            
            if ([_onlySelectDictionary objectForKey:asset]) {
                cell.selectBtn.selected = YES;
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
        
        if ([_onlySelectDictionary objectForKey:asset]) {
            cell.selectBtn.selected = YES;
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
            [self pushFLImageShowVCAction:indexPath.row - 1];
        }
    } else {
        NSLog(@"点击了%li",indexPath.row);
        [self pushFLImageShowVCAction:indexPath.row];
       
    }
}

#pragma mark --跳转下个页面，并且执行回调--
- (void)pushFLImageShowVCAction:(NSInteger)index {
    __weak __typeof(&*self)weakSelf = self;
    
    FLImageShowVC *fvc = [[FLImageShowVC alloc] init];
    
    fvc.onlySelectDictionary = weakSelf.onlySelectDictionary;
    [fvc setOnlySelectDictionaryBlock:^(NSMutableDictionary *selectDictionary){
        [weakSelf.okBtn setTitle:[NSString stringWithFormat:@"下一步(%lu)",(unsigned long)[[_onlySelectDictionary allKeys] count]] forState:UIControlStateNormal];
        weakSelf.onlySelectDictionary = selectDictionary;
        [weakSelf.myCollectionView reloadData];
    }];
    
//    NSMutableDictionary *oldDic = [_selectImageDictionary objectForKey:_titleLabel.text];
//    fvc.indexPhotoDictionary = oldDic;
//    [fvc setIndexPhotoDictionaryBlock:^(NSMutableDictionary *selectDictionary){
//        [weakSelf.selectImageDictionary setObject:selectDictionary forKey:_titleLabel.text];
//        [_titleTabelView reloadData];
//    }];
    
    fvc.albumImageUrlArray = weakSelf.imageAssetAray;
    fvc.currentIndex = index;
    
    [weakSelf.navigationController pushViewController:fvc animated:YES];
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
    
    
    UIView *buttomView = [[UIView alloc] initWithFrame:CGRectMake(0, _titleTabelView.frame.size.height, SCREENWIDTH, SCREENHEIGHT)];
    [_titleTableBackgroundView addSubview:buttomView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenTitleTableBackgroundViewAction)];
    [buttomView addGestureRecognizer:tap];
}

#pragma mark --隐藏_titleTableBackgroundView--
- (void)hidenTitleTableBackgroundViewAction {
    [UIView animateWithDuration:0.5 animations:^{
        _titleTableBackgroundView.frame  =CGRectMake(0, - SCREENHEIGHT, _titleTableBackgroundView.frame.size.width, _titleTableBackgroundView.frame.size.height);
        _titleViewImageView.image = [UIImage imageNamed:@"ico_向下箭头"];
    }];
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
    
    //是否显示数字
    cell.photoSelectNum.hidden = YES;

//    if ([[_selectImageDictionary objectForKey:assetCollection.localizedTitle] allKeys].count == 0) {
//        cell.photoSelectNum.hidden = YES;
//    } else {
//        cell.photoSelectNum.hidden = NO;
//        cell.photoSelectNum.text = [NSString stringWithFormat:@"%li",[[_selectImageDictionary objectForKey:assetCollection.localizedTitle] allKeys].count];
//    }
    
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
    
    PHAssetCollection *assetCollection = _groupArray[indexPath.row];
    _titleLabel.text =assetCollection.localizedTitle;
    
    
    [_titleLabel sizeToFit];
    _titleLabel.center = CGPointMake(_titleView.frame.size.width / 2, 22);
    
    _titleViewImageView.center = CGPointMake(_titleLabel.frame.origin.x + _titleLabel.frame.size.width + _titleViewImageView.frame.size.width / 2 + 5, _titleViewImageView.center.y);
    
    [_imageAssetAray removeAllObjects];
    [_imageUrlArray removeAllObjects];
    [self getImageWithGroup:assetCollection];
    
    [self hidenTitleTableBackgroundViewAction];
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
    //刷新选择中的数字
    [_titleTabelView reloadData];
    
    MyCollectionViewCell *cell = (MyCollectionViewCell *)[[btn superview] superview];
    NSIndexPath *indexPath = [_myCollectionView indexPathForCell:cell];
    PHAsset *asset ;
    if (_isCameraRoll) {
        asset = _imageAssetAray[indexPath.row - 1];
    } else {
        asset = _imageAssetAray[indexPath.row];
    }
    
    //判断是否选中
    if (!btn.selected)
    {
        if ([_onlySelectDictionary allKeys].count >= 9) {
            [[[UIAlertView alloc] initWithTitle:@"亲，最多只能选择9张" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
            return;
        } else {
            btn.selected = YES;
            [_onlySelectDictionary setObject:asset forKey:asset];
            
//            NSMutableDictionary *newDic= [_selectImageDictionary objectForKey:_titleLabel.text];
//            [newDic setObject:asset forKey:asset];
//            [_selectImageDictionary setObject:newDic forKey:_titleLabel.text];
        }
    }
    else
    {
        btn.selected = NO;
        [_onlySelectDictionary removeObjectForKey:asset];
        
//        NSMutableDictionary *oldDic = [_selectImageDictionary objectForKey:_titleLabel.text];
//        [oldDic removeObjectForKey:asset];
//        [_selectImageDictionary setObject:oldDic forKey:_titleLabel.text];
    }
    
    if ([_onlySelectDictionary allKeys].count == 0)
    {
        [_okBtn setTitle:@"下一步" forState:UIControlStateNormal];
    }
    else
    {
        [_okBtn setTitle:[NSString stringWithFormat:@"下一步(%lu)",(unsigned long)[[_onlySelectDictionary allKeys] count]] forState:UIControlStateNormal];
    }
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
//    NSLog(@"%@",_selectImageDictionary);
}

#pragma mark--UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        NSLog(@"----调用相机拍出的图片:%@",image);
        _pickingImage = image;
        [self savePickingImage];
    }];
    
}


#pragma mark --app自定义相册--创建相簿，存储图片到手机--
//http://www.cnblogs.com/CoderAlex/p/6343880.html


/**
 *  获得刚才添加到【相机胶卷】中的图片
 */
- (PHFetchResult<PHAsset *> *)createdAssets
{
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:_pickingImage].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

/**
 *  获得【自定义相册】
 */
- (PHAssetCollection *)createdCollection
{
    // 获取软件的名字作为相册的标题
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

/**
 *  保存图片到相册
 */
- (void)saveImageIntoAlbum
{
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = self.createdAssets;
    
    // 获得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    
    if (createdAssets == nil || createdCollection == nil) {
//        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
        return;
    }
    
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
//        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
    } else {
//        [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
        
        //选中添加的照片
        for (PHAsset *asset in createdAssets) {
            [_onlySelectDictionary setObject:asset forKey:asset];
        }
        [self getAlbumList];
    }
}

- (void)savePickingImage{
    /*
     requestAuthorization方法的功能
     1.如果用户还没有做过选择，这个方法就会弹框让用户做出选择
     1> 用户做出选择以后才会回调block
     
     2.如果用户之前已经做过选择，这个方法就不会再弹框，直接回调block，传递现在的授权状态给block
     */
    
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    //  保存图片到相册
                    [self saveImageIntoAlbum];
                    break;
                }
                    
                case PHAuthorizationStatusDenied: {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) return;
                    
//                    JHLog(@"提醒用户打开相册的访问开关")
                    break;
                }
                    
                case PHAuthorizationStatusRestricted: {
//                    [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
                    break;
                }
                    
                default:
                    break;
            }
        });
    }];
}
@end
