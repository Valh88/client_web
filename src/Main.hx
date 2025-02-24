import js.html.WebSocket;
import js.Browser;
import WebSocketClient;
import RegistarionAutentication;
import View;

class Main
{
	static function main()
	{
		// var socket = new WebSocketClient("eyJ1c2VybmFtZSI6ImRzYWRzYXNzcyJ9");
		// socket.connect();
		// var cli = new RegistarionAutentication();
		var view = new View(false);
		view.onStart();
		view.debug();
	}
}
