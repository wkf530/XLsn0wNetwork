//
//  JMHttpRequestMethod.m
//  ssss
//
//  Created by 雷建民 on 16/9/25.
//  Copyright © 2016年 雷建民. All rights reserved.
//

#import "JMHttpRequestMethod.h"
#import "YTKKeyValueStore.h"

#define PATH_OF_NetWork    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

typedef NS_ENUM(NSUInteger, JMNetworkStatus) {
    JMNetworkStatusUnknown,  //未知的网络
    JMNetworkStatusNotNetWork, //没有网络
    JMNetworkStatusReachableViaWWAN,//手机蜂窝数据网络
    JMNetworkStatusReachableViaWiFi //WIFI 网络
};


@interface JMHttpRequestMethod ()
@end

@implementation JMHttpRequestMethod

static NSString *const  httpCache = @"NetworkCache";
static YTKKeyValueStore *_store;
static JMNetworkStatus _status;
static BOOL    _isHasNetWork;

+ (void)load
{
    JMHttpRequestMethod *httpMethod;
    httpMethod.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置请求的超时时间
    httpMethod.requestSerializer.timeoutInterval = 20.f;
    //设置服务器返回结果的类型:JSON (AFJSONResponseSerializer,AFHTTPResponseSerializer)
    httpMethod.responseSerializer = [AFJSONResponseSerializer serializer];
    
    httpMethod.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:
                                                            @"application/json",
                                                            @"text/html",
                                                            @"text/json",
                                                            @"text/plain",
                                                            @"text/javascript",
                                                            @"text/xml", @"image/*", nil];
      [self startMonitoringNetworkStatus];
}

/**
 监测网络状态 (在程序入口，调用一次即可)
 */
+ (void)startMonitoringNetworkStatus
{
        AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
        [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status)
            {
                case AFNetworkReachabilityStatusUnknown:
                    _isHasNetWork = NO;
                    _status = JMNetworkStatusUnknown;
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    _isHasNetWork = NO;
                    _status = JMNetworkStatusNotNetWork;
                    NSLog(@"没有网的状态");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    _isHasNetWork = YES;
                    _status = JMNetworkStatusReachableViaWWAN;
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    _isHasNetWork = YES;
                    _status = JMNetworkStatusReachableViaWiFi;
                    NSLog(@"现在是有网状态");
                    break;
            }
        }];
        [manager startMonitoring];
}
/**
 设置 请求和响应类型和超时时间
 
 @param requestType  默认为请求类型为JSON格式
 @param responseType 默认响应格式为JSON格式
 @param timeOut      请求超时时间 默认为20秒
 */
+(void)setTimeOutWithTime:(NSTimeInterval)timeOut
              requestType:(JMRequestSerializer)requestType
             responseType:(JMResponseSerializer)responseType
{
    
    JMHttpRequestMethod *httpMethod;
    httpMethod.requestSerializer.timeoutInterval = timeOut;
    switch (requestType) {
        case JMRequestSerializerJSON:
            httpMethod.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        case JMRequestSerializerPlainText:
            httpMethod.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
        default:
            break;
    }
    switch (responseType) {
        case JMResponseSerializerJSON:
            httpMethod.responseSerializer = [AFJSONResponseSerializer serializer];
            break;
            case JMResponseSerializerHTTP:
            httpMethod.responseSerializer = [AFHTTPResponseSerializer serializer];
            break;
            case JMResponseSerializerXML:
            httpMethod.responseSerializer = [AFXMLParserResponseSerializer serializer];
        default:
            break;
    }
}
/**
 设置 请求头
 
 @param httpBody 根据服务器要求 配置相应的请求体
 */
+ (void)setHttpBodyWithDic:(NSDictionary *)httpBody
{
    JMHttpRequestMethod *httpMethod;
    for (NSString *key in httpBody.allKeys) {
        if (httpBody[key] != nil) {
            [httpMethod.requestSerializer setValue:httpBody[key] forHTTPHeaderField:key];
        }
    }
}


/**
 获取当前的网络状态
 
 @return YES 有网  NO 没有联网
 */
+(BOOL)getCurrentNetWorkStatus
{
    return _isHasNetWork;
}

/**
 获取网络缓存 文件大小
 
 @return size  单位M
 */
+ (NSString *)fileSizeWithDBPath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[PATH_OF_NetWork stringByAppendingPathComponent:httpCache]]){
        unsigned  long long  fileSize =  [[manager attributesOfItemAtPath:[PATH_OF_NetWork stringByAppendingPathComponent:httpCache] error:nil] fileSize];
        NSString *size = [NSString stringWithFormat:@"%.2fM",fileSize/1024.0/1024.0];
        return  size;
    }else {
        return @"0M";
    }
    return 0;
}

/**
 清除所有网络缓存
 */
+ (void)cleanNetWorkRefreshCache
{
    NSError *error;
    BOOL isSuccess =  [[NSFileManager defaultManager]removeItemAtPath:[PATH_OF_NetWork stringByAppendingPathComponent:httpCache] error:&error];
    if (isSuccess) {
        NSLog(@"clean cache file is success");
    }else {
        if ([PATH_OF_NetWork stringByAppendingPathComponent:httpCache]) {
               NSLog(@"error:%@",error.description);
        }else {
            NSLog(@"error: cache file is not exist");
        }
     
    }
}

#pragma mark -  /**************GET 请求API ******************/

+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail
{
    return [self getWithUrl:url refreshCache:refreshCache params:nil success:success fail:fail];
}
// 多一个params参数
+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail
{
    return [self getWithUrl:url refreshCache:refreshCache params:params progress:nil success:success fail:fail];
}
// 多一个带进度回调
+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                           progress:(void(^)(int64_t bytesRead, int64_t totalBytesRead))progress
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail
{
    _store = [[YTKKeyValueStore alloc] initDBWithName:httpCache];
    [_store createTableWithName:httpCache];
    JMHttpRequestMethod *request = nil;
    if ([JMHttpRequestMethod getCurrentNetWorkStatus]) {
        if (!refreshCache) {
            [self requestNotCacheWithHttpMethod:0 url:url params:params progress:progress success:success fail:fail];
        }else {
            NSDictionary *dict =   [_store getObjectById:url  fromTable:httpCache];
            if (dict) {
                success(dict);
            }else {
                [[self manager] GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                    progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [_store putObject:responseObject withId:url intoTable:httpCache];
                    success(responseObject);
                    NSLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",url,params,responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    fail(error);
                    NSLog(@"error = %@",error.description);
                }];
            }
        }
    } else {
        NSDictionary *dict =   [_store getObjectById:url  fromTable:httpCache];
        if (dict) {
            success(dict);
        }else {
            NSLog(@"当前为无网络状态，本地也没有缓存数据");
        }
    }
    return request;
}
#pragma mark - /*********************** POST 请求API **********************/

+ (JMHttpRequestMethod *)postWithUrl:(NSString *)url
                        refreshCache:(BOOL)refreshCache
                              params:(NSDictionary *)params
                             success:(void(^)(id responseObject))success
                                fail:(void(^)(NSError *error))fail
{
    return [self postWithUrl:url refreshCache:refreshCache params:params progress:nil success:success fail:fail];
}

+ (JMHttpRequestMethod *)postWithUrl:(NSString *)url
                        refreshCache:(BOOL)refreshCache
                              params:(NSDictionary *)params
                            progress:(void(^)(int64_t bytesRead, int64_t totalBytesRead))progress
                             success:(void(^)(id responseObject))success
                                fail:(void(^)(NSError *error))fail
{
    JMHttpRequestMethod *request = nil;
    if ([JMHttpRequestMethod getCurrentNetWorkStatus]) {
        if (!refreshCache) {
            [self requestNotCacheWithHttpMethod:1 url:url params:params progress:progress success:success fail:fail];
        }else {
            NSDictionary *dict =   [_store getObjectById:url  fromTable:httpCache];
            if (dict) {
                success(dict);
            }else {
                [[self manager] POST:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
                    progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    [_store putObject:responseObject withId:url intoTable:httpCache];
                    success(responseObject);
                    NSLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",url,params,responseObject);
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    fail(error);
                }];
            }
        }
    } else {
        NSDictionary *dict =   [_store getObjectById:url  fromTable:httpCache];
        if (dict) {
            success(dict);
        }else {
            NSLog(@"当前为无网络状态，本地也没有缓存数据");
        }
    }
    
    return request;
}
+ (void)requestNotCacheWithHttpMethod:(NSInteger)httpMethod
                                  url:(NSString *)url
                               params:(NSDictionary *)params
                             progress:(void(^)(int64_t bytesRead, int64_t totalBytesRead))progress
                              success:(void(^)(id responseObject))success
                                 fail:(void(^)(NSError *error))fail
{
    if (httpMethod == 0) {
        [[self manager]GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
            progress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
            NSLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",url,params,responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            fail(error);
        }];
    }else {
        [[self manager ]POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            progress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            success(responseObject);
            NSLog(@"\nRequest success, URL: %@\n params:%@\n response:%@\n\n",url,params,responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            fail(error);
        }];
    }
}


@end
