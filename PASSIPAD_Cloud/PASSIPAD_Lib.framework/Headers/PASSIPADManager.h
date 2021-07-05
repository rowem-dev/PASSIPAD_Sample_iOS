//
//  PASSIPADManager.h
//  OneShotPad
//
//  Created by Kim Min joung on 2021/04/28.
//  Copyright © 2021 rowem. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PASSIPADResult.h"


NS_ASSUME_NONNULL_BEGIN


//#if DEBUG
//#define SERVER_LIB_URL          @"http://13.124.69.205:8081"
//#define SERVER_LIB_SDK_SPKEY    @"http://13.124.69.205:8081/spin/spmng/reqSpEncKey"
//
//#else
//
//#define SERVER_LIB_URL          @"https://api.passipad.com"
//#define SERVER_LIB_SDK_SPKEY    @"https://api.passipad.com/spin/spmng/reqSpEncKey"
//
//#endif

#define SERVER_LIB_URL          @"https://api.passipad.com"
#define SERVER_LIB_URL_SDK_SPKEY    @"https://api.passipad.com/spin/spmng/reqSpEncKey"


@interface PASSIPADManager : NSObject



//- (void) setSignData:(NSString *)signData withPublicKey:(NSString*)publicKey withOriginalData:(NSString *)orininalData;
- (NSString *)makeSignData:(NSString *)cus_no withUsedType:(NSString *)usedType withAuthToken:(NSString *)token;


#pragma mark - Initialize

+ (instancetype)shared;

//- (void) setBaseURL:(NSString *)aUrl withAppType:(NSString *)aAppType;
- (void) setWithAppType:(NSString *)aAppType;

- (void) setPartnerCode:(NSString *)partnerNo;
- (NSString*) getPartnerCode;

#pragma mark - Check Join

- (void) reqCheckJoin:(NSString *)aCusID
       withCompletion:(void(^)(PASSIPADResult *result))completion;


- (NSString *) getCusID;

#pragma mark - Request Join

- (void) reqProcJoinEx:(NSString *)aCusNo
             withCusID:(NSString *)aCusID
          withPassword:(NSString *)aPassword
         withAuthToken:(NSString *)aAuthToken
         withPushToken:(NSString *)aPushToken
          withSPEncKey:(NSString *)aSPEncKey
        withCompletion:(void(^)(PASSIPADResult *result))completion;


- (void) updProcJoinEx:(NSDictionary *)aPushData
        withCompletion:(void(^)(PASSIPADResult *result))completion;


#pragma mark - Check Bio Auth

- (BOOL) isBioAuthSet;

- (BOOL) checkPhoneBio;
#pragma mark - Request Push

- (void) reqAuthEx:(NSString *)aCusID
      withAuthType:(NSString *)authType
    withCompletion:(void(^)(PASSIPADResult *result))completion;


#pragma mark - Auth PinPad or Bio

- (void) reqAuthPinPadEx:(NSString *)aPassword
                withCusID:(NSString *)aCusID
           withCompletion:(void(^)(PASSIPADResult *result))completion;

- (void) reqAuthBiometricEx:(NSString *)aCusID
             withCompletion:(void(^)(PASSIPADResult *result))completion;


#pragma mark - Change Password

- (void)reqChangePasswordEx:(NSString *)aCertSN
               withPassword:(NSString *)aPassword
             withCompletion:(void(^)(PASSIPADResult *result))completion;


#pragma mark - PushData

- (void) setReceivePushData:(NSDictionary *)dic_PushInfo;

- (BOOL) isReceivedPush;


@end

NS_ASSUME_NONNULL_END
