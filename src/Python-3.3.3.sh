pushd src >/dev/null

rm -rf Python-3.3.3
tar -xf Python-3.3.3.tar.xz || exit 1
pushd Python-3.3.3 >/dev/null

# Build host components.
AR=ar AS=as CC=gcc CFLAGS= CPP=cpp CPPFLAGS= CXX=g++ CXXFLAGS= LD=ld LDFLAGS= RANLIB=ranlib ./configure || exit 1
AR=ar AS=as CC=gcc CFLAGS= CPP=cpp CPPFLAGS= CXX=g++ CXXFLAGS= LD=ld LDFLAGS= RANLIB=ranlib make python Parser/pgen || exit 1
mv python hostpython || exit 1
mv Parser/pgen Parser/hostpgen || exit 1
make distclean || exit 1

# Apply patches and build slave Python.
cat > config.site <<-SITE
	ac_cv_file__dev_ptmx=no
	ac_cv_file__dev_ptc=no
SITE
patch -p1 < ../Python-3.3.3-cross-compile.patch 

./configure CROSS_COMPILE_TARGET=yes CONFIG_SITE=config.site --prefix="${PREFIX}" --host="${TARGET}" --build="${HOST}" --disable-ipv6 || exit 1
make CROSS_COMPILE_TARGET=yes HOSTPYTHON=./hostpython HOSTPGEN=Parser/hostpgen || exit 1
make CROSS_COMPILE_TARGET=yes HOSTPYTHON=./hostpython HOSTPGEN=Parser/hostpgen install || exit 1

popd >/dev/null
popd >/dev/null