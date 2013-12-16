package  
{
import data.GemVo;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.utils.Dictionary;
import utils.ArrayUtil;
import utils.Random;
/**
 * ...消消看算法 类似于星宝石
 * @author Kanon
 */
public class StarGems extends EventDispatcher
{
	//总的颜色类型
	private var totalColorType:uint;
	//行数
	private var rows:uint;
	//列数
	private var columns:uint;
	//横向间隔
	private var gapH:uint;
	//纵向间隔
	private var gapV:uint;
	//起始位置x
	private var startX:uint;
	//起始位置y
	private var startY:uint;
	//宝石宽度
    private var gemWidth:Number;
    //宝石高度
    private var gemHeight:Number;
	//默认链接数量
    private var minSameNum:uint;
	//宝石字典
	private var _gemDict:Dictionary;
	//颜色列表
	private var colorList:Array;
	//宝石列表
	private var gemList:Array;
	//下落时的间隔
	private var fallGapV:Number;
	//下落宝石数组
	private var fallList:Array;
    //横向移动列表
    private var moveList:Array;
	//重力加速度
	private const g:Number = .9;
    //横向移动速度
	private const speed:int = -5;
	//是否自动下落
	private var _autoFall:Boolean = true;
	/**
     * @param	totalColorType      总的颜色类型
     * @param	rows                行数
     * @param	columns             列数
     * @param	gapH                横向间隔
     * @param	gapV                纵向间隔
     * @param	startX              起始位置x
     * @param	startY              起始位置y
     * @param	gemWidth            宝石宽度
     * @param	gemHeight           宝石高度
     * @param	minLinkNum          默认链接数量
     */
	public function StarGems(totalColorType:uint, 
							rows:uint, columns:uint, 
							gapH:Number, gapV:Number, 
							startX:Number, startY:Number, 
							gemWidth:Number, gemHeight:Number,
							minSameNum:uint = 2) 
	{
		this.totalColorType = totalColorType;
        this.rows = rows;
        this.columns = columns;
        this.gemWidth = gemWidth;
        this.gemHeight = gemHeight;
        this.startX = startX;
        this.startY = startY;
        this.gapH = gapH;
        this.gapV = gapV;
        this.minSameNum = minSameNum;
        this.initData();
	}
	
	/**
	 * 初始化数据
	 */
	private function initData():void
	{
		this.colorList = [];
		for (var i:int = 1; i <= this.totalColorType; i += 1)
			this.colorList.push(i);
		this.gemList = [];
		this.fallList = [];
		this.moveList = [];
		this._gemDict = new Dictionary();
		var gVo:GemVo;
        var color:int;
        var point:Point;
        for (var row:int = 0; row < this.rows; row += 1) 
        {
            this.gemList[row] = [];
            for (var column:int = 0; column < this.columns; column += 1) 
            {
				gVo = new GemVo();
                gVo.width = this.gemWidth;
                gVo.height = this.gemHeight;
                gVo.row = row;
                gVo.column = column;
                gVo.isInPosition = true;
                this.gemList[row][column] = gVo;
				//设置坐标位置
                point = this.getGemPos(row, column);
                gVo.x = point.x;
                gVo.y = point.y;
				gVo.g = 0;
				gVo.color = this.randomColor();
				this._gemDict[gVo] = gVo;
			}
		}
		this.fallGapV = this.gapV * 2;
	}
	
	/**
	 * 判断是否周围上下左右的宝石数据
	 * @param	curRow			当前行坐标
	 * @param	curColumn		当前列坐标
	 * @return	周围4个宝石数据列表
	 */
	private function getSelectRoundGem(curRow:int, curColumn:int):Array
	{
		var arr:Array = [];
		if (curRow > 0)
		{
			var upVo:GemVo = this.gemList[curRow - 1][curColumn];
			if (upVo) arr.push(upVo);
		}
		if (curRow < this.rows - 1)
		{
			var downVo:GemVo = this.gemList[curRow + 1][curColumn];
			if (downVo) arr.push(downVo);
		}
		if (curColumn > 0)
		{
			var leftVo:GemVo = this.gemList[curRow][curColumn - 1];
			if (leftVo) arr.push(leftVo);
		}
		if (curColumn < this.columns - 1)
		{
			var rightVo:GemVo = this.gemList[curRow][curColumn + 1];
			if (rightVo) arr.push(rightVo);
		}
		return arr;
	}
	
	/**
	 * 随机颜色
	 * @param	...args			忽略的颜色
	 * @return	选取的颜色
	 */
	private function randomColor(...args):int
	{
		if (!args || args.length == 0) return Random.randint(1, this.totalColorType);
		var colorArr:Array = ArrayUtil.cloneList(this.colorList);
		var length:int = args.length;
		var index:int;
		var color:int;
		for (var i:int = 0; i < length; i += 1) 
		{
			color = args[i];
			if (color == 0) continue;
			index = colorArr.indexOf(color);
			colorArr.splice(index, 1);
		}
		return Random.choice(colorArr);
	}
	
	/**
	 * 根据行和列获取宝石的坐标
	 * @param	row         行数
	 * @param	column      列数
	 * @return  坐标
	 */
    private function getGemPos(row:int, column:int):Point
    {
        return new Point(this.startX + column * (this.gemWidth + this.gapH),
                         this.startY + row * (this.gemHeight + this.gapV));
    }
	
	/**
     * 根据位置获取宝石数据
     * @param	posX        x位置     
     * @param	posY        y位置
     * @return  宝石数据
     */
    private function getGemVoByPos(posX:Number, posY:Number):GemVo
    {
        var gVo:GemVo;
        for each (gVo in this._gemDict) 
        {
            if (posX >= gVo.x && posX < gVo.x + gVo.width  && 
                posY >= gVo.y && posY < gVo.y + gVo.height)
                return gVo;
        }
        return null;
    }
	
	/**
	 * 获取当前宝石数据相同相邻颜色的宝石数据列表
	 * @param	gVo			当前宝石数据
	 * @return	相同相邻颜色的宝石数据列表
	 */
	private function getSameColorGem(gVo:GemVo):Array
	{
		if (!gVo) return null;
		var posAry:Array = this.getSelectRoundGem(gVo.row, gVo.column);
		if (posAry.length == 0) return null;
		var tempAry:Array;
        var roundGVo:GemVo;
        var sameColorList:Array = [];
		var length:int = posAry.length;
		for (var i:int = 0; i < length; i += 1) 
		{
			roundGVo = posAry[i];
			//颜色相同
			if (roundGVo && 
				!roundGVo.isCheck && 
				roundGVo.isInPosition && 
				roundGVo.color == gVo.color)
			{
                roundGVo.isCheck = true;
                sameColorList.push(roundGVo);
				tempAry = this.getSameColorGem(roundGVo);
				if (tempAry) sameColorList = sameColorList.concat(tempAry);
			}
		}
		return sameColorList;
	}
	
	/**
	 * 销毁宝石数据
	 * @param	gVo		宝石数据
	 */
	private function removeGem(gVo:GemVo):void
	{
		this.gemList[gVo.row][gVo.column] = null;
		delete this._gemDict[gVo];
	}
	
	/**
	 * 填补被销毁的宝石
	 * @param	columnList		被删除的列坐标列表
	 */
	private function reloadGem(columnList:Array):void
	{
        if (!columnList) return;
        var length:int = columnList.length;
        //当前列坐标
        var column:int;
        var gVo:GemVo;
		//空行数量
        var nullNum:int;
        //存放一整都为空的列表
        var nullColumList:Array = [];
        var pos:Point;
		for (var i:int = 0; i < length; i += 1) 
        {
            column = columnList[i];
			nullNum = 0;
            for (var row:int = this.rows - 1; row >= 0; row -= 1) 
            {
				gVo = this.gemList[row][column];
                if (gVo) 
                {
					//如果空行数量大于0 则往下移动空行数量个坐标
                    if (nullNum > 0)
                    {
						gVo.isInPosition = false;
                        gVo.row += nullNum;
                        pos = this.getGemPos(row + nullNum, column);
                        gVo.rangeY = pos.y;
                        gVo.rangeX = pos.x;
                        if (this._autoFall) gVo.g = this.g;
                        this.gemList[row][column] = null;
                        this.gemList[row + nullNum][column] = gVo;
						if (this.fallList.indexOf(gVo) == -1)
							this.fallList.push(gVo);
					}
				}
				else nullNum++;
			}
            //一整列都被删除
            if (nullNum == this.rows) nullColumList.push(column);
			this.fallList.sortOn("row", Array.NUMERIC);
		}
        
        //横向整体填补空列
        var nullColumn:int;
        length = nullColumList.length;
        for (i = length - 1; i >= 0; i -= 1) 
        {
            nullColumn = nullColumList[i];
            for (row = 0; row < this.rows; row += 1)
            {
                for (column = nullColumn + 1; column < this.columns; column += 1) 
                {
                    gVo = this.gemList[row][column];
                    if (gVo)
                    {
                        gVo.isInPosition = false;
                        gVo.column--;
                        pos = this.getGemPos(row, gVo.column);
                        gVo.rangeX = pos.x;
                        gVo.rangeY = pos.y;
                        this.gemList[row][column] = null;
                        this.gemList[row][gVo.column] = gVo;
                        if (this._autoFall) gVo.vx = this.speed;
                        else gVo.isHorizontalMove = true;
                        if (this.fallList.indexOf(gVo) == -1)
                            this.fallList.push(gVo);
                    }
                }
            }
        }
	}
    
    /**
     * 重置宝石是否被判断的数据
     */
    private function resetGemCheck():void
    {
        var gVo:GemVo;
        for each (gVo in this._gemDict) 
        {
            gVo.isCheck = false;
        }
    }
    
    /**
     * 下落
     */
    private function fall():void
    {
        if (!this.fallList || this.fallList.length == 0) return;
        var gVo:GemVo;
		for (var i:int = 0; i < this.fallList.length; i += 1)
        {
            gVo = this.fallList[i];
            gVo.vy += gVo.g;
            gVo.x += gVo.vx;
            gVo.y += gVo.vy;
            if (gVo.y >= gVo.rangeY)
            {
                gVo.y = gVo.rangeY;
                gVo.vy = 0;
                gVo.g = 0;
            }
            if (gVo.x <= gVo.rangeX)
            {
                gVo.x = gVo.rangeX;
                gVo.vx = 0;
                gVo.isHorizontalMove = false;
            }
            if (gVo.y >= gVo.rangeY && 
                gVo.x <= gVo.rangeX)
            {
                gVo.isInPosition = true;
                this.fallList.splice(i, 1);
            }
        }
    }
    
	//***********public function***********
	/**
	 * 点击宝石
	 * @param	posX	x位置	
	 * @param	posY	y位置
	 */
	public function selectGem(posX:Number, posY:Number):Array
	{
		var gVo:GemVo = this.getGemVoByPos(posX, posY);
		if (!gVo) return null;
		if (!gVo.isInPosition || gVo.isCheck) return null;
		var arr:Array = this.getSameColorGem(gVo);
        if (!arr || arr.length == 0) return null;
        gVo.isCheck = true;
        arr.push(gVo);
		var length:int = arr.length;
        //存放有被销毁宝石数据的列数的列表
		var columnList:Array = [];
		for (var i:int = 0; i < length; i += 1) 
		{
			gVo = arr[i];
			this.removeGem(gVo);
			if (columnList.indexOf(gVo.column) == -1)
                columnList.push(gVo.column);
		}
		arr.sortOn(["row", "column"], Array.NUMERIC);
		this.reloadGem(columnList);
		return arr;
	}
    
    /**
     * 判断是否存在相同颜色相邻的宝石数据
     * @return     相同颜色相邻的宝石数据
     */
    public function checkHasSameColor():GemVo
    {
        if (!this.gemList) return null;
        var gVo:GemVo;
        var sameGemVo:GemVo;
        for (var row:int = 0; row < this.rows; row += 1) 
        {
            for (var column:int = 0; column < this.columns; column += 1) 
            {
                gVo = this.gemList[row][column];
                if (gVo && !gVo.isCheck)
                {
                    var arr:Array = this.getSameColorGem(gVo);
                    if (arr && arr.length > 0) 
                    {
                        sameGemVo = arr[0];
                        break;
                    }
                }
            }
        }
        this.resetGemCheck();
        return sameGemVo;
    }
	
	/**
     * 销毁
     */
    public function destroy():void
    {
        this.gemList = null;
        this._gemDict = null;
		this.colorList = null;
        this.fallList = null;
        this.moveList = null;
    }
	
	/**
     * 更新数据
     */
    public function update():void
    {
       this.fall();
    }
	
	/**
	 * 开始下落
	 */
	public function beginFall():void 
	{
		if (!this.fallList || this.fallList.length == 0) return;
		var gVo:GemVo;
		for (var i:int = 0; i < this.fallList.length; i += 1)
        {
            gVo = this.fallList[i];
            gVo.g = this.g;
            if (gVo.isHorizontalMove) gVo.vx = this.speed;
        }
	}
	
	/**
	 * 宝石字典
	 */
	public function get gemDict():Dictionary { return _gemDict; }
	
	/**
	 * 是否自动下落，如果为false则需要在自行调用beginFall来控制下落的时机
	 */
	public function get autoFall():Boolean{ return _autoFall; }
	public function set autoFall(value:Boolean):void 
	{
		_autoFall = value;
	}
	
}
}