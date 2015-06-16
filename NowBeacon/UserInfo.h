//
//  UserInfo.h
//  
//
//  Created by carvin on 15/6/16.
//
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

+ (void) setUserName:(NSString *) uname;
+ (void) setLatitude:(double) lati;
+ (void) setLongitude:(double) longi;
+ (NSString *) getUserName;
+ (double) getLatitude;
+ (double) getLongitude;
@end
