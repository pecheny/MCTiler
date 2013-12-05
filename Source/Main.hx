import flash.text.TextField;
import MovieClipTiler.MovieClipStyle;
import flash.geom.Rectangle;
import flash.events.Event;
import openfl.display.Tilesheet;
import format.SWF;
import openfl.Assets;
import flash.display.Sprite;
using MovieClipTiler;
class Main extends Sprite {
    var evil:MovieClip;
    var i = 0;
    var drawList:Array<Float>;
    var clips:Array<ClipDescriptor>;
    var tilesheet:Tilesheet;
    var style:MovieClipStyle;
    var textfield:TextField;

    public function new() {
        super();
        style = {
        castShadow:true,
        strokeColor: 0x0,
        strokeSize: 3
        };
        var swf = new SWF (Assets.getBytes("assets/Animation.swf"));
        clips = [];
        evil = new MovieClip (cast swf.data.getCharacter(swf.symbols.get("Animation")));
        var bdata = evil.createTile(style);
        tilesheet = new Tilesheet(bdata);
        var rect = evil.calculateFrameSize(style);
        for (i in 0...evil.getTotalFrames()) {
            rect = evil.calculateFrameSize(style);
            rect.x = i * rect.width;
            rect.y = 0;
            tilesheet.addTileRect(rect);
        }

        rect = evil.calculateFrameSize(style);
        for (i in 0...5) {
            var clip:ClipDescriptor = {
            x : 100.0 + 70 * Std.random(5),
            y : 200.0,
            frame : Std.random(evil.getTotalFrames()),
            totalFrames :evil.getTotalFrames(),
            vx : Std.random(500) / 100 - 2.5,
            vy : Std.random(500) / 100 - 2.5,
            rect : rect
            }
            clips.push(clip);
        }
        stage.addEventListener(Event.ENTER_FRAME, stage_onEnterFrame);
    }

    private function stage_onEnterFrame(e:Event) {
        this.graphics.clear();
        drawList = [];
        clips.sort(function (descr1:ClipDescriptor, descr2:ClipDescriptor):Int {return Std.int(descr1.y - descr2.y);});
        for (clip in clips) {
            updateClip(clip);
            fillDrawListWith(clip);
        }
        tilesheet.drawTiles(this.graphics, drawList);
    }

    private function fillDrawListWith(descr:ClipDescriptor):Void {
        drawList.push(descr.x);
        drawList.push(descr.y);
        drawList.push(descr.frame);
       }

    private function updateClip(descr:ClipDescriptor):Void {
        descr.x += descr.vx;
        descr.y += descr.vy;
        if (descr.x > stage.stageWidth - descr.rect.width || descr.x < 0) descr.vx *= -1;
        if (descr.y > stage.stageHeight -descr.rect.height || descr.y < 0) descr.vy *= -1;
        descr.frame = (descr.frame < descr.totalFrames - 1) ? descr.frame + 1 : 0;
    }


}

typedef ClipDescriptor = {
x:Float,
y:Float,
frame:Int,
totalFrames:Int,
vx:Float,
vy:Float,
rect:Rectangle
}