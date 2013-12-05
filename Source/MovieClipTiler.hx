package ;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.ColorTransform;
using MovieClipTiler;
class MovieClipTiler {
    private static inline var shdSkew = 0.25;
    private static var point:Point;
    private static var addAlphaTransform:ColorTransform;

    public static function __init__() {
        point = new Point();
        addAlphaTransform = new ColorTransform(0, 0, 0, .3);
    }

    public function new() {

    }


    public static function createTile(source:MovieClip, ?style:MovieClipStyle):BitmapData {
        if (style == null) {
            style = {
            castShadow:false,
            strokeColor: 0,
            strokeSize: 0
            }
        }
        source.addStroke(style.strokeSize, style.strokeColor);
        var sourceRect = source.calculateFrameSize(style);
        var bdata = new BitmapData(Std.int(sourceRect.width * source.getTotalFrames()), Std.int(sourceRect.height), true, 0);
        var sx = source.scaleX;
        var sy = source.scaleY;
        var i = 1;
        while (i <= source.getTotalFrames()) {
            var matrix = new Matrix(sx, 0, 0, sy, (sourceRect.width * (i - 1)) - sourceRect.x, -sourceRect.y);
            var shadowCache:BitmapData = null;
            if (style.castShadow) {
                var shadowMatrix = new Matrix(sx, 0, 0, sy * .6, (sourceRect.width * (i - 1)), 0);
                shadowMatrix.concat(new Matrix(1, 0, Math.tan(shdSkew), 1, 0, 0));
                shadowMatrix.tx -= sourceRect.x;
                shadowMatrix.ty -= sourceRect.y;
                bdata.draw(source, shadowMatrix, addAlphaTransform);
            }
            bdata.draw(source, matrix);
            i++;
            source.moveMcToAndStop(i);
        }
        return bdata;
    }


    public static function addStroke(source:MovieClip, size:Float, color:Int):Void {
        var glow = new GlowFilter(color, 1, size, size, 50, BitmapFilterQuality.HIGH, false, false);
        var filtresArray = [];
        filtresArray.push(glow);
        source.filters = filtresArray;
    }


    public static function moveMcToAndStop(mc:MovieClip, n:Int):Void {
        while (n > mc.getTotalFrames()) n -= mc.getTotalFrames();
        mc.gotoAndStop(n);
        if (mc.numChildren > 0)
            for (i in 0...mc.numChildren) {
                if (Std.is(mc.getChildAt(i), MovieClip)) {
                    var child = cast(mc.getChildAt(i), MovieClip) ;
                    if (child != null) {
                        child.moveMcToAndStop(n);
                    }
                }
            }
    }

    public static function calculateFrameSize(source:MovieClip, ?style:MovieClipStyle):Rectangle {
        var sourceRect:Rectangle = source.getBounds(source);
        source.moveMcToAndStop(1);
        if (style == null) {
            style = {
            castShadow:false,
            strokeColor: 0,
            strokeSize: 0
            }
        }
        var sx = source.scaleX;
        var sy = source.scaleY;
        var lx = sourceRect.x * sx, rx = (sourceRect.x + sourceRect.width) * sx, ty = (sourceRect.y) * sy, by = (sourceRect.y + sourceRect.height) * sy;
        for (i in 1...source.getTotalFrames()) {
            source.moveMcToAndStop(i + 1);
            var tmpRect = source.getRect(source);
            if (lx > (tmpRect.x * sx - style.strokeSize)) lx = (tmpRect.x * sx - style.strokeSize);
            if (rx < (tmpRect.x + tmpRect.width ) * sx + 2 * style.strokeSize) rx = (tmpRect.x + tmpRect.width) * sx + 2 * style.strokeSize;
            if (ty > (tmpRect.y) * sy - style.strokeSize) ty = (tmpRect.y) * sy - style.strokeSize;
            if (by < (tmpRect.y + tmpRect.height) * sy + 2 * style.strokeSize) by = (tmpRect.y + tmpRect.height) * sy + 2 * style.strokeSize;
        }
        if (style.castShadow) {
            var shdOffset = Std.int((by - ty) * 0.1);
            lx -= shdOffset;
        }
        sourceRect = new Rectangle(Math.ceil(lx), Math.ceil(ty), Math.ceil(rx - lx), Math.ceil(by - ty));
        source.moveMcToAndStop(1);
        return sourceRect;
    }
}

typedef MovieClipStyle = {
strokeColor:Int,
strokeSize:Float,
castShadow:Bool
}