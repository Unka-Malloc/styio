import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vityo_app/src/view_ide/toolchain/styio_toolchain_discovery.dart';
import 'package:vityo_app/src/view_ide/toolchain/toolchain_catalog.dart';

void main() {
  test(
    'discovers all-in-one Styio compiler before platform fallback',
    () async {
      final root = await Directory.systemTemp.createTemp('vityo-all-in-one-');
      addTearDown(() async {
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      });

      await File(
        '${root.path}${Platform.pathSeparator}styio'
        '${Platform.pathSeparator}CMakeLists.txt',
      ).create(recursive: true);
      await File(
        '${root.path}${Platform.pathSeparator}vityo'
        '${Platform.pathSeparator}frontend'
        '${Platform.pathSeparator}vityo_app'
        '${Platform.pathSeparator}pubspec.yaml',
      ).create(recursive: true);

      final executableName = Platform.isWindows ? 'styio.exe' : 'styio';
      final executable = File(
        '${root.path}${Platform.pathSeparator}build'
        '${Platform.pathSeparator}default'
        '${Platform.pathSeparator}bin'
        '${Platform.pathSeparator}$executableName',
      );
      await executable.create(recursive: true);

      final catalog = await createPlatformStyioLanguageToolchainCatalog(
        environment: <String, String>{'VITYO_STYIO_ALL_IN_ONE_ROOT': root.path},
      );
      final descriptor = catalog.active(ToolchainKind.languageService);

      expect(descriptor, isNotNull);
      expect(descriptor!.id, 'all-in-one-styio-language-service');
      expect(descriptor.executablePath, executable.path);
      expect(descriptor.metadata['source'], 'all-in-one');
      expect(descriptor.metadata['allInOneRoot'], root.path);
      expect(descriptor.metadata['syntaxContract'], 'syntax-check');
    },
  );
}
