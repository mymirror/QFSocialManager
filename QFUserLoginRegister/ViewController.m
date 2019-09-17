//
//  ViewController.m
//  QFUserLoginRegister
//
//  Created by llmmirror on 2019/9/16.
//  Copyright © 2019 llmmirror. All rights reserved.
//

#import "ViewController.h"
#import "QFSocialManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    QFSocialManager *ss = [QFSocialManager shareInstance];
    [ss registerUM_channel:nil];
    [ss authPlatForm:QFSocialPlatform_QQ block:nil];
    
    [ss shareWithTitle:@"" shareUrl:nil wxShareUrl:nil shareDesc:nil shareImage:nil platformType:QFSocialSharePlatform_QQ currentController:self brokerBlock:nil resultBlock:nil];
}


@end
