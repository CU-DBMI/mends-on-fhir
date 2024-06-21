@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%"=="" @echo off
@rem ##########################################################################
@rem
@rem  distribution startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
@rem This is normally unused
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%..

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and DISTRIBUTION_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS=

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo. 1>&2
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH. 1>&2
echo. 1>&2
echo Please set the JAVA_HOME variable in your environment to match the 1>&2
echo location of your Java installation. 1>&2

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo. 1>&2
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME% 1>&2
echo. 1>&2
echo Please set the JAVA_HOME variable in your environment to match the 1>&2
echo location of your Java installation. 1>&2

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\lib\distribution-dev-SNAPSHOT.jar;%APP_HOME%\lib\hdev2-dev-SNAPSHOT.jar;%APP_HOME%\lib\common-dev-SNAPSHOT.jar;%APP_HOME%\lib\runtime-dev-SNAPSHOT.jar;%APP_HOME%\lib\transpiler-dev-SNAPSHOT.jar;%APP_HOME%\lib\proto-dev-SNAPSHOT.jar;%APP_HOME%\lib\protobuf-java-util-3.18.1.jar;%APP_HOME%\lib\grpc-protobuf-1.43.2.jar;%APP_HOME%\lib\grpc-stub-1.43.2.jar;%APP_HOME%\lib\truth-1.1.3.jar;%APP_HOME%\lib\grpc-protobuf-lite-1.43.2.jar;%APP_HOME%\lib\grpc-api-1.43.2.jar;%APP_HOME%\lib\guava-31.0.1-jre.jar;%APP_HOME%\lib\jsr305-3.0.2.jar;%APP_HOME%\lib\gson-2.8.6.jar;%APP_HOME%\lib\commons-cli-1.4.jar;%APP_HOME%\lib\commons-codec-1.13.jar;%APP_HOME%\lib\javax.json-api-1.0.jar;%APP_HOME%\lib\joda-time-2.10.5.jar;%APP_HOME%\lib\proto-google-common-protos-2.0.1.jar;%APP_HOME%\lib\protobuf-java-3.19.2.jar;%APP_HOME%\lib\javax.annotation-api-1.3.2.jar;%APP_HOME%\lib\antlr4-4.7.jar;%APP_HOME%\lib\antlr4-runtime-4.7.jar;%APP_HOME%\lib\google-extensions-0.7.1.jar;%APP_HOME%\lib\failureaccess-1.0.1.jar;%APP_HOME%\lib\listenablefuture-9999.0-empty-to-avoid-conflict-with-guava.jar;%APP_HOME%\lib\checker-qual-3.13.0.jar;%APP_HOME%\lib\error_prone_annotations-2.9.0.jar;%APP_HOME%\lib\j2objc-annotations-1.3.jar;%APP_HOME%\lib\auto-value-annotations-1.8.1.jar;%APP_HOME%\lib\ST4-4.0.8.jar;%APP_HOME%\lib\antlr-runtime-3.5.2.jar;%APP_HOME%\lib\org.abego.treelayout.core-1.0.3.jar;%APP_HOME%\lib\javax.json-1.0.4.jar;%APP_HOME%\lib\icu4j-58.2.jar;%APP_HOME%\lib\junit-4.13.2.jar;%APP_HOME%\lib\asm-9.1.jar;%APP_HOME%\lib\flogger-system-backend-0.7.1.jar;%APP_HOME%\lib\flogger-0.7.1.jar;%APP_HOME%\lib\grpc-context-1.43.2.jar;%APP_HOME%\lib\hamcrest-core-1.3.jar;%APP_HOME%\lib\checker-compat-qual-2.5.3.jar


@rem Execute distribution
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %DISTRIBUTION_OPTS%  -classpath "%CLASSPATH%" com.google.cloud.verticals.foundations.dataharmonization.Main %*

:end
@rem End local scope for the variables with windows NT shell
if %ERRORLEVEL% equ 0 goto mainEnd

:fail
rem Set variable DISTRIBUTION_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
set EXIT_CODE=%ERRORLEVEL%
if %EXIT_CODE% equ 0 set EXIT_CODE=1
if not ""=="%DISTRIBUTION_EXIT_CONSOLE%" exit %EXIT_CODE%
exit /b %EXIT_CODE%

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
