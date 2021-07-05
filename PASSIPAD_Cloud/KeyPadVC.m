//
//  KeyPadVC.m
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/19.
//

#import "KeyPadVC.h"
#import "Common/Enums.h"
#import "Common/CommonUtil.h"
#import "UIColor+expanded.h"



static CGFloat sfKeyPadButtonGap = 2.0f;

@interface KeyPadVC ()
//키패드
@property (nonatomic, strong) NSString *str_BeforePw;
@property (nonatomic, strong) NSMutableArray *arM_InputData;
@property (weak, nonatomic) IBOutlet UIView *v_Pad;
@property (weak, nonatomic) IBOutlet UILabel *lb_ErrorMsg;
@property (weak, nonatomic) IBOutlet UIView *v_CertButton;
@property (weak, nonatomic) IBOutlet UILabel *lb_Title;
@property (weak, nonatomic) IBOutlet UILabel *lb_SubTitle;


@end

@implementation KeyPadVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.arM_InputData = [NSMutableArray arrayWithCapacity:4];  //할당된 메모리를 반환
    [self viewPad:self.keyboardMode];
    
    [self.lb_ErrorMsg setHidden:YES];
    
}

//핀패드만 보이게해보자
-(void)viewPad:(KeyboardMode)mode
{
    self.keyboardMode = mode;
    NSLog(@"KeyBoard_Mode : %ld",(long)mode);
    [self.arM_InputData removeAllObjects];
    
    if( self.keyboardMode == SetMode || self.keyboardMode == ChangeSetMode )
    {
        //셋 모드일 경우 두번 입력 받음
        self.lb_Title.text = @"비밀번호 입력";
        self.lb_SubTitle.text = @"설정한 비밀번호를 입력해주세요.";
    }
    else
    {
        //인증 모드
        self.lb_Title.text = @"비밀번호 입력";
        self.lb_SubTitle.text = @"기존 비밀번호를 입력해주세요.";
    }
    [self initSufflePad];
}


-(void)initSufflePad
{
    for( UIView *subView in self.v_Pad.subviews )
    {
        [subView removeFromSuperview];  //하위 뷰들 제거
    }
    
    NSMutableArray *arM_ButtonTitles = [self makePadList];      //하위뷰를 제거하고 랜덤번호 생성
    for( NSInteger i = 0; i < arM_ButtonTitles.count; i++ )
    {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn addTarget:self action:@selector(onBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i + 1;
        
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:24]];
        [btn setTitle:arM_ButtonTitles[i] forState:UIControlStateNormal];
        
        if(i == 11)
        {
            [btn setImage:[UIImage imageNamed:@"Key_arrow.png"] forState:UIControlStateNormal];
        }
        else
        {
            [btn setTitleColor:[UIColor colorWithHexString:@"175389"]
            forState:UIControlStateNormal];
        }
        
        CGFloat fWidth = (([UIScreen mainScreen].bounds.size.width - sfKeyPadButtonGap) / 3);
        CGFloat fHeight = ((self.v_Pad.frame.size.height - sfKeyPadButtonGap) / 4);
        [btn setFrame:CGRectMake(sfKeyPadButtonGap + ((i % 3) * fWidth) , sfKeyPadButtonGap + ((i / 3) * fHeight), fWidth - sfKeyPadButtonGap, fHeight - sfKeyPadButtonGap)];

        [self.v_Pad addSubview:btn];
    }
}


//핀패드 리스트 생성
-(NSMutableArray *)makePadList
{
    NSArray *ar_Tmp = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
    NSMutableArray *ar_ButtonTitles = [NSMutableArray arrayWithArray:[self shuffledArray:ar_Tmp]];
    
    [ar_ButtonTitles insertObject:@"" atIndex:9];
    [ar_ButtonTitles insertObject:@"" atIndex:11];

    return ar_ButtonTitles;
}

//핀패드 셔플
- (NSArray *)shuffledArray:(NSArray*)arr
{
    NSMutableArray *shuffledArray = [arr mutableCopy];
    NSUInteger arrayCount = [shuffledArray count];
    for (NSUInteger i = arrayCount - 1; i > 0; i--) {       //랜덤함수 생성
        NSUInteger n = arc4random_uniform((u_int32_t)i + 1);
        [shuffledArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [shuffledArray copy];
}



- (IBAction)actionClose:(id)sender
{
    
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(pinPadUserCancel)])
    {
        [self.delegate pinPadUserCancel];

    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 버튼 눌렸을시 이벤트
-(void)onBtnClick:(UIButton *)btn
{
    if(btn.tag == 12)       //지우기버튼눌렀을 시
    {
        if (self.arM_InputData.count >0)
        {
            [self.arM_InputData removeLastObject];
        }
    }
    else if (btn.tag == 10)     //빈공간 눌렀을 시
    {
        return;
    }
    else
    {
        if(self.arM_InputData.count >=4)
        {
            return;
        }
        [self.arM_InputData addObject:btn.titleLabel.text];
        //버튼클릭시 색상 변경
        [btn setTitleColor:[UIColor colorWithHexString:@"46D1FC"] forState:UIControlStateHighlighted];
    }
    
    //버튼눌림
    [self updateInputData];
    
    
    
    if(self.arM_InputData.count == 4)
    {
        NSMutableString *strM_Pw = [NSMutableString string];
        for (NSInteger i = 0; i < self.arM_InputData.count; i++)
        {
            [strM_Pw appendString:self.arM_InputData[i]];
        }
        if(self.keyboardMode == SetMode || self.keyboardMode == ChangeSetMode)
        {
            if(self.str_BeforePw)
            {
                //두번째
                if ([self.str_BeforePw isEqualToString:strM_Pw])
                {
                    if(self.keyboardMode ==SetMode)
                    {
                        if( self.delegate != nil && [self.delegate respondsToSelector:@selector(recvSPinPadPassword: isJoin:)])
                        {
                            [self.delegate recvSPinPadPassword:strM_Pw isJoin:YES];
                            [self performSelector:@selector(dismissController) withObject:nil afterDelay:0.5f];
                        }
                        
                    }
                    else if( self.keyboardMode == ChangeSetMode )
                    {
                        if( self.delegate != nil && [self.delegate respondsToSelector:@selector(recvChangeSPinPadPassword:)])
                        {
                            [self performSelector:@selector(dismissController) withObject:nil afterDelay:0.5f];
                            [self.delegate recvChangeSPinPadPassword:strM_Pw];
                            
                        }
                    }
                }
                else
                {
//                    비번 두번 입력할때
//                    [CommonUtil showAlert:@"비밀번호가 일치하지 않습니다."];
                    [self.lb_ErrorMsg setHidden:NO];
                    self.lb_ErrorMsg.text = @"비밀번호가 일치하지 않습니다.";
                    [self.arM_InputData removeAllObjects];
                    self.str_BeforePw = nil;
                    [self updateInputData];
                    [self initSufflePad];
                }
            }
            else
            {
                //첫번째 입력
                self.str_BeforePw = [NSString stringWithString:strM_Pw];
                [self.arM_InputData removeAllObjects];
                [self updateInputData];
                self.lb_Title.text = @"비밀번호 확인";
                self.lb_SubTitle.text = @"비밀번호를 한번 더 입력해주세요.";
                [self initSufflePad];
            }
        }
        else if( self.keyboardMode == CertMode )
        {
            //[self sendOneShotPad_AuthPW:strM_Pw];
            if( self.delegate != nil && [self.delegate respondsToSelector:@selector(recvSPinPadPassword: isJoin:)])
            {
                [self.delegate recvSPinPadPassword:strM_Pw isJoin:NO];
                [self performSelector:@selector(dismissController) withObject:nil afterDelay:0.5f];
//                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
            
        }
    }
//    else if(self.arM_InputData.count < 4)
//    {
//        [self.lb_ErrorMsg setHidden:NO];
//        self.lb_ErrorMsg.text =@"비밀번호를 입력해주세요 ";
//    }
//    else
//    {
//        [self.lb_ErrorMsg setHidden:NO];
//        self.lb_ErrorMsg.text =@"4자리 초과";
//    }
}


// 번호를 누르면서 버튼눌림표시로 변경
-(void)updateInputData
{
    for( id subView in self.v_CertButton.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn = (UIButton *)subView;
            if( btn.tag > 0 )
            {
                if( btn.tag <= self.arM_InputData.count )
                {
                    [btn setImage:[UIImage imageNamed:@"key_input_on.png"] forState:UIControlStateNormal];
                }
                else
                {
                    [btn setImage:[UIImage imageNamed:@"key_input_off.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
}

-(void)dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
