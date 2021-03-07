rec {
  category = p:
  with p;
  rec {
    pipe = builtins.foldl' compose id;
  };

  fn =
  rec {
    # :: (->) a a
    id = x: x;

    # :: (->) b c -> (->) a b -> (->) a c
    compose = f: g: x: f (g x);

    # :: (a' -> a) -> (b -> b') -> (->) a b -> (->) a' b'
    dimap = f: g: fn: a': g (fn (f a'));

    # :: (a' -> a) -> (->) a b -> (->) a' b
    lmap = f: dimap f id;

    # :: (b -> b') -> (->) a b -> (->) a b'
    rmap = g: dimap id g;

    # :: (->) a b -> (->) (a /\ x) (b /\ x)
    first = f: { fst, snd }: { fst = f fst; inherit snd; };

    # :: (->) a b -> (->) (x /\ a) (x /\ b)
    second = f: { fst, snd }: { inherit fst; snd = f snd; };

    inherit (category fn) pipe;
  };

  set =
  rec {
    # k -> { [k] = v; ...r } -> v /\ r
    uncons = k: r: { fst = r."${k}"; snd = builtins.removeAttrs r [k]; };

    # k -> v /\ r -> { [k] = v; ...r }
    cons = k: { fst, snd }: snd // { "${k}" = fst; };
  };

  optics = p:
  with p;
  rec {

    # k -> Iso { [k] = a; ...r } { [k] = b; ...r } (a /\ r) (b /\ r)
    unconsed = k: dimap (set.uncons k) (set.cons k);

    # k -> Lens { [k] = a; ...r } { [k] = b; ...r } a b
    key = k: fn.pipe [(unconsed k) first];

    # given a list of keys, produces an optic that focuses on the relevant
    # part of an appropriately keyed nested attrset
    path = keys: fn.pipe (map key keys);

  };
}
