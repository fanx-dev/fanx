package fan.std;

public class LocalePeer {
	static Locale cur() {
		java.util.Locale jl = java.util.Locale.getDefault();
		Locale locale = Locale.make(jl.getLanguage(), jl.getCountry());
		return locale;
	}

	static void setCur(Locale local) {
		java.util.Locale jl = java.util.Locale.forLanguageTag(local.lang);
		java.util.Locale.setDefault(jl);
	}
}
