//
//  UserInfo.m
//  
//
//  Created by carvin on 15/6/16.
//
//

#import "UserInfo.h"
static NSString *userName;
static NSString *userType;
static double latitude = -1;
static double longitude = -1;

@implementation UserInfo


+ (NSString *) getUserName{
    return userName;
}

+ (double) getLatitude{
    return latitude;
}

+ (double) getLongitude{
    return longitude;
}
+ (void) setUserName:(NSString *) uname{
    userName = uname;
    
}
+ (void) setLatitude:(double) lati{
    latitude = lati;
}
+ (void) setLongitude:(double) longi{
    longitude = longi;
}
@end
