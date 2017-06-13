//
//  PhotoAlbumTableViewCell.h
//  FLImageShowDemo
//
//  Created by Wicrenet_Jason on 2017/6/13.
//  Copyright © 2017年 Wicrenet_Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAlbumTableViewCell : UITableViewCell
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (nonatomic,weak) IBOutlet UILabel *textLabel;

@end
