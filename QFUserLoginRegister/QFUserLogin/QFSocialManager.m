//
//  QFSocialLogin.m
//  QFUserLoginRegister
//
//  Created by llmmirror on 2019/9/16.
//  Copyright © 2019 llmmirror. All rights reserved.
//

#import "QFSocialManager.h"

@implementation QFSocialResponse

@end

@implementation QFSocialManager

+ (QFSocialManager *)shareInstance{
    static QFSocialManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QFSocialManager alloc]init];
    });
    return instance;
}

- (void)registerUM_channel:(NSString *)channel{
    if (self.umKey.length == 0) {
        NSAssert(0, @"友盟注册的umKey不存在,请确认umKey存在且有效");
        return ;
    }
    [UMConfigure initWithAppkey:self.umKey channel:channel];
#ifdef DEBUG
    [UMConfigure setLogEnabled:YES];
#else
#endif
    
    if (self.platform_QQ_Key.length && self.platform_QQ_Secret.length) {
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:self.platform_QQ_Key appSecret:self.platform_QQ_Secret redirectURL:self.platform_QQ_RedirectURL];
    }
    
    if (self.platform_WX_Key.length && self.platform_WX_Secret.length &&  self.platform_WX_RedirectURL.length) {
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:self.platform_WX_Key appSecret:self.platform_WX_Secret redirectURL:self.platform_WX_RedirectURL];
    }
    
    if (self.platform_Sina_Key.length && self.platform_Sina_Secret.length) {
        [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:self.platform_Sina_Key appSecret:self.platform_Sina_Secret redirectURL:self.platform_Sina_RedirectURL];
    }
}

- (void)authPlatForm:(QFSocialPlatform)socialPlatform block:(void(^)(QFSocialResponse *socialResponse,NSError * error))block{
    UMSocialPlatformType umPlatformType = 0;
    switch (socialPlatform) {
        case QFSocialPlatform_QQ:
            umPlatformType = UMSocialPlatformType_QQ;
            break;
            
        case QFSocialPlatform_Sina:
            umPlatformType = UMSocialPlatformType_Sina;
            break;
            
        case QFSocialPlatform_WX:
            umPlatformType = UMSocialPlatformType_WechatSession;
            break;
            
        default:
            break;
    }
    
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:umPlatformType currentViewController:nil completion:^(id result, NSError *error) {
        UMSocialUserInfoResponse *_result = (UMSocialUserInfoResponse *)result;
        if (error == nil) {
            //说明授权成功
            QFSocialResponse *response = [[QFSocialResponse alloc]init];
            response.uid = _result.uid;
            response.openid = _result.openid;
            response.refreshToken = _result.refreshToken;
            response.expiration = _result.expiration;
            response.accessToken = _result.accessToken;
            response.unionId = _result.unionId;
            response.usid = _result.usid;
            response.platformType = _result.platformType;
            response.originalResponse = _result.originalResponse;
            response.extDic = _result.extDic;
            response.name = _result.name;
            response.iconurl = _result.iconurl;
            response.unionGender = _result.unionGender;
            response.gender = _result.gender;
            if (block) {
                block(response,nil);
            }
        }else{
            if (block) {
                block(nil,error);
            }
        }
    }];
}

- (void)shareWithTitle:(NSString *)shareTitle
              shareUrl:(NSString *)shareUrl
            wxShareUrl:(NSString *)wxShareUrl
             shareDesc:(NSString *)shareDesc
            shareImage:(id)sharePicture
          platformType:(QFSocialSharePlatform)platformType
     currentController:(UIViewController *)currentController
           brokerBlock:(void(^)(void))brokerBlock
           resultBlock:(void(^)(BOOL isInstall,BOOL shareSucess))block
{
    //如果是经纪人
    if (platformType == QFSocialSharePlatform_Broker) {
        if (brokerBlock) {
            brokerBlock();
        }
        return ;
    }
    UMSocialPlatformType umPlateform = UMSocialPlatformType_QQ;
    switch (platformType) {
        case QFSocialSharePlatform_QQ:
            break;
        case QFSocialSharePlatform_WXSession:
            umPlateform = UMSocialPlatformType_WechatSession;
            break;
        case QFSocialSharePlatform_WXTimeLine:
            umPlateform = UMSocialPlatformType_WechatTimeLine;
            break;
        case QFSocialSharePlatform_Sms:
            umPlateform = UMSocialPlatformType_Sms;
            break;
            
        default:
            break;
    }
    if (![[UMSocialManager defaultManager] isInstall:umPlateform]) {
        //未安装客户端
        if (block) {
            block(NO,nil);
        }
        return ;
    }
    
    BOOL isImage = YES;
    if ([sharePicture isKindOfClass:[UIImage class]]) {
        isImage = YES;
    } else {
        isImage = NO;
    }
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareImageObject = [[UMShareImageObject alloc] init];
    
    if (platformType == QFSocialSharePlatform_Sms) {
        UMShareSmsObject *smsObject = [[UMShareSmsObject alloc] init];
        smsObject.smsContent = [NSString stringWithFormat:@"%@  %@", shareUrl, shareDesc];
        //分享消息对象设置分享内容对象
        messageObject.shareObject = smsObject;
    }
    else if (!shareTitle || shareTitle.length == 0) {
        //如果有缩略图，则设置缩略图
        shareImageObject.shareImage = sharePicture;
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareImageObject;
    } else {
        
        if (platformType == UMSocialPlatformType_WechatSession && wxShareUrl.length > 0) {
            
            //创建小程序内容对象
            UMShareMiniProgramObject *miniProgramObject;
            if (sharePicture) {
                if (!isImage) {
                    miniProgramObject = [UMShareMiniProgramObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:sharePicture];
                } else {
                    miniProgramObject = [UMShareMiniProgramObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:sharePicture];
                    NSData *data = [self compressImage:sharePicture toByte:100*1024];
                    miniProgramObject.hdImageData = data;
                }
            } else {
                miniProgramObject = [UMShareMiniProgramObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:nil];
            }
            if (self.shareWeChatAPPId.length == 0) {
                NSAssert(0, @"分享到微信小程序的APPID不能为空");
            }
            miniProgramObject.webpageUrl = shareUrl;
            miniProgramObject.userName = self.shareWeChatAPPId;
            miniProgramObject.path = wxShareUrl;
            miniProgramObject.miniProgramType = UShareWXMiniProgramTypeRelease; // 可选体验版和开发板
            messageObject.shareObject = miniProgramObject;
        } else {
            
            //创建网页内容对象
            UMShareWebpageObject *shareObject;
            if (sharePicture) {
                if (!isImage) {
                    NSString* thumbURL = sharePicture;
                    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbURL]];
                    shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:data];
                } else {
                    shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:sharePicture];
                }
            } else {
                shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareDesc thumImage:nil];
            }
            //设置网页地址
            shareObject.webpageUrl = shareUrl;
            //分享消息对象设置分享内容对象
            messageObject.shareObject = shareObject;
        }
    }
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:umPlateform messageObject:messageObject currentViewController:currentController completion:^(id data, NSError *error) {
        
        if (error) {
            //分享失败
            if (block) {
                block(YES,NO);
            }
        }else{
            //分享成功
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
            }else{
                
            }
            if (block) {
                block(YES,YES);
            }
        }
    }];
}


- (NSData *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return data;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    return data;
}

@end
