//
//  PhotoScrViewController.m
//  CH999
//
//  Created by Macbook Pro on 2017/1/10.
//  Copyright © 2017年 ch999.com. All rights reserved.
//

#import "PhotoScrViewController.h"
#import "bigImageCollectionViewCell.h"

#define viewAll self.view.frame.size

@interface PhotoScrViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UIScrollView *_bigImgScroll;
    UIImageView *_currentImg;
    UIScrollView *_currentScroll;
    NSMutableArray *newSelectedArr;
    NSMutableDictionary *thisSelectedDic;
    UICollectionView *_bigImageCollect;
    UIView *backBlackView;
    
    float currentX;
}
@end

@implementation PhotoScrViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    newSelectedArr = [[NSMutableArray alloc]init];
    _submitDic = [[NSMutableDictionary alloc]init];
    thisSelectedDic = [[NSMutableDictionary alloc]initWithDictionary:_lastDic];
    [newSelectedArr addObjectsFromArray:_selectedBtnArr];
    [self createView];
}

-(void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

-(void)createView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];

    _bigImageCollect = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    
    layout.itemSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    [_bigImageCollect registerClass:[bigImageCollectionViewCell class] forCellWithReuseIdentifier:@"myCell"];
    
    _bigImageCollect.delegate = self;
    
    _bigImageCollect.dataSource = self;
    
    _bigImageCollect.backgroundColor = [UIColor blackColor];
    
    _bigImageCollect.pagingEnabled = YES;
    
    layout.minimumLineSpacing = 0;
    
    layout.minimumInteritemSpacing = 0;
    
    _bigImageCollect.showsVerticalScrollIndicator = NO;
    
    _bigImageCollect.showsHorizontalScrollIndicator = NO;
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pressBackBtn)];
    [_bigImageCollect addGestureRecognizer:tap];
    
    
    if (_whichOne.length > 0) {
        NSInteger which = [_whichOne integerValue];
        [_bigImageCollect setContentOffset:CGPointMake(self.view.frame.size.width * which, 0)];
        
        currentX = self.view.frame.size.width * which;
        
        backBlackView = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width * which, 0, self.view.frame.size.width, self.view.frame.size.height)];
        backBlackView.backgroundColor = [UIColor blackColor];
        [_bigImageCollect addSubview:backBlackView];
        
        _currentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, backBlackView.frame.size.width, backBlackView.frame.size.height)];
        _currentScroll.showsVerticalScrollIndicator = NO;
        _currentScroll.showsHorizontalScrollIndicator = NO;
        _currentScroll.pagingEnabled = NO;
        _currentScroll.delegate = self;
        _currentScroll.maximumZoomScale=3.0;//图片的放大倍数
        _currentScroll.minimumZoomScale=1.0;//图片的最小倍率
        
        _currentImg = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, backBlackView.frame.size.width, backBlackView.frame.size.height)];
        
        PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
        reques.synchronous = NO;
        reques.resizeMode = PHImageRequestOptionsResizeModeFast;
        reques.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestImageForAsset:[self.PHFetchR objectAtIndex:which] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                _currentImg.image = result;
            }else{
                _currentImg.image = [UIImage imageNamed:@"noimage"];
            }
            _currentImg.contentMode = UIViewContentModeScaleAspectFit;
            _currentImg.clipsToBounds = YES;
        }];
        
        _currentImg.tag = 1000;
        _currentImg.contentMode = UIViewContentModeScaleAspectFit;
        [_currentScroll addSubview:_currentImg];
        [backBlackView addSubview:_currentScroll];
        [_bigImageCollect bringSubviewToFront:backBlackView];
    }else{
        currentX = 0;
    }
    
    [self.view addSubview:_bigImageCollect];
    
    //透明按钮
    UIButton *backClearBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [backClearBtn addTarget:self action:@selector(pressBackBtn) forControlEvents:UIControlEventTouchUpInside];
    backClearBtn.backgroundColor = [UIColor clearColor];
    [_currentScroll addSubview:backClearBtn];
    
    //上方视图
    UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    upView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    upView.tag = 10000;
    [self.view addSubview:upView];
    
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    [backBtn addTarget:self action:@selector(pressBack) forControlEvents:UIControlEventTouchUpInside];
    [upView addSubview:backBtn];
    
    UIImageView *backImgV = [[UIImageView alloc]initWithFrame:CGRectMake(backBtn.center.x - 10, backBtn.center.y - 10, 20, 20)];
    backImgV.image = [UIImage imageNamed:@"photoBack"];
    [backBtn addSubview:backImgV];
    
    UIButton *selectBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewAll.width - 64, 0, 64, 64)];
    [selectBtn addTarget:self action:@selector(pressSelect:) forControlEvents:UIControlEventTouchUpInside];
    selectBtn.tag = 15000;
    
    UIImageView *selectImgV = [[UIImageView alloc]initWithFrame:CGRectMake((64 - 30) / 2, (64 - 30) / 2, 30, 30)];
    selectImgV.tag = 15001;
    selectImgV.image = [UIImage imageNamed:@"ico_check_nomal"];
    [selectBtn addSubview:selectImgV];
    [selectBtn setSelected:NO];
    
    PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[[_whichOne integerValue]];
    NSArray *photoArr = thisSelectedDic[@"photoArray"];
    
    for (int i = 0; i < photoArr.count; i++) {
        if ([assetCollection.localIdentifier isEqualToString:photoArr[i][@"photoIdentifier"]]) {
            selectImgV.image = [UIImage imageNamed:@"ico_check_select"];
            [selectBtn setSelected:YES];
        }else{
            
        }
    }
    [upView addSubview:selectBtn];
    
    //下方视图
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, viewAll.height - 44, viewAll.width, 44)];
    downView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    downView.tag = 11000;
    [self.view addSubview:downView];
    
    if ([_isOriginal isEqualToString:@"1"]) {
        UIButton *originalBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        originalBtn.tag = 8000;
        [originalBtn addTarget:self action:@selector(pressOriginal:) forControlEvents:UIControlEventTouchUpInside];
        [downView addSubview:originalBtn];
        
        UIImageView *oriImg = [[UIImageView alloc]initWithFrame:CGRectMake((44 - 20) / 2, (44 - 20) / 2, 20, 20)];
        oriImg.image = [UIImage imageNamed:@"selectDot"];
        oriImg.tag = 8001;
        [originalBtn addSubview:oriImg];
        [originalBtn setSelected:NO];
        
        UILabel *originalLbl = [[UILabel alloc]initWithFrame:CGRectMake(originalBtn.frame.origin.x + originalBtn.frame.size.width + 5, (downView.frame.size.height - 20) / 2, 100, 20)];
        originalLbl.font = [UIFont systemFontOfSize:12];
        originalLbl.textColor = [UIColor whiteColor];
        originalLbl.text = @"原图";
        originalLbl.tag = 3000;
        [downView addSubview:originalLbl];
    }else{
        
    }
    
    UIButton *completeBtn = [[UIButton alloc]initWithFrame:CGRectMake(viewAll.width - 80, 5, 80, 40)];
    completeBtn.tag = 150000;
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
    
    
    if (photoArr.count >= 1) {
        completeLbl.text = [NSString stringWithFormat:@"%ld",photoArr.count];
    }else{
        completeLbl.hidden = YES;
    }
    [completeBtn addSubview:completeLbl];
    
    UILabel *compLbl = [[UILabel alloc]initWithFrame:CGRectMake(completeLbl.frame.origin.x + completeLbl.frame.size.width, (completeBtn.frame.size.height - 30) / 2, 60, 30)];
    compLbl.text = @"完成";
    compLbl.textColor = [UIColor whiteColor];
    compLbl.textAlignment = NSTextAlignmentCenter;
    [completeBtn addSubview:compLbl];
}


#pragma mark - collectinoDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _PHFetchR.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    bigImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    
    [cell getBigImageWithAsset:_PHFetchR[indexPath.item]];
    
    return cell;
}



-(void)pressBack{
    [self.navigationController popViewControllerAnimated:YES];
    _selectedDicBlock(thisSelectedDic);
}

-(void)pressBackBtn{
    UIView *upView = (id)[self.view viewWithTag:10000];
    UIView *downView = (id)[self.view viewWithTag:11000];
    if (upView.hidden == YES) {
        upView.hidden = NO;
        downView.hidden = NO;
    }else{
        upView.hidden = YES;
        downView.hidden = YES;
    }
}

-(void)pressOriginal:(UIButton *)sender{
    UILabel *oriLbl = (id)[self.view viewWithTag:3000];
    UIImageView *dotImg = (id)[sender viewWithTag:8001];
    if (sender.selected == YES) {
        [sender setSelected:NO];
        dotImg.image = [UIImage imageNamed:@"selectDot"];
        oriLbl.text = @"原图";
        _isOriginal = @"0";
    }else{
        [sender setSelected:YES];
        self.OriginalBlock(@"1");
        _isOriginal = @"1";
        dotImg.image = [UIImage imageNamed:@"selectedDot"];
        oriLbl.text = [NSString stringWithFormat:@"原图(%.2fM)",[self computesTheSizesWithImage:_currentImg.image]];
    }
}

//计算图片大小
-(float)computesTheSizesWithImage:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    float imageSize = imageData.length / (1024.00 * 1024.00);
    return imageSize;
}

//点击选择
-(void)pressSelect:(UIButton *)sender{
    int curr = backBlackView.frame.origin.x / viewAll.width;
    
    NSMutableArray *photoArr = [NSMutableArray arrayWithArray:thisSelectedDic[@"photoArray"]];
    
    PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[curr];
    
    UIImageView *imageV = (id)[sender viewWithTag:15001];
    
    if (sender.selected == NO) {
        
        if (photoArr.count >= _maxCount) {
            [sender setSelected:NO];
        }else{
            imageV.image = [UIImage imageNamed:@"ico_check_select"];
            [newSelectedArr addObject:[NSString stringWithFormat:@"%d",curr + 10000]];
            
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setValue:[NSString stringWithFormat:@"%@",assetCollection.localIdentifier] forKey:@"photoIdentifier"];
            [dic setValue:_albumIdentifier forKey:@"albumIdentifier"];
            [dic setValue:_PHFetchR[curr] forKey:@"photoAsset"];
            [photoArr addObject:dic];
            
            [thisSelectedDic setObject:photoArr forKey:@"photoArray"];

            
            [sender setSelected:YES];
        }
        
    }else{
        imageV.image = [UIImage imageNamed:@"ico_check_nomal"];
        [sender setSelected:NO];
        for (int i = 0; i < newSelectedArr.count; i++) {
            if (curr == [newSelectedArr[i] integerValue] - 10000) {
                [newSelectedArr removeObjectAtIndex:i];
            }
        }
        
        for (int i = 0; i < [photoArr count]; i++) {
            if ([photoArr[i][@"photoIdentifier"] isEqualToString:assetCollection.localIdentifier]) {
                [photoArr removeObjectAtIndex:i];
                sender.selected = NO;
            }
        }
        [thisSelectedDic setObject:photoArr forKey:@"photoArray"];
    }
    
    
    UILabel *comlpleteLbl = (id)[self.view viewWithTag:16000];
    comlpleteLbl.text = [NSString stringWithFormat:@"%ld",[thisSelectedDic[@"photoArray"] count]];

    if ([thisSelectedDic[@"photoArray"] count] == 0) {
        comlpleteLbl.hidden = YES;
    }else{
        comlpleteLbl.hidden = NO;
    }
    
    if ([_isOriginal isEqualToString:@"1"]) {
        [_submitDic setObject:@"1" forKey:@"isOriginal"];
    }else{
        [_submitDic setObject:@"0" forKey:@"isOriginal"];
    }
    
    NSMutableArray *myPhotoArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < newSelectedArr.count; i++) {
        NSMutableDictionary *photoDic = [[NSMutableDictionary alloc]init];
        
        PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[[newSelectedArr[i] integerValue] - 10000];
        [photoDic setObject:[NSString stringWithFormat:@"%@",assetCollection.localIdentifier] forKey:@"photoIdentifier"];
        [photoDic setObject:_albumIdentifier forKey:@"albumIdentifier"];
        [photoDic setObject:_PHFetchR[[newSelectedArr[i] integerValue] - 10000] forKey:@"photoAsset"];
        [myPhotoArr addObject:photoDic];
    }
    [_submitDic setObject:myPhotoArr forKey:@"photoArray"];
    
    if (_isNeed == YES) {
        __weak PhotoScrViewController *detailSelf = self;
        
        NSMutableArray *dataArr = [[NSMutableArray alloc]init];
        for (int i = 0; i < newSelectedArr.count; i++) {
            PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
            reques.synchronous = NO;
            reques.resizeMode = PHImageRequestOptionsResizeModeFast;
            reques.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            
            [[PHImageManager defaultManager] requestImageForAsset:_PHFetchR[[newSelectedArr[i] integerValue] - 10000] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                if (result) {
                    NSData *imageD = UIImageJPEGRepresentation(result, 0.3);
                    UIImage *image = [UIImage imageWithData:imageD];
                    NSData *imageData = [detailSelf resetSizeOfImageData:image maxSize:100];
                    [dataArr addObject:imageData];
                }else{
                    
                }
            }];
            
            [_submitDic setObject:dataArr forKey:@"imageDataArray"];
        }
    }else{
        
    }
    
    if (newSelectedArr.count > 0) {
        
    }else{
        NSArray *dataArr = [[NSArray alloc]init];
        [_submitDic setObject:dataArr forKey:@"imageDataArray"];
    }


}

-(void)pressComplete:(UIButton *)sender{
    NSArray *photoArr = thisSelectedDic[@"photoArray"];
    __weak PhotoScrViewController *detailSelf = self;
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    for (int i = 0; i < photoArr.count; i++) {
        PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
        reques.synchronous = NO;
        reques.resizeMode = PHImageRequestOptionsResizeModeFast;
        reques.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        for (int j = 0; j < _PHFetchR.count; j++) {
            PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[j];
            if ([assetCollection.localIdentifier isEqualToString:photoArr[i][@"photoIdentifier"]]) {
                [[PHImageManager defaultManager] requestImageForAsset:_PHFetchR[j] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    if (result) {
                        NSData *imageD = UIImageJPEGRepresentation(result, 0.3);
                        UIImage *image = [UIImage imageWithData:imageD];
                        NSData *imageData = [detailSelf resetSizeOfImageData:image maxSize:100];
                        [dataArr addObject:imageData];
                    }else{
                        
                    }
                }];
            }
        }
        
        [thisSelectedDic setObject:dataArr forKey:@"imageDataArray"];
    }
    
    self.getSubmitDic(thisSelectedDic);
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - scrollViewDelegtate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:_bigImageCollect]) {
        UILabel *oriLbl = (id)[self.view viewWithTag:3000];
        
        currentX = scrollView.contentOffset.x;
        
        backBlackView.frame = CGRectMake(scrollView.contentOffset.x, _currentScroll.frame.origin.y, _currentScroll.frame.size.width, _currentScroll.frame.size.height);
        
        _currentScroll.zoomScale = 1.0;
        
        PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
        reques.synchronous = NO;
        reques.resizeMode = PHImageRequestOptionsResizeModeFast;
        reques.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        [[PHImageManager defaultManager] requestImageForAsset:[self.PHFetchR objectAtIndex:scrollView.contentOffset.x / viewAll.width] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if (result) {
                _currentImg.image = result;
                if ([_isOriginal isEqualToString:@"1"]) {
                    oriLbl.text = [NSString stringWithFormat:@"原图(%.2fM)",[self computesTheSizesWithImage:result]];
                }else{
                    
                }
            }else{
                _currentImg.image = [UIImage imageNamed:@"noimage"];
            }
            _currentImg.contentMode = UIViewContentModeScaleAspectFit;
            _currentImg.clipsToBounds = YES;
            [_bigImageCollect bringSubviewToFront:backBlackView];
            backBlackView.hidden = NO;
        }];
        
        UIButton *selectedBtn = (id)[self.view viewWithTag:15000];
        UIImageView *selectImg = (id)[selectedBtn viewWithTag:15001];
        int curr = scrollView.contentOffset.x / viewAll.width;
        
        PHAssetCollection *assetCollection =  (PHAssetCollection *)_PHFetchR[curr];
        NSArray *photoArr = thisSelectedDic[@"photoArray"];
        
        for (int j = 0; j < photoArr.count; j++) {
            if ([assetCollection.localIdentifier isEqualToString:photoArr[j][@"photoIdentifier"]]) {
                [selectedBtn setSelected:YES];
                selectImg.image = [UIImage imageNamed:@"ico_check_select"];
                break;
            }else{
                [selectedBtn setSelected:NO];
                selectImg.image = [UIImage imageNamed:@"ico_check_nomal"];
            }
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:_bigImageCollect]) {
        
        float aaa = ABS(scrollView.contentOffset.x - currentX);
        
        if (aaa > viewAll.width / 2) {
            _currentImg.image = nil;
            backBlackView.hidden = YES;
        }
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _currentImg;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    //scrollView放大代理
    if (scrollView != _bigImageCollect) {
        CGPoint uiii;
        if (scrollView.contentSize.width>scrollView.frame.size.width) {
            uiii.x = scrollView.contentSize.width/2.0;
        }else{
            uiii.x = scrollView.frame.size.width/2.0;
        }
        if (scrollView.contentSize.height>scrollView.frame.size.height) {
            uiii.y = scrollView.contentSize.height/2.0;
        }else{
            uiii.y = scrollView.frame.size.height/2.0;
        }
        
        _currentImg.center = uiii;
    }
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
}


@end
