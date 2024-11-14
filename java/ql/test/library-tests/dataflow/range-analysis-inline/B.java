public class B {
    public int forloop() {
        int result = 0;
        for (int i = 0; i < 10; i++) {
            result += 1;
        }
        return result;
    }

    public int emptyforloop() {
        int result = 0;
        for (int i = 0; i < 0; i++) {
            result += 1;
        }
        return result;
    }

    public int noloop() {
        int result = 0;
        result += 1; // $ value=0
        return result; // $ value=1
    }

    public int foreachloop() {
        int result = 0;
        for (int i : new int[] {1, 2, 3, 4, 5}) {
            result += 1;
        }
        return result;
    }

    public int emptyforeachloop() {
        int result = 0;
        for (int i : new int[] {}) {
            result += 1;
        }
        return result;
    }

    public int whileloop() {
        int result = 100;
        while (result > 5) { // $ interval=4..100
            result = result - 2; // $ interval=6..100
        }
        return result; // $ value=4
    }

    public int oddwhileloop() {
        int result = 101;
        while (result > 5) { // $ interval=5..101
            result = result - 2; // $ interval=7..101
        }
        return result; // $ value=5
    }
}