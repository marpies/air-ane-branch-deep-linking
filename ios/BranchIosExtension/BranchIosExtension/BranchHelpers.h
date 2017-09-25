//
//  BranchHelpers.h
//  BranchIosExtension
//
//  Created by Aymeric Lamboley on 13/04/2015.
//  Copyright (c) 2015 Pawprint Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FlashRuntimeExtensions.h"
#import "Branch.h"

@interface BranchHelpers : NSObject {
    
    FREContext ctx;
    Branch *branch;
}

- (id) initWithContext:(FREContext) context;

- (void) initBranch:(BOOL) useTestKey;
- (void) setIdentity:(NSString *) userId;
- (void) getShortURL:(FREObject) linkProperties;
- (void) logout;

- (NSDictionary *) getLatestReferringParams;
- (NSDictionary *) getFirstReferringParams;
- (void) userCompletedAction:(NSString *) action;
- (void) getCredits:(NSString *) bucket;
- (void) redeemRewards:(NSInteger) credits andBucket:(NSString *) bucket;
- (void) getCreditsHistory:(NSString *) bucket;
- (void) getReferralCode;
- (void) createReferralCode:(NSString *)prefix amount:(NSInteger)amount expiration:(NSInteger)expiration bucket:(NSString *)bucket usageType:(NSInteger)usageType rewardLocation:(NSInteger)rewardLocation;
- (void) validateReferralCode:(NSString *) code;
- (void) applyReferralCode:(NSString *) code;

- (void) prepareUniversalObject:(nonnull FREObject) universalObject;

- (void) dispatchEvent:(NSString *) event withParams:(NSString * ) params;

@end
