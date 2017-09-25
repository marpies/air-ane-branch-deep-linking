package io.branch.nativeExtensions.branch
{
	
	public class BranchLinkProperties
	{
		private var _channel:String = "";
		private var _feature:String = "";
		private var _alias:String = "";
		private var _stage:String = "";
		private var _tags:Vector.<String> = new <String>[];
		private var _controlParameters:String = "{}";

		public function BranchLinkProperties()
		{
		}
		

		public function get channel():String
		{
			return _channel;
		}


		public function setChannel(value:String):BranchLinkProperties
		{
			if(value == null)
			{
				value = "";
			}

			_channel = value;
			return this;
		}


		public function get feature():String
		{
			return _feature;
		}


		public function setFeature(value:String):BranchLinkProperties
		{
			if(value == null)
			{
				value = "";
			}

			_feature = value;
			return this;
		}


		public function get alias():String
		{
			return _alias;
		}


		public function setAlias(value:String):BranchLinkProperties
		{
			if(value == null)
			{
				value = "";
			}

			_alias = value;
			return this;
		}


		public function get stage():String
		{
			return _stage;
		}


		public function setStage(value:String):BranchLinkProperties
		{
			if(value == null)
			{
				value = "";
			}

			_stage = value;
			return this;
		}


		public function get tags():Vector.<String>
		{
			return _tags;
		}


		public function setTags(value:Vector.<String>):BranchLinkProperties
		{
			if(value == null)
			{
				value = new <String>[];
			}

			_tags = value;
			return this;
		}


		public function get controlParameters():String
		{
			return _controlParameters;
		}


		public function setControlParameters(value:Object):BranchLinkProperties
		{
			if(value == null)
			{
				value = {};
			}

			_controlParameters = JSON.stringify(value);
			return this;
		}
	}
	
}
