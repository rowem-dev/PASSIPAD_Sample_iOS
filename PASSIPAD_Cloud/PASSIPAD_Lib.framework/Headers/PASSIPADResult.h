//
//  PASSIPADResult.h
//  OneShotPad
//
//  Created by Kim Min joung on 2021/04/28.
//  Copyright © 2021 rowem. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define PAD_USEDTYPE_CHECK_JOIN         @"0"        // 설정 상태 체크

#define PAD_USEDTYPE_JOIN               @"1"        // 푸쉬 프로세스 타입 - 가입
#define PAD_USEDTYPE_LOGIN              @"2"        // 푸쉬 프로세스 타입 - 로그인
#define PAD_USEDTYPE_AUTH               @"3"        // 푸쉬 프로세스 타입 - 인증
#define PAD_USEDTYPE_CHANGEPW           @"4"        // 푸쉬 프로세스 타입 - 비밀번호 변경
#define PAD_USEDTYPE_TEMINATE           @"5"        // 푸쉬 프로세스 타입 - 해지
#define PAD_USEDTYPE_PUSHTOKEN_UPDATE   @"6"        // 푸쉬 프로세스 타입 - 푸쉬토큰 업데이트
#define PAD_USEDTYPE_ADD_ID             @"7"        // 푸쉬 프로세스 타입 - ID 추가 등록
#define PAD_USEDTYPE_BIO_AUTH_SET       @"8"        // 푸쉬 프로세스 타입 - 생체인증 가입 요청
#define PAD_USEDTYPE_BIO_AUTH           @"9"        // 푸쉬 프로세스 타입 - 생체 인증
#define PAD_USEDTYPE_BIO_AUTH_DEL       @"10"       // 푸시 프로세스 타입 - 생체 인증 해지 요청


@interface PASSIPADResult : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *usedType;

@property (nonatomic, strong) NSDictionary *dic;

@property (nonatomic, strong) NSString *authToken;
@property (nonatomic, strong) NSString *sign;           
@property (nonatomic, strong) NSString *signText;



- (id) initWithResult:(NSDictionary *)dic;


+ (PASSIPADResult *) PASSIPADResultSuccess;


#pragma mark - 오류 Result
+ (PASSIPADResult *) PASSIPADResultError:(NSString *)errorCode;


@end

NS_ASSUME_NONNULL_END
