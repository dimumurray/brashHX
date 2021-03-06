package blendhx.editor.panels;
import flash.text.TextFieldAutoSize;

import blendhx.core.components.Transform;
import blendhx.core.components.Component;
import blendhx.editor.Selection;
import blendhx.editor.uicomponents.*;
import blendhx.editor.spaces.*;
import blendhx.core.*;
import flash.events.MouseEvent;
import flash.display.Graphics;
import flash.text.TextFormatAlign;
import flash.display.Sprite;
import blendhx.editor.data.AS3DefinitionHelper;

/**
* @author 
 */
class Panel extends Sprite
{
	public static var padding:Float = 10;
	
	private var title:String;
	private var handle:Sprite;
	private var minimizeHotspot:Sprite;
	private var disableFadeOverlayGraphic:Sprite;
	private var closeButton:RemoveButton;
	
	public var _width:Float=40;
	public var _height:Float=30;
	public var checkBox:Checkbox;
	public var elements:Array<UIElement> = new Array<UIElement>();
	public var shouldDrawCheckbox:Bool;
	public var hostComponent:Component;
	public var enabled(get, set):Bool;
	
	
	public function new(title:String, _width:Float, shouldDrawCheckbox:Bool = false) 
	{
		super();
		this.title = title;
		this._width = _width;
		this.shouldDrawCheckbox = shouldDrawCheckbox;
		
		elements = new Array<UIElement>();
		
		drawGraphics();
	}	
	public function drawGraphics()
	{
		createHandleGraphic();
		createMinimizeHotspot();
		drawHeaderGraphic();
		
		
	}
	public function addUIElement(element:UIElement)
	{
		elements.push(element);
		element.panel = this;

		maximize();
	}
	public function removeUIElement(element:UIElement)
	{
		
		elements.remove(element);
		removeChild(element);
		element.destroy();
	}
	//resize elements inside
	public function resize()
	{
		
		
		if(y>50)
			redrawHeaderLine();
		drawRemoveButton();
		
		if(hostComponent != null && shouldDrawCheckbox)
			checkBox.value =  hostComponent.enabled ;
		
		
		for (element in elements)
		{
			element.resize();
		}
	
	}
	
	
		
	//UI Graphic creation private functions
	private function drawRemoveButton()
	{
		var isTransform:Bool = untyped __is__(hostComponent, Transform);
		if(hostComponent != null && closeButton == null && !isTransform )
			closeButton = new RemoveButton(removeHostComponent, this);
		
		if(closeButton!= null)
		{
			closeButton.x = _width - 30;
			closeButton.y = 7;
		}
	}
	private function drawHeaderGraphic()
	{
		
		var x = 26;
		if(shouldDrawCheckbox)
		{
			checkBox = new Checkbox("Reload Shader", 1, 1, 8,  onCheckboxChanged, null);
			checkBox.x = x;
			addChild( checkBox );
			x = 45;
		}
		
		var label:SimpleTextField = new SimpleTextField(TextFormatAlign.LEFT, title);
		label.autoSize = TextFieldAutoSize.LEFT;
		label.x = x;
		label.y = 6;
		addChild(label);
	}
	
	public function onCheckboxChanged()
	{
		if(hostComponent == null )
			return;
		
		hostComponent.enabled = checkBox.value;
		enabled = checkBox.value;
			
	}
	
	private function removeHostComponent()
	{
		if(hostComponent == null)
			return;
		
		var component:Component = cast hostComponent;
    	Selection.GetSelectedEntity().removeChild(component);
		hostComponent.destroy();
		HierarchyPanel.getInstance().populate();
    	Space.Resize();
	}

	private function createHandleGraphic()
	{
		handle = new Sprite();
		var g:Graphics = handle.graphics;
		g.beginFill(0x272727);
		g.lineStyle(0, 0, 0);
		g.moveTo(-4, -4);
		g.lineTo(6,  -4);
		g.lineTo(1, 3);
		g.lineTo( -4,  -4);
		g.endFill();
		handle.x = 16;
		handle.y = 16;
		addChild(handle);
	}

	private function createMinimizeHotspot()
	{
		minimizeHotspot = new Sprite();
		var g:Graphics = minimizeHotspot.graphics;
		
		g.lineStyle(0, 0, 0);
		g.beginFill(1, 0);
		g.drawRect(5, 7, _width - 10, 20);

		addChild(minimizeHotspot);
		minimizeHotspot.addEventListener(MouseEvent.CLICK, onHandleClick);
	}
	// on resize, this needs to be redrawn
	private function redrawHeaderLine()
	{
		var g:Graphics = graphics;
		graphics.clear();
		g.lineStyle(1, 0x272727, 1);
		g.moveTo(10, 0);
		g.lineTo(_width-10, 0);
		g.lineStyle(1, 0x959595, 1);
		g.moveTo(10, 1);
		g.lineTo(_width-10, 1);
		
	}

	//minimize or maximize accordingl once clicked
	private function onHandleClick(e:MouseEvent)
	{
		if(handle.rotation == 0)
		{
			minimize();
			handle.rotation = -90;
		}
		else 
		{
			maximize();
			handle.rotation = 0;
		}
			
		Space.Resize();
	}

	public function minimize()
	{
		_height = 30;
		
		for (element in elements)
		{
			removeChild(element);
		}
	}

	public function maximize()
	{
		for (element in elements)
		{
			addChild(element);
			if (element.y + element._height + padding> _height)
			{
				_height = element.y + element._height + padding;
			}
		}
	}
	
	public function get_enabled() { return false; }
	public function set_enabled(param:Bool)
	{
		if(disableFadeOverlayGraphic == null)
			disableFadeOverlayGraphic = new Sprite();

		addChild(disableFadeOverlayGraphic);
		var g:Graphics = disableFadeOverlayGraphic.graphics;
		g.clear();
		g.lineStyle(0, 0, 0);
		g.beginFill(0x727272, 0.5);
		g.drawRect(1, 30, _width-2 , _height - 30);
		g.endFill();
			
		if(param)
			g.clear();
		
		return param;
	}
	
	//returns true if the host component variable has changed since last time this method was called
	//used by extending classes, so they won't recreate their UI elements according to the host component if the host hasn't even changed, you see
	private var previoushostComponent:Component = null;
	public function hasHostComponentChanged():Bool
	{
		var hasChange:Bool = true;
		if(previoushostComponent == hostComponent)
			hasChange = false;
		previoushostComponent = hostComponent;
		return hasChange;
	}
}