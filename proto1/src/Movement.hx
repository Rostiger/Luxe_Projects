import luxe.Vector;
import luxe.Input;
import luxe.utils.Maths;
import luxe.Component;
import luxe.Sprite;

class Movement extends Component {

	var dir : Vector;
	var vel : Vector;
	var acc : Float;
	var dec : Float;
	var maxSpeed : Int;
	var rest : Vector;
	var gravity : Float;
	var jumpStrength : Float;
	var jump : Bool;
	var canJump : Bool;
	var sprite : Sprite;

	override function init() {

		dir = new Vector( 1, 1 );
		vel = new Vector( 0, 0 );
		acc = 0.9;
		dec = 0.89;
		maxSpeed = 7;
		rest = new Vector( 0, 0 );
		gravity = 0.5;
		jumpStrength = -10.0;
		jump = false;
		canJump = true;
		sprite = cast entity;
	}

	override function update( dt:Float ) {

		// set the x direction depending on the input
		if (Luxe.input.inputdown( 'left' ) && !Luxe.input.inputdown( 'right' )) dir.x = -1;
		else if (Luxe.input.inputdown( 'right') && !Luxe.input.inputdown( 'left' )) dir.x = 1;
		else dir.x = 0;

		// set the x velocity depending on the direction
		if (dir.x != 0) {
			if (Math.abs(vel.x) < maxSpeed) vel.x += acc * dir.x;
			else vel.x = maxSpeed * dir.x;
		} else {
			if (Math.abs(vel.x) > 1) vel.x *= dec;
			else vel.x = 0;
		}

		// check if jump was pressed and if the player can jump
     	if (Luxe.input.inputdown( 'up' ) && canJump) {

     		canJump = false;
     		jump = true;

     	}

     	// check if the player is on solid ground, e.g. has a collision below
     	if (jump && (!LuxeApp._game.placeFree( pos.x, pos.y + sprite.size.y ) || !LuxeApp._game.placeFree( pos.x + sprite.size.x - 1, pos.y + sprite.size.y ))) {
     			
     			vel.y = jumpStrength;
     			jump = false;

     	} else {

			// falling
			vel.y += gravity;

		}

		// set the y direction depending on the y velocity
		dir.x =  (vel.x > 0 ) ? 1 : -1;
		dir.y =  (vel.y > 0 ) ? 1 : -1;

		// get the integer value of the velocity without the floating point values
		var intVel = new Vector( 0, 0);
		intVel.x += Math.floor( Math.abs(vel.x) );
		intVel.y += Math.floor( Math.abs(vel.y) );

		// get the floating point value of the current velocity
		rest.x += Math.abs(vel.x) - Math.floor( Math.abs(vel.x) );
		rest.y += Math.abs(vel.y) - Math.floor( Math.abs(vel.y) );

		// evertime the rest becomes larger than one, reset it to 0 and add 1 to the whole number of velocity
     	if (rest.x >= 1) {
     		rest.x = 0;
     		intVel.x++;
     	}

     	if (rest.y >= 1) {
     		rest.y = 0;
     		intVel.y++;
     	}

     	// set an offset
        var offset = new Vector( 0, 0 );
        offset.x = (vel.x < 0) ? 0 : sprite.size.x - 1;
        offset.y = (vel.y < 0) ? 0 : sprite.size.y - 1;

     	// check for left and right collisions
        var x = Std.int(intVel.x);
     	while (x > 0)  {

			if (LuxeApp._game.placeFree( pos.x + offset.x + dir.x, pos.y ) && 
				LuxeApp._game.placeFree( pos.x + offset.x + dir.x, pos.y + sprite.size.y - 1) ) {

			    pos.x += dir.x;
			
			} else vel.x = 0;

			x--;
     	}

     	// check for top and bottom collisions
        var y = Std.int(intVel.y);
     	while (y > 0)  {

			if (LuxeApp._game.placeFree( pos.x, pos.y + offset.y + dir.y ) && 
				LuxeApp._game.placeFree( pos.x + sprite.size.x - 1, pos.y + offset.y + dir.y) ) {

			    pos.y += dir.y;
			
			} else {

				vel.y = 0;

				// if the jump key was released, let the player jump again
			    if (!Luxe.input.inputdown( 'up' )) canJump = true;
			}

			y--;
     	}
	} // update
}