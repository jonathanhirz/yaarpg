package states;

import luxe.States;

class MenuState extends State {

    public function new( _name:String ) {
        super({ name:_name });
    } //new

    override function init() {

        // set basic title
        // press 'space' to start


    } //init

    override function onenter<T>( _value:T ) {


    } //onenter

    override function onleave<T>( _value:T ) {


    } //onleave

    override function update(dt:Float) {


    } //update

} //MenuState