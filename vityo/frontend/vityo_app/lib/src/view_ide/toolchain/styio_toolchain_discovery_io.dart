import 'dart:io' as io;

import '../environment/environment.dart';
import 'toolchain_catalog.dart';

const List<String> _defaultStyioExecutableCandidates = <String>[
  '/usr/local/bin/styio',
  '/usr/bin/styio',
  '/opt/homebrew/bin/styio',
  '/home/linuxbrew/.linuxbrew/bin/styio',
];

class _StyioExecutableDiscovery {
  const _StyioExecutableDiscovery({
    required this.executablePath,
    required this.source,
    this.allInOneRoot,
  });

  final String executablePath;
  final String source;
  final String? allInOneRoot;
}

Future<ToolchainCatalog> createPlatformStyioLanguageToolchainCatalog({
  PlatformManagerBundle? platformManagers,
  Map<String, String>? environment,
  Iterable<String> candidatePaths = _defaultStyioExecutableCandidates,
}) async {
  final catalog = ToolchainCatalog();
  final discovery = platformManagers == null
      ? _discoverLocalStyioExecutable(
          environment: environment ?? io.Platform.environment,
          candidatePaths: candidatePaths,
        )
      : await _discoverManagedStyioExecutable(
          platformManagers,
          environment: environment ?? const <String, String>{},
          candidatePaths: candidatePaths,
        );
  if (discovery == null) {
    return catalog;
  }

  catalog.register(
    ToolchainDescriptor(
      id: discovery.source == 'all-in-one'
          ? 'all-in-one-styio-language-service'
          : 'local-styio-language-service',
      kind: ToolchainKind.languageService,
      displayName: discovery.source == 'all-in-one'
          ? 'All-in-one Styio Language Service'
          : 'Local Styio Language Service',
      executablePath: discovery.executablePath,
      metadata: <String, Object?>{
        'source': discovery.source,
        'contract': 'styio-cli-jsonl-v1',
        'syntaxContract': 'syntax-check',
        if (discovery.allInOneRoot != null)
          'allInOneRoot': discovery.allInOneRoot,
      },
    ),
    activate: true,
  );
  return catalog;
}

_StyioExecutableDiscovery? _discoverLocalStyioExecutable({
  required Map<String, String> environment,
  required Iterable<String> candidatePaths,
}) {
  final isWindows = io.Platform.isWindows;
  final override = environment['VITYO_STYIO_BIN'];
  for (final candidate in _styioExecutableCandidates(override, isWindows)) {
    if (_isExecutableFile(candidate)) {
      return _StyioExecutableDiscovery(
        executablePath: candidate,
        source: 'environment',
      );
    }
  }

  final allInOneRoot =
      environment['VITYO_STYIO_ALL_IN_ONE_ROOT'] ??
      environment['STYIO_ALL_IN_ONE_ROOT'] ??
      _discoverAllInOneRoot(io.Directory.current);
  if (allInOneRoot != null) {
    for (final candidate in _allInOneStyioCandidates(allInOneRoot)) {
      for (final executable in _styioExecutableCandidates(
        candidate,
        isWindows,
      )) {
        if (_isExecutableFile(executable)) {
          return _StyioExecutableDiscovery(
            executablePath: executable,
            source: 'all-in-one',
            allInOneRoot: allInOneRoot,
          );
        }
      }
    }
  }

  for (final candidate in candidatePaths) {
    for (final executable in _styioExecutableCandidates(candidate, isWindows)) {
      if (_isExecutableFile(executable)) {
        return _StyioExecutableDiscovery(
          executablePath: executable,
          source: 'platform-discovery',
        );
      }
    }
  }

  try {
    final lookupExecutable = isWindows ? 'where.exe' : 'which';
    final result = io.Process.runSync(lookupExecutable, const <String>[
      'styio',
    ]);
    if (result.exitCode == 0) {
      for (final line in result.stdout.toString().split(RegExp(r'\r?\n'))) {
        final path = line.trim();
        if (_isExecutableFile(path)) {
          return _StyioExecutableDiscovery(
            executablePath: path,
            source: 'path-lookup',
          );
        }
      }
    }
  } on Object {
    return null;
  }

  return null;
}

Future<_StyioExecutableDiscovery?> _discoverManagedStyioExecutable(
  PlatformManagerBundle platformManagers, {
  required Map<String, String> environment,
  required Iterable<String> candidatePaths,
}) async {
  final isWindows =
      platformManagers.context.fileSystem.operatingSystem.toLowerCase() ==
      'windows';
  final override = environment['VITYO_STYIO_BIN'];
  for (final candidate in _styioExecutableCandidates(override, isWindows)) {
    if (await _isExecutablePath(platformManagers, candidate)) {
      return _StyioExecutableDiscovery(
        executablePath: candidate,
        source: 'environment',
      );
    }
  }

  for (final candidate in candidatePaths) {
    for (final executable in _styioExecutableCandidates(candidate, isWindows)) {
      if (await _isExecutablePath(platformManagers, executable)) {
        return _StyioExecutableDiscovery(
          executablePath: executable,
          source: 'platform-discovery',
        );
      }
    }
  }

  final lookupExecutable = isWindows ? 'where.exe' : 'which';
  final lookup = await platformManagers.process.run(
    ProcessCommandRequest(
      executablePath: lookupExecutable,
      arguments: const <String>['styio'],
      environment: environment,
    ),
  );
  if (!lookup.succeeded) {
    return null;
  }
  for (final line in lookup.stdout.split(RegExp(r'\r?\n'))) {
    final path = line.trim();
    if (await _isExecutablePath(platformManagers, path)) {
      return _StyioExecutableDiscovery(
        executablePath: path,
        source: 'path-lookup',
      );
    }
  }
  return null;
}

String? _discoverAllInOneRoot(io.Directory start) {
  var cursor = start.absolute;
  while (true) {
    if (_looksLikeAllInOneRoot(cursor)) {
      return cursor.path;
    }
    final parent = cursor.parent;
    if (parent.path == cursor.path) {
      return null;
    }
    cursor = parent;
  }
}

bool _looksLikeAllInOneRoot(io.Directory directory) {
  return io.File(
        _join(directory.path, <String>['styio', 'CMakeLists.txt']),
      ).existsSync() &&
      io.File(
        _join(directory.path, <String>[
          'vityo',
          'frontend',
          'vityo_app',
          'pubspec.yaml',
        ]),
      ).existsSync();
}

Iterable<String> _allInOneStyioCandidates(String root) sync* {
  for (final relativePath in const <List<String>>[
    <String>['build', 'default', 'bin', 'styio'],
    <String>['build', 'ci', 'bin', 'styio'],
    <String>['build', 'debug', 'bin', 'styio'],
    <String>['build', 'release', 'bin', 'styio'],
    <String>['build', 'bin', 'styio'],
    <String>['styio', 'build', 'default', 'bin', 'styio'],
    <String>['styio', 'build', 'bin', 'styio'],
  ]) {
    yield _join(root, relativePath);
  }
}

String _join(String root, List<String> segments) {
  var current = root;
  final separator = io.Platform.pathSeparator;
  for (final segment in segments) {
    if (current.endsWith(separator)) {
      current = '$current$segment';
    } else {
      current = '$current$separator$segment';
    }
  }
  return current;
}

Iterable<String> _styioExecutableCandidates(
  String? path,
  bool isWindows,
) sync* {
  if (path == null || path.isEmpty) {
    return;
  }
  if (isWindows && !_hasWindowsExecutableExtension(path)) {
    yield '$path.exe';
    yield '$path.cmd';
    yield '$path.bat';
  }
  yield path;
}

bool _hasWindowsExecutableExtension(String path) {
  return RegExp(r'\.(bat|cmd|com|exe)$', caseSensitive: false).hasMatch(path);
}

Future<bool> _isExecutablePath(
  PlatformManagerBundle platformManagers,
  String? path,
) async {
  if (path == null || path.isEmpty) {
    return false;
  }
  if (!await platformManagers.fileSystem.exists(path)) {
    return false;
  }
  return platformManagers.fileSystem.isExecutable(path);
}

bool _isExecutableFile(String? path) {
  if (path == null || path.isEmpty) {
    return false;
  }
  final stat = io.FileStat.statSync(path);
  if (stat.type != io.FileSystemEntityType.file) {
    return false;
  }
  return true;
}
