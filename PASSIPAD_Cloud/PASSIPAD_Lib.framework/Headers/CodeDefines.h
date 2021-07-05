//
//  CodeDefines.h
//  
//
//  Created by Min joungKim on 2016. 6. 30..
//  Copyright (c) 2016년 rowem. All rights reserved.
//

#import <Foundation/Foundation.h>



//#define OSPAD_COSCOM_LABEL @"OneShotPadCert"
//



#define OSPAD_OK					@"0000"     // 성공





/* 1xxx 번대 : 단말에서 발생하는 오류 코드 */


#define OSPAD_LIB_PARAM             @"1000"
#define OSPAD_LIB_PARAM_MSG         @"기본 파라미터 오류"

#define OSPAD_PASSWORD_LENGTH       @"1001"
#define OSPAD_PASSWORD_LENGTH_MSG   @"패스워드 길이 오류"       // 4자리 숫자.

#define OSPAD_TIMEOUT				@"1004"
#define OSPAD_TIMEOUT_MSG           @"타임아웃 오류"

#define OSPAD_DATA_PARSE			@"1101"
#define OSPAD_DATA_PARSE_MSG        @"데이터 파싱 오류"

#define OSPAD_DATA_ENCDEC			@"1102"
#define OSPAD_DATA_ENCDEC_MSG       @"데이터 암복호화 오류"

#define OSPAD_EMPTY_CERT			@"1200"
#define OSPAD_EMPTY_CERT_MSG        @"인증서 미존재"

#define OSPAD_CERT_PW_ERR			@"1201"
#define OSPAD_CERT_PW_ERR_MSG       @"인증서 암호 오류"

#define OSPAD_CERT_PW_SAFE			@"1202"
#define OSPAD_CERT_PW_SAFE_MSG      @"인증서 암호 보호 실패"

#define OSPAD_NEW_CERT_PW_SAFE		@"1203"
#define OSPAD_NEW_CERT_PW_SAFE_MSG  @"간편인증 인증서 암호 보호 실패"

#define OSPAD_NEW_CERT_SAVE         @"1204"
#define OSPAD_NEW_CERT_SAVE_MSG     @"인증서 정보가 일치하지 않습니다."

#define OSPAD_EMPTY_NEW_CERT		@"1205"
#define OSPAD_EMPTY_NEW_CERT_MSG    @"간편인증 인증서 미존재"

#define OSPAD_NEW_CERT_PW_CHANGE	 @"1206"
#define OSPAD_NEW_CERT_PW_CHANGE_MSG @"간편인증 인증서 암호 변경 실패"

#define OSPAD_NEW_CERT_PW_ERR		@"1207"
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

#define OSPAD_LIB_UNKNOWN			@"1999"
#define OSPAD_LIB_UNKNOWN_MSG       @"기타 오류"

#define OSPAD_BIO_SET_OK            @"1600"
#define OSPAD_BIO_SET_OK_MSG        @"바이오 인증 설정 성공"

#define OSPAD_BIO_SET_FAIL            @"1601"
#define OSPAD_BIO_SET_FAIL_MSG        @"바이오 인증 설정 실패"

#define OSPAD_BIO_AUTH_FAIL             @"1602"
#define OSPAD_BIO_AUTH_FAIL_MSG        @"바이오 인증 실패"

