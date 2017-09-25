package io.branch.nativeExtensions.branch.functions;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import io.branch.nativeExtensions.branch.BranchExtension;
import io.branch.referral.Branch.BranchLinkCreateListener;
import io.branch.referral.BranchError;
import io.branch.referral.util.LinkProperties;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Iterator;
import java.util.List;

public class GetShortUrlFunction extends BaseFunction implements BranchLinkCreateListener
{

    @Override
    public FREObject call(FREContext context, FREObject[] args)
    {
        super.call(context, args);

        if(BranchExtension.currentUniversalObject == null)
        {
            BranchExtension.context.dispatchStatusEventAsync("GET_SHORT_URL_FAILED", "Universal object must be prepared before requesting URL.");
            return null;
        }

        LinkProperties props = getLinkProperties(args[0]);

        BranchExtension.currentUniversalObject.generateShortUrl(context.getActivity().getApplicationContext(), props, this);

        return null;
    }

    private LinkProperties getLinkProperties(FREObject asProps)
    {
        LinkProperties props = new LinkProperties();

        String alias = getStringProperty("alias", asProps);
        String channel = getStringProperty("channel", asProps);
        String feature = getStringProperty("feature", asProps);
        String stage = getStringProperty("stage", asProps);
        String controlParamsJson = getStringProperty("controlParameters", asProps);

        if(alias != null && !alias.isEmpty())
        {
            props.setAlias(alias);
        }
        if(channel != null && !channel.isEmpty())
        {
            props.setChannel(channel);
        }
        if(feature != null && !feature.isEmpty())
        {
            props.setFeature(feature);
        }
        if(stage != null && !stage.isEmpty())
        {
            props.setStage(stage);
        }

        try
        {
            JSONObject controlParams = new JSONObject(controlParamsJson);
            Iterator<String> keys = controlParams.keys();
            while(keys.hasNext())
            {
                String key = keys.next();
                Object val = controlParams.get(key);
                props.addControlParameter(key, val.toString());
            }
        } catch (JSONException e)
        {
            e.printStackTrace();
        }

        List<String> tags = getStringArrayProperty("tags", asProps);
        if(tags != null && tags.size() > 0)
        {
            for(String tag : tags)
            {
                props.addTag(tag);
            }
        }

        return props;
    }

    @Override
    public void onLinkCreate(String url, BranchError branchError)
    {
        if (branchError == null)
        {
            BranchExtension.context.dispatchStatusEventAsync("GET_SHORT_URL_SUCCESSED", url);
        }
        else
        {
            BranchExtension.context.dispatchStatusEventAsync("GET_SHORT_URL_FAILED", branchError.getMessage());
        }
    }
}
