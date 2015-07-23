// Generated by CoffeeScript 1.9.3
'use strict';
var file, getManifestFile, gutil, objectAssign, path, railsManifest, relPath, sortKeys, through;

path = require('path');

through = require('through2');

gutil = require('gulp-util');

objectAssign = require('object-assign');

file = require('vinyl-file');

sortKeys = require('sort-keys');

relPath = function(base, filePath) {
  var newPath;
  if (filePath.indexOf(base) !== 0) {
    return filePath;
  }
  newPath = filePath.substr(base.length);
  if (newPath[0] === path.sep) {
    return newPath.substr(1);
  } else {
    return newPath;
  }
};

getManifestFile = function(opts, cb) {
  return file.read(opts.path, opts, function(err, manifest) {
    if (err) {
      if (err.code === 'ENOENT') {
        cb(null, new gutil.File(opts));
      } else {
        cb(err);
      }
      return;
    }
    return cb(null, manifest);
  });
};

railsManifest = function(options) {
  var firstFile, manifest;
  if (options == null) {
    options = {};
  }
  if (options.path == null) {
    options.path = 'manifest.json';
  }
  manifest = {
    files: {},
    assets: {}
  };
  firstFile = null;
  return through.obj(function(file, enc, cb) {
    var assetInfo, currentPath, existingManifest, fileInfo, originPath;
    if (!file.path || !file.revOrigPath) {
      cb();
      return;
    }
    if (options.path === file.revOrigPath) {
      existingManifest = JSON.parse(file.contents.toString());
      manifest = objectAssign(existingManifest, manifest);
    } else {
      firstFile = firstFile || file;
      originPath = relPath(firstFile.revOrigBase, file.revOrigPath);
      currentPath = relPath(firstFile.base, file.path);
      fileInfo = {};
      fileInfo[currentPath] = {
        logical_path: originPath,
        mtime: file.stat.mtime,
        size: file.contents.length,
        digest: file.revHash
      };
      assetInfo = {};
      assetInfo[originPath] = currentPath;
      manifest.files = objectAssign(manifest.files, fileInfo);
      manifest.assets = objectAssign(manifest.assets, assetInfo);
    }
    return cb();
  }, function(cb) {
    var defaults, opts;
    defaults = {
      cwd: firstFile.cwd,
      base: firstFile.base,
      path: path.join(firstFile.base, options.path)
    };
    opts = objectAssign(defaults, options);
    if (Object.keys(manifest).length === 0) {
      cb();
      return;
    }
    return getManifestFile(opts, (function(_this) {
      return function(err, manifestFile) {
        var oldManifest;
        if (err) {
          cb(err);
          return;
        }
        if (opts.merge && (manifestFile != null)) {
          oldManifest = {};
          try {
            oldManifest = JSON.parse(manifestFile.contents.toString());
          } catch (_error) {
            err = _error;
          }
          manifest.files = objectAssign(oldManifest.files || {}, manifest.files || {});
          manifest.assets = objectAssign(oldManifest.assets || {}, manifest.assets || {});
        }
        manifestFile.contents = new Buffer(JSON.stringify(sortKeys(manifest), null, '  '));
        _this.push(manifestFile);
        return cb();
      };
    })(this));
  });
};

module.exports = railsManifest;
