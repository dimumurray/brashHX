package com.blendhx.editor.panels;
import com.blendhx.editor.uicomponents.UIElement;
import com.blendhx.editor.uicomponents.TextInput;

import com.blendhx.core.assets.Material;
import com.blendhx.core.assets.Assets;
import com.blendhx.editor.uicomponents.ObjectInput;
import com.blendhx.editor.uicomponents.*;
import com.blendhx.editor.spaces.Space;
import com.blendhx.editor.assets.FileType;
import com.blendhx.editor.Selection;
import com.blendhx.editor.uicomponents.*;
import com.blendhx.editor.spaces.Space;

import com.blendhx.editor.data.IO;

import shaders.UnlitShader;
import hxsl.Shader;

/**

 * GPL

 */
class MaterialPanel extends Panel
{
	var hostMaterial:Material;
	var shader_input:ObjectInput;
	
	var property_inputs:Array<UIElement> = [];
	
	public function new() 
	{
		super("Material", Space.SPACE_WIDTH);
		
		new Label("Shader:", 1, 1, 30, this);
		shader_input = new ObjectInput(FileType.SCRIPT, 1, 1,50, changeShader, this);
	}
	
	public function createInputs()
	{
		for (input in property_inputs)
		{
			removeUIElement(input);
		}
		property_inputs = [];
	
		var editorProperties:Array<String> = hostMaterial.shader.editorProperties;
		var length:Int = Std.int( editorProperties.length / 2 );
		var input_y:Int = 70;
		var input:UIElement;
		
		for (i in 0...length)
		{
			input = new Label(editorProperties[i*2]+":", 1, 1, input_y, this);
			property_inputs.push(input);
	
			switch ( editorProperties[ (i*2) +1] )
			{
				case "Texture":
					input = new ObjectInput(FileType.IMAGE, 1, 1, input_y+20, doNothing, this);
				case "Color":
					input = new TextInput( "0xffffff77", 1, 1, input_y+20, doNothing, this);
				default:
					input = null;

			}
			input_y += 40;
			property_inputs.push(input);
		}
		
		input = new Button("Save", 1, 1, input_y+10,  saveMaterial, this);
		property_inputs.push(input);
	}
	
	public function doNothing()
	{
	}

	public function changeShader()
	{
		if ( !Selection.isFileItem() || hostMaterial==null)
			return;
		
		if(hostMaterial.shaderURL == shader_input.value)
			return;
		
		saveMaterial();
			
		createInputs();
		updateValues();
	}
	
	private function saveMaterial() 
	{
		hostMaterial.shaderURL = shader_input.value;
		
		var editorProperties:Array<String> = hostMaterial.shader.editorProperties;
		var length:Int = Std.int( editorProperties.length / 2 );
		for (i in 0...length)
			hostMaterial.properties.set( editorProperties[i*2] , property_inputs[ i*2+1 ].value );
		
		IO.WriteMaterial( hostMaterial );
		
		hostMaterial.init();
	}

	private function updateValues() 
	{
		shader_input.setValue ( hostMaterial.shaderURL );
		
		var editorProperties:Array<String> = hostMaterial.shader.editorProperties;
		var length:Int = Std.int( editorProperties.length / 2 );
		for (i in 0...length)
			property_inputs[i*2+1].setValue ( hostMaterial.properties.get( editorProperties[i*2] ) );
	}

	override public function resize()
	{
		super.resize();
		
		if( isNewMaterialSelected() )
			updateValues();
	}

	public function isNewMaterialSelected():Bool
	{
		if ( !Selection.isFileItem() )
			return false;
		
		var sourceURL:String = Selection.GetSelectedFileItem().localURL;
		var material:Material = Assets.GetMaterial( sourceURL );
		if (material==null)
			return false;
		
		if(hostMaterial != material)
		{
			hostMaterial = material;
			material.init();
			createInputs();
			return true;
		}
			
		return false;
	}
}