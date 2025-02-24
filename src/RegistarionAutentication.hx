import js.lib.Promise;
import js.Browser;
import js.html.Response;
import js.html.Request;
import js.html.RequestInit;
import js.html.Storage;

class RegistarionAutentication
{
	private var _token:Null<String>;
	var storage:Storage;

	public function new()
	{
		storage = Browser.getLocalStorage();
		token = storage.getItem("token");
	}

	public function getMe():Void
	{
		if (_token != null)
		{
			Browser.window.fetch("http://127.0.0.1:4000/api/me?token=" + this?._token)
				.then(function(response)
				{
					return response.json();
				})
				.then(function(data)
				{
					trace(data);
				})
				.catchError(function(error)
				{
					trace("Error: " + error);
				});
		} else
		{
			trace("no token");
		}
	}

	public function registration(username:String, password:String):Void
	{
		var data = {"account": {"username": username, "password": password}};
		var headers = new js.html.Headers([["Content-Type", "application/json"]]);
		var options:RequestInit =
			{
				method: "POST",
				headers: headers,
				body: haxe.Json.stringify(data)
			};

		Browser.window.fetch("http://127.0.0.1:4000/api/registration", options)
			.then(function(response)
			{
				return response.json();
			})
			.then(function(data)
			{
				trace(data);
			})
			.catchError(function(error)
			{
				trace(error);
			});
	}

	public function login(username:String, password:String):Void
	{
		var headers = new js.html.Headers([["Content-Type", "application/json"]]);
		var data = {"account": {"username": username, "password": password}};
		var options:RequestInit =
			{
				method: "POST",
				headers: headers,
				body: haxe.Json.stringify(data)
			};
		Browser.window.fetch("http://127.0.0.1:4000/api/login", options)
			.then(function(response)
			{
				return response.json();
			})
			.then(function(data)
			{
				try
				{
					if (data.status == "success")
					{
						_token = data.token;
						trace(data);
						storage.setItem("token", _token);
					}
				} catch (e)
				{
					trace(e);
					trace(data);
				}
			})
			.catchError(function(error)
			{
				trace(error);
			});
	}

	public function deleteMe():Void
	{
		var headers = new js.html.Headers([["Content-Type", "application/json"]]);
		var options:RequestInit =
			{
				method: "DELETE",
				headers: headers
			};
		storage.clear();
		Browser.window.fetch("http://127.0.0.1:4000/api/me?token=" + this?._token, options)
			.then(function(response)
			{
				return response.json();
			})
			.then(function(data)
			{
				trace(data);
			})
			.catchError(function(error)
			{
				trace(error);
			});
	}

	public var token(get, set):String;

	public function get_token():Null<String>
	{
		return _token;
	}

	function set_token(value:String):String
	{
		_token = value;
		return _token;
	}
}
