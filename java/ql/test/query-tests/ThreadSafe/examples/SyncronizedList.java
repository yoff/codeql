package examples;

import java.util.Collection;
import java.util.List;
import java.util.ListIterator;

/**
  * @serial include
  */
@ThreadSafe
class SynchronizedList<E> extends SynchronizedCollection<E> implements List<E> {
        
  // @java.io.Serial
  // private static final long serialVersionUID = -7754090372962971524L;

  @SuppressWarnings("serial") // Conditionally serializable
  final List<E> list;

  SynchronizedList(List<E> list) {
    super(list);
    this.list = list;
  }
  // SynchronizedList(List<E> list, Object mutex) {
  //     // super(list, mutex);
  //     this.list = list;
  // }

  public boolean equals(Object o) {
    if (this == o)
      return true;
    synchronized (this) {return list.equals(o);}
  }
  public int hashCode() {
    synchronized (this) {return list.hashCode();}
  }

  public E get(int index) {
    synchronized (this) {return list.get(index);}
  }
  public E set(int index, E element) {
    synchronized (this) {return list.set(index, element);} // $ Alert
  }
  public void add(int index, E element) {
    synchronized (this) {list.add(index, element);}
  }
  public E remove(int index) {
    synchronized (this) {return list.remove(index);}
  }

  public int indexOf(Object o) {
    synchronized (this) {return list.indexOf(o);}
  }
  public int lastIndexOf(Object o) {
    synchronized (this) {return list.lastIndexOf(o);}
  }

  public boolean addAll(int index, Collection<? extends E> c) {
    synchronized (this) {return list.addAll(index, c);}
  }

  public ListIterator<E> listIterator() {
    return list.listIterator(); // Must be manually synched by user
  }

  public ListIterator<E> listIterator(int index) {
    return list.listIterator(index); // Must be manually synched by user
  }

  public List<E> subList(int fromIndex, int toIndex) {
    synchronized (this) {
      return new SynchronizedList<>(list.subList(fromIndex, toIndex)); // Not correct, originally uses the mutex
    }
  }
}
