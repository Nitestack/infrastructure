{
  lib,
  stdenvNoCC,
  fetchurl,
  glibc,
  bash,
}:
let
  version = "1.3.3";
in
stdenvNoCC.mkDerivation {
  pname = "twg";
  inherit version;

  src = fetchurl {
    url = "https://teamwork-graph.atlassian.com/cli/twg-linux-x64-v${version}";
    hash = "sha256-8rJ9414rcMpTPcVEttQd8wE3Q9fkodzxE0mFKPmjhAE=";
  };

  dontUnpack = true;
  # Preserve the Bun single-file executable; ELF fixups corrupt its payload.
  dontFixup = true;
  doInstallCheck = true;

  installPhase = ''
    install -Dm755 "$src" "$out/libexec/twg"
    install -d "$out/bin"
    cat > "$out/bin/twg" <<EOF
    #!${bash}/bin/bash
    exec ${glibc}/lib64/ld-linux-x86-64.so.2 \
      --library-path ${glibc}/lib \
      "$out/libexec/twg" "\$@"
    EOF
    chmod 0755 "$out/bin/twg"
  '';

  installCheckPhase = ''
    output="$("$out/bin/twg" --help 2>&1)"
    if [[ "$output" == *"Bun is a fast JavaScript runtime"* || "$output" != *"Usage: twg"* ]]; then
      echo "TWG launcher did not return TWG CLI help" >&2
      printf '%s\n' "$output" >&2
      exit 1
    fi
  '';

  meta = {
    description = "Atlassian Teamwork Graph CLI";
    homepage = "https://developer.atlassian.com/cloud/twg-cli/";
    license = lib.licenses.asl20;
    mainProgram = "twg";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
