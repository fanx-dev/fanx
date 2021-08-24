fanb pod.props
#fant compilerx

fan build::Jar compilerx compilerx::IncCompiler.main

mkdir -p ../../../fanIDE/module/release/modules/ext/
cp ./compilerx.jar ../../../fanIDE/module/release/modules/ext/
