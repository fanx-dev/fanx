//
// Copyright (c) 2009, Brian Frank and Andy Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   28 Mar 09  Brian Frank  Creation
//
package fan.concurrent;

/**
 * Scheduler is used to schedule work to be run after an elapsed
 * period of time.  It is optimized for use with the actor framework.
 * Scheduler lazily launches a background thread the first time an
 * item of work is scheduled.
 */
public class Scheduler implements Runnable
{

//////////////////////////////////////////////////////////////////////////
// Constructor
//////////////////////////////////////////////////////////////////////////

  /**
   * Constructor.
   */
  public Scheduler(String name)
  {
    this.name = name;
    this.alive = true;
  }

//////////////////////////////////////////////////////////////////////////
// Public
//////////////////////////////////////////////////////////////////////////

  /**
   * Schedule the work item to be executed after
   * the given duration of nanoseconds has elapsed.
   */
  public synchronized void schedule(long ns, Work work)
  {
    // insert into our linked list
    boolean newHead = add(ns, work);

    // if we haven't launched our thread yet, then launch it
    if (thread == null)
    {
      thread = new Thread(this, name + "-Scheduler");
      thread.start();
    }

    // if we added to the head of our linked list, then we
    // modified our earliest deadline, so we need to notify thread
    if (newHead) notifyAll();
  }

  /**
   * Add the work item into the linked list so that the list
   * is always sorted by earliest deadline to oldest deadline.
   * Return true if we have a new head which changes our
   * next earliest deadline.
   */
  private boolean add(long ns, Work work)
  {
    // create new node for our linked list
    Node node = new Node();
    node.deadline = System.nanoTime() + ns;
    node.work = work;

    // if no items, this is easy
    if (head == null)
    {
      head = node;
      return true;
    }

    // if new item has earliest deadline it becomes new head
    if (node.deadline < head.deadline)
    {
      node.next = head;
      head = node;
      return true;
    }

    // find insertion point in linked list
    Node last = head, cur = head.next;
    while (cur != null)
    {
      if (node.deadline < cur.deadline)
      {
        node.next = cur;
        last.next = node;
        return false;
      }

      last = cur;
      cur = cur.next;
    }

    // this node has the oldest deadline, append to linked list
    last.next = node;
    return false;
  }

  /**
   * Stop the background thread and call cancel
   * on all pending work items.
   */
  public synchronized void stop()
  {
    // kill background thread
    alive = false;
    try { thread.interrupt(); } catch (Throwable e) {}

    // call cancel on everything in queue
    Node node = head;
    while (node != null)
    {
      try { node.work.cancel(); } catch (Throwable e) { e.printStackTrace(); }
      node = node.next;
    }

    // clear queue
    head = null;
  }

  /**
   * Debug
   */
  public void dump()
  {
    for (Node n = head; n != null; n = n.next)
      System.out.println("  " + n);
  }

//////////////////////////////////////////////////////////////////////////
// Thread
//////////////////////////////////////////////////////////////////////////

  public void run()
  {
    while (alive)
    {
      try
      {
        Work work = null;
        synchronized (this)
        {
          // if no work ready to go, then wait for next deadline
          long now = System.nanoTime();
          if (head == null || head.deadline > now)
          {
            long toSleep = head != null ? head.deadline - now : Long.MAX_VALUE;
            long ms = toSleep / 1000000L;
            long ns = toSleep % 1000000L;
            wait(ms, (int)ns);
            continue;
          }

          // dequeue the next work item while holding lock
          work = head.work;
          head = head.next;
        }

        // work callback
        work.work();
      }
      catch (Throwable e)
      {
        if (alive) e.printStackTrace();
      }
    }
  }

//////////////////////////////////////////////////////////////////////////
// Node (linked list of work)
//////////////////////////////////////////////////////////////////////////

  static class Node
  {
    public String toString()
    {
      long ms = (deadline - System.nanoTime()) / 1000000L;
      return "Deadline: " + ms + "ms  Work: " + work;
    }

    long deadline;   // System.nanoTime
    Work work;       // item of work to execute
    Node next;       // next node in linked list
  }

//////////////////////////////////////////////////////////////////////////
// Work (item of work to be scheduled)
//////////////////////////////////////////////////////////////////////////

  public static interface Work
  {
    public void work();
    public void cancel();
  }

//////////////////////////////////////////////////////////////////////////
// Fields
//////////////////////////////////////////////////////////////////////////

  volatile boolean alive;  // is this scheduler alive
  final String name;       // actor pool name
  Thread thread;           // thread currently being used
  Node head;               // linked list sorted by deadline
}