package fan.concurrent;

import java.util.*;

class AsyncPeer {
  private static Timer timer = null;


  public AsyncPeer make(Async self) {
    return new AsyncPeer();
  }

  public static Timer getTimer() {
    if (timer == null) {
      timer = new Timer();
    }
    return timer;
  }

  public static Promise sleep(fan.std.Duration d) {
    final Promise p = Promise$.make();
    TimerTask task = new TimerTask() {
      @Override
      public void run() {
        p.complete(null, true);
      }
    };

    getTimer().schedule(task, d.toMillis());
    return p;
  }
}