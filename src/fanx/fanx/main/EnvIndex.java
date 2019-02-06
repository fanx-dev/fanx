package fanx.main;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import fanx.fcode.FStore;
import fanx.fcode.FStore.Input;

public class EnvIndex {

	public static synchronized Map<String, List<String>> load() {
		// long t1 = System.currentTimeMillis();

		// load all the props
		HashMap<String, List<String>> map = new HashMap<String, List<String>>();
		List<String> podNames = Sys.env.listPodNames();
		for (int i = 0; i < podNames.size(); ++i) {
			String n = podNames.get(i);
			try {
				FStore store = Sys.env.loadPod(n, true);
//				loadPod(map, n, new File(n));
				Input in = store.read("index.props");
				if (in != null) {
					addProps(map, in);
				}
			} catch (Throwable e) {
				e.printStackTrace();
				System.out.println("ERROR: Env.index load: " + n + "\n  " + e);
			}
		}
		return map;
	}

	private static void loadPod(HashMap<String, List<String>> index, String n, File f) throws Exception {
		ZipFile zip = new ZipFile(f);
		try {
			ZipEntry entry = zip.getEntry("index.props");
			if (entry != null) {
				addProps(index, zip.getInputStream(entry));
			}
		} finally {
			zip.close();
		}
	}

	private static void addProps(HashMap<String, List<String>> map, InputStream in) throws IOException {
		BufferedReader r = new BufferedReader(new InputStreamReader(in));
		String line;
		while (true) {
			line = r.readLine();
			if (line == null)
				break;
			line = line.trim();
			if (line.startsWith("//"))
				continue;
			String[] fs = line.split("=", 2);
			if (fs.length != 2) {
				System.out.println("ERROR read:" + line);
			}
			String key = fs[0].trim();
			String val = fs[1].trim();

			List<String> res = map.get(key);
			if (res == null) {
				res = new ArrayList<String>();
				map.put(key, res);
			}
			res.add(val);
			
//			System.out.println(key + "=>" + res);
		}
	}

}
