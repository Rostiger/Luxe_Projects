import luxe.Input;
import luxe.Vector;
import luxe.Color;
import luxe.Text;

import luxe.Parcel;
import luxe.ParcelProgress;

import luxe.Sprite;
import luxe.components.sprite.SpriteAnimation;
import phoenix.Texture;

class Main extends luxe.Game {

    var boar : Sprite;
    var ani : SpriteAnimation;
    var image : Texture;

    var moveSpeed : Float = 0;

    override function ready() {
            // fetch  a list of assets to load from the json file
        var json_asset = Luxe.loadJSON('assets/parcel.json');

            // then create a parcel to load it for us
        var preload = new Parcel();
            preload.from_json(json_asset.json);

            // add a progress bar
        new ParcelProgress({
            parcel : preload,
            background : new Color(1,1,1,0.85),
            oncomplete : assets_loaded
        });

        preload.load();


    } //ready

    function assets_loaded(_) {

        create_boar();
        create_boar_animation();
        connect_input();

    }

    function create_boar() {

        image = Luxe.loadTexture('assets/boar_walk.png');

        image.filter = FilterType.linear;

        var frame_width = 216;
        var frame_height = 146;

        var height = Luxe.screen.h / 5.5;
        var ratio = (height / frame_height);
        var width = frame_width * ratio;

        moveSpeed = width * 0.7;

        boar = new Sprite({
            name : 'boar',
            texture : image,
            pos : new Vector(Luxe.screen.mid.x,Luxe.screen.mid.y),
            size : new Vector(width, height)
        });

    }

    function create_boar_animation() {

        var anim_object = Luxe.loadJSON('assets/boarAni.json');

        ani = boar.add(new SpriteAnimation({ name : 'ani' }));

        ani.add_from_json_object( anim_object.json );

        ani.animation = 'idle';
        ani.play();

    }

    function connect_input() {

        Luxe.input.add('left', Key.left);
        Luxe.input.add('a', Key.key_a);

        Luxe.input.add('right', Key.right);
        Luxe.input.add('d', Key.key_d);

    }

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

        if (boar == null) return;

        var moving = false;

        if (Luxe.input.inputdown('left')) {

            boar.pos.x -= moveSpeed * dt;
            boar.flipx = false;
            
            moving = true;
        
        } else if (Luxe.input.inputdown('right')) {

            boar.pos.x += moveSpeed * dt;
            boar.flipx = true;

            moving = true;

        }

        if (moving) {

            if (ani.animation != 'walk') ani.animation = 'walk';

        } else {

            if (ani.animation != 'idle') ani.animation = 'idle';
        }

        Luxe.draw.text({
                //this line is important, as each frame it will create new geometry!
            immediate:true,
            color : new Color(1,1,1,1),
            pos : new Vector(boar.pos.x,boar.pos.y + (boar.size.x / 2)),
            align : TextAlign.center,
            text : 'Frame: ' + ani.image_frame,
        });

    } //update

} //Main