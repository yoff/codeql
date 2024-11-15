public class B {
    public int forloop() {
        int result = 0;
        for (int i = 0; i < 10; i++) {
            result = i;
        }
        return result; // $ interval=0..9
    }

    public int forloopexit() {
        int result = 0;
        for (; result < 10;) { // $ interval=0..10
            result += 1; // $ interval=0..9
        }
        return result; // $ value=10
    }

    public int forloopexitstep() {
        int result = 0;
        for (; result < 10;) { // $ interval=0..12
            result += 3; // $ interval=0..9
        }
        return result; // $ value=12
    }

    public int forloopexitupd() {
        int result = 0;
        for (; result < 10; result++) { // $ interval=0..9 interval=0..10
        }
        return result; // $ value=10
    }

    public int forloopexitnested() {
        int result = 0;
        for (; result < 10;) { // $ value=0
            int i = 0;
            for (; i < 3;) {
            }
            result += i; // $ value=0
        }
        return result; // $ interval=10..0
    }

    public int emptyforloop() {
        int result = 0;
        for (int i = 0; i < 0; i++) {
            result = i;
        }
        return result; // $ value=0
    }

    public int noloop() {
        int result = 0;
        result += 1; // $ value=0
        return result; // $ value=1
    }

    public int foreachloop() {
        int result = 0;
        for (int i : new int[] {1, 2, 3, 4, 5}) {
            result = i;
        }
        return result;
    }

    public int emptyforeachloop() {
        int result = 0;
        for (int i : new int[] {}) {
            result = i;
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