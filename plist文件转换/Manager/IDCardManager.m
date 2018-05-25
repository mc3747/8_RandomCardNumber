


#import "IDCardManager.h"
@interface IDCardManager()
@property (nonatomic, copy) NSString *first6Num;
@property (nonatomic, copy) NSString *second7To14Num;
@property (nonatomic, copy) NSString *third15To17Num;
@property (nonatomic, copy) NSString *Fourth18Num;

@property (nonatomic, copy) NSString *totalString;
@property (nonatomic, copy) NSString *shortAddressString;
@property (nonatomic, copy) NSString *longAddressString;
@property (nonatomic, copy) NSString *genderString;
@end
/**
 * 身份证号码
 * 1、号码的结构
 * 公民身份号码是特征组合码，由十七位数字本体码和一位校验码组成。排列顺序从左至右依次为：六位数字地址码，
 * 八位数字出生日期码，三位数字顺序码和一位数字校验码。
 * 2、地址码(前六位数）
 * 表示编码对象常住户口所在县(市、旗、区)的行政区划代码，按GB/T2260的规定执行。
 * 3、出生日期码（第七位至十四位）
 * 表示编码对象出生的年、月、日，按GB/T7408的规定执行，年、月、日代码之间不用分隔符。
 * 4、顺序码（第十五位至十七位）
 * 表示在同一地址码所标识的区域范围内，对同年、同月、同日出生的人编定的顺序号，
 * 顺序码的奇数分配给男性，偶数分配给女性。
 * 5、校验码（第十八位数）
 * （1）十七位数字本体码加权求和公式 S = Sum(Ai * Wi), i = 0, ... , 16 ，先对前17位数字的权求和
 * Ai:表示第i位置上的身份证号码数字值 Wi:表示第i位置上的加权因子 Wi: 7 9 10 5 8 4 2 1 6 3 7 9 10 5 8 4
 * 2 （2）计算模 Y = mod(S, 11) （3）通过模得到对应的校验码 Y: 0 1 2 3 4 5 6 7 8 9 10 校验码: 1 0
 * X 9 8 7 6 5 4 3 2
 */
@implementation IDCardManager

#pragma mark - 外部调用类方法
+ (void)getCardInformationWith:(IDCardBlock)block {
    IDCardManager *manager = [[IDCardManager alloc] init];
    [manager getRandomIdInformation];
    block(manager.totalString,manager.longAddressString,manager.genderString);
}

#pragma mark - block赋值
- (void)setBlock:(IDCardBlock)block {
    IDCardManager *manager = [[IDCardManager alloc] init];
    [manager getRandomIdInformation];
    block(manager.totalString,manager.longAddressString,manager.genderString);
}

#pragma mark - 获取随机个人信息
- (void)getRandomIdInformation {
    //身份证前6位及地址
    [self getFile];
    //身份证7～14位
    [self getRandomDate];
    //身份证15～17位
    [self getDistributionNum];
    //身份证前17位
    NSString *first17String = [NSString stringWithFormat:@"%@%@%@",_first6Num,_second7To14Num,_third15To17Num];
    NSString *lastString = [self getVerifyNum:first17String];
    _totalString = [NSString stringWithFormat:@"%@%@",first17String,lastString];
   
}

#pragma mark - 获取文件：eccel文件先转化成txt，再由txt转化成plist文件
- (void)getFile {
    // 获取文件
    NSString *schoolsPath = [[NSBundle mainBundle] pathForResource:@"CardText" ofType:@"txt"];
    NSString *schoolsContent = [[NSString alloc] initWithContentsOfFile:schoolsPath encoding:NSUTF8StringEncoding error:nil];
    NSString *string = [schoolsContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *components = [string componentsSeparatedByString:@"\t\t"];
    
    //未嵌套的数组
    NSMutableArray *resultsArr = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSInteger i = 0; i < components.count; i++){
        NSString *schoolStr = [components objectAtIndex:i];
        schoolStr = [schoolStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        NSArray *schoolArr = [schoolStr componentsSeparatedByString:@"\t"];
        [resultsArr addObject:@{@"CardID":[schoolArr objectAtIndex:0],@"CardAddress":[schoolArr objectAtIndex:1]}];
    };
    
    //嵌套的数组
    //创建一个省的数组
    NSMutableArray *proArr = [NSMutableArray array];
    for (NSDictionary *dic in resultsArr) {
        NSString *str = [dic valueForKey:@"CardAddress"];
        NSString *id = [dic valueForKey:@"CardID"];
        //判断非空格字符,找出省
        if (![str hasPrefix:@" "]) {
            //每找到一个省的名字,创建一个省字典
            NSMutableDictionary *proDic = [NSMutableDictionary dictionary];
            //将便利的省名放到字典中,并设置key为proName
            [proDic setValue:str forKey:@"ProvName"];
            [proDic setValue:id forKey:@"ProvID"];
            //创建一个市的数组 作为存下属市用
            NSMutableArray *cityArr = [NSMutableArray array];
            //将市的数组放到省得字典里面 这里市是没有值的  设置key为市数组
            [proDic setObject:cityArr forKey:@"CityArray"];
            //将省字典组放到省的数组中
            [proArr addObject:proDic];
            
            //判断是否已两个空格和不是四个空格的字符串
        }else if ([str hasPrefix:@"  "] && ![str hasPrefix:@"    "])     {
            //取出省数组里的省的最后一个元素,代表市所隶属的省字典 判断是从上往下的
            NSMutableDictionary *proDic = [proArr lastObject];
            //从省得字典里预留的数组取出
            NSMutableArray *cityArr = [proDic objectForKey:@"CityArray"];
            //每找到一个市,创建一个市字典
            NSMutableDictionary *cityDic = [NSMutableDictionary dictionary];
            //将便利的东西放到市字典里
            [cityDic setObject:str forKey:@"CityName"];
            [cityDic setValue:id forKey:@"CityID"];
            //为下属区域创建个数组作为预留
            NSMutableArray *areArr = [NSMutableArray array];
            //将区的数组放到市的字典里
            [cityDic setObject:areArr forKey:@"AreaArray"];
            //将市的字典放到市的数组里
            [cityArr addObject:cityDic];
            
        }else{
            //从省的数组里面取出最后一个元素的省得字典
            NSMutableDictionary *proDic = [proArr lastObject];
            //从省得字典里面取出市的数组
            NSMutableArray *cityArr = [proDic objectForKey:@"CityArray"];
            //从市的数组里面取出最后一个元素市的字典
            NSMutableDictionary *cityDic = [cityArr lastObject];
            //从市的字典取出区的数组
            NSMutableArray *areArr = [cityDic objectForKey:@"AreaArray"];
            //将剩下便利的区名放到区的数组里
            NSMutableDictionary *areaDic = [NSMutableDictionary dictionary];
            [areaDic setValue:str forKey:@"AreaName"];
            [areaDic setValue:id forKey:@"AreaID"];
            [areArr addObject:areaDic];
        }
    }
    //写入文件
    NSString *plistPath =  @"/Users/gjfax/Desktop/CardIDText.plist";
    [proArr writeToFile:plistPath atomically:YES];
    
    //随机6位数
    [self getRandomId:resultsArr];
    //根据随机6位数，找出完整路径
    for (NSMutableDictionary *proDic in proArr) {
        //找出省，直辖市，自治区
        NSString *proString = [proDic objectForKey:@"ProvName"];
        NSString *proIDString = [proDic objectForKey:@"ProvID"];
        if ([proIDString isEqualToString:_first6Num]) {
            _longAddressString = proString;
            _longAddressString =  [_longAddressString stringByReplacingOccurrencesOfString:@" " withString:@""];
            break;
        }
            //找出那个省的市的数组
        NSMutableArray *cityArr = [proDic objectForKey:@"CityArray"];
        for (NSMutableDictionary *cityDic in cityArr) {
            NSString *cityString = [cityDic objectForKey:@"CityName"];
            NSString *cityIDString = [cityDic objectForKey:@"CityID"];
            if ([cityIDString isEqualToString:_first6Num]) {
                _longAddressString = [NSString stringWithFormat:@"%@%@",proString,cityString];
                _longAddressString =  [_longAddressString stringByReplacingOccurrencesOfString:@" " withString:@""];
                break;
            }
                //找出那个市字典里的区数组
            NSMutableArray *areArr = [cityDic objectForKey:@"AreaArray"];
            for (NSDictionary *areDic in areArr) {
                NSString *idString = [areDic valueForKey:@"AreaID"];
                if ([idString isEqualToString:_first6Num]) {
                    _longAddressString = [NSString stringWithFormat:@"%@%@%@",proString,cityString,_shortAddressString];
                    _longAddressString =  [_longAddressString stringByReplacingOccurrencesOfString:@" " withString:@""];
                    break;
                }
            }
        }
    }
}

#pragma mark - 产生随机身份证前6位
- (void)getRandomId:(NSMutableArray *)array {
    //随机产生3个地址
    NSMutableArray *randomArray = [[NSMutableArray alloc] init];
    while ([randomArray count] < 1) {
        int r = arc4random() % [array count];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSString *cardString = [[array objectAtIndex:r] valueForKey:@"CardID"];
        _first6Num = cardString;
        [dic setObject:cardString forKey:@"CardID"];
        
        for (int i = 0; i<array.count; i++) {
            if ([[array[i] objectForKey:@"CardID"] isEqualToString:cardString]) {
                NSString *addressString = [array[i] objectForKey:@"CardAddress"];
                _shortAddressString = addressString;
                [dic setObject:addressString forKey:@"CardAddress"];
                [randomArray addObject:dic];
                continue;
            };
        }
        
    };
    
}

#pragma mark - 随机日期：1970-08-30到1999-08-30当前的随机时间
- (void )getRandomDate {
  
    //要转换的字符串
    NSString * dateString = @"1970-08-30";
    //字符串转NSDate格式的方法
    NSDate *ValueDate = [self StringTODate:dateString];
    //现在的时间
//    NSDate * nowDate = [NSDate date];
    //要转换的字符串
    NSString * endDateString = @"1999-08-30";
    //字符串转NSDate格式的方法
    NSDate *endValueDate = [self StringTODate:endDateString];
    //计算两个中间差值(秒)
    NSTimeInterval time = [endValueDate timeIntervalSinceDate:ValueDate];
    //开始时间和结束时间的中间相差的时间
    int days;
    days = ((int)time)/(3600*24);  //一天是24小时*3600秒
    //0~days之间的随机数
    int randomDays = arc4random() % days;
    //时间加上随机天数
    NSDate *randomDate = [ValueDate dateByAddingTimeInterval:randomDays * 24 * 60 * 60];
    //返回格式化的日期字符串
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *randomDateString =  [dateFormatter stringFromDate:randomDate];
    _second7To14Num = randomDateString;
}

//字符串转日期
- (NSDate *)StringTODate:(NSString *)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    [dateFormatter setMonthSymbols:[NSArray arrayWithObjects:@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"10",@"11",@"12", nil]];
    NSDate * ValueDate = [dateFormatter dateFromString:sender];
    return ValueDate;
}

#pragma mark - 随机15～17位：派出所分配码，奇数为男性；偶数为女性
- (void)getDistributionNum {
    int num = (arc4random() % 1000);
    NSString *randomNumber = [NSString stringWithFormat:@"%.3d", num];
    _third15To17Num = randomNumber;
    _genderString = (num % 2)?@"男":@"女";
    //    NSLog(@"%@", randomNumber);
}

#pragma mark - 17位数产生第18位验证码：
- (NSString *)getVerifyNum:(NSString *)identityString {
    //** 开始进行校验 *//
    if (identityString.length != 17) return nil;
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"X", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    //计算出校验码所在数组的位置
    NSInteger idCardMod = idCardWiSum % 11;
    //得到最后一位身份证号码
    NSString *idCardLast = [idCardYArray objectAtIndex:idCardMod];
    return idCardLast;
}
@end
