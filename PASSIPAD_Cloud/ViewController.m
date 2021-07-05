//
//  ViewController.m
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/18.
//

#import "ViewController.h"
#import "KeyPadVC.h"
#import "SettingVC.h"
#import "Common/Enums.h"
#import "AppDelegate.h"
#import <PASSIPAD_Lib/PASSIPADManager.h>
#import "CommonUtil.h"
#import "UIColor+expanded.h"

@interface ViewController () < PinPadSampleDelegate >
@property (weak, nonatomic) IBOutlet UIButton *pwdChangeButton;
@property (weak, nonatomic) IBOutlet UIButton *reqAuthButton;

@property (weak, nonatomic) IBOutlet UIButton *btBioSet;
@property (weak, nonatomic) IBOutlet UIView *bioBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onoffConstraint;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[PASSIPADManager shared] getPartnerCode] != nil)
    {
    
        NSString *cusID = [[PASSIPADManager shared] getCusID]; //키체인에 넣었기에 삭제해도 남아있는 문제 발생..
        
        // 가입 체크
        [[PASSIPADManager shared] reqCheckJoin:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {
            if( [result.code isEqualToString:@"3000"])
            {
                // NONE - 정상 사용자 && Pinpad 사용자
//                self.swBioSet.on = NO;
                self.btBioSet.selected = NO;
                [self buttonStateChange];
            }
            else if( [result.code isEqualToString:@"3015"] )
            {
                // NONE - 정상 사용자 && Pinpad + Bio 사용자
//                self.swBioSet.on = YES;
                self.btBioSet.selected = YES;
                [self buttonStateChange];
            }
            else
            {
                self.btBioSet.selected = NO;
                [CommonUtil showAlert:result.message];
                SettingVC *vc = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
                [self.navigationController pushViewController:vc animated:NO];
                

            }
        }];
    }
    else
    {
        SettingVC *vc = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
        [self.navigationController pushViewController:vc animated:NO];
        self.btBioSet.selected = NO;
        [self buttonStateChange];
    }
    
    

    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.swBioSet.on = [[PASSIPADManager shared] isBioAuthSet];
    self.btBioSet.selected = [[PASSIPADManager shared] isBioAuthSet];
    [self buttonStateChange];
}

- (void) showPinPad:(KeyboardMode)certType
{
    KeyPadVC *vc = [[KeyPadVC alloc] initWithNibName:@"KeyPadVC" bundle:nil];
    vc.keyboardMode = certType;
    [vc setDelegate:self];
    
    UINavigationController *navi = (UINavigationController*)[[AppDelegate get].window rootViewController];
    [navi presentViewController:vc animated:YES completion:nil];
}

#pragma mark -

- (void) bioSetting:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
//        UISwitch *sw = sender;
        UIButton *btn = sender;
        
        NSString *usedType = PAD_USEDTYPE_BIO_AUTH_SET;
        if( btn.isSelected )
        {
            usedType = PAD_USEDTYPE_BIO_AUTH_SET;
        }
        else
        {
            usedType = PAD_USEDTYPE_BIO_AUTH_DEL;
        }
        
        NSString *cusID = [[PASSIPADManager shared] getCusID];
        
        [[PASSIPADManager shared] reqAuthEx:cusID withAuthType:usedType withCompletion:^(PASSIPADResult *result) {
            
            if( [result.code isEqualToString:@"0000"] )
            {
                // 핀패드 띄우고
                [self showPinPad:CertMode];
            }
            else
            {
//                self.swBioSet.on = false;
                self.btBioSet.selected = false;
                [CommonUtil showAlert:result.message];
            }
            
        }];
    });
}

//- (IBAction)clickSetBioSert:(id)sender
//{
//    /*
//    [[PASSIPADManager shared]checkBioCertWithCompletion:^(BOOL bioSuccess) {
//        if( bioSuccess )
//        {
//            NSLog(@"바이오 성공");
//            [self bioSetting:sender];
//        }
//        else
//        {
//            NSLog(@"바이오 없거나 설정 안되어 있음");
//            [CommonUtil showAlert:@"바이오 지원을 할 수 없는 단말기 이거나 바이오 등록을 해주세요."];
//            self.swBioSet.on = false;
//        }
//    }];
//     */
//    bool *bioCheck = [[PASSIPADManager shared] checkPhoneBio];
//    if (bioCheck == false) {
//        [CommonUtil showAlert:@"기기에 생체인증이 등록되어있지 않음"];
//        [_swBioSet setOn:false];
//        return;
//    }
//
//    UISwitch *sw = sender;
//
//    NSString *usedType = PAD_USEDTYPE_BIO_AUTH_SET;
//    if( sw.on )
//    {
//        usedType = PAD_USEDTYPE_BIO_AUTH_SET;
//
//    }
//    else
//    {
//        usedType = PAD_USEDTYPE_BIO_AUTH_DEL;
//
//
//    }
//
//    NSString *cusID = [[PASSIPADManager shared] getCusID];
//
//    [[PASSIPADManager shared] reqAuthEx:cusID withAuthType:usedType withCompletion:^(PASSIPADResult *result) {
//
//        if( [result.code isEqualToString:@"0000"] )
//        {
//            // 핀패드 띄우고
//            [self showPinPad:CertMode];
//        }
//        else
//        {
//            self.swBioSet.on = false;
//            [CommonUtil showAlert:result.message];
//        }
//
//    }];
//}

- (IBAction)clickSetBioBtn:(id)sender {
    
    BOOL bioCheck = [[PASSIPADManager shared] checkPhoneBio];
    if (bioCheck == false) {
        [CommonUtil showAlert:@"기기에 생체인증이 등록이 되어있지 않거나 지원되지 않는 기기입니다."];
        _btBioSet.selected = NO;
        return;
    }
    
    UIButton *btn = sender;
    NSString *usedType = PAD_USEDTYPE_BIO_AUTH_SET;
    //버튼의 현재상태 확인
    if(btn.isSelected == NO)
    {
        usedType = PAD_USEDTYPE_BIO_AUTH_SET;
    }
    else
    {
        usedType = PAD_USEDTYPE_BIO_AUTH_DEL;
    }
    
    

    NSString *cusID = [[PASSIPADManager shared] getCusID];

    [[PASSIPADManager shared] reqAuthEx:cusID withAuthType:usedType withCompletion:^(PASSIPADResult *result) {

        if( [result.code isEqualToString:@"0000"] )
        {
            // 핀패드 띄우고
            [self showPinPad:CertMode];
            self.btBioSet.selected = ! self.btBioSet.selected;
            [self buttonStateChange];
        }
        else
        {
//            self.swBioSet.on = false;
            self.btBioSet.selected = false;
            [CommonUtil showAlert:result.message];
        }

    }];

}


- (IBAction)clickTransferBtn:(id)sender {
    
    NSString *cusID = [[PASSIPADManager shared] getCusID];
    
    if( self.btBioSet.isSelected )
    {
        [[PASSIPADManager shared] reqAuthEx:cusID withAuthType:PAD_USEDTYPE_BIO_AUTH withCompletion:^(PASSIPADResult *result) {

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
    }
    else
    {
        [[PASSIPADManager shared] reqAuthEx:cusID withAuthType:PAD_USEDTYPE_LOGIN withCompletion:^(PASSIPADResult *result) {

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
    }
    
}

- (IBAction)clickPwdChangeButton:(id)sender
{
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
    
}

- (IBAction)clickMyPageBtn:(id)sender
{
    SettingVC *vc = [[SettingVC alloc] initWithNibName:@"SettingVC" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark -
- (void) checkBioAuth
{
    if( [[PASSIPADManager shared] isBioAuthSet])
    {
        NSString *cusID = [[PASSIPADManager shared] getCusID];
        
        [[PASSIPADManager shared] reqAuthBiometricEx:cusID withCompletion:^(PASSIPADResult * _Nonnull result) {

            if( [result.code isEqualToString:@"0000"] )
            {
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
    }
}



#pragma mark - PinPadSampleDelegate

- (void) recvChangeSPinPadPassword:(NSString*)pw
{
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
            
            NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/verify", SERVER_URL];
            
            [CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
                
                [CommonUtil showAlert:result.message];
                
            }];
        }
        else
        {
            [CommonUtil showAlert:result.message];
        }
        
    }];
    
}


- (void) recvSPinPadPassword:(NSString*)pw isJoin:(BOOL)join
{
    if( join )
        return;
        
    if( [[PASSIPADManager shared] isReceivedPush] != NO )
    {
        NSString *cusID = [[PASSIPADManager shared] getCusID];
        
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
                    
                    NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/verify", SERVER_URL];
                    
                    [CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
                        
                        [CommonUtil showAlert:@"인증 성공하였습니다."];
                        
                    }];

                }
                else if( [result.usedType isEqualToString:PAD_USEDTYPE_CHANGEPW] )
                {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        // 핀패드 띄우고
//                        [self showPinPad:ChangeSetMode];
//                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self showPinPad:ChangeSetMode];
                    });
                }
                else if( [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH_SET])
                {
                    [CommonUtil showAlert:@"생체인증이 설정되었습니다."];
                    self.btBioSet.selected = [[PASSIPADManager shared] isBioAuthSet];
                    [self buttonStateChange];
                }
                else if( [result.usedType isEqualToString:PAD_USEDTYPE_BIO_AUTH_DEL] )
                {
                    [CommonUtil showAlert:@"생체인증이 해제되었습니다."];
                    self.btBioSet.selected = [[PASSIPADManager shared] isBioAuthSet];
                    [self buttonStateChange];
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CommonUtil showAlert:result.message];
                    self.btBioSet.selected = [[PASSIPADManager shared] isBioAuthSet];
                    [self buttonStateChange];
                });
            }
        }];
    }

}

- (void) pinPadUserCancel
{
    NSLog(@"pinPadUserCancel");
    //핀패드 사용자 취소 할 경우 이전 값 처리 해야 함.
    self.btBioSet.selected =  [[PASSIPADManager shared] isBioAuthSet];
    [self buttonStateChange];
}

-(void)buttonStateChange
{
    if (_btBioSet.isSelected) {
        _onoffConstraint.constant = 17;
        _bioBarView.backgroundColor = [UIColor colorWithHexString:@"5DC1FF"];
    }
    else
    {
        _onoffConstraint.constant = -17;
        _bioBarView.backgroundColor = [UIColor colorWithHexString:@"CBCBCB"];
    }
}

@end
