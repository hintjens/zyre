@ECHO OFF
:-  configure.bat creates platform.h and configures the build process
:-  You MUST run this before building via msbuild or VisualStudio.

IF %1.==--help. (
    ECHO Syntax: configure [ switch ]
    ECHO    --help                  show this help
    ECHO    --enable-drafts         from zip package, enables DRAFT API
    ECHO    --disable-drafts        from git repository, disables DRAFT API
    ECHO    --without-perf_local    do not build perf_local.exe
    ECHO    --without-perf_remote   do not build perf_remote.exe
    ECHO    --without-zpinger       do not build zpinger.exe
    ECHO    --without-ztester_beacon  do not build ztester_beacon.exe
    ECHO    --without-ztester_gossip  do not build ztester_gossip.exe
    ECHO    --without-zyre_selftest  do not build zyre_selftest.exe
    GOTO END
)
ECHO Configuring zyre...

ECHO //  Generated by configure.bat> platform.h
ECHO. >> platform.h
ECHO #ifndef __PLATFORM_H_INCLUDED__>> platform.h
ECHO #define __PLATFORM_H_INCLUDED__>> platform.h
ECHO. >> platform.h
ECHO #define ZYRE_HAVE_WINDOWS 1>> platform.h

:-  Check for dependencies
IF EXIST "..\..\..\libzmq" (
    ECHO Building with libzmq
    ECHO #define HAVE_LIBZMQ 1>> platform.h
) ELSE (
    ECHO Building without libzmq
    ECHO zyre cannot build without libzmq
    ECHO Please clone https://github.com/zeromq/libzmq, and then configure & build
    ECHO TODO: resolve this problem automatically.
    GOTO error
)
IF EXIST "..\..\..\uuid" (
    ECHO Building with uuid
    ECHO #define HAVE_UUID 1>> platform.h
) ELSE (
    ECHO Building without uuid
    ECHO #undef HAVE_UUID>> platform.h
)
IF EXIST "..\..\..\czmq" (
    ECHO Building with czmq
    ECHO #define HAVE_CZMQ 1>> platform.h
) ELSE (
    ECHO Building without czmq
    ECHO zyre cannot build without czmq
    ECHO Please clone https://github.com/zeromq/czmq, and then configure & build
    ECHO TODO: resolve this problem automatically.
    GOTO error
)

:-  Check if we want to build the draft API
IF NOT EXIST "..\..\.git" GOTO no_draft
    ECHO Building with draft API (stable + legacy + draft API)
    ECHO //  Provide draft classes and methods>>platform.h
    ECHO #define ZYRE_BUILD_DRAFT_API 1>>platform.h
    GOTO end_draft
:no_draft
    ECHO Building without draft API (stable + legacy API)
    ECHO #undef ZYRE_BUILD_DRAFT_API 1>>platform.h
:end_draft
ECHO. >> platform.h
ECHO #endif>> platform.h
:error
