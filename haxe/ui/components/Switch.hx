package haxe.ui.components;

import haxe.ui.core.UIEvent;
import haxe.ui.util.Variant;
import haxe.ui.core.IClonable;
import haxe.ui.core.InteractiveComponent;
import haxe.ui.core.MouseEvent;
import haxe.ui.focus.FocusManager;
import haxe.ui.layouts.DefaultLayout;
import haxe.ui.styles.Style;
import haxe.ui.util.MathUtil;

/**
 A Switch is a two-state toggle switch component that can select between two options
**/
//@:dox(icon = "")  //TODO
class Switch extends InteractiveComponent implements IClonable<Switch> {
    private var _button:Button;

    public function new() {
        super();
    }

    //***********************************************************************************************************
    // Internals
    //***********************************************************************************************************
    private override function createDefaults() {
        _defaultLayout = new SwitchLayout();
    }

    private override function create() {
        super.create();
    }

    private override function createChildren() {
        if(_button == null) {
            _button = new Button();
            _button.id = "switch-button";
            _button.addClass("switch-button");
            _button.onClick = function(e) {
                selected = !selected;
            }
            addComponent(_button);
        }

        registerEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        registerEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        registerEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);
    }

    private override function destroyChildren() {
        super.destroyChildren();

        unregisterEvent(MouseEvent.MOUSE_OVER, _onMouseOver);
        unregisterEvent(MouseEvent.MOUSE_OUT, _onMouseOut);
        unregisterEvent(MouseEvent.MOUSE_DOWN, _onMouseDown);


        if(_button != null) {
            removeComponent(_button);
            _button = null;
        }
    }

    //***********************************************************************************************************
    // Overrides
    //***********************************************************************************************************

    private override function get_value():Variant {
        return _selected;
    }

    private override function applyStyle(style:Style) {
        super.applyStyle(style);

        if(_button != null) {
            _button.customStyle.borderRadius = style.borderRadius;
        }
    }

    //***********************************************************************************************************
    // Public API
    //***********************************************************************************************************

    private var _selected:Bool = false;
    @:clonable public var selected(get, set):Bool;
    private function get_selected():Bool {
        return _selected;
    }
    private function set_selected(value:Bool):Bool {
        if (value == _selected) {
            return value;
        }

        _selected = value;
        if (_selected == false) {
            removeClass(":selected");
        } else {
            addClass(":selected");
        }

        invalidateLayout();

        var event:UIEvent = new UIEvent(UIEvent.CHANGE);
        dispatch(event);

        return value;
    }

    //***********************************************************************************************************
    // Events
    //***********************************************************************************************************
    private var _mouseDownOffsetX:Float;
    private var _mouseDownOffsetY:Float;
    private var _down:Bool = false;

    private function _onMouseOver(event:MouseEvent) {
        if (_down == false) {
            addClass(":hover");
        }
    }

    private function _onMouseOut(event:MouseEvent) {
        removeClass(":hover");
    }

    private function _onMouseDown(event:MouseEvent) {
        if (FocusManager.instance.focusInfo != null && FocusManager.instance.focusInfo.currentFocus != null) {
            FocusManager.instance.focusInfo.currentFocus.focus = false;
        }
        _down = true;

        _mouseDownOffsetX = event.screenX;
        _mouseDownOffsetY = event.screenY;
        screen.registerEvent(MouseEvent.MOUSE_UP, _onMouseUp);
    }

    private function _onMouseUp(event:MouseEvent) {
        _down = false;

        //Check if the user makes a click (selected should change) or if the user tries to move the button
        if(MathUtil.distance(event.screenX, event.screenY, _mouseDownOffsetX, _mouseDownOffsetY) < 5) {   //TODO - DPI should be considered
            selected = !selected;
        } else {
            selected = (event.screenX - ((screenLeft + componentWidth) / 2) > 0);
        }

        if (hitTest(event.screenX, event.screenY)) {
            addClass(":hover");
        }

        screen.unregisterEvent(MouseEvent.MOUSE_UP, _onMouseUp);
    }
}

@:dox(hide)
class SwitchLayout extends DefaultLayout {
    public function new() {
        super();
    }

    private override function repositionChildren() {
        var switchComp:Switch = cast _component;
        var button:Button = switchComp.findComponent("switch-button");
        button.top = paddingTop;
        if(switchComp.selected == true) {
            button.left = switchComp.componentWidth - button.componentWidth - paddingRight;
        } else {
            button.left = paddingLeft;
        }
    }
}