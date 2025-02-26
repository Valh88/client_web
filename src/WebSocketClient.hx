import haxe.Constraints.Function;
import js.lib.Object;
import js.Browser;
import js.html.WebSocket;
import haxe.Json;

class WebSocketClient
{
	private var _token:Null<String>;
	private var _baseurl:String = "ws://localhost:4000/websocket";
	private var _url:String;
	private var _socket:WebSocket;

	public var addContacts:Function;
	public var addMessages:Function;
	public var addMessage:Function;
	public var changeStatusContact:Function;

	public function new(token:Null<String>)
	{
		this._token = token;
		_url = _baseurl + "?token=" + _token;
		_socket = new WebSocket(_url);
	}

	public function connect():Void
	{
		if (_token != null)
		{
			_socket.onopen = function(event)
			{
				trace("WebSocket opened");
				trace(event.data);
				Browser.window.setInterval(function()
				{
					if (_socket.readyState == js.html.WebSocket.OPEN)
					{
						_socket.send("ping");
					} else
					{
						trace("WebSocket is not open. Current state: " + _socket.readyState);
					}
				}, 30000);
				// _socket.send("{\"type\":\"private\",\"message\":{\"from\":\"1\",\"to\":\"2\",\"message\":\"mewewqeqweqwe\"}}");
			};
			_onClose();
			_onError();
			_onMessage();
		}
	}

	public var token(get, set):String;

	public function get_token():Null<String>
	{
		return _token;
	}

	public function set_token(value):Null<String>
	{
		_token = value;
		return _token;
	}

	public function send(values:String):Void
	{
		_socket.send(values);
	}

	public function sendDynamic(values:Dynamic):Void
	{
		trace(values);
		var data = toString(values);
		_socket.send(data);
	}

	public function toString(values:Dynamic):String
	{
		return Json.stringify(values);
	}

	public function toObject(values:String):Dynamic
	{
		return Json.parse(values);
	}

	private function _onError():Void
	{
		_socket.onerror = function(event)
		{
			trace("WebSocket error: " + event);
		};
	}

	private function _onMessage():Void
	{
		_socket.onmessage = function(event)
		{
			var data = toObject(event.data);
			trace(data);
			if (Reflect.hasField(data, "contacts"))
			{
				addContacts(data);
			} else if (Reflect.hasField(data, "new_messages"))
			{
				addMessages(data);
			} else if (Reflect.hasField(data, "type"))
			{
				addMessage(data);
			} else if (Reflect.hasField(data, "status"))
			{
				changeStatusContact(data);
			}
		};
	}

	private function _onClose():Void
	{
		_socket.onclose = function(event)
		{
			trace("WebSocket closed");
		}
	}

	public function close():Void
	{
		_socket.close();
	}
}
