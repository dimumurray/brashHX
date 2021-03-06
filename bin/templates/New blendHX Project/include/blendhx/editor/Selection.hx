package blendhx.editor;
import blendhx.editor.uicomponents.UIElement;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.Lib;
import flash.events.MouseEvent;
import blendhx.editor.assets.FileType;
import blendhx.editor.spaces.Space;
import blendhx.core.components.Entity;
import blendhx.editor.panels.DragableItem;
import blendhx.editor.panels.FileItem;
import blendhx.editor.panels.HierarchyItem;

/*
nothing much going on
static class used for getting dragabble objects and selected fileitems or hierarchy items
 */
class Selection
{
	public static var dragObject:DragableItem;
	public static var uiElement:UIElement;
	
	private static var hierarchyItem:HierarchyItem;
	private static var fileItem:FileItem;
	private static var instance:Selection;
	private static var dragSprite:Sprite;
	private static var dragBitmap:Bitmap;
	
	public static function Initialize() 
	{
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, Clear);
	}
	public static function Select( object:Dynamic ) 
	{
		
		if( Type.getClass( object ) == HierarchyItem )
		{
			var fileItem:FileItem = fileItem;
			Selection.fileItem = null;
			
			if(hierarchyItem != null)
				hierarchyItem.deselect();
			
			if(fileItem != null)
				fileItem.deselect();
			
			hierarchyItem = cast(object, HierarchyItem);
		}
		else if( Type.getClass( object ) == FileItem)
		{
			var hierarchyItem:HierarchyItem = hierarchyItem;
			Selection.hierarchyItem = null;
			
			if(fileItem != null)
				fileItem.deselect();
			
			if(hierarchyItem != null)
				hierarchyItem.deselect();
			
			fileItem = cast(object, FileItem);
		}
		
		
		Space.Resize();
	}
	


	
	public static function Clear( e:MouseEvent )
	{
		if( Selection.dragObject != null )
		{
			Selection.dragObject = null;
			dragSprite.stopDrag();
			Lib.current.stage.removeChild(dragSprite);
		}
		
	
		if(uiElement != null && e!= null &&e.target!= uiElement )
		{
			trace(e.target);
			uiElement.unfocus();
			uiElement = null;
		}
		
	}
	
	public static function SetDragObject(dragObject:Dynamic)
	{
		Selection.dragObject = dragObject;
		CreateDragGraphic();
		
	}
	
	//create the drag graphic under mouse
	public static function CreateDragGraphic()
	{
		var bitmapData:BitmapData;
		if(dragBitmap == null)
		{
			dragSprite = new Sprite();
			bitmapData = new BitmapData(200,20, true,0x00FFFFFF);
			dragBitmap = new Bitmap(bitmapData);
			dragBitmap.x=3;
			dragBitmap.y=3;
			dragSprite.addChild(dragBitmap);
		}
		bitmapData = dragBitmap.bitmapData;
		bitmapData.fillRect( new Rectangle(0, 0, 200, 20), 0x00FFFFFF );
		Lib.current.stage.addChild(dragSprite);
		bitmapData.copyPixels(dragObject.dragGraphic, bitmapData.rect, new Point());
		
		dragSprite.startDrag(true);
	}
	
	
	public static function isHierarchyItem():Bool
	{
		if(hierarchyItem != null)
			return true;
		
		return false;
	}
	
	public static function isFileItem():Bool
	{
		if(fileItem != null)
			return true;
		
		return false;
	}
	
	public static function GetSelectedEntity():Entity
	{
		if( isHierarchyItem() )
			return hierarchyItem.entity;
					
		trace("No Entity is selected");
		return null;
	}
	
	public static function GetSelectedFileItem():FileItem
	{
		if( isFileItem() )
			return fileItem;
			
		return null;
	}
	
	public static function GetSelectedHierarchyItem():HierarchyItem
	{
		if(hierarchyItem != null)
			return hierarchyItem;
		
		trace("No hierarchy item is selected");
		return null;
	}

}