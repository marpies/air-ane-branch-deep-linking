//
//  BranchHelpers.m
//  BranchIosExtension
//
//  Created by Aymeric Lamboley on 13/04/2015.
//  Copyright (c) 2015 Pawprint Labs. All rights reserved.
//

#import "BranchHelpers.h"
#import "TypeConversion.h"
#import <objc/runtime.h>

static NSDictionary* airBranchAppLaunchOptions = nil;

@implementation BranchHelpers
{
    BranchUniversalObject* mCurrentUniversalObject;
}

- (id) initWithContext:(FREContext) context {
    
    if (self = [super init])
    {
        ctx = context;
        
        mCurrentUniversalObject = nil;
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id delegate = [[UIApplication sharedApplication] delegate];
            if( delegate == nil ) return;
            
            Class adobeDelegateClass = object_getClass( delegate );
            
            SEL delegateSelector = @selector(application:openURL:sourceApplication:annotation:);
            [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(branchair_application:openURL:sourceApplication:annotation:)];
            
            delegateSelector = @selector(application:continueUserActivity:restorationHandler:);
            [self overrideDelegate:adobeDelegateClass method:delegateSelector withMethod:@selector(branchair_application:continueUserActivity:restorationHandler:)];
        });
    }
    
    return self;
}

+ (void) load {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(branchair_applicationDidFinishLaunching:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
}

/**
 * Stores last launch options (received from NSNotification).
 **/
+ (void) branchair_applicationDidFinishLaunching:(NSNotification*) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if( notification != nil ) {
        airBranchAppLaunchOptions = notification.userInfo;
    }
}

- (void) initBranch:(BOOL) useTestKey {
    
    [Branch setUseTestBranchKey:useTestKey];
    
    branch = [Branch getInstance];
    
    if(airBranchAppLaunchOptions == nil)
    {
        airBranchAppLaunchOptions = @{};
    }
    
    [branch initSessionWithLaunchOptions:airBranchAppLaunchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error)
    {
        if (!error)
        {
            NSString *JSONString = [TypeConversion ConvertNSDictionaryToJSONString:params];
            [self dispatchEvent:@"INIT_SUCCESSED" withParams:JSONString];
        }
        else
        {
            [self dispatchEvent:@"INIT_FAILED" withParams:error.description];
        }
    }];
    
    // iOS 9+
    if(floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_9_0)
    {
        NSDictionary* userActivityDict = [airBranchAppLaunchOptions objectForKey:UIApplicationLaunchOptionsUserActivityDictionaryKey];
        if(userActivityDict != nil)
        {
            [userActivityDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop)
             {
                 if ([obj isKindOfClass:[NSUserActivity class]])
                 {
                     [branch continueUserActivity:obj];
                 }
             }];
        }
    }
    // iOS 8 and older
    else
    {
        NSURL* launchUrl = [airBranchAppLaunchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if(launchUrl != nil)
        {
            [branch application:nil openURL:launchUrl sourceApplication:[airBranchAppLaunchOptions objectForKey:UIApplicationLaunchOptionsSourceApplicationKey] annotation:nil];
        }
    }
}

- (void) setIdentity:(NSString *) userId {
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [branch setIdentity:userId withCallback:^(NSDictionary *params, NSError *error) {
        
        if (!error) {
            
            [weakSelf dispatchEvent:@"SET_IDENTITY_SUCCESSED" withParams:@""];
            
        } else {
            
            [weakSelf dispatchEvent:@"SET_IDENTITY_FAILED" withParams:error.description];
        }
    }];
}

- (void) getShortURL:(FREObject) linkProperties
{
    if(mCurrentUniversalObject == nil)
    {
        [self dispatchEvent:@"GET_SHORT_URL_FAILED" withParams:@"Universal object must be prepared before requesting URL."];
        return;
    }
    
    BranchLinkProperties* linkProps = [self getLinkProperties:linkProperties];
    
    [mCurrentUniversalObject getShortUrlWithLinkProperties:linkProps andCallback:^(NSString * _Nullable url, NSError * _Nullable error)
    {
        if(error == nil)
        {
            [self dispatchEvent:@"GET_SHORT_URL_SUCCESSED" withParams:url];
        }
        else
        {
            [self dispatchEvent:@"GET_SHORT_URL_FAILED" withParams:error.description];
        }
    }];
}

- (void) logout {
    
    [branch logout];
}

- (void) userCompletedAction:(NSString *) action {
    if(mCurrentUniversalObject != nil)
    {
        [mCurrentUniversalObject userCompletedAction:action];
    }
}

- (NSDictionary *) getLatestReferringParams {
    
    return [branch getLatestReferringParams];
}

- (NSDictionary *) getFirstReferringParams {
    
    return [branch getFirstReferringParams];
}

- (void) getCredits:(NSString *) bucket {
    
    [branch loadRewardsWithCallback:^(BOOL changed, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_CREDITS_SUCCESSED" withParams:[NSString stringWithFormat: @"%ld", (long) [branch getCreditsForBucket:bucket]]];
        
        else
            [self dispatchEvent:@"GET_CREDITS_FAILED" withParams:error.description];
    }];
}

- (void) redeemRewards:(NSInteger) credits andBucket:(NSString *) bucket {
    
    [branch redeemRewards:credits forBucket:bucket callback:^(BOOL changed, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"REDEEM_REWARDS_SUCCESSED" withParams:@""];
        
        else
            [self dispatchEvent:@"REDEEM_REWARDS_FAILED" withParams:error.description];
    }];
}

- (void) getCreditsHistory:(NSString *) bucket {
    
    [branch getCreditHistoryForBucket:bucket andCallback:^(NSArray *list, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_CREDITS_HISTORY_SUCCESSED" withParams:[[list valueForKey:@"description"] componentsJoinedByString:@""]];
        
        else
            [self dispatchEvent:@"GET_CREDITS_HISTORY_FAILED" withParams:error.description];
    }];
}

- (void) getReferralCode {
    
    // deprecated?
}

- (void) createReferralCode:(NSString *)prefix amount:(NSInteger)amount expiration:(NSInteger)expiration bucket:(NSString *)bucket usageType:(NSInteger)usageType rewardLocation:(NSInteger)rewardLocation {
    
    // deprecated?
}

- (void) validateReferralCode:(NSString *) code {
    
    // deprecated?
}

- (void) applyReferralCode:(NSString *) code {
    
    // deprecated?
    
}

- (void) dispatchEvent:(NSString *) event withParams:(NSString * ) params {
    
    const uint8_t* par = (const uint8_t*) [params UTF8String];
    const uint8_t* evt = (const uint8_t*) [event UTF8String];
    
    FREDispatchStatusEventAsync(ctx, evt, par);
}

- (void) prepareUniversalObject:(nonnull FREObject) universalObject
{
    mCurrentUniversalObject = [self getUniversalObject:universalObject];
}

# pragma mark - Private

- (BranchLinkProperties*) getLinkProperties:(FREObject) asProps
{
    BranchLinkProperties* props = [[BranchLinkProperties alloc] init];
    
    NSString* alias = [[TypeConversion sharedInstance] getStringProperty:@"alias" object:asProps];
    NSString* channel = [[TypeConversion sharedInstance] getStringProperty:@"channel" object:asProps];
    NSString* feature = [[TypeConversion sharedInstance] getStringProperty:@"feature" object:asProps];
    NSString* stage = [[TypeConversion sharedInstance] getStringProperty:@"stage" object:asProps];
    NSString* controlParamsJson = [[TypeConversion sharedInstance] getStringProperty:@"controlParameters" object:asProps];
    
    if(alias != nil && [alias length] > 0)
    {
        [props setAlias:alias];
    }
    if(channel != nil && [channel length] > 0)
    {
        [props setChannel:channel];
    }
    if(feature != nil && [feature length] > 0)
    {
        [props setFeature:feature];
    }
    if(stage != nil && [stage length] > 0)
    {
        [props setStage:stage];
    }
    
    if(controlParamsJson != nil)
    {
        NSDictionary* controlParams = [[TypeConversion sharedInstance] getDictionaryFromJson:controlParamsJson];
        if(controlParams != nil)
        {
            [props setControlParams:controlParams];
        }
    }
    
    NSArray* tags = [[TypeConversion sharedInstance] getArrayProperty:@"tags" object:asProps];
    if(tags != nil && [tags count] > 0)
    {
        [props setTags:tags];
    }
    
    return props;
}

- (BranchUniversalObject*) getUniversalObject:(FREObject) asObject
{
    BranchUniversalObject* object = [[BranchUniversalObject alloc] init];
    
    NSString* canonicalIdentifier = [[TypeConversion sharedInstance] getStringProperty:@"canonicalIdentifier" object:asObject];
    NSString* title = [[TypeConversion sharedInstance] getStringProperty:@"title" object:asObject];
    NSString* contentDescription = [[TypeConversion sharedInstance] getStringProperty:@"contentDescription" object:asObject];
    NSString* contentImageUrl = [[TypeConversion sharedInstance] getStringProperty:@"contentImageUrl" object:asObject];
    NSString* contentIndexingMode = [[TypeConversion sharedInstance] getStringProperty:@"contentIndexingMode" object:asObject];
    NSString* contentMetadataJson = [[TypeConversion sharedInstance] getStringProperty:@"contentMetadata" object:asObject];
    
    if(canonicalIdentifier != nil && [canonicalIdentifier length] > 0)
    {
        [object setCanonicalIdentifier: canonicalIdentifier];
    }
    if(title != nil && [title length] > 0)
    {
        [object setTitle: title];
    }
    if(contentDescription != nil && [contentDescription length] > 0)
    {
        [object setContentDescription: contentDescription];
    }
    if(contentImageUrl != nil && [contentImageUrl length] > 0)
    {
        [object setImageUrl:contentImageUrl];
    }
    if(contentIndexingMode != nil && [contentIndexingMode length] > 0)
    {
        [object setContentIndexMode:[self getIndexMode: contentIndexingMode]];
    }
    
    if(contentMetadataJson != nil)
    {
        NSDictionary* metaData = [[TypeConversion sharedInstance] getDictionaryFromJson:contentMetadataJson];
        if(metaData != nil)
        {
            [object setMetadata:metaData];
        }
    }

    return object;
}

- (ContentIndexMode) getIndexMode:(NSString*) indexMode
{
    if([indexMode isEqualToString:@"private"])
    {
        return ContentIndexModePrivate;
    }
    return ContentIndexModePublic;
}

- (BOOL) overrideDelegate:(Class) delegateClass method:(SEL) delegateSelector withMethod:(SEL) swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(delegateClass, delegateSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(delegateClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
    
    if (didAddMethod)
    {
        class_replaceMethod(delegateClass,
                            delegateSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    return didAddMethod;
}

#pragma mark - Swizzled methods

- (BOOL) branchair_application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[Branch getInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if( [self respondsToSelector:@selector(branchair_application:openURL:sourceApplication:annotation:)] ) {
        return [self branchair_application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return NO;
}

- (BOOL) branchair_application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler
{
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    [[Branch getInstance] continueUserActivity:userActivity];
    
    if( [self respondsToSelector:@selector(branchair_application:continueUserActivity:restorationHandler:)] ) {
        [self branchair_application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        return handledByBranch;
    }
    
    return handledByBranch;
}

@end
