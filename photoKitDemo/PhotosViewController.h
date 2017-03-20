//
//  PhotosViewController.h
//  CH999
//
//  Created by Macbook Pro on 2017/1/9.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^photoArrBlock)(NSMutableDictionary *selecedDic);

@interface PhotosViewController : UIViewController

@property(nonatomic,strong)NSDictionary *imageDic;

@property(nonatomic,copy)NSString *maxCountStr;

@property(nonatomic,copy)NSString *isHaveOriginal;

@property(nonatomic,copy)photoArrBlock getSubmitDic;

-(instancetype)initWithMaxCount:(NSString *)maxCount andIsHaveOriginal:(NSString *)haveOriginal andOldImageDic:(NSDictionary *)oldImageDic andIfGetImageArr:(BOOL)ifNeedImageArr;


@end
