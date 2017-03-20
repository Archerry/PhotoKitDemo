//
//  photoDetiViewController.h
//  CH999
//
//  Created by Macbook Pro on 2017/1/10.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef void (^getSubmitDic)(NSMutableDictionary *submitDic);

@interface photoDetiViewController : UIViewController

@property(nonatomic,copy)PHFetchResult *PHFetchR;

@property(nonatomic,assign)NSInteger maxCount;

@property(nonatomic,copy)NSString *isOriginal;

@property(nonatomic,strong)NSDictionary *mySubmitDic;

@property(nonatomic,strong)NSDictionary *imageDic;

@property(nonatomic,copy)NSString *albumIdentifier;

@property(nonatomic,copy)getSubmitDic getSubmitDictionary;

@property(nonatomic,assign)NSInteger haveCount;

@property(nonatomic,assign)BOOL isNeed;

@property(nonatomic,strong)NSMutableArray *dataArr;

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize;

@end
