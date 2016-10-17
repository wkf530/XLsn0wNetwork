/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "AFHTTPSessionManager.h"

/**
   *该类默认只要导入头文件就会自动检测网络状态，且会在没有网络和未知网络的时候，自动从本地数据库中读取缓存。
   *数据库网络缓存是基于猿题库公司对FMDB进行封装的轻量级 key-value 存储框架
   *详情请见 https://github.com/yuantiku/YTKKeyValueStore  
   *对该类如有疑问可以拉个issues
 */
@interface JMHttpRequestMethod : AFHTTPSessionManager

typedef NS_ENUM(NSUInteger, JMRequestSerializer) {
    JMRequestSerializerJSON,     // 设置请求数据为JSON格式
    JMRequestSerializerPlainText    // 设置请求数据为普通 text/html
};

typedef NS_ENUM(NSUInteger, JMResponseSerializer) {
    JMResponseSerializerJSON,    // 设置响应数据为JSON格式
    JMResponseSerializerHTTP,    // 设置响应数据为二进制格式
    JMResponseSerializerXML      // 设置响应数据为XML格式
};

#pragma mark - 程序入口设置网络请求头API  一般调用一次即可

/**
  设置 请求和响应类型和超时时间

 @param requestType  默认为请求类型为JSON格式
 @param responseType 默认响应格式为JSON格式
 @param timeOut      请求超时时间 默认为20秒
 */
+(void)setTimeOutWithTime:(NSTimeInterval)timeOut
              requestType:(JMRequestSerializer)requestType
             responseType:(JMResponseSerializer)responseType;

/**
 设置 请求头

 @param httpBody 根据服务器要求 配置相应的请求体
 */
+ (void)setHttpBodyWithDic:(NSDictionary *)httpBody;

#pragma mark - 网络工具 API
/**
 获取当前的网络状态
 
 @return YES 有网  NO 没有联网
 */
+(BOOL)getCurrentNetWorkStatus;

/**
 获取网络缓存 文件大小

 @return size  单位M 默认保留两位小数 如: 0.12M
 */
+ (NSString *)fileSizeWithDBPath;
/**
 清除所有网络缓存
 */
+ (void)cleanNetWorkRefreshCache;

#pragma mark -  GET 请求API

/**
 GET 请求  不用传参 API

 @param url          请求的url
 @param refreshCache 是否对该页面进行缓存
 @param success      请求成功回调
 @param fail         请求失败回调

 @return self
 */
+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail;

/**
 GET 请求 传参数的API

 @param url          请求的url
 @param refreshCache 是否对该页面进行缓存
 @param params       请求数据向服务器传的参数
 @param success        请求成功回调
 @param fail         请求失败回调

 @return self
 */
+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail;

/**
 GET 请求 带有进度回调的 API

 @param url               请求的url
 @param refreshCache 是否对该页面进行缓存
 @param params       请求数据向服务器传的参数
 @param progress     请求进度回调
 @param success      请求成功回调
 @param fail         请求失败回调

 @return self
 */
+ (JMHttpRequestMethod *)getWithUrl:(NSString *)url
                       refreshCache:(BOOL)refreshCache
                             params:(NSDictionary *)params
                           progress:(void(^)(int64_t bytesRead, int64_t totalBytesRead))progress
                            success:(void(^)(id responseObject))success
                               fail:(void(^)(NSError *error))fail;


#pragma mark -  POST 请求API


/**
 POST 请求API

 @param url          请求的url
 @param refreshCache 是否对该页面进行缓存
 @param params       请求数据向服务器传的参数
 @param success      请求成功回调
 @param fail         请求失败回调

 @return self
 */
+ (JMHttpRequestMethod *)postWithUrl:(NSString *)url
                        refreshCache:(BOOL)refreshCache
                              params:(NSDictionary *)params
                             success:(void(^)(id responseObject))success
                                fail:(void(^)(NSError *error))fail;


/**
 POST 请求 带有进度回调的 API
 
 @param url               请求的url
 @param refreshCache 是否对该页面进行缓存
 @param params       请求数据向服务器传的参数
 @param progress     请求进度回调
 @param success      请求成功回调
 @param fail         请求失败回调
 
 @return self
 */
+ (JMHttpRequestMethod *)postWithUrl:(NSString *)url
                        refreshCache:(BOOL)refreshCache
                              params:(NSDictionary *)params
                            progress:(void(^)(int64_t bytesRead, int64_t totalBytesRead))progress
                             success:(void(^)(id responseObject))success
                                fail:(void(^)(NSError *error))fail;



@end
