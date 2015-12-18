import luxe.Log.*;
import luxe.States;
import luxe.Vector;
import luxe.Sprite;
import luxe.tilemaps.Tilemap;
import luxe.importers.tiled.TiledMap;
import luxe.importers.tiled.TiledLayer;
import luxe.importers.tiled.TiledObjectGroup;
import luxe.components.sprite.SpriteAnimation;
import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Polygon;

class PlayState extends State {

    // tilemap
    var current_tilemap : TiledMap;
    var ship_map : String = 'assets/ship_map.tmx';
    var ship_map_2 : String = 'assets/ship_map_2.tmx';
    public static var tilemap_colliders : Array<Shape> = [];
    var start_position : Vector;

    // player
    var player : Sprite;
    var player_animation : SpriteAnimation;

    public function new( _name:String ) {
        super({ name:_name });
    } //new

    override function init() {

    } //init

    override function onenter<T>( _value:T ) {

        draw_tilemap(ship_map);
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
        if(Main.draw_colliders) {
            for(shape in tilemap_colliders) draw_collider_polygon(cast shape);
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

        player = new Player({
            texture : res,
            pos : start_position,
            size : new Vector(32,32),
            depth : 1
        });

    } //create_player

    function create_player_animation() {

        var player_animation_json = Luxe.resources.json('assets/player_anim.json');
        player_animation = player.add(new SpriteAnimation({ name:'player_anim' }));
        player_animation.add_from_json_object(player_animation_json.asset.json);
        player_animation.animation = 'idle';
        player_animation.play();

    } //create_player_animation

    function clean_up() {

        if(current_tilemap != null) {
            current_tilemap.destroy();
            current_tilemap = null;
        }
        if(player != null) {
            player.destroy();
            player = null;
        }
    }

} //PlayState