package io.branch.nativeExtensions.branch.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import io.branch.nativeExtensions.branch.BranchExtension;

public class UserCompletedActionFunction extends BaseFunction implements FREFunction {
	
	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		super.call(context, args);
		
		String action = getStringFromFREObject(args[0]);

        if(BranchExtension.currentUniversalObject != null)
        {
            BranchExtension.currentUniversalObject.userCompletedAction(action);
        }
		
		return null;
	}
}
