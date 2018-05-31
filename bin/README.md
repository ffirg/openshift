<!--
#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
-->

# OpenWhisk Command Line Interface `wsk`
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0)
[![Build Status](https://travis-ci.org/apache/incubator-openwhisk-cli.svg?branch=master)](https://travis-ci.org/apache/incubator-openwhisk-cli)

# Disclaimer

This project is currently on an experimental stage. We periodically synchronize
the source code and test cases of this repository with the [CLI
folder](https://github.com/apache/incubator-openwhisk/tree/master/tools/cli/go-whisk-cli)
and the [test
folder](https://github.com/apache/incubator-openwhisk/tree/master/tests) in
OpenWhisk. The framework of test cases is under construction for this
repository. Please contribute to the [CLI
folder](https://github.com/apache/incubator-openwhisk/tree/master/tools/cli/go-whisk-cli)
in OpenWhisk for any CLI changes, before we officially announce the separation
of OpenWhisk CLI from OpenWhisk.

The OpenWhisk Command Line Interface (OpenWhisk CLI) is a unified tool that
provides a consistent interface to interact with OpenWhisk services. With this
tool to download and configure, you are able to manage OpenWhisk services from
the command line and automate them through scripts.

# Where to download the binary of OpenWhisk CLI

The OpenWhisk CLI is available on the release page: [click here to
download](https://github.com/apache/incubator-openwhisk-cli/releases). We
currently have binaries available for Linux, Mac OS and Windows under i386 and
amd64 architectures. Linux versions are also available under Linux on Z, Power
and 64-bit ARM architectures. You can download the binary, which fits your
local environment.

# How to build the binary locally

The OpenWhisk CLI is written in the Go language. You have two options to build
the binary locally:

1.  Build using the packaged Gradle scripts (including the 'gogradle' plugin),
now the preferred build method.
2.  Compile in your local Go environment,

## Build the binary with Gradle

**Note:** For those who may have used the Gradle build previously, it has been
re-engineered to no longer required Docker or Go to be pre-installed on your
system.  Using the [gogradle](https://github.com/gogradle/gogradle) plugin,
Gradle now uses a prexisting Go environment to build if it can be located, or
downloads and installs an environment within the build directory.

To build with Gradle, open an terminal, go to the directory of OpenWhisk CLI
home directory, and build the binary via the following command under Linux or
Mac:

```
$ ./gradlew compile -PnativeCompile
```

or run the following command for Windows:

```
$ ./gradlew.bat compile -PnativeCompile
```

After the build, you can find the binary `wsk` or `wsk.exe` in the build folder
under the OpenWhisk CLI home directory. In addition, it is also available under
the folder `build/<os>-<architecture>/`. For example, if your local operating
system is Mac, and the CPU architecture is amd64, the binary can be found at
`build/mac-amd64/wsk` and `build/mac`.

If you would like to build the binaries available for all the operating systems
and architectures, run the following command:

```
$ ./gradlew compile
```

The build script will place the binaries into the folder `build/<os>-<cpu arc>/`
for each operating system and CPU architecture pair. The build supports both
amd64 and 386 for Linux, Mac and Windows operating systems, as well as Power,
64-bit ARM, and S390X architectures for Linux.

A binary compatible with the local architecture will be placed at `build/wsk`
(`build\wsk.exe` on Windows).

To specify a build for specific architectures, you can provide a comma or
space-delimited list of hyphenated os-architecture pairs, like this:

```
$ ./gradlew compile -PbuildPlatforms=linux-amd64,mac-amd64,windows-amd64
```

The build library understands most representations of most Operating Systems.

Tests can be run using the Gradle script as well:

```
$ ./gradlew goTest -PgoTags=unit
$ ./gradlew goTest -PgoTags=native
```

Integration tests are best left to the Travis build as they depend on a fully
functional OpenWhisk environment.

## Compile the binary using your local Go environment

Make sure that you have Go installed [installing
Go](https://golang.org/doc/install), and `$GOPATH` is defined [Go development
environment](https://golang.org/doc/code.html).

Then download the source code of the OpenWhisk CLI and the dependencies by
typing:

```
$ cd $GOPATH
$ go get github.com/apache/incubator-openwhisk-cli
$ cd $GOPATH/src/github.com/apache/incubator-openwhisk-cli
```

The CLI internationalization should be generated dynamically using the
bindata tool:

```
$ go get -u github.com/jteeuwen/go-bindata/...
$ go-bindata -pkg wski18n -o wski18n/i18n_resources.go wski18n/resources
```

Unfortunately, it has become necessary to lock dependencies versions to obtain a
clean build of wsk.  To that end, it's now necessary to populate the `vendors`
folder using the versions selected in the `build.gradle`:

```
$ ./gradlew goVendor
```

Once vendor is populated, it's possible to build the binary:

```
$ go build -o wsk
```

If you would like to build the binary for a specific operating system, you may
add the arguments GOOS and GOARCH into the Go build command. GOOS can
be set to "linux" "darwin" or "windows".

For example, run the following command to build the binary for Linux:

```
$ GOOS=linux GOARCH=amd64 go build -o wsk-$GOOS-$GOARCH
```

If it is executed successfully, you can find your binary `wsk` directly under
OpenWhisk CLI home directory.

# How to use the binary

When you have the binary, you can copy the binary to any folder, and add folder
into the system PATH in order to run the OpenWhisk CLI command. To get the CLI
command help, execute the following command:

```
$ wsk --help
```

To get CLI command debug information, include the -d, or --debug flag when
executing this command.

# Continuous Integration

In order to build OpenWhisk CLI binaries with good quality, OpenWhisk CLI uses
Travis CI as the continuous delivery service for Linux and Mac. OpenWhisk CLI is
a Go project. Currently Travis CI supports the environments of Linux and Mac,
but it is not available for Windows. We will add support of AppVeyor CI in
future to run the test cases and build the binary for Windows.
