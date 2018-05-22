package fan.std;

public class TimeNativePeer {
	static long currentTimeMillis() {
		return System.currentTimeMillis();
	}
	
	static long nanoTicks() {
		return System.nanoTime();
	}
}
