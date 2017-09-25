
package io.branch.nativeExtensions.branch.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import io.branch.indexing.BranchUniversalObject;
import io.branch.nativeExtensions.branch.BranchExtension;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;

public class PrepareUniversalObjectFunction extends BaseFunction
{

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        BranchExtension.currentUniversalObject = getUniversalObject(args[0]);

        return null;
    }

    private BranchUniversalObject getUniversalObject(FREObject asObject)
    {
        BranchUniversalObject object = new BranchUniversalObject();

        String canonicalIdentifier = getStringProperty("canonicalIdentifier", asObject);
        String title = getStringProperty("title", asObject);
        String contentDescription = getStringProperty("contentDescription", asObject);
        String contentImageUrl = getStringProperty("contentImageUrl", asObject);
        String contentIndexingMode = getStringProperty("contentIndexingMode", asObject);
        String contentMetadataJson = getStringProperty("contentMetadata", asObject);

        if(canonicalIdentifier != null && !canonicalIdentifier.isEmpty())
        {
            object.setCanonicalIdentifier(canonicalIdentifier);
        }
        if(title != null && !title.isEmpty())
        {
            object.setTitle(title);
        }
        if(contentDescription != null && !contentDescription.isEmpty())
        {
            object.setContentDescription(contentDescription);
        }
        if(contentImageUrl != null && !contentImageUrl.isEmpty())
        {
            object.setContentImageUrl(contentImageUrl);
        }
        if(contentIndexingMode != null && !contentIndexingMode.isEmpty())
        {
            object.setContentIndexingMode(getIndexMode(contentIndexingMode));
        }

        try
        {
            JSONObject controlParams = new JSONObject(contentMetadataJson);
            Iterator<String> keys = controlParams.keys();
            while(keys.hasNext())
            {
                String key = keys.next();
                Object val = controlParams.get(key);
                object.addContentMetadata(key, val.toString());
            }
        } catch (JSONException e)
        {
            e.printStackTrace();
        }

        return object;
    }

    private BranchUniversalObject.CONTENT_INDEX_MODE getIndexMode(String contentIndexingMode)
    {
        if(contentIndexingMode.equals("private"))
        {
            return BranchUniversalObject.CONTENT_INDEX_MODE.PRIVATE;
        }
        return BranchUniversalObject.CONTENT_INDEX_MODE.PUBLIC;
    }

}

