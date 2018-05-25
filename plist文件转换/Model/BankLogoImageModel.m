

#import "BankLogoImageModel.h"

@implementation BankLogoImageModel

+ (void)bankLogoWithBankCode:(NSString *)bankName block:(BankLogoAndNameBlock)block {
    if ([bankName containsString:@"邮储"] || [bankName containsString:@"邮政"] ) {
        
    }
    NSArray *chineseBankNameArray = [self getChineseBankNameArray];
    NSArray *englishBankNameArray = [self getEnglishBankNameArray];
    NSArray *bankImageNameArray = [self getBankImageNameArray];
    
    [chineseBankNameArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:bankName]) {
            int index = (int)idx;
            NSString *englishbankName = englishBankNameArray[index];
            NSString *bankImageName = bankImageNameArray[index];
            UIImage *bankImage = [UIImage imageNamed:bankImageName];
            block(bankImage,englishbankName,bankName);
        }
    }];
    
}

+ (NSArray *)getChineseBankNameArray {
    NSArray *chineseBankNameArray = @[@"工商银行",@"农业银行",@"中国银行",@"建设银行",@"交通银行",
                               @"招商银行",@"华夏银行",@"光大银行",@"中国邮政",@"中信银行",
                               @"上海银行",@"民生银行",@"平安银行",@"浦发银行",@"兴业银行"];
    return chineseBankNameArray;
}

+ (NSArray *)getEnglishBankNameArray {
    NSArray *englishBankNameArray = @[@"GSYH",@"NYYH",@"ZGYH",@"JSYH",@"JTYH",
                               @"ZSYH",@"HXYH",@"GDYH",@"YZYH",@"ZXYH",
                               @"SHYH",@"MSYH",@"PAYH",@"PFYH",@"XYYH"];
    return englishBankNameArray;
}

+ (NSArray *)getBankImageNameArray {
    NSArray *bankImageNameArray = @[@"gsyh",@"nyyh",@"zgyh",@"jsyh",@"jtyh",
                               @"zsyh",@"hxyh",@"gdyh",@"zgyz",@"zxyh",
                               @"shyh",@"msyh",@"payh",@"pfyh",@"xyyh"];
    return bankImageNameArray;
}



+ (UIImage*)bankLogoWithBankCode:(NSString *)bankCode
{
    UIImage *bankLogoImg = [[UIImage alloc] init];
    
    if ([bankCode isEqualToString:@"HBNX"]) {
        //  河北农村信用社
        bankLogoImg = [UIImage imageNamed:@"hbsncxys"];
    } else if ([bankCode isEqualToString:@"DGYH"]) {
        //  东莞银行
        bankLogoImg = [UIImage imageNamed:@"dgyh"];
    } else if ([bankCode isEqualToString:@"PAYH"]) {
        //  平安银行
        bankLogoImg = [UIImage imageNamed:@"payh"];
    } else if ([bankCode isEqualToString:@"JXNX"]) {
        //  江西省农村信用社
        bankLogoImg = [UIImage imageNamed:@"jxsncxyhzs"];
    } else if ([bankCode isEqualToString:@"XYYH"]) {
        //  兴业银行
        bankLogoImg = [UIImage imageNamed:@"xyyh"];
    } else if ([bankCode isEqualToString:@"QZYH"]) {
        //  泉州银行
        bankLogoImg = [UIImage imageNamed:@"qzyh"];
    } else if ([bankCode isEqualToString:@"NYYH"]) {
        //  农业银行
        bankLogoImg = [UIImage imageNamed:@"nyyh"];
    } else if ([bankCode isEqualToString:@"DLYH"]) {
        //  大连银行
        bankLogoImg = [UIImage imageNamed:@"dlyh"];
    } else if ([bankCode isEqualToString:@"AHNX"]) {
        //  安徽省农村信用社
        bankLogoImg = [UIImage imageNamed:@"axsncxys"];
    } else if ([bankCode isEqualToString:@"SDNX"]) {
        //  山东省农村信用社
        bankLogoImg = [UIImage imageNamed:@"sdsncxys"];
    } else if ([bankCode isEqualToString:@"HNNX"]) {
        //  河南(or海南)省农村信用社 --> icon有错
        bankLogoImg = [UIImage imageNamed:@"gdyh"];
    } else if ([bankCode isEqualToString:@"NCYH"]) {
        //  南昌银行
        bankLogoImg = [UIImage imageNamed:@"ncyh"];
    } else if ([bankCode isEqualToString:@"ZXYH"]) {
        //  中信银行
        bankLogoImg = [UIImage imageNamed:@"zxyh"];
    } else if ([bankCode isEqualToString:@"MYYH"]) {
        //  绵阳市商业银行
        bankLogoImg = [UIImage imageNamed:@"myssyyh"];
    } else if ([bankCode isEqualToString:@"NBYH"]) {
        //  宁波银行
        bankLogoImg = [UIImage imageNamed:@"nbyh"];
    } else if ([bankCode isEqualToString:@"GDYH"]) {
        //  光大银行
        bankLogoImg = [UIImage imageNamed:@"gdyh"];
    } else if ([bankCode isEqualToString:@"NJYH"]) {
        //  南京银行
        bankLogoImg = [UIImage imageNamed:@"njyh"];
    } else if ([bankCode isEqualToString:@"PFYH"]) {
        //  浦发银行
        bankLogoImg = [UIImage imageNamed:@"pfyh"];
    } else if ([bankCode isEqualToString:@"GYYH"]) {
        //  贵阳银行
        bankLogoImg = [UIImage imageNamed:@"gyyh"];
    } else if ([bankCode isEqualToString:@"HXYH"]) {
        //  华夏银行
        bankLogoImg = [UIImage imageNamed:@"hxyh"];
    } else if ([bankCode isEqualToString:@"JSYH"]) {
        //  建设银行
        bankLogoImg = [UIImage imageNamed:@"jsyh"];
    } else if ([bankCode isEqualToString:@"ZGYH"]) {
        //  中国银行
        bankLogoImg = [UIImage imageNamed:@"zgyh"];
    } else if ([bankCode isEqualToString:@"YZYH"]) {
        //  中国邮政
        bankLogoImg = [UIImage imageNamed:@"zgyz"];
    } else if ([bankCode isEqualToString:@"ZSYH"]) {
        //  招商银行
        bankLogoImg = [UIImage imageNamed:@"zsyh"];
    } else if ([bankCode isEqualToString:@"JTYH"]){
        //  交通银行
        bankLogoImg = [UIImage imageNamed:@"jtyh"];
    } else if ([bankCode isEqualToString:@"GSYH"]) {
        //  工商银行
        bankLogoImg = [UIImage imageNamed:@"gsyh"];
    } else if ([bankCode isEqualToString:@"MSYH"]) {
        //  民生银行
        bankLogoImg = [UIImage imageNamed:@"msyh"];
    } else if ([bankCode isEqualToString:@"SHYH"]) {
        //  上海银行
        bankLogoImg = [UIImage imageNamed:@"shyh"];
    }
    
    else {
        //  银联
        bankLogoImg = [UIImage imageNamed:@"yinlian"];
    }
    
    return bankLogoImg;
}


@end
