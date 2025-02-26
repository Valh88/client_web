import js.html.UListElement;
import js.html.LIElement;
import haxe.Json;
import haxe.Constraints.Function;
import js.html.LabelElement;
import js.html.DivElement;
import js.html.TextAreaElement;
import js.html.Event;
import js.html.ButtonElement;
import js.html.InputElement;
import js.html.Element;
import js.html.DOMElement;
import js.html.HTMLCollection;
import js.Browser;
import Lambda;

typedef LoginFunc = String->String->Function->Void;
typedef SendFunc = Dynamic<{type:String, message:{from:String, to:String, message:String}}>->Void;
typedef Message = Dynamic<{type:String, message:{from:String, to:String, message:String}}>;

class View
{
	var auth:Bool;
	var document = Browser.document;
	var username:String;
	var userId:String;

	public var messages:Array<{from:String, message:String, date:String}>;
	public var contacts:Array<{user:String, username:String, status:String}>;

	var targetUserId:String;

	public var loginFunc:LoginFunc;
	public var deleteMe:Function;
	public var getMe:Function;
	public var send:SendFunc;
	public var socket:WebSocketClient;

	public function new(auth)
	{
		this.auth = auth;
		contacts = [];
		messages = [];

		username = "Я";
	}

	public function onStart():Void
	{
		changeMain();
		_messageTextEvent();
		_loginPasswordEvent();
	}

	public function debug():Void
	{
		renderContacts();
		renderMessages();
	}

	public function changeMain():Void
	{
		var title = document.getElementsByClassName("form-auth");
		if (auth)
		{
			var loginNode = title[0];
			if (loginNode != null)
			{
				var parrent = loginNode.parentNode;
				parrent.removeChild(loginNode);
				var element = _createHelloUserElement();
				parrent.insertBefore(element, parrent.firstChild);

				var button:ButtonElement = cast Browser.document.createElement("button");
				button.textContent = "logout";
				button.type = "submit";
				button.id = "logout";
				button.style.width = "80px";
				button.onclick = function(event:Event)
				{
					event.preventDefault();
					auth = false;
					deleteMe();
					socket.close();
					render();
				}
				title[0].appendChild(button);
			}
		} else
		{
			var loginNode = title[0];
			var parrent = loginNode.parentNode;
			var node:DivElement = document.createDivElement();
			node.className = "form-auth";
			node.id = "aut";

			parrent.removeChild(loginNode);

			var label:LabelElement = document.createLabelElement();
			label.htmlFor = "username";
			label.textContent = "login";
			node.append(label);

			var input:InputElement = document.createInputElement();
			input.type = "text";
			input.id = "username";
			node.append(input);

			var labelPassword:LabelElement = document.createLabelElement();
			labelPassword.htmlFor = "password";
			labelPassword.textContent = "password";
			node.append(labelPassword);

			var passwordInput:InputElement = document.createInputElement();
			passwordInput.type = "password";
			passwordInput.id = "password";
			passwordInput.autocomplete = "on";
			node.append(passwordInput);

			var button:ButtonElement = document.createButtonElement();
			button.type = "submit";
			button.id = "login";
			button.textContent = "login";
			node.append(button);

			parrent.insertBefore(node, parrent.firstChild);
			_loginPasswordEvent();
			trace("need register form TODO");
		}
	}

	private function _createHelloUserElement():Element
	{
		var element = document.createElement("div");
		element.className = "form-auth";
		element.textContent = "Hello " + username + "!";
		return element;
	}

	private function _loginPasswordEvent():Void
	{
		var buttonLoginNode:ButtonElement = cast document.getElementById("login");
		buttonLoginNode.onclick = function(event:Event)
		{
			event.preventDefault();
			var usernameNode:InputElement = cast document.getElementById("username");
			var passwordNode:InputElement = cast document.getElementById("password");
			if (usernameNode.value != null || passwordNode != null)
			{
				trace(usernameNode.value);
				trace(passwordNode.value);
				loginFunc(usernameNode.value, passwordNode.value, function(data)
				{
					this.auth = true;
					getMe(function(data)
					{
						trace(data);
						trace("getme");
						userId = data.user.id;
						username = data.user.username;
					});
					render();
				});

				// TODO controller callback
			} else
			{
				trace("need login and password");
			}
		}

		trace(buttonLoginNode);
	}

	private function _messageTextEvent():Void
	{
		var button:ButtonElement = cast document.getElementById("message-button");
		button.onclick = function(event:Event)
		{
			event.preventDefault();
			var messageNode:TextAreaElement = cast document.getElementById("textArea");
			if (messageNode.value != null)
			{
				messages.push({from: targetUserId, message: messageNode.value, date: "14:40"}); // заглушка targetUserID
				var data = {type: "private", message: {from: userId, to: targetUserId, message: messageNode.value}};
				trace(Json.stringify(data));
				socket.sendDynamic(data);
				trace(messages);

				messageNode.value = "";
			}
			renderMessages();
		}
	}

	public function messagesNode():Element
	{
		var messagesCollection = document.getElementById("messages");
		return messagesCollection;
	}

	public function newMessageNode(username:String, message:String):Element
	{
		var parrentElement = document.createElement("div");
		parrentElement.className = "message";

		var nameElement = document.createElement("div");
		nameElement.className = "from";
		nameElement.textContent = username;
		parrentElement.appendChild(nameElement);

		var messageElement = document.createElement("div");
		messageElement.className = "text-message bg-text-message";
		messageElement.textContent = message;
		parrentElement.appendChild(messageElement);

		var timeElement = document.createElement("div");
		timeElement.className = "";
		timeElement.textContent = "10.48";
		parrentElement.appendChild(timeElement);

		return parrentElement;
	}

	private function contactNode(name:String, status:String, id:String):Element
	{
		var contactNode = document.createElement("li");
		contactNode.onclick = function(event:Event)
		{
			if (targetUserId != null)
			{
				var d:LIElement = cast document.getElementById(targetUserId);
				d.className = "contact";
			};
			var li:LIElement = cast event.target;
			targetUserId = li.id;
			li.className = "contact li-contact";
			trace(targetUserId);
			renderMessages();
		}
		contactNode.className = "contact";
		contactNode.id = id;
		contactNode.textContent = name + " | " + status;
		return contactNode;
	}

	private function contactsNode():Element
	{
		var contacts = document.getElementById("contacts");
		return contacts;
	}

	public function renderContacts():Void
	{
		var contactsNode = contactsNode();
		contactsNode.innerHTML = "";
		for (contact in contacts)
		{
			var contactNode = contactNode(contact.username, contact.status, contact.user);
			contactsNode.appendChild(contactNode);
		}
	}

	public function renderMessages():Void
	{
		var messagesNode = messagesNode();
		messagesNode.innerHTML = "";
		var userTargetMessages = Lambda.filter(messages, function(message)
		{
			return message.from == targetUserId;
		});
		for (message in userTargetMessages)
		{
			var foundUser = Lambda.find(contacts, function(contact)
			{
				return contact.user == Std.string(message.from);
			});
			if (foundUser != null)
			{
				var messageNode = newMessageNode(foundUser.username, message.message);
				messagesNode.appendChild(messageNode);
			} else
			{
				var messageNode = newMessageNode(username, message.message);

				messagesNode.appendChild(messageNode);
			}
		}
	}

	public function changeContactStatus(data):Void
	{
		// %{status: %{user: %{id: user_id, status: "online"}}}
		for (contact in contacts)
		{
			if (contact.user == data.status.user.id)
			{
				contact.status = data.status.user.status;
				renderContacts();
				break;
			}
		}
	}

	public function render():Void
	{
		changeMain();
		renderContacts();
		renderMessages();
	}
}
