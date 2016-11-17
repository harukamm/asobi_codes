open import Relation.Binary.PropositionalEquality
open ≡-Reasoning
open import Data.Product

-- Basics
--- Categories

module category
    (obC : Set)
    (morC : obC → obC → Set)
    (_∘_ : {A B C : obC} → morC B C → morC A B → morC A C)
    (∘-assoc : {A B C D : obC} →
        {f : morC C D} → {g : morC B C} → {h : morC A B} →
        f ∘ (g ∘ h) ≡ (f ∘ g) ∘ h)
    (id : (A : obC) → morC A A)
    (idL : {A B : obC} → {f : morC A B} → id B ∘ f ≡ f)
    (idR : {A B : obC} → {f : morC A B} → f ∘ id A ≡ f)
  where

dom : {A B : obC} → morC A B → obC
dom {A} _ = A

cod : {A B : obC} → morC A B → obC
cod {B = B} _ = B

record inverse {A B : obC} (f : morC A B) (g : morC B A) : Set where
  field
    invL : g ∘ f ≡ id A
    invR : f ∘ g ≡ id B

inverse-unique : {A B : obC} → {f : morC A B} → {g h : morC B A} →
        inverse f g → inverse f h → g ≡ h
inverse-unique {A} {B} {f} {g} {h} inv-g inv-h = begin
    g
  ≡⟨ sym idR ⟩
    g ∘ id B
  ≡⟨ cong (_∘_ g) (sym (inverse.invR inv-h)) ⟩
    g ∘ (f ∘ h)
  ≡⟨ ∘-assoc ⟩
    (g ∘ f) ∘ h
  ≡⟨ cong (λ x → x ∘ h) (inverse.invL inv-g) ⟩
    id A ∘ h
  ≡⟨ idL ⟩
    h
  ∎

-- 定理 1.4.4 equivalence relation
record _≅_ (A : obC) (B : obC) : Set where
  field
    f : morC A B
    g : morC B A
    proof : inverse f g

record iso {A B : obC} (f : morC A B) : Set where
  field
    g : morC B A        -- g が存在し
    proof : inverse f g -- それは f の inverse である

isof→A≅B : {A B : obC} → {f : morC A B} → iso f → A ≅ B
isof→A≅B {A} {B} {f} iso-f =
  record { f = f
         ; g = iso.g iso-f
         ; proof = iso.proof iso-f
         }
A≅B→isof : {A B : obC} → (p : A ≅ B) → iso (_≅_.f p)
A≅B→isof {A} {B} p =
  record { g = _≅_.g p
         ; proof = _≅_.proof p
         }

-- reflection
iso-refl : {A : obC} → A ≅ A
iso-refl {A} =
  record { g = id A
         ; proof = record { invL = p1
                          ; invR = p1
                          }
         }
    where p1 : id A ∘ id A ≡ id A
          p1 = begin
            id A ∘ id A
           ≡⟨ idL ⟩
            id A
           ∎

-- symmetric
iso-sym : {A B : obC} → A ≅ B → B ≅ A
iso-sym {A} {B} iso-ab =
  record { g = _≅_.f iso-ab
         ; proof = record { invL = f∘g-idB
                          ; invR = g∘f-idA
                          }
         }
    where g = _≅_.g iso-ab
          inv-fg = _≅_.proof iso-ab
          f∘g-idB = inverse.invR inv-fg
          g∘f-idA = inverse.invL inv-fg

-- transitive
iso-trans : {A B C : obC} → A ≅ B → B ≅ C → A ≅ C
iso-trans {A} {B} {C} iso-ab iso-bc = 
  record { f = h ∘ f
         ; g = g ∘ k
         ; proof = record { invL = [g∘k]∘[h∘f]-idA
                          ; invR = [h∘f]∘[g∘k]-idC
                          }
         }
    where f = _≅_.f iso-ab
          g = _≅_.g iso-ab
          h = _≅_.f iso-bc
          k = _≅_.g iso-bc
          pf-iso-ab = _≅_.proof iso-ab
          pf-iso-bc = _≅_.proof iso-bc
          invL-AB = inverse.invL pf-iso-ab
          invR-AB = inverse.invR pf-iso-ab
          invL-BC = inverse.invL pf-iso-bc
          invR-BC = inverse.invR pf-iso-bc
          [h∘f]∘[g∘k]-idC : (h ∘ f) ∘ (g ∘ k) ≡ id C
          [h∘f]∘[g∘k]-idC = begin
              (h ∘ f) ∘ (g ∘ k)
            ≡⟨ ∘-assoc ⟩
              ((h ∘ f) ∘ g) ∘ k
            ≡⟨ cong (λ x → x ∘ k) (sym ∘-assoc) ⟩
              (h ∘ (f ∘ g)) ∘ k
            ≡⟨ cong (λ x → (h ∘ x) ∘ k) invR-AB ⟩
              (h ∘ id B) ∘ k
            ≡⟨ cong (λ x → x ∘ k) idR ⟩
              h ∘ k
            ≡⟨ invR-BC ⟩
              id C
            ∎
          [g∘k]∘[h∘f]-idA : (g ∘ k) ∘ (h ∘ f) ≡ id A
          [g∘k]∘[h∘f]-idA = begin
              (g ∘ k) ∘ (h ∘ f)
            ≡⟨ ∘-assoc ⟩
              ((g ∘ k) ∘ h) ∘ f
            ≡⟨ cong (λ x → x ∘ f) (sym ∘-assoc) ⟩
              (g ∘ (k ∘ h)) ∘ f
            ≡⟨ cong (λ x → (g ∘ x) ∘ f) invL-BC ⟩
              (g ∘ id B) ∘ f
            ≡⟨ cong (λ x → x ∘ f) idR ⟩
              g ∘ f
            ≡⟨ invL-AB ⟩
              id A
            ∎

-- 問題 1.4.5
inverse-left-right : {A B : obC} → {f : morC A B} → {g h : morC B A} → h ∘ f ≡ id A → f ∘ g ≡ id B → g ≡ h
inverse-left-right {A} {B} {f} {g} {h} inv-l inv-r = begin
    g
  ≡⟨ sym idL ⟩
    id A ∘ g
  ≡⟨ cong (λ x → x ∘ g) (sym inv-l) ⟩
    (h ∘ f) ∘ g
  ≡⟨ sym ∘-assoc ⟩
    h ∘ (f ∘ g)
  ≡⟨ cong (_∘_ h) inv-r ⟩
    h ∘ id B
  ≡⟨ idR ⟩
    h
  ∎

--- Monics and Epics

monic : {A B : obC} → (f : morC A B) → Set
monic {A} {B} f = {T : obC} → {g h : morC T A} → f ∘ g ≡ f ∘ h → g ≡ h

monic-composite : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        monic f → monic g → monic (g ∘ f)
monic-composite {f = f} {g = g} monic-f monic-g =
  λ {T} {g′} {h′} eq →
    let eq′ : g ∘ (f ∘ g′) ≡ g ∘ (f ∘ h′)
        eq′ = begin
            g ∘ (f ∘ g′)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ g′
          ≡⟨ eq ⟩
            (g ∘ f) ∘ h′
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ h′)
          ∎ in
    monic-f (monic-g eq′)

composite-monic : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        monic (g ∘ f) → monic f
composite-monic {f = f} {g = g} monic-g∘f =
  λ {T} {g′} {h′} eq →
    let eq′ : (g ∘ f) ∘ g′ ≡ (g ∘ f) ∘ h′
        eq′ = begin
            (g ∘ f) ∘ g′
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ g′)
          ≡⟨ cong (λ x → g ∘ x) eq ⟩
            g ∘ (f ∘ h′)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ h′
          ∎ in
    monic-g∘f eq′

epic : {A B : obC} → (f : morC A B) → Set
epic {A} {B} f = {T : obC} → {g h : morC B T} → g ∘ f ≡ h ∘ f → g ≡ h

epic-composite : {A B C : obC} → {f : morC A B} → {g : morC B C} →
        epic f → epic g → epic (g ∘ f)
epic-composite {f = f} {g = g} epic-f epic-g =
  λ {T} {g′} {h′} eq →
    let eq′ : (g′ ∘ g) ∘ f ≡ (h′ ∘ g) ∘ f
        eq′ = begin
            (g′ ∘ g) ∘ f
          ≡⟨ sym ∘-assoc ⟩
            g′ ∘ (g ∘ f)
          ≡⟨ eq ⟩
            h′ ∘ (g ∘ f)
          ≡⟨ ∘-assoc ⟩
            (h′ ∘ g) ∘ f
          ∎ in
    (epic-g (epic-f eq′))

record split-epic {A B : obC} (f : morC A B) : Set where
  field
    g : morC B A
    invR : f ∘ g ≡ id B

-- theorem 1.5.7
split-epic→epic : {A B : obC} → {f : morC A B} → split-epic f → epic f
split-epic→epic {B = B} {f = f} split-epic-f =
  λ {T} {g′} {h′} eq → begin
    g′
  ≡⟨ sym idR ⟩
    g′ ∘ id B
  ≡⟨ cong (λ x → g′ ∘ x) (sym invR) ⟩
    g′ ∘ (f ∘ g)
  ≡⟨ ∘-assoc ⟩
    (g′ ∘ f) ∘ g
  ≡⟨ cong (λ x → x ∘ g) eq ⟩
    (h′ ∘ f) ∘ g
  ≡⟨ sym ∘-assoc ⟩
    h′ ∘ (f ∘ g)
  ≡⟨ cong (λ x → h′ ∘ x) invR ⟩
    h′ ∘ id B
  ≡⟨ idR ⟩
    h′
  ∎
  where g = split-epic.g split-epic-f
        invR = split-epic.invR split-epic-f

-- theorem 1.5.8
monic-and-split-epic→iso : {A B : obC} → {f : morC A B} → monic f → split-epic f → iso f
monic-and-split-epic→iso {A} {B} {f} monic-f split-epic-f =
  record { g = g
         ; proof = record { invL = monic-f eq
                          ; invR = invR
                          }
         }
    where g = split-epic.g split-epic-f
          invR = split-epic.invR split-epic-f
          eq : f ∘ (g ∘ f) ≡ f ∘ id A
          eq = begin
             f ∘ (g ∘ f)
            ≡⟨ ∘-assoc ⟩
             (f ∘ g) ∘ f
            ≡⟨ cong (λ x → x ∘ f) invR ⟩
             id B ∘ f
            ≡⟨ idL ⟩
             f
            ≡⟨ sym idR ⟩
             f ∘ id A
            ∎

iso→monic : {A B : obC} → {f : morC A B} → iso f → monic f
iso→monic {A} {B} {f} iso-f {T} {h} {k} eq = eq′
  where g = iso.g iso-f
        invL : g ∘ f ≡ id A
        invL = inverse.invL (iso.proof iso-f)
        invR : f ∘ g ≡ id B
        invR = inverse.invR (iso.proof iso-f)
        eq′ : h ≡ k
        eq′ = begin
            h
          ≡⟨ sym idL ⟩
            id A ∘ h
          ≡⟨ cong (λ x → x ∘ h) (sym invL) ⟩
            (g ∘ f) ∘ h
          ≡⟨ sym ∘-assoc ⟩
            g ∘ (f ∘ h)
          ≡⟨ cong (_∘_ g) eq ⟩
            g ∘ (f ∘ k)
          ≡⟨ ∘-assoc ⟩
            (g ∘ f) ∘ k
          ≡⟨ cong (λ x → x ∘ k) invL ⟩
            id A ∘ k
          ≡⟨ idL ⟩
            k
          ∎

iso→split-epic : {A B : obC} → {f : morC A B} → iso f → split-epic f
iso→split-epic {A} {B} {f} iso-f = record { g = g ; invR = invR }
  where g = iso.g iso-f
        invR : f ∘ g ≡ id B
        invR = inverse.invR (iso.proof iso-f)

iso→monic-and-split-epic : {A B : obC} → {f : morC A B} → iso f → monic f × split-epic f
iso→monic-and-split-epic {A} {B} {f} iso-f = monic-f , split-epic-f
  where monic-f : monic f
        monic-f = iso→monic iso-f
        split-epic-f : split-epic f
        split-epic-f =
          record { g = iso.g iso-f
                 ; invR = inverse.invR (iso.proof iso-f)
                 }

≡-trans : ∀{l}{A : Set l} -> {x y z : A} -> x ≡ y -> y ≡ z -> x ≡ z
≡-trans {_}{_} {x} {y} {z} x≡y y≡z = begin
          x
        ≡⟨ x≡y ⟩
          y
        ≡⟨ y≡z ⟩
          z
        ∎

-- Limits and Their Duals
--- Terminal and Initial Objects
-- B へのmorCはひとつだけである。
record morC-unique_to_ (A B : obC) : Set where
  field
    m : morC A B
    unique : (m′ : morC A B) → m′ ≡ m

-- P を満たすものが unique に存在する
record exist-unique-P {A : Set} (P : A → Set) : Set where
  field
    ! : A
    proof : P !
    unique : (o : A) → P o → ! ≡ o

record terminal (one : obC) : Set where
  field
    proof : {A : obC} → morC-unique A to one

record initial (⊘ : obC) : Set where
  field
    proof : {A : obC} → morC-unique ⊘ to A

record zero (z : obC) : Set where
  field
    t : terminal z
    i : initial z

-- Theorem 2.1.2
terminal-iso : {one one′ : obC} → terminal one → terminal one′ → one ≅ one′
terminal-iso {one} {one′} t t′ =
  record { f = !1′
         ; g = !1
         ; proof = record { invR = ≡-trans (!1′∘!1≡1′→1′) (sym id1′≡1′→1′)
                          ; invL = ≡-trans (!1∘!1′≡1→1) (sym id1≡1̄→1)
                          }
         }
    where 1′→1-unique : morC-unique one′ to one
          1′→1-unique = terminal.proof t {one′}
          1→1′-unique : morC-unique one to one′
          1→1′-unique = terminal.proof t′ {one}
          !1 : morC one′ one            -- a unique morC one′ to one
          !1 = morC-unique_to_.m 1′→1-unique
          !1′ : morC one one′           -- a unique morC one to one′
          !1′ = morC-unique_to_.m 1→1′-unique
          1→1-unique : morC-unique one to one
          1→1-unique = terminal.proof t {one}
          1′→1′-unique : morC-unique one′ to one′
          1′→1′-unique = terminal.proof t′ {one′}
          1→1 : morC one one            -- a unique morC one to one
          1→1 = morC-unique_to_.m (1→1-unique)
          id1≡1̄→1 : id one ≡ 1→1
          id1≡1̄→1 = morC-unique_to_.unique (1→1-unique) (id one)
          !1∘!1′≡1→1 : !1 ∘ !1′ ≡ 1→1
          !1∘!1′≡1→1 = morC-unique_to_.unique (1→1-unique) (!1 ∘ !1′)
          1′→1′ : morC one′ one′        -- a unique morC one′ to one′
          1′→1′ = morC-unique_to_.m (1′→1′-unique)
          id1′≡1′→1′ : id one′ ≡ 1′→1′
          id1′≡1′→1′ = morC-unique_to_.unique (1′→1′-unique) (id one′)
          !1′∘!1≡1′→1′ : !1′ ∘ !1 ≡ 1′→1′
          !1′∘!1≡1′→1′ = morC-unique_to_.unique (1′→1′-unique) (!1′ ∘ !1)

unique→id : {A B : obC} → {f : morC A B} → {g : morC B A} →
            morC-unique A to A → g ∘ f ≡ id A
unique→id {A} {B} {f} {g} uni-A→A = ≡-trans g∘f≡A→A (sym idA≡A→A)
    where A→A : morC A A
          A→A = morC-unique_to_.m uni-A→A
          idA≡A→A : id A ≡ A→A
          idA≡A→A = morC-unique_to_.unique uni-A→A (id A)
          g∘f≡A→A : g ∘ f ≡ A→A
          g∘f≡A→A = morC-unique_to_.unique uni-A→A (g ∘ f)

-- Theorem 2.1.5
initial-iso : {⊘ ⊘′ : obC} → initial ⊘ → initial ⊘′ → ⊘ ≅ ⊘′
initial-iso {⊘} {⊘′} i i′ =
  record { f = !⊘′
         ; g = !⊘
         ; proof = record { invR = !⊘′∘!⊘≡id⊘′
                          ; invL = !⊘∘!⊘′≡id⊘
                          }
         }
    where ⊘→⊘′-unique : morC-unique ⊘ to ⊘′
          ⊘→⊘′-unique = initial.proof i {⊘′}
          !⊘′ : morC ⊘ ⊘′
          !⊘′ = morC-unique_to_.m (⊘→⊘′-unique)
          ⊘′→⊘-unique : morC-unique ⊘′ to ⊘
          ⊘′→⊘-unique = initial.proof i′ {⊘}
          !⊘ : morC ⊘′ ⊘
          !⊘ = morC-unique_to_.m (⊘′→⊘-unique)
          ⊘→⊘-unique : morC-unique ⊘ to ⊘
          ⊘→⊘-unique = initial.proof i {⊘}
          !⊘∘!⊘′≡id⊘ : !⊘ ∘ !⊘′ ≡ id ⊘
          !⊘∘!⊘′≡id⊘ = unique→id {⊘} {⊘′} { !⊘′} { !⊘} ⊘→⊘-unique
          ⊘′→⊘′-unique : morC-unique ⊘′ to ⊘′
          ⊘′→⊘′-unique = initial.proof i′ {⊘′}
          !⊘′∘!⊘≡id⊘′ : !⊘′ ∘ !⊘ ≡ id ⊘′
          !⊘′∘!⊘≡id⊘′ = unique→id {⊘′} {⊘} { !⊘} { !⊘′} ⊘′→⊘′-unique

-- Theorem 2.1.6
split-epic-A→⊘ : {A ⊘ : obC} → initial ⊘ → {f : morC A ⊘} → split-epic f
split-epic-A→⊘ {A} {⊘} ini⊘ {f} =
  record { g = !A
         ; invR = ≡-trans f∘!A≡!⊘ (sym id⊘≡!⊘)
         }
    where ⊘→A-unique : morC-unique ⊘ to A
          ⊘→A-unique = initial.proof ini⊘ {A}
          !A : morC ⊘ A
          !A = morC-unique_to_.m (⊘→A-unique)
          ⊘→⊘-unique : morC-unique ⊘ to ⊘
          ⊘→⊘-unique = initial.proof ini⊘ {⊘}
          !⊘ : morC ⊘ ⊘
          !⊘ = morC-unique_to_.m (⊘→⊘-unique)
          id⊘≡!⊘ : id ⊘ ≡ !⊘
          id⊘≡!⊘ = morC-unique_to_.unique (⊘→⊘-unique) (id ⊘)
          f∘!A≡!⊘ : f ∘ !A ≡ !⊘
          f∘!A≡!⊘ = morC-unique_to_.unique (⊘→⊘-unique) (f ∘ !A)

-- exercise 2.1.7
1→B-monic : {one B : obC} → terminal one → {k : morC one B} → monic k
1→B-monic {one} {B} t {k} {T} {g} {h} eq = begin
          g
         ≡⟨ g≡m ⟩
          m
         ≡⟨ sym h≡m ⟩
          h
         ∎
  where pf : morC-unique T to one
        pf = terminal.proof t {T}
        m = morC-unique_to_.m pf
        g≡m = morC-unique_to_.unique pf g
        h≡m = morC-unique_to_.unique pf h
        
-- exercise 2.1.8
{-compo-unique : {A B C : obC} → morC-unique A to B → morC-unique B to C →
               (h : morC A C) → (h′ : morC A C) → h ≡ h′
compo-unique {A}{B}{C} A→B-unique B→C-unique h h′ = {!!}
  where A→B : morC A B
        A→B = morC-unique_to_.m A→B-unique
        B→C : morC B C
        B→C = morC-unique_to_.m B→C-unique
        B→C∘A→B : morC A C
        B→C∘A→B = B→C ∘ A→B-}
{-
ter-ini-zero : {⊘ one : obC} → initial ⊘ → terminal one → morC one ⊘ → zero ⊘ × zero one
ter-ini-zero {⊘} {one} ini⊘ ter1 1→⊘ = zero⊘ , zero1
  where p1 : morC-unique ⊘ to one
        p1 = terminal.proof ter1 {⊘}
        p2 : morC-unique ⊘ to one
        p2 = initial.proof ini⊘ {one}
        ⊘→1 : morC ⊘ one
        ⊘→1 = morC-unique_to_.m p1
        ⊘→A-unique-m : {A : obC} → morC ⊘ A
        ⊘→A-unique-m {A} = morC-unique_to_.m (initial.proof ini⊘ {A})
        A→1-unique-m : {A : obC} → morC A one
        A→1-unique-m {A} = morC-unique_to_.m (terminal.proof ter1 {A})
        ini1 : initial one -- morC-unique one to A
        ini1 = record { proof = λ {A} → 
                         record { m = ⊘→A-unique-m ∘ 1→⊘
                                ; unique = λ m′ → {!!}
                                }
                }
        ter⊘ : terminal ⊘
        ter⊘ = record { proof = λ {A} → 
                         record { m = 1→⊘ ∘ A→1-unique-m
                                ; unique = λ m′ → {!!}
                                }
                }
        zero⊘ : zero ⊘
        zero⊘ = record { t = ter⊘
                       ; i = ini⊘
                       }
        zero1 : zero one
        zero1 = record { t = ter1
                       ; i = ini1
                       }
-}

record _X_ (A B : obC) : Set where
  field
    obj : obC
    π₁ : morC obj A
    π₂ : morC obj B
    proof : {C : obC} → {f : morC C A} → {g : morC C B} →
            Σ[ C→AxB-unique ∈ morC-unique C to obj ]
            π₁ ∘ (morC-unique_to_.m C→AxB-unique) ≡ f × π₂ ∘ (morC-unique_to_.m C→AxB-unique) ≡ g

bproduct-unique-refl : {A B : obC} → (AxB : A X B) → morC-unique (_X_.obj AxB) to (_X_.obj AxB)
bproduct-unique-refl {A}{B} AxB = proj₁ (_X_.proof AxB {_} {π₁} {π₂})
  where π₁ = _X_.π₁ AxB
        π₂ = _X_.π₂ AxB

-- Theorem 2.2.2
{- For any objects A and B, a binary product of A and B is unique up to isomorphism if it exists. -}
AxB-unique : {A : obC} → {B : obC} → (AXB : A X B) → (AXB′ : A X B) → _X_.obj AXB ≅ _X_.obj AXB′
AxB-unique {A} {B} AXB AXB′ =
  record { f = f
         ; g = g
         ; proof = record { invR = f∘g≡idP′
                          ; invL = g∘f≡idP
                          }
         }
  where P : obC
        P = _X_.obj AXB
        P′ : obC
        P′ = _X_.obj AXB′
        π₁p : morC P A
        π₁p = _X_.π₁ AXB
        π₂p : morC P B
        π₂p = _X_.π₂ AXB
        π₁p′ : morC P′ A
        π₁p′ = _X_.π₁ AXB′
        π₂p′ : morC P′ B
        π₂p′ = _X_.π₂ AXB′
        P→P′-unique : morC-unique P to P′
        P→P′-unique = proj₁ (_X_.proof AXB′ {P} {π₁p} {π₂p})
        f : morC P P′
        f = morC-unique_to_.m P→P′-unique
        P′→P-unique : morC-unique P′ to P
        P′→P-unique = proj₁ (_X_.proof AXB {P′} {π₁p′} {π₂p′})
        g : morC P′ P
        g = morC-unique_to_.m P′→P-unique
        P→P-unique : morC-unique P to P
        P→P-unique = bproduct-unique-refl AXB
        P′→P′-unique : morC-unique P′ to P′
        P′→P′-unique = bproduct-unique-refl AXB′
        g∘f≡idP : g ∘ f ≡ id P
        g∘f≡idP = unique→id {P} {P′} {f} {g} P→P-unique
        f∘g≡idP′ : f ∘ g ≡ id P′
        f∘g≡idP′ = unique→id {P′} {P} {g} {f} P′→P′-unique

-- Exercise 2.2.3.
{- Show that product constructions are associative: for any objects A, B, C,
   A X (B X C) ≅ (A X B) X C -}

≅-assoc : {A B C : obC} →
          {BxC : B X C} → {Ax[BxC] : A X (_X_.obj BxC)} →
          {AxB : A X B} → {[AxB]xC : (_X_.obj AxB) X C} → _X_.obj Ax[BxC] ≅ _X_.obj [AxB]xC
≅-assoc {A}{B}{C} {BxC} {Ax[BxC]} {AxB} {[AxB]xC} =
  record { f = f
         ; g = g
         ; proof = record { invR = unique→id {_}{_} {g} {f} [AxB]xC→[AxB]xC-unique
                          ; invL = unique→id {_}{_} {f} {g} Ax[BxC]→Ax[BxC]-unique
                          }
         }
  where AxB-obj = _X_.obj AxB
        BxC-obj = _X_.obj BxC
        Ax[BxC]-obj = _X_.obj Ax[BxC]
        [AxB]xC-obj = _X_.obj [AxB]xC
        π₁-Ax[BxC] = _X_.π₁ Ax[BxC]
        π₂-Ax[BxC] = _X_.π₂ Ax[BxC]
        π₁-[AxB]xC = _X_.π₁ [AxB]xC
        π₂-[AxB]xC = _X_.π₂ [AxB]xC
        π₁-BxC = _X_.π₁ BxC
        π₂-BxC = _X_.π₂ BxC
        π₂-AxB = _X_.π₂ AxB
        f : morC Ax[BxC]-obj [AxB]xC-obj
        f = morC-unique_to_.m p2
          where k₁ : morC Ax[BxC]-obj C
                k₁ = π₂-BxC ∘ π₂-Ax[BxC]
                k₂ : morC Ax[BxC]-obj AxB-obj
                k₂ = morC-unique_to_.m p1
                  where p1 : morC-unique Ax[BxC]-obj to AxB-obj
                        p1 = proj₁ (_X_.proof AxB {Ax[BxC]-obj} {π₁-Ax[BxC]} {π₁-BxC ∘ π₂-Ax[BxC]})
                p2 : morC-unique Ax[BxC]-obj to [AxB]xC-obj
                p2 = proj₁ (_X_.proof [AxB]xC {Ax[BxC]-obj} {k₂} {k₁})
        g : morC [AxB]xC-obj Ax[BxC]-obj
        g = morC-unique_to_.m p2
          where k₁ : morC [AxB]xC-obj A
                k₁ = (_X_.π₁ AxB) ∘ (_X_.π₁ [AxB]xC)
                k₂ : morC [AxB]xC-obj BxC-obj
                k₂ = morC-unique_to_.m p1
                  where p1 : morC-unique [AxB]xC-obj to BxC-obj
                        p1 = proj₁ (_X_.proof BxC {[AxB]xC-obj} {π₂-AxB ∘ π₁-[AxB]xC} {π₂-[AxB]xC})
                p2 : morC-unique [AxB]xC-obj to Ax[BxC]-obj
                p2 = proj₁ (_X_.proof Ax[BxC] {[AxB]xC-obj} {k₁} {k₂})
        Ax[BxC]→Ax[BxC]-unique : morC-unique Ax[BxC]-obj to Ax[BxC]-obj
        Ax[BxC]→Ax[BxC]-unique = bproduct-unique-refl Ax[BxC]
        [AxB]xC→[AxB]xC-unique : morC-unique [AxB]xC-obj to [AxB]xC-obj
        [AxB]xC→[AxB]xC-unique = bproduct-unique-refl [AxB]xC

-- Theorem 2.2.4
-- For any object A, B, A X B ≅ B X A
≅-sym-bproduct : {A B : obC} → {AxB : A X B} → {BxA : B X A} → _X_.obj AxB ≅ _X_.obj BxA
≅-sym-bproduct {A}{B} {AxB} {BxA} =
  record { f = f
         ; g = g
         ; proof = record { invR = unique→id {_}{_} {g} {f} BxA→BxA-unique
                          ; invL = unique→id {_}{_} {f} {g} AxB→AxB-unique
                          }
         }
  where AxB-obj = _X_.obj AxB
        BxA-obj = _X_.obj BxA
        π₁-AxB = _X_.π₁ AxB
        π₂-AxB = _X_.π₂ AxB
        π₁-BxA = _X_.π₁ BxA
        π₂-BxA = _X_.π₂ BxA
        p1 : morC-unique AxB-obj to BxA-obj
        p1 = proj₁ (_X_.proof BxA {AxB-obj} {π₂-AxB} {π₁-AxB})
        f : morC AxB-obj BxA-obj
        f = morC-unique_to_.m p1
        p2 : morC-unique BxA-obj to AxB-obj
        p2 = proj₁ (_X_.proof AxB {BxA-obj} {π₂-BxA} {π₁-BxA})
        g : morC BxA-obj AxB-obj
        g = morC-unique_to_.m p2
        AxB→AxB-unique : morC-unique AxB-obj to AxB-obj
        AxB→AxB-unique = bproduct-unique-refl AxB
        BxA→BxA-unique : morC-unique BxA-obj to BxA-obj
        BxA→BxA-unique = bproduct-unique-refl BxA
-- π₁π₂
