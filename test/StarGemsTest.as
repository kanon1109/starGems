package  
{
import com.greensock.easing.Sine;
import com.greensock.TweenMax;
import data.GemVo;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.utils.getTimer;
/**
 * ...消消看算法 测试类
 * @author Kanon
 */
public class StarGemsTest extends Sprite 
{
	private var removeList:Array;
	private var starGems:StarGems;
	private var colorAry:Array = [null, 0xFF00FF, 0xFFCC00, 0x0000FF, 
										/*0x55FF33, 0x55CCFF, 0xC88CC0*/];
	public function StarGemsTest() 
	{
		this.removeList = [];
		this.starGems = new StarGems(this.colorAry.length - 1, 10, 10, 5, 5, 200, 80, 50, 50);
		this.initDrawGem();
		stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}
	
	/**
     * 绘制宝石
     */
    private function initDrawGem():void 
    {
        var gVo:GemVo;
		for each (gVo in this.starGems.gemDict) 
		{
			gVo.userData = new Sprite();
			Sprite(gVo.userData).graphics.beginFill(this.colorAry[gVo.color]);
			Sprite(gVo.userData).graphics.drawRoundRect(0, 0, 50, 50, 5, 5);
			Sprite(gVo.userData).graphics.endFill();
			Sprite(gVo.userData).x = gVo.x;
			Sprite(gVo.userData).y = gVo.y;
			this.addChild(Sprite(gVo.userData));
		}
    }
	
	/**
	 * 重置
	 */
	private function reset():void
	{
		var gVo:GemVo;
		for each (gVo in this.starGems.gemDict) 
		{
			if (gVo.userData && gVo.userData is Sprite)
				Sprite(gVo.userData).filters = null;
		}
	}
	
	private function mouseDownHandler(event:MouseEvent):void 
	{
		this.reset();
		var t:Number = getTimer()
		var arr:Array =	this.starGems.selectGem(event.stageX, 
												event.stageY);
		trace(getTimer() - t);
		if (!arr) return;
		var gVo:GemVo;
		var length:int = arr.length;
		if (length <= 1) return;
		for (var i:int = 0; i < length; i += 1) 
		{
			gVo = arr[i];
			if (gVo.userData && 
				gVo.userData is Sprite && 
				!TweenMax.isTweening(Sprite(gVo.userData)))
			{
				var posY:Number = Sprite(gVo.userData).y - 5;
				Sprite(gVo.userData).filters = [new GlowFilter(0x330000)];
				TweenMax.to(Sprite(gVo.userData), .1, { y:posY, yoyo:true, repeat:1 } );
				this.removeList.push(Sprite(gVo.userData));
			}
		}
		this.removeGem();
	}
	
	/**
	 * 销毁宝石显示对象
	 */
	private function removeGem():void
	{
		var spt:Sprite
		var length:int = this.removeList.length;
		for (var i:int = length - 1; i >= 0; i -= 1) 
		{
			spt = this.removeList[i];
			if (spt)
			{
				var posX:Number = spt.x + spt.width * .5;
				var posY:Number = spt.y + spt.height * .5;
				TweenMax.to(spt, .2, { scaleX:0, scaleY:0, 
										x:posX, y:posY,
										ease:Sine.easeOut, 
										delay: i * .03, 
										onComplete:function ():void
										{
											if (spt.parent)
												spt.parent.removeChild(spt);
										}} );
				this.removeList.splice(i, 1);
			}
		}
	}
}
}