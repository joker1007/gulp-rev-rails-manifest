'use strict'

path = require('path')
through = require('through2')
gutil = require('gulp-util')
objectAssign = require('object-assign')

relPath = (base, filePath) ->
  if filePath.indexOf(base) != 0
    return filePath

  newPath = filePath.substr(base.length)
  if newPath[0] == path.sep
    newPath.substr(1)
  else
    newPath

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
    if firstFile
      output = new gutil.File
        cwd: firstFile.cwd
        base: firstFile.base
        path: path.join(firstFile.base, options.path)
        contents: new Buffer(JSON.stringify(manifest, null, '  '))
      @push(output)
    cb()
  )

module.exports = railsManifest
