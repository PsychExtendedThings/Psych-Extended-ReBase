package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;

#if NEW_PSYCH063
class CustomFadeTransition extends FlxSubState {
	public static var finishCallback:Void->Void;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;
	var LoadBF:FlxSprite;

	var duration:Float;
	public function new(duration:Float, isTransIn:Bool)
	{
		this.duration = duration;
		this.isTransIn = isTransIn;
		super();
	}

	override function create()
	{
		var cam:FlxCamera = new FlxCamera();
		cam.bgColor = 0x00;
		FlxG.cameras.add(cam, false);
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];

		var width:Int = Std.int(FlxG.width / Math.max(camera.zoom, 0.001));
		var height:Int = Std.int(FlxG.height / Math.max(camera.zoom, 0.001));
		transGradient = FlxGradient.createGradientFlxSprite(1, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scale.x = width;
		transGradient.updateHitbox();
		transGradient.scrollFactor.set();
		transGradient.screenCenter(X);
		transGradient.cameras = [cam];
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		transBlack.scale.set(width, height + 400);
		transBlack.updateHitbox();
		transBlack.scrollFactor.set();
		transBlack.screenCenter(X);
		transBlack.cameras = [cam];
		add(transBlack);

		if(isTransIn)
			transGradient.y = transBlack.y - transBlack.height;
		else
			transGradient.y = -transGradient.height;

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transGradient.cameras = [nextCamera];
		}
		nextCamera = null;

		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		final height:Float = FlxG.height * Math.max(camera.zoom, 0.001);
		final targetPos:Float = transGradient.height + 50 * Math.max(camera.zoom, 0.001);
		if(duration > 0)
			transGradient.y += (height + targetPos) * elapsed / duration;
		else
			transGradient.y = (targetPos) * elapsed;

		if(isTransIn)
			transBlack.y = transGradient.y + transGradient.height;
		else
			transBlack.y = transGradient.y - transBlack.height;

		if(transGradient.y >= targetPos)
		{
			close();
		}
	}

	// Don't delete this
	override function close():Void
	{
		super.close();

		if(finishCallback != null)
		{
			finishCallback();
			finishCallback = null;
		}
	}
}
#else
class CustomFadeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	private var leTween:FlxTween = null;
	public static var nextCamera:FlxCamera;
	var isTransIn:Bool = false;
	var transBlack:FlxSprite;
	var transGradient:FlxSprite;

	public function new(duration:Float, isTransIn:Bool) {
		super();

		this.isTransIn = isTransIn;
		var zoom:Float = CoolUtil.boundTo(FlxG.camera.zoom, 0.05, 1);
		var width:Int = Std.int(FlxG.width / zoom);
		var height:Int = Std.int(FlxG.height / zoom);
		transGradient = FlxGradient.createGradientFlxSprite(width, height, (isTransIn ? [0x0, FlxColor.BLACK] : [FlxColor.BLACK, 0x0]));
		transGradient.scrollFactor.set();
		add(transGradient);

		transBlack = new FlxSprite().makeGraphic(width, height + 400, FlxColor.BLACK);
		transBlack.scrollFactor.set();
		add(transBlack);

		transGradient.x -= (width - FlxG.width) / 2;
		transBlack.x = transGradient.x;

		if(isTransIn) {
			transGradient.y = transBlack.y - transBlack.height;
			FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween) {
					close();
				},
			ease: FlxEase.linear});
		} else {
			transGradient.y = -transGradient.height;
			transBlack.y = transGradient.y - transBlack.height + 50;
			leTween = FlxTween.tween(transGradient, {y: transGradient.height + 50}, duration, {
				onComplete: function(twn:FlxTween) {
					if(finishCallback != null) {
						finishCallback();
					}
				},
			ease: FlxEase.linear});
		}

		if(nextCamera != null) {
			transBlack.cameras = [nextCamera];
			transGradient.cameras = [nextCamera];
		}
		nextCamera = null;
	}

	override function update(elapsed:Float) {
		if(isTransIn) {
			transBlack.y = transGradient.y + transGradient.height;
		} else {
			transBlack.y = transGradient.y - transBlack.height;
		}
		super.update(elapsed);
		if(isTransIn) {
			transBlack.y = transGradient.y + transGradient.height;
		} else {
			transBlack.y = transGradient.y - transBlack.height;
		}
	}

	override function destroy() {
		if(leTween != null) {
			finishCallback();
			leTween.cancel();
		}
		super.destroy();
	}
}
#end