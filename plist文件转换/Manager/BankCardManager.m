

#import "BankCardManager.h"
/*
 iOS 信用卡/银联卡校验-Luhn算法
 一、Luhn算法
 检验数字算法（Luhn Check Digit Algorithm），也叫做模数10公式，是一种简单的算法，用于验证银行卡、信用卡号码的有效性的算法。对所有大型信用卡公司发行的信用卡都起作用，这些公司包括美国Express、护照、万事达卡、Discover和用餐者俱乐部等。这种算法最初是在20世纪60年代由一组数学家制定，现在Luhn检验数字算法属于大众，任何人都可以使用它。
 
 二、校验过程：
 1、从卡号最后一位数字开始，逆向将奇数位(1、3、5等等)相加。
 2、从卡号最后一位数字开始，逆向将偶数位数字，先乘以2（如果乘积为两位数，则将其减去9），再求和。
 3、将奇数位总和加上偶数位总和，结果应该可以被10整除。
 
 例如：卡号为4514617608810943
 1) 奇数位和：3+9+1+8+6+1+4+5 = 37
 2) 偶数位和：4*2+0*2+(8*2-9)+0*2+(7*2-9)+(6*2-9)+1*2+4*2 = 33
 3) 余数为0则是银行卡：(37+33)/10 = 0
 
 另外：
 　　1、卡号位数少于14的基本是外资银行或小银行
 　　2、卡号位数多余23的大多是卡号包含字母或空格
 　　3、国内主流的银行（中、农、工、建、招、交等）基本都是基于16位或者19位的卡号
 
 不符合Luhn算法的银行卡：
 1、招商银行的运通卡
 2、江苏银行有些卡号不符合
 
 注意：
 　　并非所有信用卡银行卡都符合Luhn算法、所以即使用户填写的卡号违反了该规则，我们应该仍然运行用户的填写，但可以给出相应的警示内容，提示用户可能填错了
 */
@interface BankCardManager()
@property (nonatomic, copy) NSString *bankNumberString;
@property (nonatomic, copy) NSString *cardTypeString;
@end
@implementation BankCardManager

+ (void)getBankName:(NSString *)bankName numberLengthInt:(int )numberLengthInt block:(BankCardBlock)block {
    BankCardManager *manager = [[BankCardManager alloc] init];
//    [manager getCardBin:bankName numberLengthInt:numberLengthInt];
    [manager getBankCardBin:bankName numberLengthInt:numberLengthInt];
    block(manager.bankNumberString,manager.cardTypeString);
}

#pragma mark - 获取BankList.plist中
- (void )getBankCardBin:(NSString *)bankName  numberLengthInt:(int )numberLengthInt{
    
    //找出各个银行对应的银行卡bin
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"BankList" ofType:@"plist"];
    NSArray *bankArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    //选中银行卡的卡bin
    NSMutableArray *cardBinArray = [NSMutableArray array];
    NSMutableArray *cardTypeArray = [NSMutableArray array];
    for (NSDictionary *dic in bankArray) {
        NSString *bankNameString = [dic valueForKey:@"bankName"];
        
        if ([bankNameString containsString:bankName]) {
            [cardBinArray addObject:[dic valueForKey:@"cardPrefix"]];
            [cardTypeArray addObject:[dic valueForKey:@"cardType"]];
            
        } else if([bankName isEqualToString:@"中国邮政"] && ([bankNameString containsString:@"邮储"] || [bankNameString containsString:@"邮政"])) {
            [cardBinArray addObject:[dic valueForKey:@"cardPrefix"]];
            [cardTypeArray addObject:[dic valueForKey:@"cardType"]];
        };
    };
    //随机获取卡bin中的一个值
    int x = arc4random() % cardBinArray.count;
    NSString *cardBinString = cardBinArray[x];
    _cardTypeString = cardTypeArray[x];
    //随机生成已选长度 - cardBinString.length的数字串
    for (int k = 0; k< 1000000; k++) {
        long int maxLength = numberLengthInt - cardBinString.length;
        NSMutableString *string = [NSMutableString string];
        for (int i = 0; i < maxLength; i++) {
            int randomInt = arc4random() % 10;
            NSString *randomString = [NSString stringWithFormat:@"%d",randomInt];
            [string appendString:randomString];
            
        };
        NSString *totalString = [NSString stringWithFormat:@"%@%@",cardBinString,string];
        //是否符合Luhn算法
        if ([self checkCardNo:totalString]) {
            _bankNumberString = totalString;
            break;
        };
    }
}

#pragma mark - 获取bank.plist中的
- (void )getCardBin:(NSString *)bankName  numberLengthInt:(int )numberLengthInt{
    //找出各个银行对应的银行卡bin
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"bank" ofType:@"plist"];
    NSDictionary *bankDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableArray *array = [NSMutableArray array];
        //遍历key
    for (id string in bankDic) {
        //得到value
        NSString *valueString = bankDic[string];
        if ([valueString containsString:bankName]) {
            [array addObject:string];
        } else if([bankName isEqualToString:@"中国邮政"] && ([valueString containsString:@"邮储"] || [valueString containsString:@"邮政"])) {
            [array addObject:string];
        }
    };
    //将常用的表格，存在一张新的plist中
    #warning TODO 待办
    
    //随机获取卡号
    for (int k = 0; k< 1000000; k++) {
        //获取随机的一个卡bin
        int r = arc4random() % [array count];
        NSString *cardBinString = [array objectAtIndex:r];
        cardBinString = [cardBinString stringByReplacingOccurrencesOfString:@" " withString:@""];
        //随机生成16 - cardBinString.length的数字串
        long int maxLength = numberLengthInt - cardBinString.length;
        NSMutableString *string = [NSMutableString string];
        for (int i = 0; i < maxLength; i++) {
            int randomInt = arc4random() % 10;
            NSString *randomString = [NSString stringWithFormat:@"%d",randomInt];
            [string appendString:randomString];
            
        };
        NSString *totalString = [NSString stringWithFormat:@"%@%@",cardBinString,string];
        //是否符合Luhn算法
        if ([self checkCardNo:totalString]) {
            _bankNumberString = totalString;
            break;
        };
        
    };
    
}

#pragma mark - 符合Luhn算法
-(BOOL) checkCardNo:(NSString*) cardNo{
    int oddsum = 0;
    int evensum = 0;
    int allsum = 0;
    
    for (int i = 0; i< [cardNo length];i++) {
        NSString *tmpString = [cardNo substringWithRange:NSMakeRange(i, 1)];
        int tmpVal = [tmpString intValue];
        if((i % 2) == 0){
            tmpVal *= 2;
            if(tmpVal>=10)
                tmpVal -= 9;
            evensum += tmpVal;
        }else{
            oddsum += tmpVal;
            
        }
    }
    allsum = oddsum + evensum;
    
    if((allsum % 10) == 0)
        return YES;
    else
        return NO;
}

@end
