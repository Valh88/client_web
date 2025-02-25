import RegistarionAutentication;
import WebSocketClient;
import View;

class Controller
{
	private var _view:View;
	private var _httpClient:RegistarionAutentication;
	private var _socket:WebSocketClient;

	public function new()
	{
		_socket = new WebSocketClient(null);
		_httpClient = new RegistarionAutentication(_socket);
		_httpClient.runSocket = function(data)
		{
			_socket = new WebSocketClient(data);

			_socket.addContacts = function(data) {
				trace(data.contacts);
				_view.contacts = data.contacts;
				_view.renderContacts();
			}

			_socket.addMessages = function(data) {
				// _view.messages.push(data.new_messages);
				var array = data.new_messages.concat(_view.messages);
				trace(array);
				trace("123123123");
				trace(data);
				_view.messages = array;
				_view.renderMessages();
			}

			_socket.connect();
			_view.socket = _socket;
		}
		_view = new View(false);
		_view.loginFunc = _httpClient.login;
		_view.deleteMe = _httpClient.deleteMe;
		_view.getMe = _httpClient.getMe;
	}

	public function run():Void
	{
		_view.onStart();
		_view.render();
	}
}
