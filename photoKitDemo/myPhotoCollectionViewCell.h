//
//  myPhotoCollectionViewCell.h
//  CH999
//
//  Created by Archer on 2017/2/9.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@protocol selectDelegate <NSObject>

-(void)selectBtn:(UIButton *)sender;

@end

@interface myPhotoCollectionViewCell : UICollectionViewCell

@property(nonatomic,strong)UIButton *selectBtn;

@property(nonatomic,assign)NSInteger which;

@property(nonatomic,strong)UIImageView *__block imageView;

@property(nonatomic,assign)id<selectDelegate> delegate;

-(void)getPhotoWithAsset:(PHAsset *)myAsset andWhichOne:(NSInteger)which;

@end
