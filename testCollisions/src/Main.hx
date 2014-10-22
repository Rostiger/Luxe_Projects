import luxe.Input;
import luxe.Vector;
import luxe.Color;
import luxe.Sprite;
import luxe.Text;

import luxe.collision.shapes.Shape;
import luxe.collision.shapes.Circle;
import luxe.collision.shapes.Polygon;
import luxe.collision.CollisionData;
import luxe.collision.Collision;

//for debug view
import luxe.collision.ShapeDrawerLuxe;

class Main extends luxe.Game {

    // declare debug variables
    var debug : Bool = false;
    var debugColor : Int = 0x999999;
    var drawer : ShapeDrawerLuxe;

    // declare the shapes to collide with
    var numberOfShapes : Int;
    var shapes : Array < Polygon >;
    var shapeSprites : Array < Sprite >;
    var selectedShape : Shape;

    // declare the cursor variables
    var cursor : Circle;
    var cursorDistance : Vector;

    // declare a collision data object for the cursor shape
    var cursorCollision : CollisionData;

    override function ready() {

        // initialize the shape drawer for debug draw
        drawer = new ShapeDrawerLuxe();

        // initialize the mouse cursor
        var cursorRadius : Int = 5;
        cursor = new Circle( Luxe.screen.mid.x, Luxe.screen.mid.y, cursorRadius );
        cursorDistance = new Vector();

        // create the collider shapes
        numberOfShapes = 5;
        selectedShape = null;

        // initialise the array storing the shapes and their values
        shapes = [for (i in 0...numberOfShapes) null ];
        // initialise the array storing sprites representing the shapes on screen
        shapeSprites = [for (i in 0...numberOfShapes) null ];

        // set up the depth difference between each shape sprite
        var depthDifference : Float = 5.0;

        // step through the shapes array and fill it with shapes!
        for (i in 0...numberOfShapes) {

            // setup shape variables
            var shapeSize : Vector;
            var shapePos : Vector;

            // set the shape size to the width and height of the screen
            shapeSize = new Vector( Luxe.screen.w, Luxe.screen.h );

            // divide the window height by the number of shapes to determine the y position of the shape
            shapePos = new Vector( shapeSize.x / 2, (shapeSize.y / 2) + (Luxe.screen.h / numberOfShapes) * i );

            // store a polygon with the stored size and position in the shapes array
            shapes[i] = Polygon.rectangle(shapePos.x,shapePos.y,shapeSize.x,shapeSize.y);

            // store the id, size and depth of the shape as additional data in the the data field of the shape
            shapes[i].data = {
                id : i,
                size : new Vector( shapeSize.x, shapeSize.y ),
                depth : i * depthDifference
            };

            // add a sprite with the same size and position to the sprites array
            shapeSprites[i] = new Sprite({
                name : 'shapeSprite'+i,
                pos : new Vector(shapePos.x,shapePos.y),
                size : new Vector(shapeSize.x,shapeSize.y),
                color : new Color(0.8 - (i/20),0.3,0.8,1.0),
                depth : shapes[i].data.depth
            });

        }
    } //ready

    override function onmousemove( e : MouseEvent ) {

        // update the position of the cursor
        cursor.x = e.pos.x;
        cursor.y = e.pos.y;

        // get the boundaries the shape can be moved between
        if (selectedShape != null) {

            // the ids of the shapes before and after the selected one
            var prevShapeId : Int;
            var nextShapeId : Int;

            prevShapeId = selectedShape.data.id +-1; // <-- this is the strangest thing, try removing the + and it'll throw an error
            nextShapeId = selectedShape.data.id + 1;

            // the boundaries the shape can be moved between
            var maxUp : Float;
            var maxDown : Float;

            // figure out the boundaries of the current shape
            maxUp = (prevShapeId >= 0) ? shapes[prevShapeId].y : 0.0;
            maxDown = (nextShapeId < numberOfShapes) ? shapes[nextShapeId].y : Luxe.screen.h * 1.5; // the 1.5 is a dirty hack, but I'm too lazy to do it properly

            // move the selected shape
            selectedShape.y = e.pos.y + cursorDistance.y;

            // keep the selected shape between boundaries
            if (selectedShape.y < maxUp) selectedShape.y = maxUp;
            if (selectedShape.y > maxDown) selectedShape.y = maxDown;
        }
    } //onmousemove

    override function onmousedown ( e : MouseEvent ) {

        // on mouse down, check how many shapes the cursor collides with
        // and pick the one with the highest depth
        var numberOfCollisions : Int = 0;
        var collidingShapes : Array < Shape >;
        collidingShapes = [for (i in 0...numberOfShapes) null ];

        // step through all shapes...
        for (i in 0...numberOfShapes) {

            // and check if there is a collision with the mouse cursor
            cursorCollision = Collision.test( cursor, shapes[i] );

            // if there is a collision, store the colliding shape and count up the total number of collisions
            if (cursorCollision != null) {
                collidingShapes[numberOfCollisions] = cursorCollision.shape2;
                numberOfCollisions++;
            }
        }

        // if more than one shapes are colliding with the mouse cursor, pick the one with the highest depth value
        if (numberOfCollisions > 0) {

            var highestDepth : Float = 0.0;

            // step through the list of colliding shapes
            for (i in 0...numberOfCollisions) {

                // check if the current shape has a higher depth than the previous one
                if (collidingShapes[i].data.depth >= highestDepth) {

                    // if so, set it as selected shape
                    highestDepth = collidingShapes[i].data.depth ;
                    selectedShape = collidingShapes[i];

                }
            }
        }

        // now that we have the selected shape, calculate the distance from the cursor to the shape center
        if (selectedShape != null) {

            cursorDistance = Vector.Subtract(selectedShape.position , e.pos);
        }
    } // onmousedown

    override function onmouseup ( e : MouseEvent ) {

        // when the mouse isn't down, there are no collisions
        cursorCollision = null;
        selectedShape = null;
    } // onmouseup

    override function onkeyup( e:KeyEvent ) {

        // exit the game with the escape key
        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

        // toggle debug mode with the 'd' key
        if (e.keycode == Key.key_d) {
            if (!debug) debug = true;
            else debug = false;
        }
    } //onkeyup

    override function update(dt:Float) {

        // update the position and size of the sprite that belongs to the currently selected shape
        if (selectedShape != null) {

            // get the id of the shape
            var id : Int = selectedShape.data.id;

            // position the selected sprite to the position of its shape
            shapeSprites[id].pos.y = selectedShape.y;

        }

        // debug draw
        if (debug) {

            var selected : String;

            for (i in 0...numberOfShapes) {

                if (selectedShape == shapes[i]) selected = 'SELECTED!';
                else selected = '';

                Luxe.draw.text({
                    immediate : true,
                    size : 12,
                    text : 'ID: ' + shapes[i].data.id + '\nDepth: ' + shapeSprites[i].depth + '\n' + selected,
                    pos : new Vector(10,shapes[i].y - (shapes[i].data.size.y / 2)),
                    depth : shapeSprites[i].depth+1
                });

                drawer.drawPolygon(shapes[i], new Color().rgb(debugColor),  true );
            }

            drawer.drawCircle( cursor, new Color().rgb(debugColor), true );
        }

        Luxe.draw.text({
            immediate : true,
            size : 14,
            pos : new Vector( 20, 30 ),
            text : 'Click and drag the shapes\nPress D for debug draw',
            depth : 4
        });
    } //update


} //Main
