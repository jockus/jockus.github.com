# => SRC FOLDER
toast 'src'

  # EXCLUDED FOLDERS (optional)
  # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

  # => VENDORS (optional)
  # vendors: ['vendors/three.js' ]
  #          'vendors/stats.min.js',
  #          'vendors/tween.min.js',
  #          'vendors/mousetrap.min.js',
  #          'vendors/Box2dWeb-2.1.a.3.js' ]

  # => OPTIONS (optional, default values listed)
  bare: true
  # packaging: true
  expose: 'window'
  # minify: false

  # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
  httpfolder: 'js'
  release: 'www/js/app.js'
  debug: 'www/js/app-debug.js'
