// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:expect/expect.dart';
import 'package:async_helper/async_helper.dart';
import 'compiler_helper.dart';

const String TEST_IF = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is int) {
    param = param + 42;
  }
  return param + 53;
}
""";

const String TEST_IF_ELSE = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is int) {
    param = param + 42;
  } else {
    param = param + 53;
  }
  return param + 53;
}
""";

const String TEST_IF_RETURN = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is int) {
    return param + 42;
  }
  return param + 53;
}
""";

const String TEST_IF_NOT_ELSE = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is !int) {
    param = param + 53;
  } else {
    param = param + 42;
  }
  return param;
}
""";

const String TEST_IF_NOT_RETURN = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is !int) return param + 53;
  return param + 42;
}
""";

const String TEST_IF_NOT_ELSE_RETURN = r"""
test(param) {
  print('Printing this ensures that String+ is in the system.');
  if (param is !int) {
    return param + 53;
  } else {
    param = param + 42;
  }
  return param;
}
""";

Future compileAndTest(String code, {bool useKernel}) {
  return compile(code, entry: 'test', useKernel: useKernel,
      check: (String generated) {
    RegExp validAdd =
        new RegExp("($anyIdentifier \\+ 42)|($anyIdentifier \\+= 42)");
    RegExp invalidAdd = new RegExp("$anyIdentifier \\+ 53");
    Expect.isTrue(validAdd.hasMatch(generated));
    Expect.isFalse(invalidAdd.hasMatch(generated));
  });
}

main() {
  runTests({bool useKernel}) async {
    await compileAndTest(TEST_IF, useKernel: useKernel);
    await compileAndTest(TEST_IF_ELSE, useKernel: useKernel);
    await compileAndTest(TEST_IF_RETURN, useKernel: useKernel);
    await compileAndTest(TEST_IF_NOT_ELSE, useKernel: useKernel);
    await compileAndTest(TEST_IF_NOT_RETURN, useKernel: useKernel);
    await compileAndTest(TEST_IF_NOT_ELSE_RETURN, useKernel: useKernel);
  }

  asyncTest(() async {
    print('--test from ast---------------------------------------------------');
    await runTests(useKernel: false);
    print('--test from kernel------------------------------------------------');
    await runTests(useKernel: true);
  });
}
