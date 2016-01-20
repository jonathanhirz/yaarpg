import luxe.Component;
import luxe.Vector;
import luxe.Sprite;
import luxe.components.sprite.SpriteAnimation;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.collision.ShapeDrawerLuxe;

class PlayerBrain extends Component {

    var player : Sprite;
    var player_speed : Float = 1.5;
    var player_collider : Circle;
    var player_velocity : Vector = new Vector(0, 0);
    var player_acceleration : Vector = new Vector(0, 0);
    var x_flipped : Bool = false;
    var player_collider_drawer : ShapeDrawerLuxe;
    var player_animation : SpriteAnimation;

    public function new(_name:String) {
        super({ name:_name });
    } //new

    override function init() {

        // sprite
        player = cast entity;

        // collider
        player_collider = new Circle(player.pos.x, player.pos.y, player.size.x/2 - 1);
        player_collider_drawer = new ShapeDrawerLuxe();
        player.pos = player_collider.position;

        //todo: fix player animation while moving
        // animation
        var player_animation_json = Luxe.resources.json('assets/player_anim.json');
        player_animation = player.add(new SpriteAnimation({ name:'player_anim' }));
        player_animation.add_from_json_object(player_animation_json.asset.json);
        player_animation.animation = 'idle';
        player_animation.play();

    } //init

    override function update(dt:Float) {

        //todo: adjust player movement. should be physics-ey, with roll
        // player movement
        if(Luxe.input.inputdown('up')) {
            player_acceleration = new Vector(player_acceleration.x, -player_speed);
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputreleased('up')) {
            player_acceleration = new Vector(player_acceleration.x, 0);
        }
        if(Luxe.input.inputdown('down')) {
            player_acceleration = new Vector(player_acceleration.x, player_speed);
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputreleased('down')) {
            player_acceleration = new Vector(player_acceleration.x, 0);
        }
        if(Luxe.input.inputdown('left')) {
            x_flipped = true;
            player_acceleration = new Vector(-player_speed, player_acceleration.y);
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputreleased('left')) {
            player_acceleration = new Vector(0, player_acceleration.y);
        }
        if(Luxe.input.inputdown('right')) {
            x_flipped = false;
            player_acceleration = new Vector(player_speed, player_acceleration.y);
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputreleased('right')) {
            player_acceleration = new Vector(0, player_acceleration.y);
        }

        player.pos.add(player_velocity);
        player_velocity.add(player_acceleration);
        player_velocity.multiply(new Vector(0.8, 0.8));
        if(Math.abs(player_velocity.x) < 0.01) player_velocity.x = 0;
        if(Math.abs(player_velocity.y) < 0.01) player_velocity.y = 0;

        resolve_horizontal_collisions();
        resolve_vertical_collisions();

        if(Main.draw_colliders) {
            player_collider_drawer.drawCircle(player_collider);
        }

    } //update

    function resolve_horizontal_collisions() {

        var collisions = Collision.shapeWithShapes(player_collider, PlayState.tilemap_colliders);
        if(collisions.length == 1) {
            player_collider.position.x += collisions[0].separation.x;
        }
        if(collisions.length > 1) {

            if(Math.abs(collisions[0].separation.x) > Math.abs(collisions[1].separation.x)) {
                player_collider.position.x += collisions[0].separation.x;
            }
            if(Math.abs(collisions[1].separation.x) > Math.abs(collisions[0].separation.x)) {
                player_collider.position.x += collisions[1].separation.x;
            }
        }

    } //resolve_horizontal_collisions

    function resolve_vertical_collisions() {

        var collisions = Collision.shapeWithShapes(player_collider, PlayState.tilemap_colliders);
        if(collisions.length == 1) {
            player_collider.position.y += collisions[0].separation.y;
        }
        if(collisions.length > 1) {

            if(Math.abs(collisions[0].separation.y) > Math.abs(collisions[1].separation.y)) {
                player_collider.position.y += collisions[0].separation.y;
            }
            if(Math.abs(collisions[1].separation.y) > Math.abs(collisions[0].separation.y)) {
                player_collider.position.y += collisions[1].separation.y;
            }
        }

    } //resolve_vertical_collisions

    function flip_sprite() {

        if(x_flipped) {
            player.flipx = true;
        } else {
            player.flipx = false;
        }

    } //flip_sprite

} //PlayerBrain