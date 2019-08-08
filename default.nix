with import <nixpkgs> {};

stdenv.mkDerivation {
    name = "typed-struct-cast";

    buildInputs = [
        elixir_1_8
    ];
}
