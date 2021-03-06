package blendhx.editor.panels;
import openfl.Vector;

import openfl.system.ApplicationDomain;
import openfl.Lib;

import blendhx.editor.Selection;
import blendhx.core.components.Component;
import blendhx.core.components.Camera;
import blendhx.editor.uicomponents.*;
import blendhx.editor.spaces.Space;
import blendhx.editor.assets.FileType;
import blendhx.editor.data.UserScripts;
import blendhx.editor.data.AS3DefinitionHelper;

class AddComponentPanel extends Panel
{
	var className:ObjectInput;
	
    public function new()
    {
    	super("Add Script", Space.SPACE_WIDTH);
    	new Label("Script file:", 1, 1, 30, this);
		
    	className = new ObjectInput(FileType.SCRIPT, 1, 1, 50, doNothing, this);
		
    	new Button("Add", 1, 1, 80, addComponent, this);
    }

    public function doNothing()
    { }

    public function addComponent()
    {
		if ( className.value == null)
			return;
		
		var component:Component = UserScripts.GetComponent( className.value );
		
		if (component == null)
			return;
		
    	Selection.GetSelectedEntity().addChild(component);
		HierarchyPanel.getInstance().populate();
    	Space.Resize();
    }
}
