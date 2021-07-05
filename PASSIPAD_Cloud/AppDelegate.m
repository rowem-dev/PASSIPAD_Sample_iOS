//
//  AppDelegate.m
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/18.
//

#import "AppDelegate.h"
#import <PASSIPAD_Lib/PASSIPADManager.h>

#import "ViewController.h"
#import "Common/CommonUtil.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate*) get
{
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
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
    
//    if (@available(iOS 10.0, *))
//    {
//        UNUserNotificationCenter *settings = [UNUserNotificationCenter currentNotificationCenter];
//        settings.delegate = self;
//        [settings requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//            if( !error ) {
//            // 푸시 서비스 등록 성공
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[UIApplication sharedApplication] registerForRemoteNotifications];
//                });
//            }
//            else {
//            // 푸시 서비스 등록 실패
//            }
//        }];
//    }
    
    NSString *partnerCode = [[PASSIPADManager shared] getPartnerCode];
    if(partnerCode != nil)
        [[PASSIPADManager shared] setWithAppType:[NSString stringWithFormat:@"%@",partnerCode]];
    
    return YES;
}


#pragma mark - APNS
//iOS8용
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    if (notificationSettings.types == UIUserNotificationTypeNone)
    {

    }
    else
    {

    }

    [[NSUserDefaults standardUserDefaults] synchronize];
}

//iOS8용 수정
//- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UNNotificationSettings *)notificationSettings
//{
//    if (notificationSettings.showPreviewsSetting == UNShowPreviewsSettingNever)
//    {
//
//    }
//    else
//    {
//
//    }
//
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

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
//
//
//    [[SPinManager shared] reqTimeCheckOneShotPadPush:@"NO"];
    
//    [FIRMessaging messaging].APNSToken = deviceToken;
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"pushtoken error ");
}

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



//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
//{
//
//    application.applicationIconBadgeNumber = 0;
//
//    [CommonUtil showAlert:@"Push가 수신되었습니다"];
//
//
//    NSLog(@"didReceiveRemoteNotification userInfo : %@", userInfo);
//
//    NSString *str_Val = [userInfo objectForKey:@"spinpad"];
//    if( str_Val && str_Val.length > 0 )
//    {
//        NSError *error = nil;
//
//        NSData *data = [str_Val dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dic_Val = [NSJSONSerialization JSONObjectWithData:data
//                                                                options:kNilOptions
//                                                                  error:&error];
//        id spinPad = [dic_Val objectForKey:@"spinpad"];
//        if( spinPad != nil )
//        {
//            data = [spinPad dataUsingEncoding:NSUTF8StringEncoding];
//            dic_Val = [NSJSONSerialization JSONObjectWithData:data
//                                                      options:kNilOptions
//                                                        error:&error];
//
//            NSLog(@"spinpad pushInfo : %@", dic_Val);
//
//            [[PASSIPADManager shared] setReceivePushData:dic_Val];
//
//            UINavigationController *navi = (UINavigationController*)[[AppDelegate get].window rootViewController];
//
//            ViewController *controller = (ViewController*)navi.topViewController;
//            if( [controller respondsToSelector:@selector(checkBioAuth)] )
//                [controller checkBioAuth];
//
//        }
//    }
//}

@end
