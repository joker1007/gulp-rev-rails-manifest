'use strict'

assert = require('power-assert')
gulp = require('gulp')
gutil = require('gulp-util')
rev = require('gulp-rev')
manifest = require('./index')

describe 'gulp-rev-rails-manifest', ->
  it 'should write manifest file that is Rails asset helper compatible', (cb) ->
    stream = gulp.src('./fixtures/**/*.js')
      .pipe(rev())
      .pipe(manifest())

    stream.on 'data', (file) ->
      manifestData = JSON.parse(file.contents.toString())
      expected =
        files:
          "sample-af9d57fd.js":
            logical_path: "sample.js"
            mtime: new Date(2014, 8, 17, 3, 7, 16).toJSON()
            size: 21
            digest: "af9d57fd"
        assets:
          "sample.js": "sample-af9d57fd.js"

      assert.deepEqual(manifestData.files["sample-af9d57fd.js"], expected.files["sample-af9d57fd.js"])
      assert.deepEqual(manifestData.assets["sample.js"], expected.assets["sample.js"])
      cb()

  it 'should merge manifest file if manifest file is already created', (cb) ->
    stream = gulp.src('./fixtures/**/*')
      .pipe(rev())
      .pipe(manifest())

    stream.on 'data', (file) ->
      manifestData = JSON.parse(file.contents.toString())
      expected =
        files:
          "sample-12267ffb.css":
            logical_path: "sample.css"
            mtime: new Date(2014, 8, 17, 3, 58, 10).toJSON()
            size: 23
            digest: "12267ffb"
          "sample-af9d57fd.js":
            logical_path: "sample.js"
            mtime: new Date(2014, 8, 17, 3, 7, 16).toJSON()
            size: 21
            digest: "af9d57fd"
        assets:
          "sample.js": "sample-af9d57fd.js"
          "sample.css": "sample-12267ffb.css"

      assert.deepEqual(manifestData.files["sample-12267ffb.css"], expected.files["sample-12267ffb.css"])
      assert.deepEqual(manifestData.files["sample-af9d57fd.js"], expected.files["sample-af9d57fd.js"])
      assert.deepEqual(manifestData.assets["sample.js"], expected.assets["sample.js"])
      assert.deepEqual(manifestData.assets["sample.css"], expected.assets["sample.css"])
      cb()
