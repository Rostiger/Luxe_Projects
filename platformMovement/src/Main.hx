import luxe.Input;
import luxe.Sprite;
import luxe.Scene;
import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;
import luxe.Text;

import phoenix.geometry.RectangleGeometry;

class Main extends luxe.Game {

    var tileSize                : Int;
    var tileColor               : Int = 0x4c4c7f;
    var levelWidth              : Int;
    var levelHeight             : Int;
    var level                   : Array < Sprite >;
    var cursor                  : Sprite;
    var cursorOutline           : RectangleGeometry;
    var cursorEnabled           : Bool = true;
    var cursorColor             : Color;
    var cursorColorEnabled      : Int = 0xeade7c;
    var cursorColorDisabled     : Int = 0xff1e3a;

    var playerScene : Scene;

    override function ready() {

        tileSize = 32;

        // determine how many tiles with the size of 'tileSize' fit onto the screen
        levelWidth = Std.int(Math.floor(Luxe.screen.w / tileSize));
        levelHeight = Std.int(Math.floor(Luxe.screen.h / tileSize));

        // create the level
        createLevel();

        // PROTIP: change the background color by setting the clear_color variable!
        Luxe.renderer.clear_color = new Color().rgb(0xea6455);

        // setup the cursor
        createCursor();

        // create the player
        createPlayer();
    } // ready

    function createLevel() {

        // set the array size
        var arraySize : Int = levelWidth * levelHeight;

        // initialise the array using the size determined above
        // fill each entries with 'null'
        level = [for (i in 0...arraySize) null ];

        // now fill the array with something useful - sprites!
        // each sprite will represent a level tile
        for (xi in 0...levelWidth) {
            for (yi in 0...levelHeight) {

                // treat the array like a 2d array
                // instead of getting the index using arrayname[x][y]
                // the index is calculated with this formula: x + y * arrayWidth
                var index : Int = xi + yi * levelWidth;
                
                // now store an invisible sprite in the array at the position of the index
                level[index] = new Sprite({
                    name : 'tile'+index,
                    pos : new Vector(tileSize * xi, tileSize * yi),
                    size : new Vector(tileSize,tileSize),
                    centered : false,
                    color : new Color().rgb(tileColor),
                });

                // we want a border around the level made of tiles
                // check the position of the current tile in the index
                // and set it to visible or invisible accordingly
                if (xi == 0 || xi == levelWidth - 1 || yi == 0 || yi == levelHeight - 1) level[index].visible = true;
                else level[index].visible = false;

            }
        }
    } // createLevel

    function createCursor() {

        // create a sprite for the mouse cursor
        // and place it in the middle of the screen
        cursor = new Sprite({
            name : 'cursor',
            pos : new Vector(Luxe.screen.mid.x,Luxe.screen.mid.y),
            size : new Vector(tileSize,tileSize),
            color : new Color().rgb(cursorColorEnabled),
            centered : false,
        });

        // set the alpha of the cursor color
        cursor.color.a = 0.3;
    } // createCursor

    function createPlayer() {

        // here I've set up a new scene for the player
        // this is actually an unnecessary misuse of the scene concept (as far as I can tell),
        // but I wanted to learn how it works :)
        // I'll re-write this later to make proper use of the scene
        if (playerScene != null) return;

        playerScene = new Scene( 'player scene' );

        // set up the player sprite
        var player = new Sprite({
            name : 'player',
            pos : new Vector( (levelWidth / 2) * tileSize, (levelHeight / 2) * tileSize ),
            size : new Vector( tileSize, tileSize ),
            color : new Color().rgb(0xfff19e),
            scene : playerScene,
            centered : false
        });

        // add the movement component
        player.add(new Movement({ name:'movement' }));

        // connect the input
        connectInput();
    } // createPlayer

    function connectInput() {

        // here the keys are defined that can be used for input
        Luxe.input.add('left', Key.left);
        Luxe.input.add('left', Key.key_a);

        Luxe.input.add('right', Key.right);
        Luxe.input.add('right', Key.key_d);

        Luxe.input.add('up', Key.up);
        Luxe.input.add('up', Key.key_w);
    } //connect_input

    var removeBlocks : Bool = false;
    var addBlocks    : Bool = false;

    function toggleBlock( x : Float, y : Float ) {

        // this function sets the tile visible or invisible

        x = Math.floor(x / tileSize);        // converts the level x position to the leve array x position
        y = Math.floor(y / tileSize);        // same for the y position

        // get the index
        var index : Int = Std.int(x + y * levelWidth);

        // if the tile is visible and the player isn't currently removing blocks
        if (!level[index].visible && !removeBlocks) {

            // 'add' a block
            level[index].visible = true;
            addBlocks = true;

        // otherwise if the player isn't currently adding blocks
        } else if (!addBlocks) {

            // 'remove' a block
            level[index].visible = false;
            removeBlocks = true;

        }
    } // toggleBlock

    public function placeFree( x : Float, y : Float ) {

        //checks if the a block sprite at given point (x,y) in the level array is visible or not

        x = Math.floor(x / tileSize);        // converts the level x position to the leve array x position
        y = Math.floor(y / tileSize);        // same for the y position
        
        // get the index
        var index : Int = Std.int(x + y * levelWidth);
        
        // returns true if not visible and false if visible
        return (level[index].visible == false);
    } // placeFree


    override function onmousemove( e:MouseEvent ) {

        var cursorIndex = new Vector();

        // to make the cursor position jump between
        // grid cells, we need to check the
        // modulo (rest of division) of the mouse x 
        // position by the tile size
        if (e.pos.x % tileSize == 0) {
            // divide the mouse x position by the tile size, round up and multiply by the tilesize
            cursorIndex.x = Math.ceil(e.pos.x / tileSize);
        } else {
            // otherwise do the same but round down
            cursorIndex.x = Math.floor(e.pos.x / tileSize);
        }

        // same goes for the mouse y position
        if (e.pos.y % tileSize == 0) {
            cursorIndex.y = Math.ceil(e.pos.y / tileSize);
        } else {
            cursorIndex.y = Math.floor(e.pos.y / tileSize);
        }

        // restrict the cursor to its bounds
        if (cursorIndex.x == 0) cursorIndex.x = 1;
        if (cursorIndex.y == 0) cursorIndex.y = 1;
        if (cursorIndex.x == levelWidth - 1) cursorIndex.x = levelWidth - 2;
        if (cursorIndex.y == levelHeight - 1) cursorIndex.y = levelHeight - 2;

        // set the cursor position
        cursor.pos = Vector.Multiply(cursorIndex, tileSize);
    } // onmousemove

    var mouse_down : Bool = false;

    override function onmousedown( e:MouseEvent ) {

        if(e.button == MouseButton.left) {
            
            mouse_down = true;

            if (cursor.visible) cursor.visible = false;
        }                  
    } // onmousedown

    override function onmouseup( e:MouseEvent ) {

        if(e.button == MouseButton.left) {
            mouse_down = false;
            addBlocks = false;
            removeBlocks = false;
            if (!cursor.visible) cursor.visible = true;
        }             
    } // onmouseup

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }
    } // onkeyup

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
            depth : 100
        });

        // cursor.color = cursorColor;
        // cursor.color.a = 0.3;

        Luxe.draw.text({
            immediate : true,
            size : 14,
            pos : new Vector( tileSize * 2, tileSize * 2 ),
            text : 'Use WASD to move.\nUse the mouse to build or remove blocks',
            depth : -10
        });
    } // update

} //Main
