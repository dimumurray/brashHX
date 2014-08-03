package com.blendhx.editor.data;
import hxsl.Shader;

import flash.utils.ByteArray;
import flash.net.URLLoaderDataFormat;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.SecurityDomain;
import flash.display.LoaderInfo;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.display.Loader;
import flash.filesystem.File;
import flash.Vector;
import flash.events.Event;
import flash.events.IOErrorEvent;

import com.blendhx.core.Utils;
import com.blendhx.core.components.Component;
import com.blendhx.core.assets.Assets;
import com.blendhx.editor.data.Process;
import com.blendhx.editor.Debug;
import com.blendhx.editor.Progressbar;
import com.blendhx.editor.data.AS3DefinitionHelper;
import com.blendhx.core.shaders.DefaultShader;


/**

 * GPL

 */
class UserScripts
{
	
	public static var onScriptsLoaded:Void->Void;
	
	public static var userScriptsDomain:ApplicationDomain = new ApplicationDomain();
	
	public static function Compile():Void
	{
	
		if( Process.getInstance().isRunning() )
		{
			Debug.Log("There is another process running");
			return null;
		}
		
		var file:File = Assets.projectDirectory.resolvePath( "compile.cmd" );
		
		var args:Vector<String> = new Vector<String>();
		args.push(Assets.projectDirectory.nativePath);
		Progressbar.getInstance().show(true, "Compiling");
		
		var process:Process = Process.getInstance();
		process.onComplete = loadScripts;
		process.startProcess(args, file);
	}
	
	public static function loadScripts()
	{	
		var uldr : URLLoader = new URLLoader();
		var request:URLRequest = new URLRequest( Assets.casheDirectory.resolvePath( "scripts.swf" ).nativePath );
		
		uldr.dataFormat = URLLoaderDataFormat.BINARY;
		uldr.addEventListener(Event.COMPLETE, onBytesComplete);
		uldr.addEventListener(IOErrorEvent.IO_ERROR, onScriptsNotFound);
		uldr.load( request );
	}
	private static function onScriptsNotFound(e:IOErrorEvent)
	{
		var uldr : URLLoader = cast (e.target, URLLoader);
		uldr.removeEventListener(Event.COMPLETE, onBytesComplete);
		uldr.removeEventListener(IOErrorEvent.IO_ERROR, onScriptsNotFound);
		
		if ( onScriptsLoaded != null)
			onScriptsLoaded();
		onScriptsLoaded = null;
		
		Debug.Log("Problem loading user scripts");
	}

	private static function onBytesComplete(e : Event)
	{
		var uldr : URLLoader = cast (e.target, URLLoader);
		uldr.removeEventListener(Event.COMPLETE, onBytesComplete);
		uldr.removeEventListener(IOErrorEvent.IO_ERROR, onScriptsNotFound);
		
		var bytes : ByteArray = uldr.data;
		var loader:Loader = new Loader();
		var ldrC : LoaderContext = new LoaderContext();
		userScriptsDomain = new ApplicationDomain(  ApplicationDomain.currentDomain );
		
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, scriptsLoaded);
		ldrC.applicationDomain = userScriptsDomain;
		ldrC.allowCodeImport = true;
		loader.loadBytes(bytes, ldrC);
		
		uldr.data = null;
		uldr = null;
	}

	private static function scriptsLoaded( e:Event )
	{
		cast (e.target, LoaderInfo).loader.removeEventListener(Event.COMPLETE, scriptsLoaded);
		
		if ( onScriptsLoaded != null)
			onScriptsLoaded();
		onScriptsLoaded = null;
	}
	
	public static function GetComponent( classURL:String ):Component
	{
		var componentClass:Class<Dynamic> = userScriptsDomain.getDefinition( Utils.GetClassNameFromURL( classURL ) ); 
		if(componentClass == null)
		{
			Debug.Log("Script definition not found. Consider re compiling");
			return null;
		}
		else if(Type.getSuperClass(componentClass) != Component)
		{
			Debug.Log("Applied script is not extending com.blendhx.Component");
			return null;
		}
		
		var className:String = Utils.GetClassNameFromURL( classURL );
		var component:Component = cast(AS3DefinitionHelper.Instantiate(userScriptsDomain, className, Component), Component);
		
		return component;
	}
	
	public static function GetShader( classURL:String ):Shader
	{
		var className:String = Utils.GetClassNameFromURL( classURL );
		var shader:Shader;
		
		shader =  cast(AS3DefinitionHelper.Instantiate(userScriptsDomain, className, Shader), Shader);
		
		if(shader == null)
		{
			shader = new DefaultShader();
			shader.create(ApplicationDomain.currentDomain);
		}
		else
		{
			shader.create(userScriptsDomain);
		}
		
		return shader;
	}
}