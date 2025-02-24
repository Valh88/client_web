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
        _httpClient.runSocket = function(data) {
            _socket = new WebSocketClient(data);
            _socket.connect();
        }
        _view = new View(false);
        _view.loginFunc = _httpClient.login;
        _view.deleteMe = _httpClient.deleteMe;
	}

	public function run():Void
	{
		_view.onStart();
        _view.render();
	}
}
