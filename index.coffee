'use strict'

path = require('path')
through = require('through2')
gutil = require('gulp-util')
objectAssign = require('object-assign')
file = require('vinyl-file')
sortKeys = require('sort-keys')

relPath = (base, filePath) ->
  if filePath.indexOf(base) != 0
    return filePath

  newPath = filePath.substr(base.length)
  if newPath[0] == path.sep
    newPath.substr(1)
  else
    newPath

getManifestFile = (opts, cb) ->
  file.read opts.path, opts, (err, manifest) ->
    if err
      if err.code == 'ENOENT'
        cb null, new gutil.File(opts)
      else
        cb(err)
      return
    cb(null, manifest)

railsManifest = (options = {}) ->
  options.path ?= 'manifest.json'
  manifest = {files: {}, assets: {}}
  firstFile = null

  return through.obj((file, enc, cb) ->
    if !file.path || !file.revOrigPath
      cb()
      return

    if options.path == file.revOrigPath
      existingManifest = JSON.parse(file.contents.toString())
      manifest = objectAssign(existingManifest, manifest)
    else
      firstFile = firstFile || file
      originPath = relPath(firstFile.revOrigBase, file.revOrigPath)
      currentPath = relPath(firstFile.base, file.path)
      fileInfo = {}
      fileInfo[currentPath] =
        logical_path: originPath
        mtime: file.stat.mtime
        size: file.contents.length
        digest: file.revHash
      assetInfo = {}
      assetInfo[originPath] = currentPath
      manifest.files = objectAssign(manifest.files, fileInfo)
      manifest.assets = objectAssign(manifest.assets, assetInfo)

    cb()
  , (cb) ->
    # Adapted from gulp-rev
    defaults =
      cwd: firstFile.cwd
      base: firstFile.base
      path: path.join(firstFile.base, options.path)
    opts = objectAssign(defaults, options)
    if Object.keys(manifest).length == 0
      cb()
      return

    getManifestFile opts, (err, manifestFile) =>
      if err
        cb(err)
        return

      if opts.merge && manifestFile?
        oldManifest = {}

        try
          oldManifest = JSON.parse(manifestFile.contents.toString())
        catch err

        manifest.files = objectAssign(oldManifest.files || {}, manifest.files || {})
        manifest.assets = objectAssign(oldManifest.assets || {}, manifest.assets || {})

      manifestFile.contents = new Buffer(JSON.stringify(sortKeys(manifest), null, '  '))
      @push(manifestFile)
      cb()
  )

module.exports = railsManifest
