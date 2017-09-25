package io.branch.nativeExtensions.branch
{
	
	public class BranchUniversalObject
	{
		private var _canonicalIdentifier:String = "";
		private var _title:String = "";
		private var _contentDescription:String = "";
		private var _contentImageUrl:String = "";
		private var _contentIndexingMode:String = "";
		private var _contentMetadata:String = "{}";

		public function BranchUniversalObject()
		{
		}
		

		public function get canonicalIdentifier():String
		{
			return _canonicalIdentifier;
		}


		public function setCanonicalIdentifier(value:String):BranchUniversalObject
		{
			if(value == null)
			{
				value = "";
			}

			_canonicalIdentifier = value;
			return this;
		}


		public function get title():String
		{
			return _title;
		}


		public function setTitle(value:String):BranchUniversalObject
		{
			if(value == null)
			{
				value = "";
			}

			_title = value;
			return this;
		}


		public function get contentDescription():String
		{
			return _contentDescription;
		}


		public function setContentDescription(value:String):BranchUniversalObject
		{
			if(value == null)
			{
				value = "";
			}

			_contentDescription = value;
			return this;
		}


		public function get contentImageUrl():String
		{
			return _contentImageUrl;
		}


		public function setContentImageUrl(value:String):BranchUniversalObject
		{
			if(value == null)
			{
				value = "";
			}

			_contentImageUrl = value;
			return this;
		}


		public function get contentIndexingMode():String
		{
			return _contentIndexingMode;
		}


		public function setContentIndexingMode(value:String):BranchUniversalObject
		{
			if(value == null)
			{
				value = "";
			}

			_contentIndexingMode = value;
			return this;
		}


		public function get contentMetadata():String
		{
			return _contentMetadata;
		}


		public function setContentMetadata(value:Object):BranchUniversalObject
		{
			if(value == null)
			{
				value = {};
			}

			_contentMetadata = JSON.stringify(value);
			return this;
		}
	}
	
}
