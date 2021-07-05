//
//  KeyPadVC.h
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/19.
//

#import <UIKit/UIKit.h>
#import "Common/Enums.h"


NS_ASSUME_NONNULL_BEGIN


@protocol PinPadSampleDelegate <NSObject>
@optional

- (void) recvSPinPadPassword:(NSString*)pw isJoin:(BOOL)join;   // 가입, 인증
- (void) recvChangeSPinPadPassword:(NSString*)pw;               // 비밀번호 변경

- (void) pinPadUserCancel;

@end
@interface KeyPadVC : UIViewController
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) KeyboardMode keyboardMode;


@end

NS_ASSUME_NONNULL_END
