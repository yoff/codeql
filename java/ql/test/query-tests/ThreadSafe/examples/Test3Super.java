package examples;

@ThreadSafe
public class Test3Super extends Test2 {

  public Test3Super() {
    super.x = 0;
  }

  public void y() {
    super.x = 0;
  }

  public void yLst() {
    super.lst.add("Hello!");
  }
}
