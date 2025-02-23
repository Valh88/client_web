import js.lib.Object;
import js.Browser;
import js.html.WebSocket;
import haxe.Json;

class WebSocketClient
{
	private var _token:String;
	private var _baseurl:String = "ws://localhost:4000/websocket";
	private var _url:String;
	private var _socket:WebSocket;

	public function new(token:String)
	{
		this._token = token;
		_url = _baseurl + "?token=" + _token;
		_socket = new WebSocket(_url);
	}

	public function connect():Void
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
			_socket.send("{\"type\":\"private\",\"message\":{\"from\":\"1\",\"to\":\"2\",\"message\":\"mewewqeqweqwe\"}}");
		};
		_onClose();
		_onError();
		_onMessage();
	}

	public function send(values:String):Void
	{
		_socket.send(values);
	}

	public function sendDynamic(values:Dynamic):Void
	{
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
		};
	}

	private function _onClose():Void
	{
		_socket.onclose = function(event)
		{
			trace("WebSocket closed");
		}
	}
}
