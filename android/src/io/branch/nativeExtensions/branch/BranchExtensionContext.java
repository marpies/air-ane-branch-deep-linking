package io.branch.nativeExtensions.branch;

import io.branch.nativeExtensions.branch.functions.*;

import java.util.HashMap;
import java.util.Map;

import android.content.Intent;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class BranchExtensionContext extends FREContext {

	@Override
	public void dispose() {
	}

	@Override
	public Map<String, FREFunction> getFunctions() {
		
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		
		functionMap.put("init", new InitFunction());
		functionMap.put("setIdentity", new SetIdentityFunction());
		functionMap.put("getShortUrl", new GetShortUrlFunction());
		functionMap.put("logout", new LogoutFunction());
		functionMap.put("getLatestReferringParams", new GetLatestReferringParamsFunction());
		functionMap.put("getFirstReferringParams", new GetFirstReferringParamsFunction());
		functionMap.put("userCompletedAction", new UserCompletedActionFunction());
		functionMap.put("getCredits", new GetCreditsFunction());
		functionMap.put("redeemRewards", new RedeemRewardsFunction());
		functionMap.put("getCreditsHistory", new GetCreditsHistoryFunction());
		functionMap.put("getReferralCode", new GetReferralCodeFunction());
		functionMap.put("applyReferralCode", new ApplyReferralCodeFunction());
		functionMap.put("createReferralCode", new CreateReferralCodeFunction());
		functionMap.put("validateReferralCode", new ValidateReferralCodeFunction());
		functionMap.put("closeSession", new CloseSessionFunction());
		functionMap.put("prepareUniversalObject", new PrepareUniversalObjectFunction());

		return functionMap;
	}
	
	public void initActivity(Boolean useTestKey) {
		
		Intent i = new Intent(getActivity().getApplicationContext(), BranchActivity.class);
		
		i.putExtra(BranchActivity.extraPrefix + ".useTestKey", useTestKey);
		
		getActivity().startActivity(i);
	}

}
