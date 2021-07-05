//
//  CommonUtil.h
//  PASSIPAD_Cloud
//
//  Created by Kim Min joung on 2021/05/24.
//

#import <Foundation/Foundation.h>
#import <PASSIPAD_Lib/PASSIPADManager.h>


NS_ASSUME_NONNULL_BEGIN

@interface CommonUtil : NSObject


#pragma mark - UserDefault

+ (BOOL)setUserDefault:(id)value forKey:(NSString*)key;

+ (id)getUserDefault:(NSString*)key;


#pragma mark -
+ (void) PostNetManager:(NSString *)url withMethod:(NSString *)httpMethod withParam:(NSMutableDictionary*)dic withCompletion:(void(^)(PASSIPADResult *result))completion;


#pragma mark -
+ (void) showAlert:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
