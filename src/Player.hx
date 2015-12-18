import luxe.Sprite;
import luxe.Vector;

class Player extends Sprite {

    override function init() {

        var tilemap_colliders = cast PlayState.tilemap_colliders;
        trace(tilemap_colliders.length);

    } //init

    override function update(dt:Float) {

        // player movement
        if(Luxe.input.inputdown('up')) {

        }
        if(Luxe.input.inputdown('down')) {

        }
        if(Luxe.input.inputdown('left')) {

        }
        if(Luxe.input.inputdown('right')) {

        }

    } //update

} //Player