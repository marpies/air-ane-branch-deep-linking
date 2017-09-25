package io.branch.nativeExtensions.branch;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import io.branch.indexing.BranchUniversalObject;

public class BranchExtension implements FREExtension {
	
	static public BranchExtensionContext context;
    static public BranchUniversalObject currentUniversalObject;
	
	@Override
	public FREContext createContext(String label) {
		
		return context = new BranchExtensionContext();
	}
	
	@Override
	public void dispose() {
		
		context = null;
	}
	
	@Override
	public void initialize() {
		
	}

}
