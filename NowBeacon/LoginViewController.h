//
//  LoginViewController.h
//  
//
//  Created by carvin on 15/6/16.
//
//

#import <UIKit/UIKit.h>
#import "JSONKit.h"
#import "AFNetworking.h"

@interface LoginViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;

@end
