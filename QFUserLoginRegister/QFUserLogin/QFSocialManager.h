//
//  QFSocialLogin.h
//  QFUserLoginRegister
//
//  Created by llmmirror on 2019/9/16.
//  Copyright © 2019 llmmirror. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMCommon/UMConfigure.h>
#import <UMShare/UMShare.h>

//授权登录平台
typedef enum : NSUInteger {
    QFSocialPlatform_QQ, // QQ平台
    QFSocialPlatform_WX, // 微信平台
    QFSocialPlatform_Sina,// 微博平台
} QFSocialPlatform;

// 分享平台
typedef enum : NSUInteger {
    QFSocialSharePlatform_QQ,           //QQ聊天
    QFSocialSharePlatform_WXSession,    //微信聊天
    QFSocialSharePlatform_WXTimeLine,   //微信朋友圈
    QFSocialSharePlatform_Sms,          //短信
    QFSocialSharePlatform_Broker,       //经纪人
} QFSocialSharePlatform;


@interface QFSocialResponse : NSObject

@property (nonatomic, copy) NSString  *uid;
@property (nonatomic, copy) NSString  *openid;
@property (nonatomic, copy) NSString  *refreshToken;
@property (nonatomic, copy) NSDate    *expiration;
@property (nonatomic, copy) NSString  *accessToken;

@property (nonatomic, copy) NSString  *unionId;

/**
 usid 兼容U-Share 4.x/5.x 版本，与4/5版本数值相同
 即，对应微信平台：openId，QQ平台openId，其他平台不变
 */
@property (nonatomic, copy) NSString  *usid;

@property (nonatomic, assign) UMSocialPlatformType  platformType;
/**
 * 第三方原始数据
 */
@property (nonatomic, strong) id  originalResponse;

/**
 6.5版版本新加入的扩展字段
 */
@property (nonatomic, strong)NSDictionary* extDic;//每个平台特有的字段有可能会加在此处，有可能为nil

/**
 第三方平台昵称
 */
@property (nonatomic, copy) NSString  *name;

/**
 第三方平台头像地址
 */
@property (nonatomic, copy) NSString  *iconurl;

/**
 通用平台性别属性
 QQ、微信、微博返回 "男", "女"
 Facebook返回 "male", "female"
 */
@property (nonatomic, copy) NSString  *unionGender;

@property (nonatomic, copy) NSString  *gender;

@end

@interface QFSocialManager : NSObject

#pragma mark --- 注册UM
/**
    官网申请的友盟的key
 */
@property (nonatomic, copy) NSString *umKey;

#pragma mark --- 注册QQ
/**
    官网申请的QQ平台的key(必填)
 */
@property (nonatomic, copy) NSString *platform_QQ_Key;

/**
    官网申请的QQ平台的secret(必填)
 */
@property (nonatomic, copy) NSString *platform_QQ_Secret;

/**
 官网申请的QQ平台的回调地址(可选)
 */
@property (nonatomic, copy) NSString *platform_QQ_RedirectURL;

#pragma mark --- 注册微信

/**
    官网申请的微信平台的key(必填)
 */
@property (nonatomic, copy) NSString *platform_WX_Key;

/**
    官网申请的微信平台的secret(必填)
 */
@property (nonatomic, copy) NSString *platform_WX_Secret;

/**
 官网申请的微信平台的回调地址(必填)
 */
@property (nonatomic, copy) NSString *platform_WX_RedirectURL;

#pragma mark --- 注册sina微博

/**
 官网申请的sina微博平台的key(必填)
 */
@property (nonatomic, copy) NSString *platform_Sina_Key;

/**
 官网申请的sina微博平台的secret(必填)
 */
@property (nonatomic, copy) NSString *platform_Sina_Secret;

/**
 官网申请的sina微博平台的回调地址(可选)
 */
@property (nonatomic, copy) NSString *platform_Sina_RedirectURL;


/**
  微信分享到小程序，必须添加小程序的APPID
 */
@property (nonatomic, copy) NSString *shareWeChatAPPId;


#pragma mark --- public method 

/**
 单例

 @return                返回自身
 */
+ (QFSocialManager *)shareInstance;

/**
 注册

 **必须先设置上述属性，才能调用注册，否则注册失败**

 @param channel         渠道标识,可设置nil表示"App Store".
 */
- (void)registerUM_channel:(NSString *)channel;


/**
 三方授权，以及获取用户信息

 @param socialPlatform  三方授权平台，目前只支持三个平台 QQ WeiXin Sina微博
 @param block           socialResponse 返回授权以及用户信息，详情见 QFSocialResponse 说明
                        error 返回授权h、获取用户资料等出错错误信息
 */
- (void)authPlatForm:(QFSocialPlatform)socialPlatform block:(void(^)(QFSocialResponse *socialResponse,NSError * error))block;


/**
 三方分享，包含QQ、微信、新浪微博、sms(短信)、分享到经纪人

 @param shareTitle      标题
 @param shareUrl        链接url
 @param wxShareUrl      微信小程序链接url
 @param shareDesc       分享描述
 @param sharePicture    分享图片(可以为image也可以设置为string)
 @param platformType    分享的平台，详情见QFSocialSharePlatform
 @param currentController 分享的页面
 @param brokerBlock     分享到经纪人事件回调
 @param block           分享的结果 (备注：优先判断是否安装对应平台的APP，然后再判断是否分享成功或者失败)
                        install 当前分享的平台是否已经安装 YES：已安装 NO：未安装
                        shareSucess 是否分享成功  YES：分享成功 NO：分享失败
 */
- (void)shareWithTitle:(NSString *)shareTitle
              shareUrl:(NSString *)shareUrl
            wxShareUrl:(NSString *)wxShareUrl
             shareDesc:(NSString *)shareDesc
            shareImage:(id)sharePicture
          platformType:(QFSocialSharePlatform)platformType
     currentController:(UIViewController *)currentController
           brokerBlock:(void(^)(void))brokerBlock
           resultBlock:(void(^)(BOOL isInstall,BOOL shareSucess))block;


@end
