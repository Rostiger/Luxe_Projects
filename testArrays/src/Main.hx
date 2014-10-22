import luxe.Input;
import luxe.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;
import luxe.Text;

import phoenix.geometry.RectangleGeometry;
import phoenix.geometry.QuadGeometry;

class Main extends luxe.Game {

    var tileSize : Int;
    var levelWidth : Int;
    var levelHeight : Int;
    var level : Array < Sprite >;
    var cursor : Sprite;
    var cursorColor : Color = new Color().rgb(0xeade7c);
    var cursorOutline : RectangleGeometry;

    override function ready() {

        tileSize = 32;

        // determine how many tiles with the size of 'tileSize' fit onto the screen
        levelWidth = Std.int(Math.floor(Luxe.screen.w / tileSize));
        levelHeight = Std.int(Math.floor(Luxe.screen.w / tileSize));

        var arraySize : Int = levelWidth * levelHeight;

        // initialise the array with the full level size determined above and fill every entry with 'null'
        level = [for (i in 0...arraySize) null ];

        // now fill the array with invisible sprites
        for (xi in 0...levelWidth) {
            for (yi in 0...levelHeight) {

                // treat the array like a 2d array
                // by adding the y value x the levelWidth
                var index : Int = xi + yi * levelWidth;
                
                level[index] = new Sprite({
                    name : 'tile'+index,
                    pos : new Vector(tileSize * xi, tileSize * yi),
                    size : new Vector(tileSize,tileSize),
                    centered : false,
                    color : new Color(Math.random(),0.3,0.5,1),
                    visible : false
                });

            }
        }

        // PROTIP: change the background color by setting the clear_color variable!
        Luxe.renderer.clear_color = new Color().rgb(0xea6455);

        // setup the cursor
        createCursor();

    } //ready

    function createCursor() {

        // setup the mouse cursor
        cursor = new Sprite({
            name : 'cursor',
            pos : new Vector(Luxe.screen.mid.x,Luxe.screen.mid.y),
            size : new Vector(tileSize,tileSize),
            color : new Color().rgb(0xeade7c),
            centered : false,
        });

        cursor.color.a = 0.3;


    } //createCursor

    var removeBlocks : Bool = false;
    var addBlocks    : Bool = false;

    function toggleBlock(posX : Float, posY : Float) {

        var x : Int = Std.int(posX / tileSize);
        var y : Int = Std.int(posY / tileSize);
        var index : Int = x + y * levelWidth;

        if (!level[index].visible && !removeBlocks) {

            level[index].visible = true;
            level[index].color = new Color(Math.random(),0.3,0.5,1);
            addBlocks = true;

        } else if (!addBlocks) {

            level[index].visible = false;
            removeBlocks = true;

        }
    }

    override function onmousemove( e:MouseEvent ) {

        // to make the cursor position jump between
        // grid cells, we need to check the
        // modulo (rest of division) of the mouse x 
        // position by the tile size
        if (e.pos.x % tileSize == 0) {
            // divide the mouse x position by the tile size, round up and multiply by the tilesize
            cursor.pos.x = Math.ceil(e.pos.x / tileSize) * tileSize;
        } else {
            // otherwise do the same but round down
            cursor.pos.x = Math.floor(e.pos.x / tileSize) * tileSize;
        }

        // same goes for the mouse y position
        if (e.pos.y % tileSize == 0) {
            cursor.pos.y = Math.ceil(e.pos.y / tileSize) * tileSize;
        } else {
            cursor.pos.y = Math.floor(e.pos.y / tileSize) * tileSize;
        }
    
    } //onmousemove

    var mouse_down : Bool = false;

    override function onmousedown( e:MouseEvent ) {

        if(e.button == MouseButton.left) {
            
            mouse_down = true;

            if (cursor.visible) cursor.visible = false;
        }
                    
    } //onmousedown

    override function onmouseup( e:MouseEvent ) {

        if(e.button == MouseButton.left) {
            mouse_down = false;
            addBlocks = false;
            removeBlocks = false;
            if (!cursor.visible) cursor.visible = true;
        }
                    
    } //onmouseup

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {

        // check if the mouse was pressed and add/remove a block accordingly
        if (mouse_down) toggleBlock(cursor.pos.x,cursor.pos.y);
        
        // draw a cursor outline
        cursorOutline = Luxe.draw.rectangle({
            immediate : true,
            id : 'cursorOutline',
            x : cursor.pos.x,
            y : cursor.pos.y,
            w : tileSize,
            h : tileSize,
            color: cursorColor,
            depth : 10
        });
    } //update

} //Main
