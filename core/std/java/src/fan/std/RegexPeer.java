package fan.std;

import java.util.regex.Pattern;

import fan.sys.FanStr;
import fan.sys.List;
import fanx.interop.Interop;

public class RegexPeer {
	private Pattern pattern;

	public static RegexPeer make(Regex self) {
		return new RegexPeer();
	}

	void init(Regex self) {
		pattern = Pattern.compile(self.source);
	}

	public boolean matches(Regex self, String s) {
		return pattern.matcher(s).matches();
	}

	public RegexMatcher matcher(Regex self, String s) {
		return new RegexMatcher(pattern.matcher(s));
	}

	public List split(Regex self, String s) {
		return split(self, s, 0L);
	}

	public List split(Regex self, String s, long limit) {
		return Interop.toFanList(FanStr.type, pattern.split(s, (int) limit));
	}
}
