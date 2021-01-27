// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@TestOn('browser')
import 'package:test/test.dart';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis_auth/src/oauth2_flows/implicit.dart' as impl;
import 'package:googleapis_auth/src/utils.dart' as utils;

import 'utils.dart';

void main() {
  impl.gapiUrl = resource('gapi_auth_hybrid_force.js');

  test('gapi-auth-hybrid-force-test', () async {
    final clientId = auth.ClientId('foo_client', 'foo_secret');
    final scopes = ['scope1', 'scope2'];

    final flow = await auth.createImplicitBrowserFlow(clientId, scopes);
    final result = await flow.runHybridFlow();

    final credentials = result.credentials;

    final date = DateTime.now().toUtc().add(
        const Duration(seconds: 3210 - utils.maxExpectedTimeDiffInSeconds));
    final difference = credentials.accessToken.expiry.difference(date);
    final seconds = difference.inSeconds;

    expect(-3 <= seconds && seconds <= 3, isTrue);
    expect(credentials.accessToken.data, 'foo_token');
    expect(credentials.refreshToken, isNull);
    expect(credentials.scopes, hasLength(2));
    expect(credentials.scopes[0], 'scope1');
    expect(credentials.scopes[1], 'scope2');

    expect(result.authorizationCode, 'mycode');
  });
}