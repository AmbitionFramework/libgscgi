project ('gscgi', ['vala', 'c'], version: '1.0')

version_split = meson.project_version().split('.')
api_version = '.'.join([version_split[0], version_split[1]])
library_name = meson.project_name() + '-' + api_version
full_library_name = 'lib' + library_name

deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
]

lib_sources = files([
	'Request.vala',
	'Server.vala',
])

lib = shared_library(
  library_name,
  vala_header: full_library_name + '.h',
  vala_vapi: full_library_name + '.vapi',
  sources: lib_sources,
  dependencies: deps,
  install: true,
  install_dir: [true, true, true]
)

pc = import('pkgconfig').generate(
  libraries: lib,
  version: meson.project_version(),
  name: full_library_name,
  filebase: full_library_name,
  description: 'Glib scgi implementation'
)

install_data(
    meson.current_source_dir() + '/' + full_library_name + '.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

