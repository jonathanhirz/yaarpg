import luxe.Log.*;
import luxe.Input;
import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledLayer;
import luxe.importers.tiled.TiledObjectGroup;
import luxe.components.sprite.SpriteAnimation;
import luxe.collision.Collision;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;
import luxe.collision.shapes.Circle;
import luxe.collision.ShapeDrawerLuxe;

class PlayState extends State {

    // tilemap
    var tilemap_name : String;
    var current_tilemap : TiledMap;
    var tilemap_colliders : Array<Shape> = [];
    var start_position : Vector;

    // player
    var player : Sprite;
    var player_animation : SpriteAnimation;
    var x_flipped : Bool = false;
    var player_speed : Float;
    var player_walk_speed : Float = 5;
    var player_run_speed : Float = 8;
    var player_collider : Circle;
    var player_collider_drawer : ShapeDrawerLuxe;

    public function new( _name:String ) {
        super({ name:_name });
    } //new

    override function init() {

        player_speed = player_walk_speed;
        player_collider_drawer = new ShapeDrawerLuxe();

    } //init

    override function onenter<T>( _value:T ) {

        clean_up();
        tilemap_name = cast _value;
        draw_tilemap(tilemap_name);
        get_tilemap_colliders();
        get_start_position();
        create_player();
        create_player_animation();

    } //onenter

    override function onleave<T>( _value:T ) {

        current_tilemap.destroy();
        current_tilemap = null;

    } //onleave

    override function update(dt:Float) {

        Luxe.camera.center.weighted_average_xy(player.pos.x, player.pos.y, 10);

        // player movement
        if(Luxe.input.inputdown('up')) {
            player_collider.position.y -= player_speed;
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputdown('down')) {
            player_collider.position.y += player_speed;
            resolve_vertical_collisions();
        }
        if(Luxe.input.inputdown('left')) {
            x_flipped = true;
            player_collider.position.x -= player_speed;
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputdown('right')) {
            x_flipped = false;
            player_collider.position.x += player_speed;
            resolve_horizontal_collisions();
            flip_sprite();
        }
        if(Luxe.input.inputdown('run')) {
            player_speed = player_run_speed;
        }
        if(Luxe.input.inputreleased('run')) {
            player_speed = player_walk_speed;
        }

        resolve_horizontal_collisions();
        resolve_vertical_collisions();

        player.pos = player_collider.position.clone();

        if(Main.draw_colliders) {
            player_collider_drawer.drawCircle(player_collider);
        }

        if(Main.draw_colliders) {
            for(shape in tilemap_colliders) draw_collider_polygon(cast shape);
        }

        if(Luxe.input.keydown(Key.key_z)) {
            Main.machine.set('play_state', 'assets/ship_map.tmx');
        }
        if(Luxe.input.keydown(Key.key_x)) {
            Main.machine.set('play_state', 'assets/ship_map_2.tmx');
        }

    } //update

    // TILEMAP
    function draw_tilemap( _map:String ) {

        var res = Luxe.resources.text(_map);
        assertnull(res, "Tilemap resource not found");

        current_tilemap = new TiledMap({
            tiled_file_data : res.asset.text,
            format : 'tmx',
            pos : new Vector(0, 0)
        });
        current_tilemap.display({});

    } //draw_tilemap

    function get_tilemap_colliders() {

        // setup wall collisions, these don't move
        var bounds = current_tilemap.layer('collision').bounds_fitted();
        for(bound in bounds) {
            bound.x *= current_tilemap.tile_width;
            bound.y *= current_tilemap.tile_height;
            bound.w *= current_tilemap.tile_width;
            bound.h *= current_tilemap.tile_height;
            tilemap_colliders.push(Polygon.rectangle(bound.x, bound.y, bound.w, bound.h, false));
        }

    } //get_tilemap_colliders

    function get_start_position() {

        for(_group in current_tilemap.tiledmap_data.object_groups) {
            for(_object in _group.objects) {
                if(_object.name == 'entrance') {
                    start_position = _object.pos;
                }
            }
        }

    } //get_start_position

    function draw_collider_polygon(poly:Polygon) {

        var geom = Luxe.draw.poly({
            solid:false,
            close:true,
            depth:100,
            points:poly.vertices,
            immediate:true
        });

        geom.transform.pos.copy_from(poly.position);

    } //draw_collider_polygon

    // PLAYER
    function create_player() {

        var res = Luxe.resources.texture('assets/player.png');
        assertnull(res, "Player texture not found");

        player = new Sprite({
            texture : res,
            pos : start_position,
            size : new Vector(32,32),
            depth : 1
        });

        player_collider = new Circle(player.pos.x, player.pos.y, player.size.x/2 - 1);

    } //create_player

    function create_player_animation() {

        var player_animation_json = Luxe.resources.json('assets/player_anim.json');
        player_animation = player.add(new SpriteAnimation({ name:'player_anim' }));
        player_animation.add_from_json_object(player_animation_json.asset.json);
        player_animation.animation = 'idle';
        player_animation.play();

    } //create_player_animation

    function resolve_horizontal_collisions() {

        var collisions = Collision.shapeWithShapes(player_collider, tilemap_colliders);
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

        var collisions = Collision.shapeWithShapes(player_collider, tilemap_colliders);
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

    function clean_up() {

        if(current_tilemap != null) {
            current_tilemap.destroy();
            current_tilemap = null;
        }
        if(player != null) {
            player.destroy();
            player = null;
        }
        tilemap_colliders = [];
    }

} //PlayState