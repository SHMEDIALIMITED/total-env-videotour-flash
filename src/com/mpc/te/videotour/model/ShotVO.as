package com.mpc.te.videotour.model
{
	public class ShotVO {
		
		public var id:String;
		public var videoSource:Vector.<String> = new Vector.<String>();
		public var videoSourceLow:Vector.<String> = new Vector.<String>();
		public var nextVideo:String = "";
		public var prevVideo:String = "";
		public var pictureTracks:Vector.<Vector.<PictureTrackVO>>;
		public var hotspotTracks:Vector.<Vector.<HotspotVO>> = new Vector.<Vector.<HotspotVO>>();
		
	}
}