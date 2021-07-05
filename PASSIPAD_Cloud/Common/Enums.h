//
//  Enums.h
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/20.
//

#ifndef Enums_h
#define Enums_h
typedef NS_ENUM(NSInteger, KeyboardMode) {
    SetMode = 0,        // 처음 비밀번호를 세팅할 때 사용 (사용자에게 비밀번호를 두번 입력 받음)
    CertMode,           // 인증할 때 사용
    
    ChangeCertMode,     // 비밀번호 변경용으로 인증할 때
    ChangeSetMode,      // 비밀번호 변경용으로 세팅할 떄
};


#endif /* Enums_h */
