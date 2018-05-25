

#import "ViewController.h"
#import "IDCardManager.h"
#import "BankCardManager.h"
#import "BankLogoImageModel.h"
#import "CollectionViewCell.h"

static NSString * const CellReuseIdentify = @"CellReuseIdentify";
static NSString * const SupplementaryViewHeaderIdentify = @"SupplementaryViewHeaderIdentify";
static NSString * const SupplementaryViewFooterIdentify = @"SupplementaryViewFooterIdentify";

@interface ViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property (nonatomic, copy) NSString *first6Num;
@property (nonatomic, copy) NSString *second7To14Num;
@property (nonatomic, copy) NSString *third15To17Num;
@property (nonatomic, copy) NSString *Fourth18Num;

@property (nonatomic, copy) NSString *totalString;
@property (nonatomic, copy) NSString *shortAddressString;
@property (nonatomic, copy) NSString *longAddressString;
@property (nonatomic, copy) NSString *genderString;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *bankNameArray;
@property (nonatomic, weak) UILabel *idCardLabel;
@property (nonatomic, weak) UILabel *bankCardLabel;
@property (nonatomic, copy) NSString *selectedLength;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"随机获取身份证号&银行卡号";
    _bankNameArray = [BankLogoImageModel getChineseBankNameArray];
    [self getIDCardUI];
    [self getBankCardUI];
    
}
#pragma mark - 身份证
- (void)getIDCardUI {
    UIButton *idCardButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 50, [UIScreen mainScreen].bounds.size.width - 40, 30)];
    idCardButton.adjustsImageWhenHighlighted = YES;
    [idCardButton setTitle:@"1_点我随机获取身份证信息" forState:UIControlStateNormal];
    idCardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    idCardButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [idCardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    UIImage *normalImage = [self buttonImageFromColor:[[UIColor redColor] colorWithAlphaComponent:0.5f]];
    UIImage *highlightImage = [self buttonImageFromColor:[[UIColor orangeColor] colorWithAlphaComponent:0.5f]];
    [idCardButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [idCardButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [idCardButton addTarget:self action:@selector(getIDCard) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:idCardButton];
    
    UILabel *idCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, [UIScreen mainScreen].bounds.size.width - 40, 100)];
    [idCardLabel setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.5f]];
    idCardLabel.numberOfLines = 0;
    idCardLabel.lineBreakMode = NSLineBreakByCharWrapping;
    idCardLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:idCardLabel];
    _idCardLabel = idCardLabel;
}

//通过颜色来生成一个纯色图片
- (UIImage *)buttonImageFromColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//获取身份证事件
- (void)getIDCard {
     __weak typeof(self) weakSelf = self;
    [IDCardManager getCardInformationWith:^(NSString *cardNum, NSString *address, NSString *gender) {
        weakSelf.idCardLabel.text = [NSString stringWithFormat:@"身份证：%@；\n性别：%@；\n地址：%@；",cardNum,gender,address];
    }];
}

#pragma mark - 银行卡
- (void)getBankCardUI {
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width - 40, 60)];
    [titleLabel setText:@"2_选择银行卡长度\n再点击列表银行图标，随机获取银行卡信息"];
    
    [titleLabel setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.5f]];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.view addSubview:titleLabel];
    //长度选择button
    for (int i = 0; i <4; i++) {
        CGFloat buttonWidth = ([UIScreen mainScreen].bounds.size.width - 40)/4.f;
        UIButton *bankCardButton = [[UIButton alloc] initWithFrame:CGRectMake(20 + buttonWidth * i, 260, buttonWidth, 30)];
        bankCardButton.adjustsImageWhenHighlighted = YES;
        [bankCardButton setTitle:[NSString stringWithFormat:@"%d位",16 + i] forState:UIControlStateNormal];
        UIImage *normalImage = [self buttonImageFromColor:[[UIColor purpleColor] colorWithAlphaComponent:0.5f]];
        UIImage *highlightImage = [self buttonImageFromColor:[[UIColor orangeColor] colorWithAlphaComponent:0.5f]];
        [bankCardButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [bankCardButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        [bankCardButton addTarget:self action:@selector(bankCardLengthSelected:) forControlEvents:UIControlEventTouchUpInside];
        [bankCardButton setTag:16 + i];
        [self.view addSubview:bankCardButton];
        //初始化状态
        _selectedLength = @"16";
        [self refreshStateWithTag:16];
    }
    //展示
    UILabel *bankCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 290, [UIScreen mainScreen].bounds.size.width - 40, 50)];
    [bankCardLabel setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.5f]];
    bankCardLabel.numberOfLines = 0;
    bankCardLabel.lineBreakMode = NSLineBreakByCharWrapping;
    bankCardLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:bankCardLabel];
    _bankCardLabel = bankCardLabel;
    
    [self.view addSubview:self.collectionView];
}
//选择银行卡长度
- (void)bankCardLengthSelected:(UIButton *)button {
    _selectedLength = [NSString stringWithFormat:@"%li",(long)button.tag];
    [self refreshStateWithTag:button.tag];
}
//刷新选中
- (void)refreshStateWithTag:(NSInteger)tag {
    UIImage *normalImage = [self buttonImageFromColor:[[UIColor purpleColor] colorWithAlphaComponent:0.5f]];
    UIImage *selecterImage = [self buttonImageFromColor:[[UIColor magentaColor] colorWithAlphaComponent:0.5f]];
    NSArray *tagArray = @[@"16",@"17",@"18",@"19"];
    NSString *selectedTagString = [NSString stringWithFormat:@"%ld",tag];
    //按钮选择互斥
    for (UIButton *btn in self.view.subviews) {
        NSString *tagString = [NSString stringWithFormat:@"%ld",btn.tag];
        if ([tagArray containsObject:tagString]) {
            if ([tagString isEqualToString:selectedTagString]) {
                [btn setBackgroundImage:selecterImage forState:UIControlStateNormal];
            } else {
                [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
            }
        }
    };
}

#pragma mark - UICollectionViewDataSource
// 指定Section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// 指定section中的collectionViewCell的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _bankNameArray.count;
}

// 配置section中的collectionViewCell的显示
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellReuseIdentify forIndexPath:indexPath];
    
    [BankLogoImageModel bankLogoWithBankCode:_bankNameArray[indexPath.row] block:^(UIImage *logoImage, NSString *bankCode,NSString *bankName) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@(%@)", bankName, bankCode];
        cell.imageView.image = logoImage;
    }];
  
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify forIndexPath:indexPath];
        supplementaryView.backgroundColor = [UIColor whiteColor];
        return supplementaryView;
    }
    else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *supplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify forIndexPath:indexPath];
        supplementaryView.backgroundColor = [UIColor redColor];
        return supplementaryView;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate method
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//选中颜色
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.2f]];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = (CollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell setBackgroundColor:nil];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//选中
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     __weak typeof(self) weakSelf = self;
    int selectedLengthInt = _selectedLength.length?[_selectedLength intValue]:16;
    [BankCardManager getBankName:_bankNameArray[indexPath.row] numberLengthInt:selectedLengthInt block:^(NSString *bankCardNum,NSString *cardType) {
        weakSelf.bankCardLabel.text = [NSString stringWithFormat:@"银行卡号：%@%@(类型：%@)",bankCardNum,_bankNameArray[indexPath.row],cardType];
    }];
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]
        || [NSStringFromSelector(action) isEqualToString:@"paste:"])
        return YES;
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    NSLog(@"复制之后，可以插入一个新的cell");
}


#pragma mark - UICollectionViewDelegateFlowLayout method
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section == 1){
        return CGSizeMake(100, 50);
    }
    return CGSizeMake(100, 10);
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        //layout
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake((self.view.frame.size.width - 20)/3.0, 100);
        //初始化
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 350, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 350) collectionViewLayout:layout];
        _collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        _collectionView.delaysContentTouches = NO;//去掉延迟点击效果
        _collectionView.alwaysBounceVertical = YES;//可以滚动
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //注册
        [_collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:CellReuseIdentify];
        //UICollectionElementKindSectionHeader注册是固定的
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SupplementaryViewHeaderIdentify];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:SupplementaryViewFooterIdentify];
    }
    
    return _collectionView;
}
@end
