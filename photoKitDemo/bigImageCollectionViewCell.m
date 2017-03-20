//
//  bigImageCollectionViewCell.m
//  CH999
//
//  Created by Archer on 2017/2/9.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import "bigImageCollectionViewCell.h"

@implementation bigImageCollectionViewCell

#define allScreen [UIScreen mainScreen].bounds.size


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self createCellUI];
    }
    return self;
}

-(void)createCellUI{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, allScreen.width, allScreen.height)];
    [self.contentView addSubview:_imageView];
}

-(void)getBigImageWithAsset:(PHAsset *)asset{
    PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
    reques.synchronous = NO;
    reques.networkAccessAllowed = NO;
    reques.resizeMode = PHImageRequestOptionsResizeModeExact;
    reques.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(allScreen.width / 4, allScreen.height / 4) contentMode:PHImageContentModeAspectFit options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (result) {
            _imageView.image = result;
        }else{
            _imageView.image = [UIImage imageNamed:@"noimage"];
            
        }
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = YES;
        
    }];
}

@end
