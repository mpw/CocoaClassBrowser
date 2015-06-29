##Compile clang and LLVM

Follow the instructions in clang's getting started guide to build the clang and LLVM libraries, and install them into /usr/local along with the headers.

The current master in ClassBrowser was tested with SVN revision 240948 of LLVM, Clang and Compiler-RT. Contributions for a better build process that let us manage the LLVM libraries better are welcome :-).


##Clone the project

and run `git submodule update --init`.


##Build and run in Xcode

Sorry step 1 was really long. Suggestions or pull requests for [better ways to build ClassBrowser](https://bitbucket.org/iamleeg/ikbclassbrowser/issue/14/better-build-process) are of course welcome.
