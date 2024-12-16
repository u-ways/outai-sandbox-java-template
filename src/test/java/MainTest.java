import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.is;

import org.junit.jupiter.api.Test;

class MainTest {
    @Test
    void testHelloWorld() {
        assertThat("Hello, World!", is("Hello, World!"));
    }
}
