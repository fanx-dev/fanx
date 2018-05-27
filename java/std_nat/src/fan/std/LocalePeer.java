package fan.std;

public class LocalePeer {
	static Locale getLocale() {
		java.util.Locale jl = java.util.Locale.getDefault();
		Locale locale = Locale.make(jl.getLanguage(), jl.getCountry());
		return locale;
	}

	static void setLocale(Locale local) {
		java.util.Locale jl = java.util.Locale.forLanguageTag(local.lang);
		java.util.Locale.setDefault(jl);
	}
}
