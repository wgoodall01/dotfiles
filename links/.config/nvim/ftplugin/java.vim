let b:ale_fixers = {'java': ['clang-format']}
let b:ale_linters = {'java': ['javac']}

let g:ale_java_javac_classpath = '/home/wgoodall01/Android/Sdk/platforms/android-30/android.jar'

let g:ale_java_javac_sourcepath = [
			\ 'src/src/com/mesmerhq/sidecar',
			\ ]
