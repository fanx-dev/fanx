package fan.std;

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.util.Enumeration;
import java.util.NoSuchElementException;

import fan.sys.Err;
import fan.sys.FanInt;

public class UuidFactoryPeer {

	public static long resolveMacAddr() {
		// first try MAC address
		try {
			return doResolveMacAddr();
		} catch (NoSuchMethodError e) {
		} // ignore if not on 1.6
		catch (NoSuchElementException e) {
		} // ignore if no network interfaces
		catch (Throwable e) {
			e.printStackTrace();
		}

		// then try local IP address
		try {
			return resolveIpAddr();
		} catch (Throwable e) {
			e.printStackTrace();
		}
		return 0;
	}

	private static long doResolveMacAddr() throws Exception {
		// use 1.6 API to get MAC address
		Enumeration e = NetworkInterface.getNetworkInterfaces();
		while (e.hasMoreElements()) {
			NetworkInterface net = (NetworkInterface) e.nextElement();
			byte[] mac = net.getHardwareAddress();
			if (mac != null)
				return toLong(mac);
		}
		throw new NoSuchElementException();
	}

	private static long resolveIpAddr() throws Exception {
		return toLong(InetAddress.getLocalHost().getAddress());
	}

	private static long toLong(byte[] bytes) {
		// if bytes less then 6 pad with random
		if (bytes.length < 6) {
			byte[] temp = new byte[6];
			System.arraycopy(bytes, 0, temp, 0, bytes.length);
			for (int i = bytes.length; i < temp.length; ++i)
				temp[i] = (byte) FanInt.random();
			bytes = temp;
		}

		// mask bytes into 6 byte long
		long x = ((bytes[0] & 0xFFL) << 40) | ((bytes[1] & 0xFFL) << 32) | ((bytes[2] & 0xFFL) << 24)
				| ((bytes[3] & 0xFFL) << 16) | ((bytes[4] & 0xFFL) << 8) | ((bytes[5] & 0xFFL) << 0);

		// if we have more then six bytes mask against primary six bytes
		for (int i = 6; i < bytes.length; ++i)
			x ^= (bytes[i] & 0xFFL) << (((i - 6) % 6) * 8);

		return x;
	}
}
