package scripts;

import com.blendhx.core.*;
import com.blendhx.core.components.*;
import flash.geom.Vector3D;
/**
* @author 
 */
class RotateAroundZero extends Component
{
	override public function update():Void
	{
		if (!enabled)
			return;
		
		transform.matrix.identity();
		transform.matrix.appendRotation(flash.Lib.getTimer()/50, Vector3D.Y_AXIS);
		transform.matrix.appendRotation(-15, Vector3D.X_AXIS);
		transform.matrix.appendTranslation(0,0,3);
	}
}