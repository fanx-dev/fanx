
Code Conventions
======
These conventions are enforced if contributing code for the core distribution.

Indention
------
Do not use tab characters, use spaces only.
Use indention styling braces:
```
  if (cond) {
    doTrue
  }
  else {
    doFalse
  }
```

Pod Naming
------
Pod names are lower snake case.
Prefix with an organization or domain name, for example:
```
  google_produceName_moduleName
```
don't include the "com" in your pod names.


Fields before Methods
-------
```
  //Prefer:
  class Person {
    private Str name
    Void say() {}
  }

  //Never do:
  class Person {
    Void say() {}
    private Str name
  }
```

Field Naming
-------
- Slot names are lower camel case such as "fooBar" (this includes all fields and methods, even const fields)
- Never use screaming caps such as "FOO_BAR"

Others
-----
As same as [Fantom](http://fantom.org/doc/docLang/Conventions)

