//
//  ViewController.m
//  photoKitDemo
//
//  Created by Archer on 2017/2/11.
//  Copyright © 2017年 minhangwang. All rights reserved.
//

#import "ViewController.h"
#import "PhotosViewController.h"
#import <Photos/Photos.h>

#define viewAll self.view.frame.size

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectView;
    NSMutableArray *dataSource;
    NSDictionary *selectImageDic;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    dataSource = [[NSMutableArray alloc]init];
    [self createUI];
}

-(void)createUI{
    //按钮
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    
    button.backgroundColor = [UIColor redColor];
    
    [button addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    //collectionView
    UICollectionViewFlowLayout *flowLay = [[UICollectionViewFlowLayout alloc]init];
    
    flowLay.itemSize = CGSizeMake((viewAll.width - 25) / 4, (viewAll.width - 25) / 4);
    
    flowLay.minimumLineSpacing = 5;
    
    flowLay.minimumInteritemSpacing = 0;
    
    _collectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(button.frame) + 10, viewAll.width, viewAll.height - CGRectGetMaxY(button.frame) - 10) collectionViewLayout:flowLay];
    
    _collectView.delegate = self;
    
    _collectView.dataSource = self;
    
    _collectView.backgroundColor = [UIColor whiteColor];
    
    _collectView.showsVerticalScrollIndicator = NO;
    
    _collectView.showsHorizontalScrollIndicator = NO;
    
    [_collectView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    [self.view addSubview:_collectView];
}


#pragma mark - 触发事件
-(void)pressBtn:(UIButton *)sender{
    PhotosViewController *photos = [[PhotosViewController alloc]initWithMaxCount:@"9" andIsHaveOriginal:@"0" andOldImageDic:selectImageDic andIfGetImageArr:YES];
    
    [photos setGetSubmitDic:^(NSDictionary *dic){
        NSLog(@"%@",dic);
        
        selectImageDic = dic;
        
        [self updateCollection];
    }];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:photos];
    
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - collectionDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataSource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, (viewAll.width - 25) / 4, (viewAll.width - 25) / 4)];
    
    
    PHImageRequestOptions *reques = [[PHImageRequestOptions alloc]init];
    
    reques.synchronous = NO;
    
    reques.networkAccessAllowed = NO;
    
    reques.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    reques.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    [[PHImageManager defaultManager]requestImageForAsset:dataSource[indexPath.item] targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:reques resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            imageView.image = result;
        }else{
            imageView.image = [UIImage imageNamed:@"noimage"];
        }
    }];
    
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    imageView.clipsToBounds = YES;
    
    [cell addSubview:imageView];
    
    return cell;
}

#pragma mark - 事件
-(void)updateCollection{
    if (dataSource.count > 0) {
        [dataSource removeAllObjects];
    }
    
    NSArray *photoArray = [selectImageDic objectForKey:@"photoArray"];
    
    for (int i = 0; i < photoArray.count; i++) {
        [dataSource addObject:[photoArray[i] objectForKey:@"photoAsset"]];
    }
    
    [_collectView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
