{
  lib,
  stdenv,
  kernel,
  clang,
  lld,
}:
stdenv.mkDerivation {
  pname = "cpuid_fault_emulation";
  version = "0.1";
  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies ++ [
    clang
    lld
  ];

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "CC=clang"
    "LLVM=1"
    "KCFLAGS=-Wno-unused-command-line-argument"
    "KAFLAGS=-Wno-unused-command-line-argument"
  ];

  buildPhase = ''
    make \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$PWD \
      CC=clang \
      LLVM=1 \
      KCFLAGS=-Wno-unused-command-line-argument \
      KAFLAGS=-Wno-unused-command-line-argument \
      modules
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
    find . -name '*.ko' -exec cp {} \
      $out/lib/modules/${kernel.modDirVersion}/extra/ \;
  '';

  meta = {
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
  };
}
