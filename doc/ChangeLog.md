## ChangeLog

### Build 4.2 (2022-04-10)
- add Env.fileResolver
- remove finalize
- optimze Gc
- fix funServices
- fix CallExpr.len for IDE
- reflect nullable type
- Uri.query immutable
- add Cache.containsKey
- C: fix Str.toByteIndex Str.getRange
- C: fix getInterfaceVTable
- C: auto detach thread
- C: fix SysInStream.readBytes
- C: fix Float.toLocale
- C: fix MemBuf.pipFrom
- C: fix DateTime.fromTicks
- C: fix str literal
- JS: fix Lock
- JS: fix unchecked Sys.findType
- JS: add Pod.config, Pod.props


### Build 4.1.4 (2021-12-11)
- fix local var scpe start
- fix Type toImmutable
- fix read FFI fcode error
- fix negative wait time
- fix enclosingVars
- Int.clamp,Float.clamp

### Build 4.1.3 (2021-10-12)
- native: fix Method reflect with default param
- native: Pod.file fallback
- native: fix Str without ConstantFolder
- compiler: check depends in compilerx

### Build 4.1.2 (2021-10-08)
- genC: add Field.size
- Uri field to method
- new Duration literal
- add fr_getField/fr_setField

### Build 4.1.0 (2021-09-30)
- genC: fix as Expr
- fix gc visitChildren
- fix pod reflect load
- genC: support type's mixins meta
- fni: find Field in base class
- file read with 'rb'
- compileToJs return pod info
- fanx: disable Duration literals
- normalize CRLF
- test in AddressSanitizer
- optimize GC
- support amalgamation build
- replace zlib
- fix bug: Array.arraycopy, Str.get, EnvProps

### Build 4.0.2 (2021-09-08)
- update fantom
- restore fantom syntax
- use Env peer
- fix assignment codeAsm
- fix linklist clear
- Env.compilerScriptToJs

### Build 4.0.1 (2021-08-31)
- java like constructor chain
- static ctor is not supported

### Build 4.0 (2021-08-26)
- new fanx compiler
- fix fanrun vm and genc
- std pod JNI like code
- rewrite concurrent pod
- support new .fanx file
- allow 'as' Nullable; forbid 'is' Nullable

### Build 3.4 (2021-05-30)
- JS support NoPeer facet
- ObjDecoder support static const
- fanrun: new ABI
- fanrun: add NoNative facet
- List groupBy, groupByInto
- BoolArray clear, eachTrue, getAndSet
- Int.clip, Float.clip
- Bit I/O: OutStream.writeBits, InStream.readBits
- Allow once methods to be used on const classes
- Add Closure flags

### Build 3.3 (2020-10-25)
- Fix NioBuf
- Fix async in abstract method
- Update Fantom to 1.0.75
- Rewrite AsyncRunner
- Support Async.sleep
- Support await concurrent::Future
- Support override async method
- Fix async exception handing
- Fix ConstBuf Stream bug

### Build 3.2 (2020-06-07)
- Fix Err warn on Windows
- Unicode as Identifier
- parser: close FPod
- Fix Js safe warn
- Fix closureExpr in async
- Fix Js datetime
- Add Process.outToIn

### Build 3.1 (2020-04-22)
- Add Native C FFI
- Add JarDistMain (build to Java JAR)
- Add parser pod for IDE
- Reflect Api to rtconst
- Test on NodeJs

### Build 3.0 (2019-12-07)
- Move Type to std pod
- Support raw Array and Pointer
- Add List.slice
- Enhance type alias
- Rework Func for MethodHandle
- Check set const on compile time
- Remove Func.arity
- Fix static inherit bug
- Uri standard form support
- Postfix type annotations

### Build 2.2 (2019-06-01)
- Add Promise
- Fix ExprFlat
- Move Josn to util
- Support Map.defV
- Fix path on Windows
- Fix the devHome configure
- Support bootstrap build
- Test on Windows
- Jigsaw (Java9+) support

### Build 2.1 (2019-03-30)
- No doc test code
- Allow method body in native class
- Fix growing non-nullable List
- Move Str method to StrExt
- Fix Js reflect
- Fix for Android
- Fix ScriptCompiler
- Fix JarDist
- Add Type.emptyList
- Update Fantom-1.0.72

### Build 2.0 (2019-02-16)
- Fix Service bug
- Fix UriScheme
- Add Int/Float toLocale
- Fix virtual once
- Add JS support
- Fix JS static init dependency
- More primitive type (Int8/Int16/Int32/Int64/Float32/Float64)
- Fix data class ctor
- The async/await pattern coroutine
- Named param
- AOP support by checked dynamic call '~>'
- Class default is 'final'
- Inline finally block and remove JumpFinally opcode
- Emit param default in front-end compiler
- Add flags for MethodRef
- Add LoadFieldLiteral/LoadMethodLiteral Opcode

### Build 1.0 (2018-09-10)
- Generics
- Extension Method
- Struct Type
- RunTime Immutable
- Readonly keyword
- Data Class
- Initialization Assignment
- Closure Inference
- Local Return
- Build Script
- Portable Library
- More Container
- New JSON Api
- Actor Enhance
- Return From Void
- Float Literals
