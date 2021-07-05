//
//  AppDelegate.h
//  PASSIPAD_Cloud
//
//  Created by 이경주 on 2021/05/18.
//
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>


//로컬테스트코드
//#define SERVER_URL          @"http://13.124.69.205:8081"
//#define SERVER_URL_SPKEY    @"http://13.124.69.205:8081/spin/spmng/reqSpEncKey"

#define SERVER_URL          @"https://api.passipad.com"
//#define SERVER_URL_SPKEY    @"https://api.passipad.com/spin/spmng/reqSpEncKey"

@interface AppDelegate : UIResponder <UIApplicationDelegate , UNUserNotificationCenterDelegate>
+ (AppDelegate*) get;
@property (strong, nonatomic) UIWindow *window;
@end

