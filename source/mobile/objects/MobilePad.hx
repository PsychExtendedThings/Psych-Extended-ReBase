package mobile.objects;

import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.utils.Assets;

//More button support (Some buttons doesn't have a texture)
@:build(mobile.macros.ButtonMacro.createButtons(["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","SELECTOR"]))
@:build(mobile.macros.ButtonMacro.createExtraButtons(30)) //Psych Extended Allows to Create 30 Extra Button with Json for now
class MobilePad extends FlxTypedSpriteGroup<MobileButton> {
	//DPad
	public var buttonLeft:MobileButton = new MobileButton(0, 0);
	public var buttonUp:MobileButton = new MobileButton(0, 0);
	public var buttonRight:MobileButton = new MobileButton(0, 0);
	public var buttonDown:MobileButton = new MobileButton(0, 0);

	//PAD DUO MODE
	public var buttonLeft2:MobileButton = new MobileButton(0, 0);
	public var buttonUp2:MobileButton = new MobileButton(0, 0);
	public var buttonRight2:MobileButton = new MobileButton(0, 0);
	public var buttonDown2:MobileButton = new MobileButton(0, 0);

	public var dPad:FlxTypedSpriteGroup<MobileButton>;
	public var actions:FlxTypedSpriteGroup<MobileButton>;
	public var createdButtons:Array<String> = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","SELECTOR","Left","Up","Right","Down","Left2","Up2","Right2","Down2"];
	
	/**
	 * Create a gamepad.
	 *
	 * @param   DPadMode   The D-Pad mode. `LEFT_FULL` for example.
	 * @param   ActionMode   The action buttons mode. `A_B_C` for example.
	 */

	public function new(DPad:String, Action:String) {
		super();

		dPad = new FlxTypedSpriteGroup<MobileButton>();
		dPad.scrollFactor.set();

		actions = new FlxTypedSpriteGroup<MobileButton>();
		actions.scrollFactor.set();

		if (DPad != "NONE")
		{
			if (!MobileData.dpadModes.exists(DPad))
				throw 'The mobilePad dpadMode "$DPad" doesn\'t exists.';

			for (buttonData in MobileData.dpadModes.get(DPad).buttons)
			{
				Reflect.setField(this, buttonData.button,
					createMobileButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color)));
				dPad.add(add(Reflect.field(this, buttonData.button)));
			}
		}

		if (Action != "NONE" && Action != "controlExtend")
		{
			if (!MobileData.actionModes.exists(Action))
				throw 'The mobilePad actionMode "$Action" doesn\'t exists.';

			for (buttonData in MobileData.actionModes.get(Action).buttons)
			{
				Reflect.setField(this, buttonData.button,
					createMobileButton(buttonData.x, buttonData.y, buttonData.graphic, CoolUtil.colorFromString(buttonData.color), buttonData.bg));
				actions.add(add(Reflect.field(this, buttonData.button)));
			}
		}

		switch (Action){
			case "controlExtend":
				if (Type.getClass(FlxG.state) != PlayState || Type.getClass(FlxG.state) == PlayState && ClientPrefs.data.extraKeys >= 1) actions.add(add(buttonExtra1 = createMobileButton(FlxG.width * 0.5 - 44, FlxG.height * 0.5 - 127 * 0.5, "f", 0xFF0000)));
				if (Type.getClass(FlxG.state) != PlayState || Type.getClass(FlxG.state) == PlayState && ClientPrefs.data.extraKeys >= 2) actions.add(add(buttonExtra2 = createMobileButton(FlxG.width * 0.5 - 44, FlxG.height * 0.5 - 127 * 0.5, "g", 0xFFFF00)));
				if (Type.getClass(FlxG.state) != PlayState || Type.getClass(FlxG.state) == PlayState && ClientPrefs.data.extraKeys >= 3) actions.add(add(buttonExtra3 = createMobileButton(FlxG.width * 0.5 - 44, FlxG.height * 0.5 - 127 * 0.5, "x", 0x99062D)));
				if (Type.getClass(FlxG.state) != PlayState || Type.getClass(FlxG.state) == PlayState && ClientPrefs.data.extraKeys >= 4) actions.add(add(buttonExtra4 = createMobileButton(FlxG.width * 0.5 - 44, FlxG.height * 0.5 - 127 * 0.5, "y", 0x4A35B9)));
			case "NONE":
		}
	}

	public function createMobileButton(x:Float, y:Float, Frames:String, ColorS:Int, ?bg:String):Dynamic
	{
		return createVirtualButton(x, y, Frames, ColorS);
	}

	public function createVirtualButton(x:Float, y:Float, Frames:String, ?ColorS:Int = 0xFFFFFF):MobileButton {
		var frames:FlxGraphic;

		final path:String = 'assets/mobile/MobileButton/VirtualPad/original/$Frames.png';
		#if MODS_ALLOWED
		final modsPath:String = Paths.modFolders('mobile/MobileButton/VirtualPad/original/$Frames');
		if(sys.FileSystem.exists(modsPath))
			frames = FlxGraphic.fromBitmapData(BitmapData.fromFile(modsPath));
		else #end if(Assets.exists(path))
			frames = FlxGraphic.fromBitmapData(Assets.getBitmapData(path));
		else
			frames = FlxGraphic.fromBitmapData(Assets.getBitmapData('assets/mobile/MobileButton/VirtualPad/original/default.png'));

		var button = new MobileButton(x, y);
		button.frames = FlxTileFrames.fromGraphic(frames, FlxPoint.get(Std.int(frames.width / 2), frames.height));

		button.updateHitbox();
		button.updateLabelPosition();

		button.bounds.makeGraphic(Std.int(button.width - 50), Std.int(button.height - 50), FlxColor.TRANSPARENT);
		button.centerBounds();

		button.immovable = true;
		button.solid = button.moves = false;
		button.antialiasing = ClientPrefs.data.antialiasing;
		button.tag = Frames.toUpperCase();

		if (ColorS != -1) button.color = ColorS;

		return button;
	}

	override public function destroy():Void
	{
		super.destroy();
		for (field in Reflect.fields(this))
			if (Std.isOfType(Reflect.field(this, field), MobileButton))
				Reflect.setField(this, field, FlxDestroyUtil.destroy(Reflect.field(this, field)));
	}
}