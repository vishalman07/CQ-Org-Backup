@IsTest
private class FakeClassTest {
    @IsTest
    static void testBehavior() {
        FakeClass fakeClass = new FakeClass();

        fakeClass.fakeTestMethod();
    }
}