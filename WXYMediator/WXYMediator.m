//
//  WXYMediator.m
//  WXYMediator
//
//  Created by wuxu on 16/5/10.
//  Copyright © 2016年 wuxu. All rights reserved.
//

#import "WXYMediator.h"

@interface WXYMediator ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id(^)()> *servicesByProtocolStr;
@property (nonatomic, strong) NSLock *serviceRegisterLock;

@property (nonatomic, strong) NSMutableDictionary<NSString *, BOOL(^)(NSDictionary *parameters)> *routes;
@property (nonatomic, strong) NSLock *routeAddLock;
@end

@implementation WXYMediator

+ (instancetype)shared
{
    static WXYMediator *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _servicesByProtocolStr = [NSMutableDictionary dictionary];
        _serviceRegisterLock = [NSLock new];
        
        _routes = [NSMutableDictionary dictionary];
        _routeAddLock = [NSLock new];
    }
    return self;
}

@end

#pragma mark - Service

@implementation WXYMediator (Service)

+ (nullable NSSet<Protocol *> *)allServiceProtocol
{
    if ([WXYMediator shared].servicesByProtocolStr.count == 0) {
        return nil;
    }
    
    NSSet<NSString *> *protocolsStr = [NSSet setWithArray:[[WXYMediator shared].servicesByProtocolStr allKeys]];
    
    __block NSMutableSet *mProtocols = [NSMutableSet set];
    
    [protocolsStr enumerateObjectsUsingBlock:^(NSString * _Nonnull protocolStr, BOOL * _Nonnull stop) {
        [mProtocols addObject:NSProtocolFromString(protocolStr)];
    }];
    
    return [mProtocols copy];
}

+ (BOOL)registerService:(Protocol *)serviceProtocol withImpl:(id (^)())block
{
    NSParameterAssert(serviceProtocol != nil);
    NSParameterAssert(block != nil);
    
    if (!serviceProtocol || !block) {
        return NO;
    }
    
    [[WXYMediator shared].serviceRegisterLock lock];
    
    //防止重复添加协议
    if ([WXYMediator shared].servicesByProtocolStr[NSStringFromProtocol(serviceProtocol)]) {
        [[WXYMediator shared].serviceRegisterLock unlock];
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 协议已经注册", NSStringFromProtocol(serviceProtocol)] userInfo:nil];
#endif
        
        return NO;
    }
    
#if DEBUG
    //防止对象没有实现协议
    id instance = block();
    if (![[instance class] conformsToProtocol:serviceProtocol]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 服务不符合 %@ 协议", NSStringFromClass([instance class]), NSStringFromProtocol(serviceProtocol)] userInfo:nil];
    }
#endif
    
    NSString *protocolName = NSStringFromProtocol(serviceProtocol);
    if (protocolName) {
        [WXYMediator shared].servicesByProtocolStr[protocolName] = [block copy];
        
#if DEBUG
        NSLog(@"%@ 协议注册成功", NSStringFromProtocol(serviceProtocol));
#endif
        
        [[WXYMediator shared].serviceRegisterLock unlock];
        return YES;
    }
    
    [[WXYMediator shared].serviceRegisterLock unlock];
    return NO;
}

+ (void)unregisterService:(Protocol *)serviceProtocol
{
    NSParameterAssert(serviceProtocol != nil);
    
    if (!serviceProtocol) {
        return ;
    }
    
    [[WXYMediator shared].serviceRegisterLock lock];
    
    if (![WXYMediator shared].servicesByProtocolStr[NSStringFromProtocol(serviceProtocol)]) {
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 协议未被注册，因此反注册失败", NSStringFromProtocol(serviceProtocol)] userInfo:nil];
#endif
        
    } else {
        [[WXYMediator shared].servicesByProtocolStr removeObjectForKey:NSStringFromProtocol(serviceProtocol)];
        
#if DEBUG
        NSLog(@"%@ 协议反注册成功", NSStringFromProtocol(serviceProtocol));
#endif
    }
    
    [[WXYMediator shared].serviceRegisterLock unlock];
}

+ (nullable id)findService:(Protocol *)serviceProtocol
{
    NSParameterAssert(serviceProtocol != nil);
    
    if (!serviceProtocol) {
        return nil;
    }
    
    id (^block)() = [WXYMediator shared].servicesByProtocolStr[NSStringFromProtocol(serviceProtocol)];
    
    if (block) {
        return block();
    }
    
    return nil;
}

@end

#pragma mark - Route

@implementation WXYMediator (Route)

+ (nullable NSSet<NSString *> *)allRoute
{
    if ([WXYMediator shared].routes.count == 0) {
        return nil;
    }
    
    NSSet<NSString *> *routesStr = [NSSet setWithArray:[[WXYMediator shared].routes allKeys]];
    
    __block NSMutableSet *mRoute = [NSMutableSet set];
    
    [routesStr enumerateObjectsUsingBlock:^(NSString * _Nonnull routeStr, BOOL * _Nonnull stop) {
        [mRoute addObject:routeStr];
    }];
    
    return [mRoute copy];
}

+ (BOOL)addRoute:(NSString *)route handler:(BOOL (^__nullable)(NSDictionary *parameters))block
{
    NSParameterAssert(route != nil);
    NSParameterAssert(block != nil);
    
    if (!route || !block) {
        return NO;
    }
    
    [[WXYMediator shared].routeAddLock lock];
    
    //防止重复添加协议
    if ([WXYMediator shared].routes[route]) {
        [[WXYMediator shared].routeAddLock unlock];
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 路径已经添加", route] userInfo:nil];
#endif
        
        return NO;
    }
    
    [WXYMediator shared].routes[route] = [block copy];
    
#if DEBUG
    NSLog(@"%@ 路径添加成功", route);
#endif
    
    [[WXYMediator shared].routeAddLock unlock];
    return YES;
}

+ (void)removeRoute:(NSString *)route
{
    NSParameterAssert(route != nil);
    
    if (!route) {
        return ;
    }
    
    [[WXYMediator shared].routeAddLock lock];
    
    if (![WXYMediator shared].routes[route]) {
        
#if DEBUG
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ 路径未被添加，因此移除失败", route] userInfo:nil];
#endif
        
    } else {
        [[WXYMediator shared].routes removeObjectForKey:route];
        
#if DEBUG
        NSLog(@"%@ 路径移除成功", route);
#endif
    }
    
    [[WXYMediator shared].routeAddLock unlock];
}

+ (BOOL)routeTo:(NSString *)route withParameters:(nullable NSDictionary *)parameters
{
    NSParameterAssert(route != nil);
    
    if (!route) {
        return NO;
    }
    
    BOOL (^block)(NSDictionary *parameters) = [WXYMediator shared].routes[route];
    
    if (block) {
        return block(parameters);
    }
    
    return NO;
}

+ (BOOL)canRouteTo:(NSString *)route
{
    NSParameterAssert(route != nil);
    
    if (!route) {
        return NO;
    }
    
    BOOL (^block)(NSDictionary *parameters) = [WXYMediator shared].routes[route];
    
    if (block) {
        return YES;
    }
    
    return NO;
}

@end



