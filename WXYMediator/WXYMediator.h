//
//  WXYMediator.h
//  WXYMediator
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WXYMediator : NSObject

@end

@interface WXYMediator (Service)

/**
 *  获取目前所有被注册的协议
 */
+ (nullable NSSet<Protocol *> *)allServiceProtocol;

/**
 *  注册一个实现某协议的服务
 *
 *  @param serviceProtocol  服务遵守的协议
 *  @param block            返回实现协议的实例
 */
+ (BOOL)registerService:(Protocol *)serviceProtocol withImpl:(id (^)())block;

/**
 *  反注册某个服务
 *
 *  @param serviceProtocol  需要反注册的服务
 */
+ (void)unregisterService:(Protocol *)serviceProtocol;

/**
 *  通过某个协议找到实现协议的实例
 *
 *  @param serviceProtocol  服务协议
 */
+ (nullable id)findService:(Protocol *)serviceProtocol;

@end

@interface WXYMediator (Route)

/**
 *  获取目前所有被注册的路径
 */
+ (nullable NSSet<NSString *> *)allRoute;

/**
 *  注册一个路径
 *
 *  @param route  路径
 *  @param block  成功失败的block
 */
+ (BOOL)addRoute:(NSString *)route handler:(BOOL (^__nullable)(NSDictionary *parameters))block;

/**
 *  反注册某个路径
 *
 *  @param route  需要移除的路径
 */
+ (void)removeRoute:(NSString *)route;

/**
 *  通过某个URL进行导航
 *
 *  @param route        路径
 *  @param parameters   参数
 */
+ (BOOL)routeTo:(NSString *)route withParameters:(nullable NSDictionary *)parameters;

/**
 *  检查某路径是否存在
 *
 *  @param route 路径
 */
+ (BOOL)canRouteTo:(NSString *)route;

@end

NS_ASSUME_NONNULL_END
