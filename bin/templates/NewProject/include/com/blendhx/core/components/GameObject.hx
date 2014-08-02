package com.blendhx.core.components;
import flash.system.ApplicationDomain;
import com.blendhx.editor.data.UserScripts;
import com.blendhx.editor.Debug;
import com.blendhx.editor.data.AS3DefinitionHelper;
/*
Gameobjects contain components, a simple composition pattern
 */
class GameObject extends Component
{
	//basic initializations
	public function new(name:String = "GameObject") 
	{
		children = new Array<Component>();
		//there always need to be a transform component, because it's used so much
		addChild( new Transform() );
		this.name = name;
	}
	// calls child components update, if gameobject is enabled
	override public function update():Void
	{
		if (!enabled)
			return;
		//call update if child component is enabled
		for (child in children)
			if(child.enabled)
			 	child.update();
	}
	
	//upon destruction, call components to destroy
	override public function destroy()
	{
		for (child in children)
			child.destroy();
		children = [];
		transform = null;
	}
	//add a child only if there isn't one already added with the same Type. There can't be two children of the same type in one Gameobject
	public function addChild(child:Component)
	{
		//if the new child is a gameObject, then add it anyway
		if ( !AS3DefinitionHelper.ObjectIsOfType(child, GameObject) )
		{
			var childClass:Class<Dynamic> = AS3DefinitionHelper.getClass(ApplicationDomain.currentDomain, child);
			for (existingChild in children)
			{
				//if there is a child with the same class type, return
				var existingChildClass:Class<Dynamic> =  AS3DefinitionHelper.getClass(ApplicationDomain.currentDomain, existingChild);
				if( childClass ==  existingChildClass )
				{
					Debug.Log("You can't add same component twice");
					return;
				}
			}
		}
	
		children.push(child);
		child.setParent(this);
	}

	//add a component to the children list, and also let component know that we are her parent
	public function removeChild(child:Component)
	{
		children.remove(child);
		child.setParent(null);
	}
	
	//giving a reference to a child of a certain type
	public function getChild( componentType:Class<Dynamic> ):Dynamic
	{
		var className:String = Type.getClassName(componentType);
		for (child in children)
		{
			var childClassName:String = Type.getClassName(Type.getClass(child));
			var childSuperClassName:String = Type.getClassName(Type.getSuperClass(Type.getClass(child)));
			//if child is a of a certain component type, or if i's parent is of a certain component type
			if( childClassName ==  className || childSuperClassName ==  className)
			{
				return child;
			}
		}
		return null;
	}
}