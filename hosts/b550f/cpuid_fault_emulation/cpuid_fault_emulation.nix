{
  lib,
  stdenv,
  kernel,
}:

stdenv.mkDerivation {
  pname = "cpuid_fault_emulation";
  version = "0.1";

  src = ./.;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildPhase = ''
    make \
      -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$PWD \
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
