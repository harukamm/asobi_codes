module internal where

open import Data.Nat
open import Data.Fin hiding (_<_)
open import Data.Vec
open import Data.Product
open import Data.Sum
open import Data.String
open import Data.Maybe.Base

open import Relation.Nullary using (¬_)
open import Data.Empty using (⊥ ; ⊥-elim)

open import Relation.Binary.PropositionalEquality
open ≡-Reasoning

record kvector {l} (A : Set l) : (Set l) where
  field
    k : ℕ
    vec : Vec A k

-- ========================================
--   Lemma
-- ========================================
-- Get k from kvector-type
get-k : ∀{l} {A : Set l} -> (kvec : kvector A) -> ℕ
get-k kvec = kvector.k kvec

-- Get vector from kvector-type
get-vec : ∀{l} {A : Set l} -> (kvec : kvector A) -> Vec A (kvector.k kvec)
get-vec kvec = kvector.vec kvec

-- Remove nth from vector-type
remove-nth : ∀{a n} {A : Set a} → Fin (suc n) → Vec A (suc n) → Vec A n
remove-nth zero    (x ∷ xs) = xs
remove-nth {n = zero} (suc ())
remove-nth {n = suc m} (suc n) (x ∷ xs) = x ∷ (remove-nth {n = m} n xs)

-- Delete j-th from kvector-type
delete-j : ∀{l} {A : Set l} -> (kvec : kvector A) -> (j : Fin (kvector.k kvec)) -> kvector A
delete-j (record {k = zero; vec = vec}) ()
delete-j (record {k = suc k; vec = vec}) j =
                 record { k = k
                        ; vec = remove-nth j vec
                        }

contra : ∀{l}{P R : Set l} -> P -> ¬ P -> R
contra p ¬p = ⊥-elim (¬p p)

suc≢zero : {n : ℕ} -> {a : Fin n} -> Data.Fin.suc a ≢ zero
suc≢zero ()

sym≢ : {A : Set}{x y : A} -> x ≢ y -> y ≢ x
sym≢ neq eq = neq (sym eq)

≡-suc : {n : ℕ} -> {c d : Fin n} -> c ≡ d -> Data.Fin.suc c ≡ suc d
≡-suc {c = c} {d = d} eq = begin
          suc c
         ≡⟨ cong (λ x → suc x) eq ⟩
          suc d
         ∎

suc-≡ : {n : ℕ} -> {c d : Fin n} -> Data.Fin.suc c ≡ suc d -> c ≡ d --pred
suc-≡ refl = refl

suc-≢ : {n : ℕ} -> {a b : Fin n} -> Data.Fin.suc a ≢ suc b -> a ≢ b
suc-≢ neq p = contra (≡-suc p) neq

≢-suc : {n : ℕ} -> {a b : Fin n} -> a ≢ b -> Data.Fin.suc a ≢ suc b
≢-suc neq p = contra (suc-≡ p) neq

removed-jth-pf : ∀{l} {A : Set l} -> (x : kvector A) -> (j : Fin (kvector.k x)) ->
                 get-k x ≡ suc (get-k (delete-j x j))
removed-jth-pf (record {k = zero; vec = vec}) ()
removed-jth-pf (record {k = suc k; vec = vec}) j = refl

-- **** vector equality *****************
vec-eq : ∀{l}{A : Set l} -> {a b : A} -> {n : ℕ} -> {l1 l2 : Vec A n} ->
       (a ≡ b) -> (l1 ≡ l2) -> (a ∷ l1 ≡ b ∷ l2)
vec-eq {_}{_} {a}{b} {_} {l1} {l2} eq1 eq2 = begin
         a ∷ l1
       ≡⟨ cong (λ x -> a ∷ x) eq2 ⟩
         a ∷ l2
       ≡⟨ cong (λ x -> x ∷ l2) eq1 ⟩
         b ∷ l2
       ∎

-- Any nth element of list1 and list2 are equal, then list1 ≡ list2
vec-eq-main : ∀{l}{A : Set l} -> {n : ℕ} -> {l1 l2 : Vec A n} ->
              ((m : Fin n) -> lookup m l1 ≡ lookup m l2) -> l1 ≡ l2
vec-eq-main {n = zero} {l1 = []} {l2 = []} fun = refl
vec-eq-main {n = suc n} {l1 = x ∷ xs} {l2 = y ∷ ys} fun = vec-eq (fun zero) xs≡ys
  where fun2 : (a : Fin n) -> lookup a xs ≡ lookup a ys
        fun2 a = begin
             lookup a xs
            ≡⟨ sym p1 ⟩
             lookup (suc a) (x ∷ xs)
            ≡⟨ p3 ⟩
             lookup (suc a) (y ∷ ys)
            ≡⟨ p2 ⟩
             lookup a ys
            ∎
          where p1 : lookup (suc a) (x ∷ xs) ≡ lookup a xs
                p1 = refl
                p2 : lookup (suc a) (y ∷ ys) ≡ lookup a ys
                p2 = refl
                p3 : lookup (suc a) (x ∷ xs) ≡ lookup (suc a) (y ∷ ys)
                p3 = fun (suc a)
        xs≡ys : xs ≡ ys
        xs≡ys = vec-eq-main {n = n} {l1 = xs} {l2 = ys} fun2
-- **************************************

-- Returns just if a ≡ b, nothing otherwise.
_≡f_ : {n : ℕ} -> (a b : Fin n) -> a ≡ b ⊎ a ≢ b
_≡f_ {zero} ()
_≡f_ zero zero = inj₁ refl
_≡f_ (suc a) zero = inj₂ (suc≢zero{a = a})
_≡f_ zero (suc b) = inj₂ (sym≢ (suc≢zero{a = b}))
_≡f_ (suc a) (suc b) with a ≡f b
... | inj₁ eq = inj₁ (≡-suc eq)
... | inj₂ neq = inj₂ (≢-suc neq)

≡-trans : ∀{l}{A : Set l} -> {x y z : A} -> x ≡ y -> y ≡ z -> x ≡ z
≡-trans {_}{_} {x} {y} {z} x≡y y≡z = begin
          x
        ≡⟨ x≡y ⟩
          y
        ≡⟨ y≡z ⟩
          z
        ∎

lenght-thm-n≢z : ∀{l} {A : Set l} -> {m : ℕ} -> (x : kvector A) -> (xs : Vec (kvector A) m) ->
                 (n : Fin (suc m)) -> (j : Fin (get-k x)) ->
                 (neq : n ≢ zero) ->
                 get-k (lookup n (x ∷ xs)) ≡ get-k (lookup n ((delete-j x j) ∷ xs))
lenght-thm-n≢z x xs zero j neq = contra refl neq
lenght-thm-n≢z {m = zero} x [] (suc ())
lenght-thm-n≢z {m = suc m} x (x′ ∷ xs) (suc n) j neq = refl

anyN≡ : ∀{l}{A : Set l} -> {m : ℕ} -> (lst y y′ : Vec (kvector A) m) ->
        {i : Fin m} -> {j : Fin (get-k (lookup i lst))} ->
        ((n : Fin m) ->
                 (n ≢ i -> lookup n y ≡ lookup n lst) ×
                   (n ≡ i -> lookup n y ≡ delete-j (lookup i lst) j)) ->
        ((n : Fin m) ->
                 (n ≢ i -> lookup n y′ ≡ lookup n lst) ×
                   (n ≡ i -> lookup n y′ ≡ delete-j (lookup i lst) j)) ->
        (n2 : Fin m) -> lookup n2 y ≡ lookup n2 y′
anyN≡ lst y y′ {i} {j} fun-y fun-y′ n2 with n2 ≡f i
... | inj₁ n2≡i = ≡-trans for-y (sym for-y′)
    where for-y : lookup n2 y ≡ delete-j (lookup i lst) j
          for-y = proj₂ (fun-y n2) n2≡i
          for-y′ : lookup n2 y′ ≡ delete-j (lookup i lst) j
          for-y′ = proj₂ (fun-y′ n2) n2≡i
... | inj₂ n2≢i = ≡-trans for-y (sym for-y′)
    where for-y : lookup n2 y ≡ lookup n2 lst
          for-y = proj₁ (fun-y n2) n2≢i
          for-y′ : lookup n2 y′ ≡ lookup n2 lst
          for-y′ = proj₁ (fun-y′ n2) n2≢i

fin-pred : {m : ℕ} → (n : Fin (suc m)) → n ≢ zero → Fin m
fin-pred {m} zero n≢zero = contra refl n≢zero
fin-pred {m} (suc n) n≢zero = n

suc-predn≡n : {m : ℕ} → {n : Fin (suc m)} → {n≢z : n ≢ zero} →
              suc (fin-pred n n≢z) ≡ n
suc-predn≡n {m}{zero}{n≢z} = contra refl n≢z
suc-predn≡n {m}{suc n}{n≢z} = refl

lookup-thm : {A : Set} → {m : ℕ} → {n : Fin (suc m)} → (x : A) → (xs : Vec A m) →
             (n≢z : n ≢ zero) → lookup n (x ∷ xs) ≡ lookup (fin-pred n n≢z) xs
lookup-thm {_}{m}{zero} x xs n≢z = contra refl n≢z
lookup-thm {_}{m}{suc n} x xs n≢z = refl

lookup-thm′ : {A : Set} → {m : ℕ} → {n : Fin m} → (x : A) → (xs : Vec A m) →
             lookup n xs ≡ lookup (suc n) (x ∷ xs)
lookup-thm′ {_}{m}{n} x xs = sym refl

-- ========================================
--   remove-lst2
-- ========================================
record removed-lst-pf {l m} (A : Set l) (lst : Vec (kvector A) m) (i : Fin m) (j : Fin (get-k (lookup i lst))) : (Set l) where
  field
    y : Vec (kvector A) m
    removed-pf : (n : Fin m) ->
                 (n ≢ i -> lookup n y ≡ lookup n lst) ×
                   (n ≡ i -> lookup n y ≡ delete-j (lookup i lst) j)
    length-pf : (n : Fin m) ->
                (n ≢ i -> get-k (lookup n y) ≡ get-k (lookup n lst)) ×
                   (n ≡ i -> suc (get-k (lookup n y)) ≡ get-k (lookup n lst))
    unique : (y′ : Vec (kvector A) m) ->
              ((n : Fin m) ->
                (n ≢ i -> lookup n y′ ≡ lookup n lst) ×
                 (n ≡ i -> lookup n y′ ≡ delete-j (lookup i lst) j)) ->
              ((n : Fin m) ->
                (n ≢ i -> get-k (lookup n y′) ≡ get-k (lookup n lst)) ×
                   (n ≡ i -> suc (get-k (lookup n y′)) ≡ get-k (lookup n lst))) ->
              y ≡ y′

remove-lst2 : {A : Set} -> {m : ℕ} -> (lst : Vec (kvector A) m) ->
              {i : Fin m} -> {j : Fin (get-k (lookup i lst))} -> removed-lst-pf A lst i j
remove-lst2 {A} {zero} [] {()}
remove-lst2 {A} {suc m′} (x ∷ xs) {zero} {j} =
  record { y = y
         ; removed-pf = fun1
         ; length-pf = fun2
         ; unique = fun3
         }
    where y : Vec (kvector A) (suc m′)
          y = (delete-j x j) ∷ xs
          fun1 : (n : Fin (suc m′)) ->
                 (n ≢ zero -> lookup n y ≡ lookup n (x ∷ xs)) ×
                 (n ≡ zero -> lookup n y ≡ delete-j (lookup zero (x ∷ xs)) j)
          fun1 n = (λ n≢z → begin
                 lookup n ((delete-j x j) ∷ xs)
                ≡⟨ lookup-thm (delete-j x j) xs n≢z ⟩
                 lookup (pred-n n≢z) xs
                ≡⟨ lookup-thm′ {m = m′} {n = pred-n n≢z} x xs ⟩
                 lookup (suc (pred-n n≢z)) (x ∷ xs)
                ≡⟨ cong (λ h → lookup h (x ∷ xs)) (suc-pred-n {n≢z}) ⟩
                 lookup n (x ∷ xs)
                ∎) , (λ n≡z → begin
                 lookup n ((delete-j x j) ∷ xs)
                ≡⟨ cong (λ h → lookup h ((delete-j x j) ∷ xs)) n≡z ⟩
                 lookup zero ((delete-j x j) ∷ xs)
                ≡⟨ refl ⟩
                 delete-j x j
                ∎)
                where pred-n : n ≢ zero → Fin m′
                      pred-n n≢z = fin-pred {m′} n n≢z
                      suc-pred-n : {n≢z : n ≢ zero} → suc (pred-n n≢z) ≡ n
                      suc-pred-n = suc-predn≡n
          fun2 : (n : Fin (suc m′)) ->
                 (n ≢ zero -> get-k (lookup n y) ≡ get-k (lookup n (x ∷ xs))) ×
                 (n ≡ zero -> suc (get-k (lookup n y)) ≡ get-k (lookup n (x ∷ xs)))
          fun2 n = (λ n≢z → begin
                get-k (lookup n y)
               {- lenght-thm-n≢z : ∀{l} {A : Set l} -> {m : ℕ} -> (x : kvector A) ->
                 (xs : Vec (kvector A) m) ->
                 (n : Fin (suc m)) -> (j : Fin (get-k x)) ->
                 (neq : n ≢ zero) ->
                 get-k (lookup n (x ∷ xs)) ≡ get-k (lookup n ((delete-j x j) ∷ xs)) -}
               ≡⟨ sym (lenght-thm-n≢z x xs n j n≢z) ⟩
                get-k (lookup n (x ∷ xs))
               ∎) , (λ n≡z → begin
                suc (get-k (lookup n y))
               ≡⟨ cong (λ h → suc (get-k (lookup h y))) n≡z ⟩
                suc (get-k (lookup zero y))
               ≡⟨ refl ⟩
                 suc (get-k (delete-j x j))
               {- removed-jth-pf : ∀{l} {A : Set l} ->
                 (x : kvector A) -> (j : Fin (kvector.k x)) ->
                 get-k x ≡ suc (get-k (delete-j x j)) -}
               ≡⟨ sym (removed-jth-pf x j) ⟩
                 get-k x
               ≡⟨ sym refl ⟩
                get-k (lookup zero (x ∷ xs))
               ≡⟨ cong (λ h → get-k (lookup h (x ∷ xs))) (sym n≡z) ⟩
                get-k (lookup n (x ∷ xs))
               ∎)
          fun3 : (y′ : Vec (kvector A) (suc m′)) ->
                 ((n : Fin (suc m′)) ->
                   (n ≢ zero -> lookup n y′ ≡ lookup n (x ∷ xs)) ×
                   (n ≡ zero -> lookup n y′ ≡ delete-j (lookup zero (x ∷ xs)) j)) ->
                 ((n : Fin (suc m′)) ->
                   (n ≢ zero -> get-k (lookup n y′) ≡ get-k (lookup n (x ∷ xs))) ×
                   (n ≡ zero -> suc (get-k (lookup n y′)) ≡ get-k (lookup n (x ∷ xs)))) ->
                 y ≡ y′
          fun3 y′ fun1′ fun2′ = vec-eq-main (anyN≡ (x ∷ xs) y y′ fun1 fun1′)
remove-lst2 {A} {suc m′} (x ∷ xs) {suc i} {j} =
  record { y = y
         ; removed-pf = fun1
         ; length-pf = fun2
         ; unique = fun3
         }
    where recur : removed-lst-pf A xs i j
          recur = remove-lst2 {A} {m′} xs {i} {j}
          recur-y : Vec (kvector A) m′
          recur-y = removed-lst-pf.y recur
          y : Vec (kvector A) (suc m′)
          y = x ∷ recur-y
          i′ : Fin (suc m′)
          i′ = suc i
          fun1′ : (n : Fin m′) ->
                   (n ≢ i -> lookup n recur-y ≡ lookup n xs) ×
                   (n ≡ i -> lookup n recur-y ≡ delete-j (lookup i xs) j)
          fun1′ = removed-lst-pf.removed-pf recur
          fun1 : (n : Fin (suc m′)) →
                   (n ≢ suc i → lookup n y ≡ lookup n (x ∷ xs)) ×
                   (n ≡ suc i → lookup n y ≡ delete-j (lookup (suc i) (x ∷ xs)) j)
          fun1 zero = (λ z≢suci → begin
              lookup zero y
             ≡⟨ refl ⟩
              x
             ≡⟨ sym refl ⟩
              lookup zero (x ∷ xs)
             ∎) , (λ z≡suci → contra z≡suci (sym≢ (suc≢zero {a = i})))
          fun1 (suc n) = (λ sucn≢suci → proj₁ (fun1′ n) (suc-≢ (sucn≢suci))) ,
                           (λ sucn≡suci → proj₂ (fun1′ n) (suc-≡ (sucn≡suci)))
          fun2′ : (n : Fin m′) →
                  (n ≢ i → get-k (lookup n recur-y) ≡ get-k (lookup n xs)) ×
                  (n ≡ i → suc (get-k (lookup n recur-y)) ≡ get-k (lookup n xs))
          fun2′ = removed-lst-pf.length-pf recur
          fun2 : (n : Fin (suc m′)) →
                 (n ≢ suc i → get-k (lookup n y) ≡ get-k (lookup n (x ∷ xs))) ×
                 (n ≡ suc i → suc (get-k (lookup n y)) ≡ get-k (lookup n (x ∷ xs)))
          fun2 zero = (λ z≢suci → refl) , (λ z≡suci → contra z≡suci (sym≢ (suc≢zero {a = i})))
          fun2 (suc n) = (λ sucn≢suci → proj₁ (fun2′ n) (suc-≢ (sucn≢suci))) ,
                            (λ sucn≡suci → proj₂ (fun2′ n) (suc-≡ (sucn≡suci)))
          fun3 : (y′ : Vec (kvector A) (suc m′)) →
                  ((n : Fin (suc m′)) →
                    (n ≢ suc i → lookup n y′ ≡ lookup n (x ∷ xs)) ×
                    (n ≡ suc i → lookup n y′ ≡ delete-j (lookup (suc i) (x ∷ xs)) j)) →
                  ((n : Fin (suc m′)) →
                    (n ≢ suc i → get-k (lookup n y′) ≡ get-k (lookup n (x ∷ xs))) ×
                    (n ≡ suc i → suc (get-k (lookup n y′)) ≡ get-k (lookup n (x ∷ xs)))) →
                  y ≡ y′
          fun3 y′ fun1-y′ fun2-y′ = vec-eq-main (anyN≡ (x ∷ xs) y y′ fun1 fun1-y′)

-- ========================================
--   Test
-- ========================================
len : ℕ
len = suc (suc (suc (zero)))

kv1 : kvector String
kv1 = record { k = suc (suc (suc (suc (suc zero))))
             ; vec = "a" ∷ "b" ∷ "c" ∷ "d" ∷ "e" ∷ []
             }

kv2 : kvector String
kv2 = record { k = suc (suc (suc (suc zero)))
             ; vec = "1" ∷ "2" ∷ "3" ∷ "4" ∷ []
             }

kv3 : kvector String
kv3 = record { k = suc (suc zero)
             ; vec = "m" ∷ "l" ∷ []
             }

t1 : Vec (kvector String) len
t1 = kv1 ∷ kv2 ∷ kv3 ∷ []

suc-suc-< : {m n : ℕ} -> (suc m) < (suc n) -> m < n
suc-suc-<{m}{n} (s≤s m≤n) = m≤n

make-fin : (m n : ℕ) -> m < n -> Fin n
make-fin zero zero ()
make-fin zero (suc n) p = zero
make-fin (suc m) zero ()
make-fin (suc m) (suc n) p = Data.Fin.suc (make-fin m n (suc-suc-<{m}{n} p))

Fin-< : {n : ℕ} -> (i : Fin n) -> (toℕ i) < n
Fin-< zero = s≤s z≤n
Fin-< (suc i) = s≤s (Fin-< i)

test-n0 : Fin len
test-n0 = make-fin 0 len (s≤s z≤n)

test-n1 : Fin len
test-n1 = make-fin 1 len (s≤s (s≤s z≤n))

test-n2 : Fin len
test-n2 = make-fin 2 len (s≤s (s≤s (s≤s z≤n)))

test-i : Fin len
test-i = make-fin 0 len (s≤s z≤n)

test-k : ℕ
test-k = get-k (lookup test-i t1) -- 5

j<k : 1 < 5
j<k = s≤s (s≤s (z≤n{3}))

test-j : Fin test-k
test-j = make-fin 1 test-k j<k

removed-t1 : removed-lst-pf String t1 test-i test-j
removed-t1 = remove-lst2 t1

t1-y : Vec (kvector String) len
t1-y = removed-lst-pf.y removed-t1

removed-t1-rmpf : (n : Fin len) →
                  (n ≢ test-i → lookup n t1-y ≡ lookup n t1) ×
                    (n ≡ test-i → lookup n t1-y ≡ delete-j (lookup test-i t1) test-j)
removed-t1-rmpf = removed-lst-pf.removed-pf removed-t1

removed-t1-lnpf : (n : Fin len) →
                  (n ≢ test-i → get-k (lookup n t1-y) ≡ get-k (lookup n t1)) ×
                    (n ≡ test-i → suc (get-k (lookup n t1-y)) ≡ get-k (lookup n t1))
removed-t1-lnpf = removed-lst-pf.length-pf removed-t1

removed-t1-uni : (y′ : Vec (kvector String) len) →
                    ((n : Fin len) →
                     (n ≢ test-i → lookup n y′ ≡ lookup n t1) ×
                     (n ≡ test-i → lookup n y′ ≡ delete-j (lookup test-i t1) test-j)) →
                    ((n : Fin len) →
                     (n ≢ test-i → get-k (lookup n y′) ≡ get-k (lookup n t1)) ×
                     (n ≡ test-i → suc (get-k (lookup n y′)) ≡ get-k (lookup n t1))) →
                 t1-y ≡ y′
removed-t1-uni = removed-lst-pf.unique removed-t1

exp1 : lookup test-i t1-y ≡ delete-j (lookup test-i t1) test-j
exp1 = proj₂ (removed-t1-rmpf test-i) refl

exp2 : lookup test-n1 t1-y ≡ lookup test-n1 t1
exp2 = proj₁ (removed-t1-rmpf test-n1) n1≢i
       where n1≢i : test-n1 ≢ test-i
             n1≢i = suc≢zero


