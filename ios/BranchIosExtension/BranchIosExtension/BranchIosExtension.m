//
//  BranchIosExtension.m
//  BranchIosExtension
//
//  Created by Aymeric Lamboley on 08/04/2015.
//  Copyright (c) 2015 Pawprint Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#import "FlashRuntimeExtensions.h"

#import "TypeConversion.h"
#import "BranchHelpers.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }


TypeConversion* typeConverter;
BranchHelpers* branchHelpers;

DEFINE_ANE_FUNCTION(init) {
    
    uint32_t useTestKey;
    FREGetObjectAsBool(argv[0], &useTestKey);
    
    [branchHelpers initBranch:useTestKey];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(setIdentity) {
    
    NSString* userId;
    [typeConverter FREGetObject:argv[0] asString:&userId];
    
    [branchHelpers setIdentity:userId];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(getShortUrl) {
    
    FREObject linkProperties = argv[0];
    
    [branchHelpers getShortURL:linkProperties];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(logout) {
    
    [branchHelpers logout];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(userCompletedAction) {
    
    NSString* action;
    [typeConverter FREGetObject:argv[0] asString:&action];
    
    [branchHelpers userCompletedAction:action];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(getLatestReferringParams) {
    
    NSDictionary *sessionParams = [branchHelpers getLatestReferringParams];
    NSString *JSONString = [TypeConversion ConvertNSDictionaryToJSONString:sessionParams];

    FREObject retStr;
    [typeConverter FREGetString:JSONString asObject:&retStr];

    return retStr;
}

DEFINE_ANE_FUNCTION(getFirstReferringParams) {
    
    NSDictionary *installParams = [branchHelpers getFirstReferringParams];
    NSString *JSONString = [TypeConversion ConvertNSDictionaryToJSONString:installParams];
    
    FREObject retStr;
    [typeConverter FREGetString:JSONString asObject:&retStr];
    
    return retStr;
}

DEFINE_ANE_FUNCTION(getCredits) {
    
    NSString* bucket;
    [typeConverter FREGetObject:argv[0] asString:&bucket];
    
    [branchHelpers getCredits:bucket];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(redeemRewards) {
    
    int32_t credits;
    FREGetObjectAsInt32(argv[0], &credits);
    
    NSString* bucket;
    [typeConverter FREGetObject:argv[1] asString:&bucket];
    
    [branchHelpers redeemRewards:credits andBucket:bucket];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(getCreditsHistory) {
    
    NSString* bucket;
    [typeConverter FREGetObject:argv[0] asString:&bucket];
    
    [branchHelpers getCreditsHistory:bucket];
    
    return  NULL;
}

DEFINE_ANE_FUNCTION(getReferralCode) {
    
    [branchHelpers getReferralCode];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(createReferralCode) {
    
    NSString* prefix;
    [typeConverter FREGetObject:argv[0] asString:&prefix];
    
    int32_t amount;
    FREGetObjectAsInt32(argv[1], &amount);
    
    int32_t expiration;
    FREGetObjectAsInt32(argv[2], &expiration);
    
    NSString* bucket;
    [typeConverter FREGetObject:argv[3] asString:&bucket];
    
    int32_t type;
    FREGetObjectAsInt32(argv[4], &type);
    
    int32_t rewardLocation;
    FREGetObjectAsInt32(argv[5], &rewardLocation);
    
    [branchHelpers createReferralCode:prefix amount:amount expiration:expiration bucket:bucket usageType:type rewardLocation:rewardLocation];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(validateReferralCode) {
    
    NSString* code;
    [typeConverter FREGetObject:argv[0] asString:&code];
    
    [branchHelpers validateReferralCode:code];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(applyReferralCode) {
    
    NSString* code;
    [typeConverter FREGetObject:argv[0] asString:&code];
    
    [branchHelpers applyReferralCode:code];
    
    return NULL;
}

DEFINE_ANE_FUNCTION(prepareUniversalObject) {
    
    [branchHelpers prepareUniversalObject:argv[0]];
    
    return NULL;
}

void BranchContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
    
    static FRENamedFunction functionMap[] = {
        MAP_FUNCTION(init, NULL),
        MAP_FUNCTION(setIdentity, NULL),
        MAP_FUNCTION(getShortUrl, NULL),
        MAP_FUNCTION(logout, NULL),
        MAP_FUNCTION(userCompletedAction, NULL),
        MAP_FUNCTION(getLatestReferringParams, NULL),
        MAP_FUNCTION(getFirstReferringParams, NULL),
        MAP_FUNCTION(getCredits, NULL),
        MAP_FUNCTION(redeemRewards, NULL),
        MAP_FUNCTION(getCreditsHistory, NULL),
        MAP_FUNCTION(getReferralCode, NULL),
        MAP_FUNCTION(createReferralCode, NULL),
        MAP_FUNCTION(validateReferralCode, NULL),
        MAP_FUNCTION(applyReferralCode, NULL),
        MAP_FUNCTION(prepareUniversalObject, NULL)
    };
    
    *numFunctionsToSet = sizeof( functionMap ) / sizeof( FRENamedFunction );
    *functionsToSet = functionMap;
    
    typeConverter = [TypeConversion sharedInstance];
    branchHelpers = [[BranchHelpers alloc] initWithContext:ctx];
}

void BranchContextFinalizer(FREContext ctx) {
    return;
}

void BranchExtensionInitializer( void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    
    extDataToSet = NULL;
    *ctxInitializerToSet = &BranchContextInitializer;
    *ctxFinalizerToSet = &BranchContextFinalizer;
}

void BranchExtensionFinalizer() {
    return;
}
