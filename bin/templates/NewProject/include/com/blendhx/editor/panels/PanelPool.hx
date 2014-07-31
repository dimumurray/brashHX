package com.blendhx.editor.panels;

import com.blendhx.editor.panels.*;
import com.blendhx.editor.spaces.Space;

/**

 * GPL

 */
class PanelPool
{
	private static var panels:Map<String,Panel>;

	public static function Get( name:String ):Panel
	{
		if(name == "GameObject")
			return null;
		
		if( panels == null)
		{
			panels = new Map<String,Panel>();
			panels.set("Transform", new TransformPanel() );
			panels.set("Camera", new CameraPanel() );
			panels.set("MeshRenderer", new MeshRendererPanel() );
			panels.set("Material", new MaterialPanel() );
			panels.set("AddComponent", new AddComponentPanel() );
			panels.set("Utility", new UtilityPanel() );
			panels.set("Panel", new Panel("Empty", Space.SPACE_WIDTH ) );
		}
		
		if ( !panels.exists(name) )
			panels.set( name, new Panel(name, Space.SPACE_WIDTH, true ) );
			
		return panels.get( name );
	}	
}