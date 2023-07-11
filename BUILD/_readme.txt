2023 July 10

I can't publish the modified sources because they are based on files that are
copyrighted by The Soft Warehouse.

The files in this directory are not the original MuMath-83 files.
For example, a diff between MuMath-83 arith.mus and the file arith.mus in this
directory show many differenes (ignoring the comments that I added decades ago).
I don't remember on which files I applied the changes to make them work with
muLisp-87.

As reported in issue #1, the original MuMath 83 files are not supported.

The files in this directory are ready to be loaded as described in the README:

mulisp                                      % Start muLISP %
(load "EXTMLISP.LSP")                       % Load the binary extension EXTMLISP.BIN %
(load "MUSIMP.LSP")                         % Load the surface language muSIMP %
    rds("FORMMATH.MUS");
    save("MUSIMP.SYS");                     % At this step, you have the muSIMP language with FormMath preloaded %
    demo: nil;                              % to not execute the demos %
    rds("ARITH.MUS");                       % 10/01/83 %
    etc...

The resulting SYS file is named MUMATHFM.SYS to make clear it's not an official MuMath.
TRG.ALG has not been loaded: error nonnumeric argument break: (/ 1 (^ 2 1/2))

Tested with DOSBox-X (should work with DOSBox or vDosPlus):
mulisp mumathfm.sys

muLISP-87 IBM PC MS-DOS Version 6.03 (07/12/88)
(C) Copyright Soft Warehouse, Inc., 1983, 1985, 1986, 1987.
All Rights Reserved Worldwide
muSIMP Surface Language For Symbolic Math Processing.

To exit, type:
system();
