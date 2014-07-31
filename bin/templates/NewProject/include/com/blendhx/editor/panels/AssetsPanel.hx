package com.blendhx.editor.panels;
import com.blendhx.core.assets.Assets;

import flash.errors.IllegalOperationError;
import flash.errors.Error;
import flash.events.ErrorEvent;
import com.blendhx.core.components.GameObject;
import com.blendhx.editor.uicomponents.Button;
import com.blendhx.editor.assets.FileType;


import com.blendhx.core.*;
import com.blendhx.editor.spaces.*;
import com.blendhx.editor.panels.*;
import com.blendhx.core.components.*;
import flash.events.Event;
import flash.display.Graphics;
import flash.filesystem.File;

/**
* @author 
 */
class AssetsPanel extends Panel
{
	public static var padding:Float = 20;
	public static var colomnWidth:Float = 300;
	public static var rows:Int = 0;
	public static var colomns:Int = 0;
	
	public static  var currentDirectory:File;
	
	public var fileItems:Array<FileItem>;
	private var fileItemPool:Array<FileItem>;
	
	private static var instance:AssetsPanel;
	public static inline function getInstance()
  	{
    	if (instance == null)
          return instance = new AssetsPanel();
      	else
          return instance;
  	}	
	
	public function new() 
	{
		super("File Browser", Space.SPACE_WIDTH);
		
		fileItems = new Array<FileItem>();
		fileItemPool = new Array<FileItem>();
		
		currentDirectory =  Assets.sourceDirectory;
	}
	
	public function clearItems() 
	{
		
		for (item in fileItems)
		{
			removeChild( item );
		}
	
		fileItems = [];
	}
	private function getItemFromPool(fileName:String, extension:String,  onClick:FileItem->Void)
	{
		var item:FileItem;
			
		if( fileItemPool[fileItems.length] == null)
		{
			item = new FileItem(fileName, extension, onItemClick); 
			fileItemPool.push(item);
		}
		
		item = fileItemPool[fileItems.length];
		item.init(fileName, extension);
		fileItems.push(item);
		return item;
			
	}

	public function populate()
	{
		clearItems();
		
		var files:Array<File> = currentDirectory.getDirectoryListing();
		var fileItem:FileItem;
		var row:Int = 0;
		var colomn:Int = 0;
		
		
		if (currentDirectory.nativePath !=  Assets.sourceDirectory.nativePath)
		{
			fileItem = getItemFromPool("...", "back", onItemClick);
			
			fileItem.x = colomn * colomnWidth + padding/2;
			fileItem.y = row * padding + 1;
			
			addChild( fileItem );
			row = 1;
		}
		
		
		for(file in files)
		{
			
			fileItem = getItemFromPool(file.name, file.extension, onItemClick);
			fileItem.localURL = getLocalURL(file);
			addChild( fileItem );
			fileItem.x = colomn * colomnWidth + padding/2;
			fileItem.y = row * padding + 2;
		
			row++;
			if(row>rows-1)
			{
				colomn ++;
				row = 0;
			}
		}
	}
	private inline function getLocalURL(file:File):String
	{
		return StringTools.urlDecode( file.url.substring(Assets.sourceDirectory.url.length+1) );
	}
	private function onItemClick(fileItem:FileItem)
	{
		
		
		if ( fileItem.type == FileType.FOLDER )
			currentDirectory = currentDirectory.resolvePath(fileItem.fileName);	
		else if ( fileItem.type == FileType.BACK )
			currentDirectory = currentDirectory.parent;
		else
		{
			var file:File = currentDirectory.resolvePath(fileItem.fileName);
			
			try
			{
				file.openWithDefaultApplication();
			}
			catch(e:IllegalOperationError)
			{
				
				trace(e);
			}
				
		}
		
		populate();

	}


	override public function resize()
	{
		y = 0;
		
		drawGraphics();
		for (element in elements)
		{
			element.resize();
		}
	}

	override public function drawGraphics()
	{
		if(parent == null)return;
		
		
		var g:Graphics = graphics;
		g.clear();
		g.beginFill(0x4c4c4c);
		var prevRows:Int = rows;
		
		rows = 0;
		var gridY:Float = 2;
		_height = cast(parent, Space)._height - 26;

		
		while(gridY < _height)
		{
			g.drawRect(2, gridY, _width-4, padding);
			gridY += padding * 2;
			rows += 2;
		}
		rows -=1;
		g.endFill();
		
		var gridX:Float = colomnWidth;
		colomns = 0;
		while(gridX < _width)
		{
			g.lineStyle(1, 0x2e2e2e);
			g.moveTo(gridX, 2);
			g.lineTo(gridX, _height - 1);
			g.lineStyle(1, 0x6a6a6a);
			g.moveTo(gridX+1, 2);
			g.lineTo(gridX+1, _height - 1);
			gridX += colomnWidth;
			colomns ++;
		}

		
		
		if (rows != prevRows && rows >=1)
		{
			populate();
		}

	}

}