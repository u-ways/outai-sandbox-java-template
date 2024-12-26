import org.junit.jupiter.api.Test;

class MainTest {
    @Test
    void smokeTestMain() {
        System.out.println("Smoke testing Main.main()");
        System.out.println("Result: ");
        Main.main(new String[0]);
    }
}
