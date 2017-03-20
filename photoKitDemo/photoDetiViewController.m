//
//  photoDetiViewController.m
//  CH999
//
//  Created by Macbook Pro on 2017/1/10.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import "photoDetiViewController.h"
#import "PhotoScrViewController.h"
#import "myPhotoCollectionViewCell.h"
#import "PhotosViewController.h"

#define viewAll self.view.frame.size


@interface photoDetiViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,selectDelegate>

@end

@implementation photoDetiViewController
{
    UIScrollView *_bigImgScroll;
    NSMutableArray *lowQulityArr;
    NSMutableDictionary *_submitDic;
    NSMutableDictionary *thisSelectedDic;
    dispatch_queue_t  queue;
    NSMutableArray *imgArr;
    NSInteger page;
    UICollectionView *_myCollect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_maxCount > 0) {
        
    }else{
        _maxCount = 9;
    }
    
    if (self.isOriginal.length > 0) {
        
    }else{
        self.isOriginal = @"0";
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    lowQulityArr = [[NSMutableArray alloc]init];
    _submitDic = [[NSMutableDictionary alloc]initWithDictionary:_mySubmitDic];
    thisSelectedDic = [[NSMutableDictionary alloc]initWithDictionary:_submitDic];
    
    self.title = [NSString stringWithFormat:@"%ld/%ld",[thisSelectedDic[@"photoArray"] count],_maxCount];

    [self navigationSetting];
    
    [self addSubView];
}


-(void)navigationSetting{
    UIButton *leftBackBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
    [leftBackBtn addTarget:self action:@selector(pressBack) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *backImg = [[UIImageView alloc]initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
    backImg.image = [UIImage imageNamed:@"news_back"];
    [leftBackBtn addSubview:backImg];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftBackBtn];
    
    if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0?20:0))
        
    {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer,leftItem];
    }else{
        self.navigationItem.leftBarButtonItem=leftItem;
    }
    
    
    
    UIButton *buttonr=[UIButton buttonWithType:UIButtonTypeCustom];
        buttonr.frame=CGRectMake(0,0,65,44);
        [buttonr setExclusiveTouch :YES];
    
        UILabel *backLabelr=[[UILabel alloc]initWithFrame:CGRectMake(15,0, 45, 44)];
        backLabelr.text=@"取消";
        backLabelr.font=[UIFont systemFontOfSize:16];
        backLabelr.textColor = [UIColor blackColor];
        [buttonr addSubview:backLabelr];
        [buttonr addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rItemr=[[UIBarButtonItem alloc]initWithCustomView:buttonr];
        if(([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0?20:0))
    
        {
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                           target:nil
                                                                                           action:nil];
            negativeSpacer.width = -10;//这个数值可以根据情况自由变化
            self.navigationItem.rightBarButtonItems = @[negativeSpacer,rItemr];
        }else{
            self.navigationItem.rightBarButtonItem=rItemr;
        }
}


-(void)back:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)pressBack{
    for (UINavigationController *nvc in self.navigationController.viewControllers) {
        if ([nvc isKindOfClass:[PhotosViewController class]]) {
            PhotosViewController *photo = (PhotosViewController *)nvc;
            photo.imageDic = thisSelectedDic;
            [self.navigationController popToViewController:nvc animated:YES];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addSubView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    
    _myCollect = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 50) collectionViewLayout:layout];
    
    layout.itemSize = CGSizeMake((self.view.frame.size.width - 25) / 4, (self.view.frame.size.width - 25) / 4);
    
    [_myCollect registerClass:[myPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    
    _myCollect.delegate = self;
    
    _myCollect.dataSource = self;
        
    _myCollect.backgroundColor = [UIColor whiteColor];
    
    layout.minimumLineSpacing = 5;
    
    layout.minimumInteritemSpacing = 0;
    
    _myCollect.showsVerticalScrollIndicator = YES;
    
    _myCollect.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:_myCollect];
    
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    downView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:downView];
    
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, 5, 80, 40)];
    completeBtn.tag = 15000;
    [completeBtn addTarget:self action:@selector(pressComplete:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:completeBtn];
    
    UILabel *completeLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, (completeBtn.frame.size.height - 20) / 2, 20, 20)];
    completeLbl.textColor = [UIColor whiteColor];
    completeLbl.backgroundColor = [UIColor greenColor];
    completeLbl.font = [UIFont systemFontOfSize:12];
    completeLbl.layer.cornerRadius = 10;
    completeLbl.clipsToBounds = YES;
    completeLbl.textAlignment = NSTextAlignmentCenter;
    completeLbl.tag = 16000;
    NSArray *photoArr = _submitDic[@"photoArray"];
    if (photoArr.count >= 1) {
        completeLbl.text = [NSString stringWithFormat:@"%ld",photoArr.count];
    }else{
        completeLbl.hidden = YES;
    }
    [completeBtn addSubview:completeLbl];
    
    UILabel *compLbl = [[UILabel alloc]initWithFrame:CGRectMake(completeLbl.frame.origin.x + completeLbl.frame.size.width, (completeBtn.frame.size.height - 30) / 2, 60, 30)];
    compLbl.text = @"完成";
    compLbl.textAlignment = NSTextAlignmentCenter;
    [completeBtn addSubview:compLbl];
}

#pragma mark - collectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _PHFetchR.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    myPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    
    cell.delegate = self;
        
    [cell getPhotoWithAsset:_PHFetchR[indexPath.item] andWhichOne:indexPath.item + 10000];
    
    PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[indexPath.item];
    
    NSArray *photoArr = thisSelectedDic[@"photoArray"];
    if (photoArr.count > 0) {
        for (int i = 0 ; i < photoArr.count; i++) {
            if ([photoArr[i][@"photoIdentifier"] isEqualToString:assetCollection.localIdentifier]) {
                cell.selectBtn.selected = YES;
                break;
            }else{
                
                cell.selectBtn.selected = NO;
            }
        }
    }
    
    NSLog(@"%ld",indexPath.item);
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoScrViewController *scView = [[PhotoScrViewController alloc]init];
    scView.PHFetchR = self.PHFetchR;
    scView.whichOne = [NSString stringWithFormat:@"%ld",indexPath.item];
    scView.lastDic = thisSelectedDic;
    scView.albumIdentifier = _albumIdentifier;
    scView.isNeed = _isNeed;
    scView.maxCount = _maxCount;
    scView.isOriginal = _isOriginal;
    
    [scView setSelectedDicBlock:^(NSDictionary *selectDic){
        thisSelectedDic = [[NSMutableDictionary alloc]initWithDictionary:selectDic];
        
        for (int i = 0; i < self.PHFetchR.count; i++) {
            PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[i];
            
            if ([thisSelectedDic[@"photoArray"] count] > 0) {
                for (int j = 0; j < [thisSelectedDic[@"photoArray"] count]; j++) {
                    if ([thisSelectedDic[@"photoArray"][j][@"photoIdentifier"] isEqualToString:assetCollection.localIdentifier]) {
                        UIButton *selectBtn = (id)[self.view viewWithTag:i + 10000];
                        [selectBtn setSelected:YES];
                        break;
                    }else{
                        UIButton *selectBtn = (id)[self.view viewWithTag:i + 10000];
                        [selectBtn setSelected:NO];
                    }
                }
            }else{
                UIButton *selectBtn = (id)[self.view viewWithTag:i + 10000];
                [selectBtn setSelected:NO];
            }
            
            
        }
        
        if ([thisSelectedDic[@"photoArray"] count] > 0) {
            UILabel *comlpleteLbl = (id)[self.view viewWithTag:16000];
            comlpleteLbl.text = [NSString stringWithFormat:@"%ld",[thisSelectedDic[@"photoArray"] count]];
            self.title = [NSString stringWithFormat:@"%ld/%ld",[thisSelectedDic[@"photoArray"] count],_maxCount];
            comlpleteLbl.hidden = NO;
        }else{
            self.title = [NSString stringWithFormat:@"0/%ld",_maxCount];
        }
        
    }];
    [scView setGetSubmitDic:^(NSMutableDictionary *dic){
        self.getSubmitDictionary(dic);
    }];
    
    [scView setOriginalBlock:^(NSString *isOriginal){
        self.isOriginal = isOriginal;
        [_submitDic setObject:isOriginal forKey:@"isOriginal"];
    }];
    
    [self.navigationController pushViewController:scView animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    NSLog(@"111");
    
    if (imgArr.count>1&&page+1<imgArr.count) {
        if (scrollView.contentOffset.y>((self.view.frame.size.width-25)/4+5)*50+((self.view.frame.size.width-25)/4+5)*75*page) {
            page= page+1;
            PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
            reques.synchronous = NO;
            reques.networkAccessAllowed = NO;
            reques.resizeMode = PHImageRequestOptionsResizeModeExact;
            reques.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            NSMutableArray *arrimg = [NSMutableArray arrayWithArray:[imgArr objectAtIndex:page]];
            NSInteger sum = page*300;
            dispatch_async(queue, ^{
                for (NSInteger i = 0;i<arrimg.count; i++) {
                    UIImageView *imV = (UIImageView*)[self.view viewWithTag:5000+i+sum];
                    __block   UIImage *aaa = [[UIImage alloc]init];
                    [[PHImageManager defaultManager] requestImageForAsset:[arrimg objectAtIndex:i] targetSize:CGSizeMake(self.view.frame.size.width/4, self.view.frame.size.height/4) contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        
                        if (result) {
                            aaa = result;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                imV.image = aaa;
                            });
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                imV.image = [UIImage imageNamed:@"noimage"];
                            });
                        }
                        imV.contentMode = UIViewContentModeScaleAspectFill;
                        imV.clipsToBounds = YES;
                        imV.userInteractionEnabled = YES;
                    }];
                }
            });
        }
    }
}

#pragma mark - selectDelegate
-(void)selectBtn:(UIButton *)sender{
    NSLog(@"%ld",sender.tag);
    
    UILabel *comlpleteLbl = (id)[self.view viewWithTag:16000];
    
    NSMutableArray *photoArr = [NSMutableArray arrayWithArray:thisSelectedDic[@"photoArray"]];
    
    PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[sender.tag - 10000];
    
    UIButton *button = (id)[self.view viewWithTag:sender.tag];
    if (button.selected == YES) {
        for (int i = 0; i < [photoArr count]; i++) {
            if ([photoArr[i][@"photoIdentifier"] isEqualToString:assetCollection.localIdentifier]) {
                [photoArr removeObjectAtIndex:i];
                sender.selected = NO;
            }
        }
        [thisSelectedDic setObject:photoArr forKey:@"photoArray"];
    }else{
        if (photoArr.count < _maxCount) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[NSString stringWithFormat:@"%@",assetCollection.localIdentifier] forKey:@"photoIdentifier"];
            [dic setValue:_albumIdentifier forKey:@"albumIdentifier"];
            [dic setValue:_PHFetchR[sender.tag - 10000] forKey:@"photoAsset"];
            [photoArr addObject:dic];
            
            sender.selected = YES;
            
            [thisSelectedDic setObject:photoArr forKey:@"photoArray"];
        }else{
            NSLog(@"不能选了");
        }
    }
    
    comlpleteLbl.text = [NSString stringWithFormat:@"%ld",photoArr.count];
    self.title = [NSString stringWithFormat:@"%ld/%ld",photoArr.count,_maxCount];
    if (photoArr.count == 0) {
        comlpleteLbl.hidden = YES;
    }else{
        comlpleteLbl.hidden = NO;
    }
}


//点击图片
-(void)pressImg:(UIButton *)sender{
    PhotoScrViewController *scView = [[PhotoScrViewController alloc]init];
    scView.PHFetchR = self.PHFetchR;
    scView.whichOne = [NSString stringWithFormat:@"%ld",sender.tag - 1000];
    scView.lowQualityArr = lowQulityArr;
    scView.lastDic = thisSelectedDic;
    scView.albumIdentifier = _albumIdentifier;
    scView.isNeed = _isNeed;
    scView.maxCount = _maxCount;
    
    [scView setSelectedDicBlock:^(NSDictionary *selectDic){
        thisSelectedDic = [[NSMutableDictionary alloc]initWithDictionary:selectDic];
        
        for (int i = 0; i < self.PHFetchR.count; i++) {
            PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[i];

            for (int j = 0; j < [thisSelectedDic[@"photoArray"] count]; j++) {
                if ([thisSelectedDic[@"photoArray"][j][@"photoIdentifier"] isEqualToString:assetCollection.localIdentifier]) {
                    UIButton *selectBtn = (id)[self.view viewWithTag:i + 10000];
                    [selectBtn setSelected:YES];
                    break;
                }else{
                    UIButton *selectBtn = (id)[self.view viewWithTag:i + 10000];
                    [selectBtn setSelected:NO];
                }
            }
        }
        
        UILabel *comlpleteLbl = (id)[self.view viewWithTag:16000];
        comlpleteLbl.text = [NSString stringWithFormat:@"%ld",[thisSelectedDic[@"photoArray"] count]];

    }];
    
    [scView setGetSubmitDic:^(NSMutableDictionary *dic){
        self.getSubmitDictionary(dic);
    }];
    
    [scView setOriginalBlock:^(NSString *isOriginal){
        self.isOriginal = isOriginal;
        [_submitDic setObject:isOriginal forKey:@"isOriginal"];
    }];
    
    [self.navigationController pushViewController:scView animated:YES];
}

//点击完成
-(void)pressComplete:(UIButton *)sender{
    self.getSubmitDictionary(thisSelectedDic);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize
{
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }
    else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        
        
        
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.50);
        if ([finallImageData length]/1024>200) {
            NSData *finallImageData1 = UIImageJPEGRepresentation(newImage,0.30);
            return finallImageData1;
        }
        return finallImageData;
    }
    return imageData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
