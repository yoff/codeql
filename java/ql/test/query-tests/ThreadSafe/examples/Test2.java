package examples;

import java.util.ArrayList;

public class Test2 {
  int x;
  protected ArrayList<String> lst = new ArrayList<>();

  public Test2() {
    this.x = 0;
  }

  public void changeX() {
    this.x = x + 1;
  }

  public void changeLst() {
    lst.add("Hello");
  }
}
