import luxe.Input;
import luxe.States;
import luxe.Screen;
import luxe.GameConfig;

import states.*;

class Main extends luxe.Game {

    public static var machine : States;
    public static var draw_colliders : Bool = false;

    override function config(config:GameConfig) : GameConfig {

        if(config.user.window != null) {
            if(config.user.window.width != null) {
                config.window.width = Std.int(config.user.window.width);
            }
            if(config.user.window.height != null) {
                config.window.height = Std.int(config.user.window.height);
            }
        }

        config.window.title = config.user.window.title;


        config.preload.textures.push({ id:'assets/player.png' });
        config.preload.textures.push({ id:'assets/tileset.png' });
        config.preload.textures.push({ id:'assets/sheet_19.png' });

        config.preload.jsons.push({ id:'assets/player_anim.json' });

        config.preload.texts.push({ id:'assets/ship_map.tmx' });
        config.preload.texts.push({ id:'assets/ship_map_2.tmx' });
        config.preload.texts.push({ id:'assets/outside.tmx' });

        return config;

    } //config

    override function ready() {


        //todo: Outside tiles
        //todo: Switch tilemap on certain tiles
        //todo: New character (human)
        //todo: Swing something (sword or stick)
        //todo: Enemies to hit
        //todo: is this an action rpg?

        // app.render_rate = 1/30;
        // app.update_rate = 1/40;  //30 FPS lock

        connect_input();
        machine = new States({ name:'statemachine' });
        machine.add(new MenuState('menu_state'));
        machine.add(new GameState('game_state'));
        Luxe.on(init, function(_) {
            machine.set('game_state', 'assets/ship_map.tmx');
        });

    } //ready

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
        if(e.keycode == Key.key_0) {
            draw_colliders = !draw_colliders;
        }

    } //onkeyup

    override function update(dt:Float) {

    } //update

    override function onwindowresized( e:WindowEvent ) {
        trace(e);
        Luxe.camera.viewport = new luxe.Rectangle(0, 0, e.x, e.y);
    }

    function connect_input() {

        Luxe.input.bind_key('up', Key.up);
        Luxe.input.bind_key('up', Key.key_w);
        Luxe.input.bind_key('right', Key.right);
        Luxe.input.bind_key('right', Key.key_d);
        Luxe.input.bind_key('down', Key.down);
        Luxe.input.bind_key('down', Key.key_s);
        Luxe.input.bind_key('left', Key.left);
        Luxe.input.bind_key('left', Key.key_a);
        Luxe.input.bind_key('space', Key.space);
        Luxe.input.bind_key('run', Key.lshift);

    } //connect_input

} //Main
