

#import <Foundation/Foundation.h>
typedef void (^IDCardBlock) (NSString *cardNum,NSString *address,NSString *gender);
@interface IDCardManager : NSObject
@property (nonatomic, copy) IDCardBlock block;
+ (void)getCardInformationWith:(IDCardBlock)block;
@end
