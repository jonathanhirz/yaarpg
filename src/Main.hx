import luxe.Input;
import luxe.States;

import states.StartCreditsState;
import states.TitleScreenState;
import states.MenuState;
import states.PlayState;

class Main extends luxe.Game {

    public static var machine : States;
    public static var draw_colliders : Bool = false;

    override function config(config:luxe.AppConfig) {

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

        // app.render_rate = 1/30;
        // app.update_rate = 1/40;  //30 FPS lock

        connect_input();
        machine = new States({ name:'statemachine' });
        machine.add(new MenuState('menu_state'));
        machine.add(new PlayState('play_state'));
        Luxe.on(init, function(_) {
            machine.set('play_state', 'assets/ship_map.tmx');
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
