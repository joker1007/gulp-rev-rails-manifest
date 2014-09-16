# [gulp](https://github.com/wearefractal/gulp)-rev-rails-manifest

Write [gulp-rev](https://github.com/sindresorhus/gulp-rev "sindresorhus/gulp-rev") manifest.json that is Rails assets helper compatible

## Install

```bash
$ npm install --save-dev gulp-rev-rails-manifest
```

## Usage

```js
var gulp = require('gulp');
var rev = require('gulp-rev');
var manifest = require('gulp-rev-rails-manifest');

gulp.task('default', function () {
    return gulp.src(['assets/css/*.css', 'assets/js/*.js'], {base: 'assets'})
        .pipe(rev())
        .pipe(gulp.dest('build/assets'))  // write rev'd assets to build dir
        .pipe(manifest())
        .pipe(gulp.dest('build/assets')); // write manifest to build dir
});
```
