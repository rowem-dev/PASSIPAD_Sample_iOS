//
//  CommonUtil.m
//  PASSIPAD_Cloud
//
//  Created by Kim Min joung on 2021/05/24.
//

#import "CommonUtil.h"
#import <UIKit/UIKit.h>


@implementation CommonUtil


#pragma mark - UserDefault

+ (BOOL)setUserDefault:(id)value forKey:(NSString*)key
{
    if( value == nil )
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    else
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)getUserDefault:(NSString*)key
{
    id ret = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (!ret)
        ret = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    
    return ret;
}


#pragma mark -
+ (void) PostNetManager:(NSString *)url withMethod:(NSString *)httpMethod withParam:(NSMutableDictionary*)dic withCompletion:(void(^)(PASSIPADResult *result))completion
{
    NSString* url2 = url;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration ephemeralSessionConfiguration]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url2]];
    
    request.timeoutInterval = 2.;
    request.HTTPMethod = httpMethod;
    request.HTTPShouldHandleCookies = YES;
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    NSError *error = nil;
    
    [request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];

    if( dic != nil )
    {
        [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:dic options:(NSJSONWritingOptions)0 error:&error]];
    }
    
    NSLog(@"request api   : %@", url2);
    NSLog(@"request param : %@", dic);
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        
        // call the completion handler on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if( completion != nil )
            {
                if( data == nil )
                {
                    PASSIPADResult *result = [[PASSIPADResult alloc] init];
                    result.code = @"9999";
                    result.message = @"NETWORK_ERROR";
                    
                    completion(result);

                    return;
                }
                

                NSError *Error = nil;
                NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&Error];
                NSLog(@"receive json data : %@", jsonDict);
                if( jsonDict == nil )
                {
                    PASSIPADResult *result = [[PASSIPADResult alloc] init];
                    result.code = @"9999";
                    result.message = @"NETWORK_ERROR";
                    
                    completion(result);

                    return;
                }
                
                PASSIPADResult *result = [[PASSIPADResult alloc] initWithResult:jsonDict];
                completion(result);

            }
            else
            {
                
                PASSIPADResult *result = [[PASSIPADResult alloc] init];
                result.code = @"9999";
#ifdef DEBUG
                NSLog(@"Error: %@", error);
                result.message = [NSString stringWithFormat:@"Network Error\n URL = %@,\ncode = %@", [error.userInfo objectForKey:@"NSErrorFailingURLKey"],  [error.userInfo objectForKey:@"NSLocalizedDescription" ]];
#else
                result.message = @"Network Error";
#endif
                
                    
            }
        });
        
    }];
    
    [task resume];

    
}

#pragma mark -
+ (void) showAlert:(NSString *)msg
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
    [alertView show];


}

@end
