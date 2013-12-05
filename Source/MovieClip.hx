package ;
import format.swf.tags.TagDefineEditText;
import format.swf.tags.TagDefineText;
import format.swf.tags.TagDefineShape;
import format.swf.tags.TagDefineBits;
import format.swf.tags.TagDefineBitsLossless;
import flash.display.DisplayObject;
import format.swf.tags.TagDefineSprite;
class MovieClip extends format.swf.instance.MovieClip {

    public function getCurrentFrame():Int {
        return __currentFrame;
    }

    public function getTotalFrames():Int {
        return __totalFrames;
    }

    override private function renderFrame(index:Int):Void {
        var frame = data.frames[index];
        for (object in frame.getObjectsSortedByDepth()) {
            var symbol = data.getCharacter(object.characterId);
            var displayObject:DisplayObject = null;
            if (Std.is(symbol, TagDefineSprite)) {
                displayObject = new MovieClip (cast symbol);
            } else if (Std.is(symbol, TagDefineBitsLossless)) {
                trace("png");
            } else if (Std.is(symbol, TagDefineBits)) {
                trace("jpg");
            } else if (Std.is(symbol, TagDefineShape)) {
                displayObject = createShape(cast symbol);
            } else if (Std.is(symbol, TagDefineText)) {
                displayObject = createStaticText(cast symbol);
            } else if (Std.is(symbol, TagDefineEditText)) {
                displayObject = createDynamicText(cast symbol);
            }
            if (displayObject != null) {
                placeObject(displayObject, object);
                addChild(displayObject);
            }

        }
    }
}