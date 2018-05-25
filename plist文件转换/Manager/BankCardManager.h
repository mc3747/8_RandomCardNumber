

#import <Foundation/Foundation.h>
typedef void (^BankCardBlock) (NSString *bankCardNum,NSString *cardType);
@interface BankCardManager : NSObject
+ (void)getBankName:(NSString *)bankName numberLengthInt:(int )numberLengthInt block:(BankCardBlock)block;
@end
