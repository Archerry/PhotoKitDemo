//
//  bigImageCollectionViewCell.h
//  CH999
//
//  Created by Archer on 2017/2/9.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface bigImageCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIImageView *imageView;

-(void)getBigImageWithAsset:(PHAsset *)asset;

@end
