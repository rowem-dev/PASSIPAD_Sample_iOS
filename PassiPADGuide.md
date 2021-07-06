# IOS SDK 적용하기 


## 프로젝트에 SDK 적용


1.   제휴사 Project 폴더 >  PASSIPAD_Lib.framework 파일을  복사합니다.
// https://admin.passipad.com/download/sample?tab=sdk 경로에서 SDK 다운로드 합니다.

2.   Project > TARGETS > Build Phases > Link Binary With Libraries 에서 PASSIPAD_Lib.framework 추가합니다.



## SDK 초기화
1. AppDelegate Source Code

- objective - c
``` objc
.m
#import <PASSIPAD_Lib/PASSIPADManager.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ..
    ..
    //푸쉬 알림 등록 필수 
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound |
                                                                                             UIUserNotificationTypeAlert)
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    // 이전 파트너사 등록이 되어 있는 경우 설정
    NSString *partnerCode = [[PASSIPADManager shared] getPartnerCode];
    if(partnerCode != nil)
        [[PASSIPADManager shared] setWithAppType:[NSString stringWithFormat:@"%@",partnerCode]];
  
    return YES;
}

//APNS에 장치 등록 성공시 호출되는 콜백
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSMutableString *deviceId = [NSMutableString string];
    const unsigned char* ptr = (const unsigned char*) [deviceToken bytes];
    
    for(NSInteger i = 0 ; i < 32 ; i++)
    {
        [deviceId appendFormat:@"%02x", ptr[i]];
    }
    
    NSLog(@"Token : %@", deviceId);
    [[NSUserDefaults standardUserDefaults] setObject:deviceId forKey:@"pushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
}

//push 수신 후 데이터 처리 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{

    application.applicationIconBadgeNumber = 0;

    [CommonUtil showAlert:@"Push가 수신되었습니다"];


    NSLog(@"didReceiveRemoteNotification userInfo : %@", userInfo);

    NSString *str_Val = [userInfo objectForKey:@"spinpad"];
    if( str_Val && str_Val.length > 0 )
    {
        NSError *error = nil;

        NSData *data = [str_Val dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic_Val = [NSJSONSerialization JSONObjectWithData:data
                                                                options:kNilOptions
                                                                  error:&error];
        id spinPad = [dic_Val objectForKey:@"spinpad"];
        if( spinPad != nil )
        {
            data = [spinPad dataUsingEncoding:NSUTF8StringEncoding];
            dic_Val = [NSJSONSerialization JSONObjectWithData:data
                                                      options:kNilOptions
                                                        error:&error];

            NSLog(@"spinpad pushInfo : %@", dic_Val);

            [[PASSIPADManager shared] setReceivePushData:dic_Val];

            UINavigationController *navi = (UINavigationController*)[[AppDelegate get].window rootViewController];

            ViewController *controller = (ViewController*)navi.topViewController;
            if( [controller respondsToSelector:@selector(checkBioAuth)] )
                [controller checkBioAuth];

        }
    }
}

```  

## 고객사 API 설명
1. SP키 및 인증토큰 요청
- 패시패드 가입전 sp코드와 인증토큰을 요청합니다.
- sp코드와 인증토큰은 고객사에서 발행하며 이 api는 개발및 테스트용으로 사용됩니다.

URL : http://고객사서버/spin/spmng/reqSpEncKey (고객사 서버)

NSMutableDictionary *dic = [NSMutableDictionary dictionary];
[dic setObject:self.tf_UserID.text               forKey:@"cus_no"]; //사용자 id
[dic setObject:PAD_USEDTYPE_JOIN        forKey:@"used_type"]; //가입 타입
[dic setObject:self.tf_PartnerCode.text        forKey:@"app_type"]; // 고객 제휴사 id

NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/reqSpEncKey", SERVER_URL];

[CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {

    NSString *authToken  = [result.dic objectForKey:@"auth_token"];
    NSString *spEncKey   = [result.dic objectForKey:@"sp_enc_key"];
    NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
}];

2. 전자 서명 검증 요청  
- 패시패드의 전자 서명을 검증 합니다.
- 고객사의 전자서명 검증 요청용으로 개발되었으며 개발및 테스트용으로 사용됩니다.

// 로그인 또는 비밀번호 요청 api에서 받은 결과값을 사용합니다.  
NSMutableDictionary *dic = [NSMutableDictionary dictionary];
[dic setObject:cusID       forKey:@"cus_id"];
[dic setObject:result.authToken         forKey:@"auth_token"];
[dic setObject:result.sign              forKey:@"sign"];
[dic setObject:result.signText          forKey:@"sign_text"];

NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/verify", SERVER_URL];
[CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
    
    // 성공 실패 확인 
    
}];


## 라이브러리 API 설명
/*
//LIB API 타입
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
*/

1. 가입
- 패시패드 가입 요청.
- 본 api는 전자서명 값을 필요로 합니다.

//고개사 spin/spmng/reqSpEncKey통한 값을 이용하여 가입합니다. 
[[PASSIPADManager shared] reqProcJoinEx:self.tf_UserID.text withCusID:self.tf_UserID.text withPassword:pw withAuthToken:authToken withPushToken:pushToken withSPEncKey:spEncKey withCompletion:^(PASSIPADResult * _Nonnull result) {
    
    // 가입 완료
    if( [result.code isEqualToString:@"0000"] )
    {
       // 가입완료 
        [[PASSIPADManager shared] setPartnerCode: self.tf_PartnerCode.text];
    }
    else
    {
        //실패 메시지 
    }
}];

2. 가입 체크 
- 패시패드 가입전 사용자의 가입 상태를 체크합니다.
- api의 결과에 따라 가입 여부를 판단 합니다.

[[PASSIPADManager shared] getPartnerCode] // 등록된 고객사 체크 
NSString *cusID = [[PASSIPADManager shared] getCusID]; // 사용자 ID
[[PASSIPADManager shared] reqCheckJoin:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {
    if( [result.code isEqualToString:@"3000"])
    {
        // NONE - 정상 사용자 && Pinpad 사용자
    }
    else if( [result.code isEqualToString:@"3015"] )
    {
        // NONE - 정상 사용자 && Pinpad + Bio 사용자
    }
    else
    {   
        //가입 화면으로 이동처리 

    }
}];


3. 로그인 -핀패드 이용 시
- 인증용 푸시를 요청 합니다.
- 서버는 요청 정보를 바탕으로 기기에 푸시로 인증에 필요한 정보를 발송 합니다.

//로그인 푸쉬 api 호출
[[PASSIPADManager shared] reqAuthEx:cusID withAuthType:PAD_USEDTYPE_LOGIN withCompletion:^(PASSIPADResult *result) {

    if( [result.code isEqualToString:@"0000"] )
    {
        // 핀패드 활성화 
        [self showPinPad:CertMode];
        
    }
    else
    {
        //에러 메시지 
    }
    
}];

3 - 1 로그인 - 핀패드 확인
- 푸시데이터를 바탕으로 인증을 확인합니다.

// 핀패드 입력 후 인증 체크 
[[PASSIPADManager shared] reqAuthPinPadEx:pw withCusID:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {
    
    if( [result.code isEqualToString:@"0000"] )
    {
        if( [result.usedType isEqualToString:PAD_USEDTYPE_LOGIN] ||
            [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH] ||
            [result.usedType isEqualToString:PAD_USEDTYPE_AUTH]  ||
            [result.usedType isEqualToString:PAD_USEDTYPE_TEMINATE] )
        {
            // 기간계 전자서명 검증 요청 API
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:cusID       forKey:@"cus_id"];
            [dic setObject:result.authToken         forKey:@"auth_token"];
            [dic setObject:result.sign              forKey:@"sign"];
            [dic setObject:result.signText          forKey:@"sign_text"];
            
            //고객사 전자 서명 체크 
            NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/verify", SERVER_URL];
            [CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
                
                [CommonUtil showAlert:@"인증 성공하였습니다."];
                
            }];

        }
    }
        ...
    }];    

4 - 1.  로그인  - 생체인증 로그인 이용 시 
- 인증용 푸시를 요청 합니다.
- 서버는 요청 정보를 바탕으로 기기에 푸시로 인증에 필요한 정보를 발송 합니다.

//생체 인증 로그인 푸쉬 api 호출
[[PASSIPADManager shared] reqAuthEx:cusID withAuthType:PAD_USEDTYPE_BIO_AUTH withCompletion:^(PASSIPADResult *result) {

    if( [result.code isEqualToString:@"0000"] )
    {
        // 핀패드 활성화 
        [self showPinPad:CertMode];
    }
    else
    {
      //에러 메시지 
    }
    
}];

4 - 2. 로그인 - 생체인증 로그인 확인
- 푸시데이터를 바탕으로 생체인증을 확인합니다.

// 4-1에서 받은 push  메시지 후 처리 
NSString *cusID = [[PASSIPADManager shared] getCusID];

[[PASSIPADManager shared] reqAuthBiometricEx:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {

    if( [result.code isEqualToString:@"0000"] )
    {
        //핀패드 dismiss
        UINavigationController *navi = (UINavigationController*)[[AppDelegate get].window rootViewController];
        KeyPadVC *vc = navi.presentedViewController;
        [vc dismissViewControllerAnimated:YES completion:^{
            [CommonUtil showAlert:@"생체인증 성공"];
        }];
    }
    else
    {
        
    }
}];

5. 패스워드 변경 
- 인증용 푸시를 요청 합니다.
- 서버는 요청 정보를 바탕으로 기기에 푸시로 인증에 필요한 정보를 발송 합니다.

//패스워드 변경을 위한 푸쉬 api 호출
NSString *cusID = [[PASSIPADManager shared] getCusID];
[[PASSIPADManager shared] reqAuthEx:cusID withAuthType:PAD_USEDTYPE_CHANGEPW withCompletion:^(PASSIPADResult *result) {

    if( [result.code isEqualToString:@"0000"] )
    {
        // 핀패드 띄우고
        [self showPinPad:CertMode];
    }
    else
    {
        [CommonUtil showAlert:result.message];
    }
    
}];

5 - 1 패스워드 변경 확인
- 비밀번호 변경을 요청 합니다.
- 본 api는 전자서명 값을 필요로 합니다.

// 핀패드 입력 후 인증 체크 
NSString *cusID = [[PASSIPADManager shared] getCusID];
[[PASSIPADManager shared] reqChangePasswordEx:cusID withPassword:pw withCompletion:^(PASSIPADResult * _Nonnull result) {
    
    if( [result.code isEqualToString:@"0000"] )
    {
        // 기간계 전자서명 검증 요청 API
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:cusID       forKey:@"cus_id"];
        [dic setObject:result.authToken         forKey:@"auth_token"];
        [dic setObject:result.sign              forKey:@"sign"];
        [dic setObject:result.signText          forKey:@"sign_text"];
        
        //고객사 인증 체크 
        NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/verify", SERVER_URL];        
        [CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
            
           // 성공 메시지 
            
        }];
    }
    else
    {
        //에러 메시지 
    }
    
}]; 


6. 바이오 등록/해제
- 인증용 푸시를 요청 합니다.
- 서버는 요청 정보를 바탕으로 기기에 푸시로 인증에 필요한 정보를 발송 합니다.

// 바이오 설정을 위한 푸쉬 api 호출
NSString *usedType = PAD_USEDTYPE_BIO_AUTH_SET;
//버튼의 현재상태 확인
if(btn.isSelected == NO)
{
    usedType = PAD_USEDTYPE_BIO_AUTH_SET; // 등록
}
else
{
    usedType = PAD_USEDTYPE_BIO_AUTH_DEL; //해제
}

NSString *cusID = [[PASSIPADManager shared] getCusID];
[[PASSIPADManager shared] reqAuthEx:cusID withAuthType:usedType withCompletion:^(PASSIPADResult *result) {

    if( [result.code isEqualToString:@"0000"] )
    {
        // 핀패드 활성화 
        [self showPinPad:CertMode];
        self.btBioSet.selected = ! self.btBioSet.selected;
        [self buttonStateChange];
    }
    else
    {
        // 에러 메시지 
    }

}];

6 - 1 바이오 등록/해제 확인
-푸시데이터를 바탕으로 생체인증을 확인합니다.
 
NSString *cusID = [[PASSIPADManager shared] getCusID];
[[PASSIPADManager shared] reqAuthPinPadEx:pw withCusID:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {
    
    if( [result.code isEqualToString:@"0000"] )
    {
        if( [result.usedType isEqualToString:PAD_USEDTYPE_LOGIN] ||
            [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH] ||
            [result.usedType isEqualToString:PAD_USEDTYPE_AUTH]  ||
            [result.usedType isEqualToString:PAD_USEDTYPE_TEMINATE] )
            {
        ...
        }
        else if( [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH_SET])
        {
            //생체인증 등록 처리 

        }
        else if( [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH_DEL] )
        {
            //생체인증 해제 처리 
        }

}];




- 성공 및 오류 코드 내역

#define OSPAD_OK                    @"0000"     // 성공

/* 1xxx 번대 : 단말에서 발생하는 오류 코드 */

#define OSPAD_LIB_PARAM             @"1000"
#define OSPAD_LIB_PARAM_MSG         @"기본 파라미터 오류"

#define OSPAD_PASSWORD_LENGTH       @"1001"
#define OSPAD_PASSWORD_LENGTH_MSG   @"패스워드 길이 오류"       // 4자리 숫자.

#define OSPAD_TIMEOUT                @"1004"
#define OSPAD_TIMEOUT_MSG           @"타임아웃 오류"

#define OSPAD_DATA_PARSE            @"1101"
#define OSPAD_DATA_PARSE_MSG        @"데이터 파싱 오류"

#define OSPAD_DATA_ENCDEC            @"1102"
#define OSPAD_DATA_ENCDEC_MSG       @"데이터 암복호화 오류"

#define OSPAD_EMPTY_CERT            @"1200"
#define OSPAD_EMPTY_CERT_MSG        @"인증서 미존재"

#define OSPAD_CERT_PW_ERR            @"1201"
#define OSPAD_CERT_PW_ERR_MSG       @"인증서 암호 오류"

#define OSPAD_CERT_PW_SAFE            @"1202"
#define OSPAD_CERT_PW_SAFE_MSG      @"인증서 암호 보호 실패"

#define OSPAD_NEW_CERT_PW_SAFE        @"1203"
#define OSPAD_NEW_CERT_PW_SAFE_MSG  @"간편인증 인증서 암호 보호 실패"

#define OSPAD_NEW_CERT_SAVE         @"1204"
#define OSPAD_NEW_CERT_SAVE_MSG     @"인증서 정보가 일치하지 않습니다."

#define OSPAD_EMPTY_NEW_CERT        @"1205"
#define OSPAD_EMPTY_NEW_CERT_MSG    @"간편인증 인증서 미존재"

#define OSPAD_NEW_CERT_PW_CHANGE     @"1206"
#define OSPAD_NEW_CERT_PW_CHANGE_MSG @"간편인증 인증서 암호 변경 실패"

#define OSPAD_NEW_CERT_PW_ERR        @"1207"
#define OSPAD_NEW_CERT_PW_ERR_MSG   @"간편인증 인증서 암호 오류"

#define OSPAD_PUSH_NOTI_UNREGIST     @"1300"
#define OSPAD_PUSH_NOTI_UNREGIST_MSG @"서비스 이용을 위해 알림허용을 한 후 다시 이용해 주시기 바랍니다.\n(설정 > 알림 > XXX 알림 허용)"

#define OSPAD_NO_PUSH_DATA          @"1301"
#define OSPAD_NO_PUSH_DATA_MSG      @"푸쉬 데이터 미수신"

#define OSPAD_3TABLE_CREATE_ERROR      @"1400"
#define OSPAD_3TABLE_CREATE_ERROR_MSG  @"3차테이블 생성 오류"

#define OSPAD_3TABLE_NOT_EXIST      @"1401"
#define OSPAD_3TABLE_NOT_EXIST_MSG  @"3차테이블 미존재"

#define OSPAD_3TABLE_DECRYPT_ERROR      @"1402"
#define OSPAD_3TABLE_DECRYPT_ERROR_MSG  @"3차테이블 복호화 오류"

//coldshop
#define OSPAD_NOT_MATCH_CERT_JOIN      @"1501"
#define OSPAD_NOT_MATCH_CERT_JOIN_MSG  @"가입 당시 공인인증서와 일치하지 않습니다."  // 인증서 갱신 or 재발급시

#define OSPAD_NETWORK_ERR           @"1998"
#define OSPAD_NETWORK_ERR_MSG       @"네트워크 오류"

#define OSPAD_LIB_UNKNOWN            @"1999"
#define OSPAD_LIB_UNKNOWN_MSG       @"기타 오류"

#define OSPAD_BIO_SET_OK            @"1600"
#define OSPAD_BIO_SET_OK_MSG        @"바이오 인증 설정 성공"

#define OSPAD_BIO_SET_FAIL            @"1601"
#define OSPAD_BIO_SET_FAIL_MSG        @"바이오 인증 설정 실패"

#define OSPAD_BIO_AUTH_FAIL             @"1602"
#define OSPAD_BIO_AUTH_FAIL_MSG        @"바이오 인증 실패"



