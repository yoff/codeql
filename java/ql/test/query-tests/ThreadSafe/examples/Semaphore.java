package examples;

@ThreadSafe
public class Semaphore {
  private final int capacity;
  private int state;

  public Semaphore(int c) {
    capacity = c;
    state = 0;
  }

  public void acquire() {
    synchronized (this) {
      try {
        while (state == capacity) {
          this.wait();
        }
        state++;
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

  public void release() {
    synchronized (this) {
      state--; // State can become negative
      this.notifyAll();
    }
  }
}
