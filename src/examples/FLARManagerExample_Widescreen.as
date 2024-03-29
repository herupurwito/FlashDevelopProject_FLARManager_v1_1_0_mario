package examples {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.utils.time.FramerateDisplay;
	
	import examples.support.SimpleCubes_Away3D;
	
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * standard FLARToolkit Away3D example, with our friends the Cubes.
	 * this version displays the cubes, and accepts marker input,
	 * in lovely widescreen format (16:9).
	 * the aspect ratio is set in flarConfig_wide.xml.
	 * 
	 * code is borrowed heavily from Saqoosha, Mikko Haapoja, and Squidder.
	 * http://saqoosha.net/en/flartoolkit/start-up-guide/
	 * http://www.mikkoh.com/blog/?p=182
	 * http://www.squidder.com/2009/03/06/flar-how-to-multiple-instances-of-multiple-markers/#more-285
	 * 
	 * the Away3D platform can be found here:
	 * http://away3d.com/
	 * please note, usage of the Away3D platform is subject to Away3D's licensing.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARManagerExample_Widescreen extends Sprite {
		private var flarManager:FLARManager;
		private var simpleCubes:SimpleCubes_Away3D;
		
		public function FLARManagerExample_Widescreen () {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			
			// pass the path to the FLARManager xml config file into the FLARManager constructor.
			// FLARManager creates and uses a FLARCameraSource by default.
			// the image from the first detected camera will be used for marker detection.
			// also pass an IFLARTrackerManager instance to communicate with a tracking library,
			// and a reference to the Stage (required by some trackers).
			this.flarManager = new FLARManager("../resources/flar/flarConfig_wide.xml", new FLARToolkitManager(), this.stage);
			
			// to switch tracking engines, pass a different IFLARTrackerManager into FLARManager.
			// refer to this page for information on using different tracking engines:
			// http://words.transmote.com/wp/inside-flarmanager-tracking-engines/
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig_wide.xml", new FlareManager(), this.stage);
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig_wide.xml", new FlareNFTManager(), this.stage);
			
			// handle any errors generated during FLARManager initialization.
			this.flarManager.addEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			
			// add FLARManager.flarSource to the display list to display the video capture.
			this.addChild(Sprite(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents.
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			// framerate display helps to keep an eye on performance.
			var framerateDisplay:FramerateDisplay = new FramerateDisplay();
			this.addChild(framerateDisplay);
			
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}
		
		private function onFlarManagerError (evt:ErrorEvent) :void {
			this.flarManager.removeEventListener(ErrorEvent.ERROR, this.onFlarManagerError);
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			trace(evt.text);
			// NOTE: developers can include better feedback to the end user here if desired.
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			// viewport width/height are hardcoded here, but could also be tied to stageWidth/Height if desired.
			this.simpleCubes = new SimpleCubes_Away3D(this.flarManager, new Rectangle(0, 0, 640, 360));
			
			this.addChild(this.simpleCubes);
			
			// turn off interactivity in simpleCubes
			this.simpleCubes.mouseChildren = false;
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] added");
			this.simpleCubes.addMarker(evt.marker);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] removed");
			this.simpleCubes.removeMarker(evt.marker);
		}
	}
}