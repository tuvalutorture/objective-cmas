#  OBJECTIVE-CMAS LIBRARIES

### What is an Objective-CMAS library?
In Objective-CMAS, you may find the current selection of types and/or instructions lacklustre. <br>
Hence, in Objective-CMAS, libraries are fully supported, and can be included with <br>
`utilising [library name]` or `utilising [library name] as [prefix]` <br>
where `prefix` is the prefix you want to use for instructions of that library (i.e. list operations are prefixed with `list`)

### How do I make my own?
To make an Objective-CMAS library, all you need is the SIMAS runtime library and headers. <br>
First, you need to create a library that conforms to the `SIMASLibrary` protocol (defined in `SIMASRuntime.h`). <br>
Then, in your implementation, you can define any `SIMASFUNC(name)` functions, or pass in Objective-C methods as operators (use the macros, they're helpful). <br>
To register types, use `[(your type class) registerToRuntime]`, to register instructions use `[[SIMASRuntime runtime] registerOperation:(operation variable) withName:(the name of your instruction) withPrefix:(the passed prefix)]`. <br>
If you have any library dependencies you want loaded in, you can use `[[SIMASRuntime runtime] loadLibrary:(the bundle of the library) withPrefix:(that library's prefix)]` to load it in for you. <br>
Then, all you need to do is compile your class into a .bundle, linking against the SIMAS runtime, and you're done!

A good example of a library would be `SIMASList`, where you could completely separate it into its own .bundle, and it would still function (as long as it's linked correctly).
