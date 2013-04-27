package examples {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.utils.Cast;
	import away3d.events.Loader3DEvent;
	import away3d.lights.DirectionalLight3D;
	import away3d.loaders.AbstractParser;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;
	import away3d.loaders.utils.AnimationLibrary;
	import away3d.materials.BitmapMaterial;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.camera.FLARCamera_Away3D;
	import com.transmote.flar.camera.FLARCamera_PV3D;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.flar.utils.geom.AwayGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	
	/**
	 * This file (MultiMarkerMultiCollada.as) is modification of the standard
	 * example file to display collada-formatted model using FLARManager v1.1,
	 * FLARToolkit, and Away3D (FLARManagerTutorial_Collada_Away3D.as) authored 
	 * by Eric Socolofsky (http://transmote.com/flar). The collada model used 
	 * for this example (mario_testrun.dae) comes from Away3D's examples.
	 * 
	 * The method to display multiple colladas on multiple markers is derived
	 * from a code to display multiple colladas on multiple markers using 
	 * previous version of FLARManager, FLARToolkit, and Papervision3D
	 * (http://www.looneydoodle.com/MultiMarkerMultiCollada.zip) authored by
	 * Arunram Kalaiselvan aka lOOney dOOdle (http://www.looneydoodle.com/).
	 * 
	 * @author	Fathah Noor Prawita
	 * @url		http://blog.fathah.net
	 * 
	 * customized by herupurwito - herupurwito.wordpress.com 
	 */
	
	public class MultiMarkerMultiCollada extends Sprite {
		private var flarManager:FLARManager;
		
		private var view:View3D;
		private var camera3D:FLARCamera_Away3D;
		private var scene3D:Scene3D;
		private var light:DirectionalLight3D;
		
		private var activeMarkerMarioMerah:FLARMarker;
		private var activeMarkerMarioIjo:FLARMarker;
		private var activeMarkerZoom:FLARMarker;
		
		private var modelLoader:Loader3D;
		
		private var modelContainerMarioMerah:ObjectContainer3D;
		private var modelContainerMarioIjo:ObjectContainer3D;
		
		
		
		// texture file for mario
		[Embed(source="../../resources/assets/mario_tex_red-blue.jpg")]
		private var MarioTextureRedBlue:Class;
		
		[Embed(source="../../resources/assets/mario_tex_green-red.jpg")]
		private var MarioTextureGreenRed:Class;
		
		
		// collada file for mario
		[Embed(source="../../resources/assets/mario_testrun.dae",mimeType="application/octet-stream")]
		private var MarioDae:Class;
		
				
		public function MultiMarkerMultiCollada () {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			
			// pass the path to the FLARManager xml config file into the FLARManager constructor.
			// FLARManager creates and uses a FLARCameraSource by default.
			// the image from the first detected camera will be used for marker detection.
			// also pass an IFLARTrackerManager instance to communicate with a tracking library,
			// and a reference to the Stage (required by some trackers).
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			
			// to switch tracking engines, pass a different IFLARTrackerManager into FLARManager.
			// refer to this page for information on using different tracking engines:
			// http://words.transmote.com/wp/inside-flarmanager-tracking-engines/
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FlareManager(), this.stage);
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FlareNFTManager(), this.stage);
			
			// add FLARManager.flarSource to the display list to display the video capture.
			this.addChild(Sprite(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents.
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			// wait for FLARManager to initialize before setting up Away3D environment.
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			this.scene3D = new Scene3D();
			this.camera3D = new FLARCamera_Away3D(this.flarManager, new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight));
			this.view = new View3D({x:0.5*this.stage.stageWidth, y:0.5*this.stage.stageHeight, scene:this.scene3D, camera:this.camera3D});
			this.addChild(this.view);
			
			this.light = new DirectionalLight3D();
			this.light.direction = new Vector3D(500, -300, 200);
			this.scene3D.addLight(light);
			
			
			//--------------------------------------3D-Model merah----
			var colladaMarioMerah:Collada = new Collada();
			colladaMarioMerah.scaling = 10;
			var modelMarioMerah:ObjectContainer3D = colladaMarioMerah.parseGeometry(MarioDae) as ObjectContainer3D;
			modelMarioMerah.materialLibrary.getMaterial("FF_FF_FF_mario1").material = new BitmapMaterial(Cast.bitmap(MarioTextureRedBlue));
			modelMarioMerah.mouseEnabled = false;
			modelMarioMerah.rotationX = 180;
			modelMarioMerah.rotationZ = 180;
			
			// create a container for the model, that will accept matrix transformations.
			this.modelContainerMarioMerah = new ObjectContainer3D();
			this.modelContainerMarioMerah.addChild(modelMarioMerah);
			this.modelContainerMarioMerah.visible = false;
			this.scene3D.addChild(this.modelContainerMarioMerah);
			
			
			//--------------------------------------3D-Model ijo----
			var colladaMarioIjo:Collada = new Collada();
			colladaMarioIjo.scaling = 10;
			var modelMarioIjo:ObjectContainer3D = colladaMarioIjo.parseGeometry(MarioDae) as ObjectContainer3D;
			modelMarioIjo.materialLibrary.getMaterial("FF_FF_FF_mario1").material = new BitmapMaterial(Cast.bitmap(MarioTextureGreenRed));
			modelMarioIjo.mouseEnabled = false;
			modelMarioIjo.rotationX = 180;
			modelMarioIjo.rotationZ = 180;
			
			// create a container for the model, that will accept matrix transformations.
			this.modelContainerMarioIjo = new ObjectContainer3D();
			this.modelContainerMarioIjo.addChild(modelMarioIjo);
			this.modelContainerMarioIjo.visible = false;
			this.scene3D.addChild(this.modelContainerMarioIjo);
			
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] added");
			
			if (evt.marker.patternId == 0) {
				markerAdded(0);
				this.activeMarkerMarioMerah = evt.marker;
			}
			
			if (evt.marker.patternId == 1) {
				markerAdded(1);
				this.activeMarkerMarioIjo = evt.marker;
			}
			
			if (evt.marker.patternId == 2) {
				this.activeMarkerZoom = evt.marker;
			}
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] updated");
			
			if (evt.marker.patternId == 0) {
				markerAdded(0);
				this.activeMarkerMarioMerah = evt.marker;
			}
			
			if (evt.marker.patternId == 1) {
				markerAdded(1);
				this.activeMarkerMarioIjo = evt.marker;
			}
			
			if (evt.marker.patternId == 2) {
				this.activeMarkerZoom = evt.marker;
			}
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] removed");
			
			if (evt.marker.patternId == 0) {
				markerRemoved(0);
			}
			
			if (evt.marker.patternId == 1) {
				markerRemoved(1);
			}
			
			this.activeMarkerMarioMerah = null;
			this.activeMarkerMarioIjo = null;
			this.activeMarkerZoom = null;
		}
		
		private function onEnterFrame (evt:Event) :void {
			// apply the FLARToolkit transformation matrix to the Cube.
			if (this.activeMarkerMarioMerah) {
				this.modelContainerMarioMerah.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.activeMarkerMarioMerah.transformMatrix);
				if (this.activeMarkerZoom) {
					this.modelContainerMarioMerah.scale(2);
				}
			}
			
			if (this.activeMarkerMarioIjo) {
				this.modelContainerMarioIjo.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.activeMarkerMarioIjo.transformMatrix);
				if (this.activeMarkerZoom) {
					this.modelContainerMarioIjo.scale(2);
				}
			}
			
			this.view.render();
		}
		
		private function markerAdded(markerId:int):void {
			switch(markerId) {
				case 0: {
					if (modelContainerMarioMerah.visible == false) {
						modelContainerMarioMerah.visible = true;
						break;
					} else {
						break;
					}
				}
				case 1: {
					if (modelContainerMarioIjo.visible == false) {
						modelContainerMarioIjo.visible = true;
						break;
					} else {
						break;
					}
				}
				
			}
		}
		
		private function markerRemoved(markerId:int):void {
			switch(markerId) {
				case 0: {
					if (modelContainerMarioMerah.visible == true) {
						modelContainerMarioMerah.visible = false;
						break;
					} else {
						break;
					}
				}
				case 1: {
					if (modelContainerMarioIjo.visible == true) {
						modelContainerMarioIjo.visible = false;
						break;
					} else {
						break;
					}
				}
				
			}
		}
	}
}
