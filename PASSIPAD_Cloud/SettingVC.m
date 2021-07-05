//
//  SettingVC.m
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/19.
//

#import "SettingVC.h"
#import "UIColor+expanded.h"
#import <PASSIPAD_Lib/PASSIPADManager.h>
#import "KeyPadVC.h"
#import "AppDelegate.h"
#import "CommonUtil.h"

@interface SettingVC ()<UITextFieldDelegate>
//@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lb_ErrorMsg;
@property (weak, nonatomic) IBOutlet UITextField *tf_PartnerCode;
@property (weak, nonatomic) IBOutlet UITextField *tf_UserID;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@end
 
@implementation SettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tf_PartnerCode.placeholder =@"코드를 입력해주세요.";
    self.tf_UserID.placeholder =@"ID를 입력해주세요.";
    
    self.lb_Title.text = @"가입";
    self.lb_SubTitle.text =@"가입정보를 입력해주세요";
    [self.lb_ErrorMsg setHidden:YES];
    self.lb_ErrorMsg.textColor = [UIColor colorWithHexString:@"ED1E1E"];
    
    self.confirmButton.layer.cornerRadius = 10;
    [self.confirmButton setEnabled:NO];
    
}

//파트너코드 텍스트필드 입력시
- (IBAction)actionPartnerEditChange:(id)sender
{
    
    if (_tf_PartnerCode.text.length > 0 && _tf_UserID.text.length > 0) {
        self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"5DC1FF"];
        [self.confirmButton setEnabled:YES];
    }
    else
    {
        self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"E0E0E0"];
    }
    
}

//회원id 텍스트필드 입력시
- (IBAction)actionUserIdEditChange:(id)sender
{
    if (_tf_PartnerCode.text.length > 0 && _tf_UserID.text.length > 0) {
        self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"5DC1FF"];
        [self.confirmButton setEnabled:YES];
    }
    else
    {
        self.confirmButton.backgroundColor = [UIColor colorWithHexString:@"E0E0E0"];
    }
}

//뒤로가기(화살표)버튼
- (IBAction)actionBackButton:(id)sender
{
    //popviewcontroller 는 뒤로가기개념
    [self.navigationController popViewControllerAnimated:true];
}

//키보드 내릴때
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

- (IBAction)clickConfirmButton:(id)sender
{
    if(self.tf_PartnerCode.text.length > 0)
        [[PASSIPADManager shared] setWithAppType:[NSString stringWithFormat:@"%@",self.tf_PartnerCode.text]];
    else
    {
        [CommonUtil showAlert:@"파트너 코드를 입력해주세요."];
        return;
    }
    
    if(self.tf_UserID.text.length < 1)
    {
        [CommonUtil showAlert:@"아이디를 입력해주세요."];
        return;
    }
    
    KeyPadVC * keyVc = [[KeyPadVC alloc] initWithNibName:@"KeyPadVC" bundle:nil];
    keyVc.keyboardMode =SetMode;
    [keyVc setDelegate:self];
    [self.navigationController presentViewController:keyVc animated:YES completion:nil];
}

#pragma mark -
- (void) recvSPinPadPassword:(NSString*)pw isJoin:(BOOL)join
{
    if( join ) // 가입
    {
        
        // 기간계 SMS 인증 확인 요청 API
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self.tf_UserID.text               forKey:@"cus_no"];
        [dic setObject:PAD_USEDTYPE_JOIN        forKey:@"used_type"];
        //[dic setObject:PASSIPAD_APP_TYPE             forKey:@"app_type"];
        [dic setObject:self.tf_PartnerCode.text        forKey:@"app_type"];
        
        NSString *serverIP = [NSString stringWithFormat:@"%@/spin/spmng/reqSpEncKey", SERVER_URL];
        
        [CommonUtil PostNetManager:serverIP withMethod:@"POST" withParam:dic withCompletion:^(PASSIPADResult *result) {
            
            
            
            NSString *authToken  = [result.dic objectForKey:@"auth_token"];
            NSString *spEncKey   = [result.dic objectForKey:@"sp_enc_key"];
            NSString *pushToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"pushToken"];
            
            
            [[PASSIPADManager shared] setPartnerCode: self.tf_PartnerCode.text];
         
            [[PASSIPADManager shared] reqProcJoinEx:self.tf_UserID.text withCusID:self.tf_UserID.text withPassword:pw withAuthToken:authToken withPushToken:pushToken withSPEncKey:spEncKey withCompletion:^(PASSIPADResult * _Nonnull result) {
                
                // 가입 완료
                if( [result.code isEqualToString:@"0000"] )
                {
                    [CommonUtil showAlert:@"가입완료"];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                else
                {
                    [CommonUtil showAlert:result.message];
                }
            }];
            
        }];
        
    }
    else // 로그인
    {
        
    }

}
@end
