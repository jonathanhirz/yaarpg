import luxe.Sprite;
import luxe.Vector;
import luxe.collision.Collision;
import luxe.collision.shapes.Circle;
import luxe.collision.ShapeDrawerLuxe;

class Player extends Sprite {

    // player movement
    var speed : Float;
    var walk_speed : Float = 5;
    var run_speed : Float = 8;
    var x_flipped : Bool = false;

    // player collider
    var collider : Circle;
    var collider_drawer : ShapeDrawerLuxe;

    override function init() {

        speed = walk_speed;
        var tilemap_colliders = cast PlayState.tilemap_colliders;
        collider = new Circle(pos.x, pos.y, size.x/2 - 1);
        collider_drawer = new ShapeDrawerLuxe();

    } //init

    override function update(dt:Float) {

        // player movement
        if(Luxe.input.inputdown('up')) {
            collider.position.y -= speed;
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputdown('down')) {
            collider.position.y += speed;
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputdown('left')) {
            x_flipped = true;
            collider.position.x -= speed;
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputdown('right')) {
            x_flipped = false;
            collider.position.x += speed;
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputdown('run')) {
            speed = run_speed;
        }
        if(Luxe.input.inputreleased('run')) {
            speed = walk_speed;
        }

        resolve_horizontal_collisions();
        resolve_vertical_collisions();

        pos = collider.position.clone();

        if(Main.draw_colliders) {
            collider_drawer.drawCircle(collider);
        }

    } //update

    function resolve_horizontal_collisions() {

        var collisions = Collision.shapeWithShapes(collider, PlayState.tilemap_colliders);
        if(collisions.length == 1) {
            collider.position.x += collisions[0].separation.x;
        }
        if(collisions.length > 1) {

            if(Math.abs(collisions[0].separation.x) > Math.abs(collisions[1].separation.x)) {
                collider.position.x += collisions[0].separation.x;
            }
            if(Math.abs(collisions[1].separation.x) > Math.abs(collisions[0].separation.x)) {
                collider.position.x += collisions[1].separation.x;
            }
        }

    } //resolve_horizontal_collisions

    function resolve_vertical_collisions() {

        var collisions = Collision.shapeWithShapes(collider, PlayState.tilemap_colliders);
        if(collisions.length == 1) {
            collider.position.y += collisions[0].separation.y;
        }
        if(collisions.length > 1) {

            if(Math.abs(collisions[0].separation.y) > Math.abs(collisions[1].separation.y)) {
                collider.position.y += collisions[0].separation.y;
            }
            if(Math.abs(collisions[1].separation.y) > Math.abs(collisions[0].separation.y)) {
                collider.position.y += collisions[1].separation.y;
            }
        }

    } //resolve_vertical_collisions

    function flip_sprite() {

        if(x_flipped) {
            flipx = true;
        } else {
            flipx = false;
        }

    } //flip_sprite

} //Player