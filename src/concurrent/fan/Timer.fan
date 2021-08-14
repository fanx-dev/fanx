//
// Copyright (c) 2021, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2021-8-13 Jed Young Creation
//


internal class SchedulerTask : LinkedElem {
  new SchedulerTask() : super.make() {}
	Int deadline
}

internal rtconst class Timer {
	private Bool alive := true;  // is this scheduler alive
 	private Str name;       // actor pool name
 	private Thread? thread;           // thread currently being used
 	private LinkedList list = LinkedList()
 	private Lock lock = Lock()
 	private ConditionVar condVar = ConditionVar(lock)
  private Bool cancelled := false

  static const Timer defVal := Timer("default")

 	new make(Str name) {
 		this.name = name
 	}

  override Bool isImmutable() { true }

 	Void schedule(Int ns, |->| task) {
 		node := SchedulerTask();
  	node.deadline = TimePoint.nanoTicks() + ns;
  	node.val = task

  	lock.sync {
      success := false
      SchedulerTask? itr := list.first
    	while (itr != null) {
    		if (node.deadline < itr.deadline) {
    			list.insertBefore(node, itr)
          success = true
    			break
    		}
    		itr = itr.next
    	}
      if (!success) list.add(node)

    	if (thread == null) {
    		thread = Thread(name) |->| { run }.start
    	}
      else {
        condVar.signal
      }
      lret null
  	}
 	}

 	Void stop() {
    lock.lock
    cancelled = true
    alive = false
 		condVar.signal
    lock.unlock
 	}

  Void kill() {
    lock.lock
    alive = false
    list.clear
    condVar.signal
    lock.unlock
  }

 	private Void run() {
    while (alive)
    {
      SchedulerTask? task

      lock.lock
      // if no work ready to go, then wait for next deadline
      Int now = TimePoint.nanoTicks();
      task = list.first
      if (task == null) {
      	 condVar.wait()
      	 lock.unlock
      	 continue
      }
      if (task.deadline > now)
      {
        Int toSleep = task.deadline - now
        //echo("timer sleep:$toSleep")
        condVar.wait( Duration.fromNanos(toSleep))
        lock.unlock
        continue
      }
      list.remove(task)
      lock.unlock

      try
      {
        //echo("Timer run:$task")
        |->| f := task.val
        f.call()
      }
      catch (Err e)
      {
        if (alive) e.trace()
      }
    }

    if (cancelled) {
      task := list.first
      while (task != null) {
        try {
          //echo("Timer run:$task")
          |->| f := task.val
          f.call()
        }
        catch {}

        list.remove(task)
        task = list.first
      }
    }
 	}
}