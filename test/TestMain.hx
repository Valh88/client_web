package test;

import utest.Runner;
import utest.ui.Report;
import utest.Assert;
import RegistarionAutentication;

class TestMain
{
	public static function main()
	{
		var runner = new Runner();
		runner.addCase(new RegistarionAutenticationTest());
		Report.create(runner);
		runner.run();
	}
}

class RegistarionAutenticationTest
{
	private var testClient:RegistarionAutentication;

	public function new()
	{
		testClient = new RegistarionAutentication();
	}

	public function testAddition()
	{
		var result = 2 + 2;
		testClient.registration("username4", "password4");

		testClient.login("username4", "password4");
		trace(testClient.token);
		Assert.isNull(testClient.token);

		testClient.deleteMe();
	}
}
