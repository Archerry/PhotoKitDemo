                       //
//  PhotosViewController.m
//  CH999
//
//  Created by Macbook Pro on 2017/1/9.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import "PhotosViewController.h"
#import <Photos/Photos.h>
#import "photoDetiViewController.h"

#define viewAll self.view.frame.size


@interface PhotosViewController (){
    NSMutableArray *photosG;
    BOOL ifNeed;
}

@end

@implementation PhotosViewController

-(instancetype)initWithMaxCount:(NSString *)maxCount andIsHaveOriginal:(NSString *)haveOriginal andOldImageDic:(NSDictionary *)oldImageDic andIfGetImageArr:(BOOL)ifNeedImageArr{
    self = [super init];
    if (self) {
        self.isHaveOriginal = haveOriginal;
        self.maxCountStr = maxCount;
        self.imageDic = oldImageDic;
        ifNeed = ifNeedImageArr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    photosG = [[NSMutableArray alloc]init];
    
    [self addtitle];
    
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            
            if (status == PHAuthorizationStatusAuthorized) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addSubView];
                });
            }else{
                NSLog(@"关闭了权限，需要授权");
                //授权路径
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
    }else if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        //授权路径
        //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        [self addSubView];
    }
}


-(void)createView{
    [self addSubView];
}

-(void)viewDidAppear:(BOOL)animated{
    UIScrollView *sc = (id)[self.view viewWithTag:5000];
    
    NSArray *photoArray = _imageDic[@"photoArray"];
    for (NSInteger i = 0; i < photosG.count; i++) {
        UIButton *btn = (id)[sc viewWithTag:1001 + i];
        
        UILabel *countLbl = (id)[btn viewWithTag:10000 + i];

        int sum = 0;
        
        PHAssetCollection *assetCollection = photosG[i];
        
        for (int k = 0; k < photoArray.count; k++) {
            if ([assetCollection.localIdentifier isEqualToString:photoArray[k][@"albumIdentifier"]]) {
                sum++;
            }
        }
        
        if (sum > 0) {
            countLbl.text = [NSString stringWithFormat:@"%d",sum];
            countLbl.hidden = NO;
        }else{
            countLbl.hidden = YES;
        }
    }
}

-(void)addtitle{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(0,0,44,44);
    [button setExclusiveTouch :YES];
    
    UILabel *backLabelr=[[UILabel alloc]initWithFrame:CGRectMake(15,0, 44, 44)];
    backLabelr.text=@"取消";
    backLabelr.font=[UIFont systemFontOfSize:16];
    backLabelr.textColor = [UIColor blackColor];
    [button addSubview:backLabelr];

    button.tag=101;
    [button addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rItem=[[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem=rItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0?20:0))
        
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil
                                                                                       action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
    }else{
        self.navigationItem.leftBarButtonItem=leftItem;
    }
}

-(void)btnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)addSubView{
    UIScrollView *sv = [[UIScrollView alloc]init];
    sv.tag = 5000;
    sv.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
    [self.view addSubview:sv];
    
    PHFetchResult *smartAlbums = [PHAssetCollection
                                  fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                  subtype:PHAssetCollectionSubtypeAlbumRegular
                                  options:nil];
    
    for (NSInteger i=0; i<smartAlbums.count; i++) {
        // 获取一个相册PHAssetCollection
        PHCollection *collection = smartAlbums[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            if ([assetCollection.localizedTitle isEqualToString:@"相机胶卷"]||[assetCollection.localizedTitle isEqualToString:@"所有照片"]) {
                [photosG insertObject:assetCollection atIndex:0];
            }else if ([assetCollection.localizedTitle isEqualToString:@"视频"]){
                
                
            }else if ([assetCollection.localizedTitle isEqualToString:@"已隐藏"]){
                
                
            }else if ([assetCollection.localizedTitle isEqualToString:@"最近删除"]){
                
                
            }
            else{
            [photosG addObject:assetCollection];
            }
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    for (NSInteger i=0; i<topLevelUserCollections.count; i++) {
        // 获取一个相册PHAssetCollection
        PHCollection *collection = topLevelUserCollections[i];
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            [photosG addObject:assetCollection];
            // 从一个相册中获取的PHFetchResult中包含的才是PHAsset
            
        } else {
            NSAssert1(NO, @"Fetch collection not PHCollection: %@", collection);
        }
    }
    
    NSArray *photoArray = _imageDic[@"photoArray"];
    
    for (NSInteger i = 0; i < photosG.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 60*i, self.view.frame.size.width, 60);
        btn.tag = 1001+i;
        [btn addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
        [sv addSubview:btn];
        
        UILabel *lineLabel = [[UILabel alloc]init];
        lineLabel.frame = CGRectMake(0, 59.5, self.view.frame.size.width, 0.5);
        lineLabel.backgroundColor = [UIColor lightGrayColor];
        [btn addSubview:lineLabel];
        PHAssetCollection *assetCollection = photosG[i];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        UILabel *titleLa = [[UILabel alloc]init];
        titleLa.frame = CGRectMake(70, 0, self.view.frame.size.width-70, 60);
        titleLa.text = [NSString stringWithFormat:@"%@(%ld)",assetCollection.localizedTitle,fetchResult.count];
        [titleLa sizeToFit];
        titleLa.frame = CGRectMake(70, 0, titleLa.frame.size.width, 60);
        [btn addSubview:titleLa];
        
        UILabel *countLbl = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(titleLa.frame) + 5, (btn.frame.size.height - 20) / 2, 20, 20)];
        countLbl.backgroundColor = [UIColor greenColor];
        countLbl.layer.cornerRadius = 10;
        countLbl.clipsToBounds = YES;
        countLbl.textColor = [UIColor whiteColor];
        countLbl.font = [UIFont systemFontOfSize:12];
        countLbl.tag = 10000 + i;
        countLbl.textAlignment = NSTextAlignmentCenter;
        
        int sum = 0;
        
        for (int k = 0; k < photoArray.count; k++) {
            if ([assetCollection.localIdentifier isEqualToString:photoArray[k][@"albumIdentifier"]]) {
                sum++;
            }
        }
        
        if (sum > 0) {
            countLbl.text = [NSString stringWithFormat:@"%d",sum];
            countLbl.hidden = NO;
        }else{
            countLbl.hidden = YES;
        }
        [btn addSubview:countLbl];
        
        PHAsset *asset = nil;
        if (fetchResult.count != 0) {
            asset = fetchResult[fetchResult.count-1];
        }
        
        // 使用PHImageManager从PHAsset中请求图片
        PHImageManager *imageManager = [[PHImageManager alloc] init];
        [imageManager requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            UIImageView *im = [[UIImageView alloc]init];
            im.frame = CGRectMake(0, 0, 60, 60);
            
            [btn addSubview:im];
            
            if (result) {
                im.image = result;
                NSLog(@"%@", result);
            }else{
                im.image = [UIImage imageNamed:@"noimage"];
            }
            im.contentMode = UIViewContentModeScaleAspectFill;
            im.clipsToBounds = YES;
        }];
        
    }
    sv.contentSize = CGSizeMake(self.view.frame.size.width, photosG.count*60);
}



-(void)photo:(UIButton*)sender{
     NSMutableArray *aaa = [[NSMutableArray alloc]init];
    for (PHAsset *as in [PHAsset fetchAssetsInAssetCollection:[photosG objectAtIndex:sender.tag-1001] options:nil]) {
        [aaa addObject:as];
        
    }
    
    photoDetiViewController *pvc = [[photoDetiViewController alloc]init];
    pvc.PHFetchR = [PHAsset fetchAssetsInAssetCollection:[photosG objectAtIndex:sender.tag-1001] options:nil];
    PHAssetCollection *assetCollection = [photosG objectAtIndex:sender.tag-1001];
    pvc.albumIdentifier = assetCollection.localIdentifier;
    pvc.maxCount = [_maxCountStr integerValue];
    pvc.isOriginal = _isHaveOriginal;
    pvc.mySubmitDic = _imageDic;
    pvc.imageDic = _imageDic;
    pvc.haveCount = [_imageDic[@"imageDataArray"] count];
    pvc.isNeed = ifNeed;
    __weak PhotosViewController *weakself = self;
    [pvc setGetSubmitDictionary:^(NSMutableDictionary *submitDic){
        if (weakself.getSubmitDic) {
            weakself.imageDic = submitDic;
            weakself.getSubmitDic(submitDic);
        }
    }];
    
    [self.navigationController pushViewController:pvc animated:YES];
}

-(void)getImageArrWithOldImageDic:(NSDictionary *)oldImageDic{
    if ([[_imageDic allKeys] count] > 0) {
        NSArray *photoArr = _imageDic[@"photoArray"];
        if (photoArr.count > 0) {
            
        }else{
            
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
