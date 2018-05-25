

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void(^BankLogoAndNameBlock) (UIImage *logoImage,NSString *bankCode,NSString *bankName);
@interface BankLogoImageModel : NSObject

+ (NSArray *)getChineseBankNameArray;

+ (void)bankLogoWithBankCode:(NSString *)bankName block:(BankLogoAndNameBlock)block;

+ (UIImage *)bankLogoWithBankCode:(NSString *)bankCode;

@end
