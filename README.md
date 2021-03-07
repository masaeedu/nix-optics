# Overview

Using profunctor optics to focus modifications in Nix.

# Motivation

Using nixpkgs often involves overriding deeply nested derivations. This often looks something like the following:

```nix
let

myoverlay = self: super:
  {
    foo = super.foo // {
      bar = super.foo.bar // {
        baz = super.foo.bar.baz.overrideAttrs
          { /* ... */ };
      };
    };
  };
  
in
{ /* ... */ }
```

We can avoid this ugly telescoping by writing a function to modify the innermost bit we actually care about, and simply _focusing_ it past all the irrelevant layers of nesting. Profunctor optics are perfectly suited to this purpose.

With an appropriate lens, the code above can be refactored to:

```nix
let

modification = super:
  super.overrideAttrs { /* ... */ };

_foobarbaz = with optics fn; path [ "foo" "bar" "baz" ];

myoverlay = self: _foobarbaz modification;

in
{ /* ... */ }
```

# Example

The `default.nix` file in this repo provides an illustration of the problem and solution. The `ghc'` variable contains an overlay for nixpkgs that modifies a deeply nested part of it. The `ghc` variable contains a lensy refactoring of the same overlay.
