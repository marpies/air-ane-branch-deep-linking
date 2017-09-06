//
//  BranchHelpers.m
//  BranchIosExtension
//
//  Created by Aymeric Lamboley on 13/04/2015.
//  Copyright (c) 2015 Pawprint Labs. All rights reserved.
//

#import "BranchHelpers.h"
#import "TypeConversion.h"

@implementation BranchHelpers

- (id) initWithContext:(FREContext) context {
    
    if (self = [super init])
        ctx = context;
    
    return self;
}

- (void) initBranch:(BOOL) useTestKey {
    Branch.useTestBranchKey = useTestKey;
    
    [[Branch getInstance] initSessionWithLaunchOptions:@{} andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        
        if (!error) {
            
            NSError *error;
            NSData *JSONData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:&error];
            NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
            
            if (error) {
                [self dispatchEvent:@"INIT_FAILED" withParams:error.description];
                return;
            }

            [self dispatchEvent:@"INIT_SUCCESSED" withParams:JSONString];
            
        } else {
            
            [self dispatchEvent:@"INIT_FAILED" withParams:error.description];
        }
    }];
}

- (void) setIdentity:(NSString *) userId {
    [[Branch getInstance] setIdentity:userId withCallback:^(NSDictionary *params, NSError *error) {

        if (!error) {
            
            [self dispatchEvent:@"SET_IDENTITY_SUCCESSED" withParams:@""];
            
        } else {
            
            [self dispatchEvent:@"SET_IDENTITY_FAILED" withParams:error.description];
        }
    }];
}

- (void) getShortURL:(NSString *) json andTags:(NSArray *) tags andChannel:(NSString *) channel andFeature:(NSString *) feature andStage:(NSString *) stage andAlias:(NSString *) alias andType:(int) type {
    
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    
    NSDictionary* params = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    
    if (jsonError) {
        [self dispatchEvent:@"GET_SHORT_URL_FAILED" withParams:jsonError.description];
        return;
    }
    
    callbackWithUrl callback = ^(NSString *url, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_SHORT_URL_SUCCESSED" withParams:url];
        
        else
            [self dispatchEvent:@"GET_SHORT_URL_FAILED" withParams:error.description];
    };
    
    if (alias.length != 0)
        [[Branch getInstance] getShortURLWithParams:params andTags:tags andChannel:channel andFeature:feature andStage:stage andAlias:alias andCallback:callback];
    
    else if (type != -1)
        [[Branch getInstance] getShortURLWithParams:params andTags:tags andChannel:channel andFeature:feature andStage:stage andType:type andCallback:callback];
    else
        [[Branch getInstance] getShortURLWithParams:params andTags:tags andChannel:channel andFeature:feature andStage:stage andCallback:callback];
}

- (void) logout {
    
    [[Branch getInstance] logout];
}

- (void) userCompletedAction:(NSString *) action withState:(NSString *) appState {
    
    NSData *data = [appState dataUsingEncoding:NSUTF8StringEncoding];
    NSError *jsonError;
    
    NSDictionary* params = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
    
    if (!jsonError)
        [[Branch getInstance] userCompletedAction:action withState:params];
}

- (NSDictionary *) getLatestReferringParams {
    
    return [[Branch getInstance] getLatestReferringParams];
}

- (NSDictionary *) getFirstReferringParams {
    
    return [[Branch getInstance] getFirstReferringParams];
}

- (void) getCredits:(NSString *) bucket {
    
    [[Branch getInstance] loadRewardsWithCallback:^(BOOL changed, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_CREDITS_SUCCESSED" withParams:[NSString stringWithFormat: @"%ld", (long) [[Branch getInstance] getCreditsForBucket:bucket]]];
        
        else
            [self dispatchEvent:@"GET_CREDITS_FAILED" withParams:error.description];
    }];
}

- (void) redeemRewards:(NSInteger) credits andBucket:(NSString *) bucket {
    
    [[Branch getInstance] redeemRewards:credits forBucket:bucket callback:^(BOOL changed, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"REDEEM_REWARDS_SUCCESSED" withParams:@""];
        
        else
            [self dispatchEvent:@"REDEEM_REWARDS_FAILED" withParams:error.description];
    }];
}

- (void) getCreditsHistory:(NSString *) bucket {
    
    [[Branch getInstance] getCreditHistoryForBucket:bucket andCallback:^(NSArray *list, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_CREDITS_HISTORY_SUCCESSED" withParams:[[list valueForKey:@"description"] componentsJoinedByString:@""]];
        
        else
            [self dispatchEvent:@"GET_CREDITS_HISTORY_FAILED" withParams:error.description];
    }];
}

/*
- (void) getReferralCode {
    
    [[Branch getInstance] getPromoCodeWithCallback:^(NSDictionary *params, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"GET_REFERRAL_CODE_SUCCESSED" withParams:[params objectForKey:@"promo_code"]];
        
        else
            [self dispatchEvent:@"GET_REFERRAL_CODE_FAILED" withParams:error.description];
    }];
}

- (void) createReferralCode:(NSString *)prefix amount:(NSInteger)amount expiration:(NSInteger)expiration bucket:(NSString *)bucket usageType:(NSInteger)usageType rewardLocation:(NSInteger)rewardLocation {
    
    
    [[Branch getInstance] getPromoCodeWithPrefix:prefix amount:amount expiration:[NSDate dateWithTimeIntervalSince1970:expiration / 1000] bucket:bucket usageType:usageType rewardLocation:rewardLocation callback:^(NSDictionary *params, NSError *error) {
        
        if (!error)
            [self dispatchEvent:@"CREATE_REFERRAL_CODE_SUCCESSED" withParams:[params objectForKey:@"promo_code"]];
        
        else
            [self dispatchEvent:@"CREATE_REFERRAL_CODE_FAILED" withParams:error.description];
    }];
}

- (void) validateReferralCode:(NSString *) code {
    
    [[Branch getInstance] validatePromoCode:code callback:^(NSDictionary *params, NSError *error) {
        
        if (!error) {
            
            if ([code isEqualToString:[params objectForKey:@"promo_code"]])
                [self dispatchEvent:@"VALIDATE_REFERRAL_CODE_SUCCESSED" withParams:@""];
            
            else
                [self dispatchEvent:@"VALIDATE_REFERRAL_CODE_FAILED" withParams:@"invalid (should never happen)"];
            
        } else
            [self dispatchEvent:@"VALIDATE_REFERRAL_CODE_FAILED" withParams:error.description];
    }];
}

- (void) applyReferralCode:(NSString *) code {
    
    [[Branch getInstance] applyPromoCode:code callback:^(NSDictionary *params, NSError *error) {
        
        if (!error) {
            
            NSString *JSONString = [TypeConversion ConvertNSDictionaryToJSONString:params];
            
            [self dispatchEvent:@"APPLY_REFERRAL_CODE_SUCCESSED" withParams:JSONString];
            
        } else
            [self dispatchEvent:@"APPLY_REFERRAL_CODE_FAILED" withParams:error.description];
    }];
    
}
// */

- (void) dispatchEvent:(NSString *) event withParams:(NSString * ) params {
    
    const uint8_t* par = (const uint8_t*) [params UTF8String];
    const uint8_t* evt = (const uint8_t*) [event UTF8String];
    
    FREDispatchStatusEventAsync(ctx, evt, par);
}

@end
