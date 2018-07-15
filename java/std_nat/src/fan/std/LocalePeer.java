package fan.std;

public class LocalePeer {
	static Locale defaultLocale;
	static {
		java.util.Locale jl = java.util.Locale.getDefault();
		defaultLocale = Locale.make(jl.getLanguage(), jl.getCountry());
	}

	static ThreadLocal<Locale> threadLocale = new ThreadLocal<Locale>() {
		@Override
		protected Locale initialValue() {
			return defaultLocale;
		}
	};

	static Locale cur() {
		return threadLocale.get();
	}

	static void setCur(Locale local) {
		threadLocale.set(local);
		try {
			java.util.Locale jl = java.util.Locale.forLanguageTag(local.lang);
			java.util.Locale.setDefault(jl);
		} catch (Throwable e) {
			e.printStackTrace();
		}
	}
}
