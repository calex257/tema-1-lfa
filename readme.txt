Calciu Alexandru 331CC

Timp de efectuare: ~6 ore

Dificultati intalnite:

- intelegerea particularitatilor cerintei din moment ce nu sunt
exprimate in clar, ci trebuie deduse comparand inputul cu
outputul.

- faptul ca pe windows newline se traduce in CRLF si nu doar LF
a dus la un bug destul de enervant de descoperit si rezolvat.

- documentatia destul de slaba a FLEX si faptul ca google search
ma ducea spre orice alt 'flex' decat analizorul lexical.

Implementare:

- din starea initiala atunci cand intalnesc un "@" inseamna ca am
descoperit un tag.
- urmeaza apoi sa ii determin tipul. pentru a lua in calcul toate
combinatiile de litere lowercase si uppercase pentru aceste reguli
am folosit structuri precum [Bb] concatenate.
- daca tipul este unul cunoscut, adaug in buffer textul corespunzator
si caut prima acolada
- dupa ce o gasesc intru in starea in care caut campuri.
- dupa ce gasesc un camp, adaug in buffer text corespunzand tipului
campului si apoi parsez valoarea
- am facut o stare generala pentru parsat valoarea numita GET_VALUE
si stari speciale pentru campurile author, year, title si pages.
- in GET_VALUE iau toate caracterele pana la "}" si excluzand comentariile
- in GET_PAGES iau tot continutul dar schimb "--" in "-"
- in GET_YEAR nu permit sa se regaseasca \n si de asemenea permit sa nu fie
prezente {} in jurul valorii pentru logica de la year
- in GET_TITLE iau tot continutul dar pun ghilimele inainte si dupa
- in GET_AUTHORS mai intai retin numele de familie intr-un buffer separat,
apoi adaug in buffer-ul principal toate prenumele, apoi adaug ce salvasem
in buffer anterior
- dupa ce ies din starea pentru extras continutul reintru in starea in care
caut urmatorul camp.
- in tot acest timp am un contor pentru acolade pentru a verifica nivelul de
imbricare care imi indica daca sunt sau nu intr-un tag
- in starea INVALID_TAG nu se intampla nimic, este o stare de eroare
cand nu este intalnit un tag dintre cele cunoscute.