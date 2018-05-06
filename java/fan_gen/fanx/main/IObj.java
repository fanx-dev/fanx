package fanx.main;


public interface IObj extends Comparable {
	Object toImmutable();
	boolean isImmutable();
	Type typeof();
}
