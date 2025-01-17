package examples;

import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.util.Collection;
import java.util.Iterator;
import java.util.Objects;
import java.util.Spliterator;
import java.util.function.Consumer;
import java.util.function.IntFunction;
import java.util.function.Predicate;
import java.util.stream.Stream;

/**
 * @serial include
 */
@ThreadSafe
class SynchronizedCollection<E> implements Collection<E>, Serializable {
  // @java.io.Serial
  // private static final long serialVersionUID = 3053995032091335093L;

  @SuppressWarnings("serial") // Conditionally serializable
  final Collection<E> c; // Backing Collection
  // @SuppressWarnings("serial") // Conditionally serializable
  // final Object mutex; // Object on which to synchronize

  SynchronizedCollection(Collection<E> c) {
    this.c = Objects.requireNonNull(c);
    // mutex = this;
  }

  // SynchronizedCollection(Collection<E> c, Object mutex) {
  //   this.c = Objects.requireNonNull(c);
  //   this.mutex = Objects.requireNonNull(mutex);
  // }

  public int size() {
    synchronized (this) {
      return c.size();
    }
  }

  public boolean isEmpty() {
    synchronized (this) {
      return c.isEmpty();
    }
  }

  public boolean contains(Object o) {
    synchronized (this) {
      return c.contains(o);
    }
  }

  public Object[] toArray() {
    synchronized (this) {
      return c.toArray();
    }
  }

  public <T> T[] toArray(T[] a) {
    synchronized (this) {
      return c.toArray(a);
    }
  }

  public <T> T[] toArray(IntFunction<T[]> f) {
    synchronized (this) {
      return c.toArray(f);
    }
  }

  public Iterator<E> iterator() {
    return c.iterator(); // Must be manually synched by user!
  }

  public boolean add(E e) {
    synchronized (this) {
      return c.add(e);
    }
  }

  public boolean remove(Object o) {
    synchronized (this) {
      return c.remove(o);
    }
  }

  public boolean containsAll(Collection<?> coll) {
    synchronized (this) {
      return c.containsAll(coll);
    }
  }

  public boolean addAll(Collection<? extends E> coll) {
    synchronized (this) {
      return c.addAll(coll);
    }
  }

  public boolean removeAll(Collection<?> coll) {
    synchronized (this) {
      return c.removeAll(coll);
    }
  }

  public boolean retainAll(Collection<?> coll) {
    synchronized (this) {
      return c.retainAll(coll);
    }
  }

  public void clear() {
    synchronized (this) {
      c.clear();
    }
  }

  public String toString() {
    synchronized (this) {
      return c.toString();
    }
  }

  // Override default methods in Collection
  @Override
  public void forEach(Consumer<? super E> consumer) {
    synchronized (this) {
      c.forEach(consumer);
    }
  }

  @Override
  public boolean removeIf(Predicate<? super E> filter) {
    synchronized (this) {
      return c.removeIf(filter);
    }
  }

  @Override
  public Spliterator<E> spliterator() {
    return c.spliterator(); // Must be manually synched by user!
  }

  @Override
  public Stream<E> stream() {
    return c.stream(); // Must be manually synched by user!
  }

  @Override
  public Stream<E> parallelStream() {
    return c.parallelStream(); // Must be manually synched by user!
  }

  // @java.io.Serial
  private void writeObject(ObjectOutputStream s) throws IOException {
    synchronized (this) {
      s.defaultWriteObject();
    }
  }
}
