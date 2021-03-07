with (import ./utils.nix);

let
# This thing...
ghc' = self: super:
  {
    haskell = super.haskell // {
      packages = super.haskell.packages // {
        ghc883 = super.haskell.packages.ghc883.override {
          overrides = hself: hsuper:
            { patat = self.haskell.lib.unmarkBroken hsuper.patat;
            };
        };
      };
    };
  };

# Can be written like this...
ghc = self:
  with optics fn;
  path
    ["haskell" "packages" "ghc883"]
    (super: super.override {
      overrides = hself: hsuper:
        { patat = self.haskell.lib.unmarkBroken hsuper.patat;
        };
    });

in (import <nixpkgs> { overlays = [ ghc ]; }).haskell.packages.ghc883.patat
