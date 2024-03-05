/* Calciu Alexandru 331CC */
%{
    #include <stdio.h>
    int brace_counter = 0;
    char family_name[50];
    int buffer_size = 1000;
    char* buffer;
    void append_to_buffer(char *to_append) {
        if (strlen(buffer) + strlen(to_append) > buffer_size) {
            buffer_size *= 2;
            buffer = realloc(buffer, buffer_size);
        }
        strcat(buffer, to_append);
    }
%}
%option noyywrap
%option stack

%s COMMENT
%s TAG
%s INVALID_TAG
%s LOOK_FOR_BRACE
%s INSIDE_TAG
%s GET_VALUE
%s GET_TITLE
%s GET_AUTHORS
%s GET_YEAR
%s GET_PAGES_BEGIN
%s GET_PAGES_LINES
%s GET_PAGES_END
%s SEPARATOR
%s MOVE_ON
%s BIRTH_NAME

numar ([0-9]+)(.[0-9]+)?

%%

 /* regula pentru comentarii, accesibila din toate starile */
 /* se pune pe stiva starea comment, retinandu-se sub ea starea precedenta */
"\%" {
    yy_push_state(COMMENT);
}

<INITIAL>"@" {
    BEGIN(TAG);
}

<COMMENT>.*|\n {
    yy_pop_state();
}

 /* Am folosit aceste reguli scrise in felul acesta pentru a */
 /* acoperi toate combinatiile posibile de litere mari si litere mici */
 /* Dupa fiecare tag intru in starea in care caut acolada deschisa '{' */
 /* care marcheaza inceputul continutului tagului */
<TAG>[Bb][Oo][Oo][Kk] {
    brace_counter = 0;
    append_to_buffer("Carte:\n");
    BEGIN(LOOK_FOR_BRACE);
}

<TAG>[Aa][Rr][Tt][Ii][Cc][Ll][Ee] { 
    brace_counter = 0;
    append_to_buffer("Articol in revista:\n");
    BEGIN(LOOK_FOR_BRACE);
}

<TAG>[Ii][Nn][Pp][Rr][Oo][Cc][Ee][Ee][Dd][Ii][Nn][Gg][Ss] {
    brace_counter = 0;
    append_to_buffer("Articol prezentat la conferinta:\n");
    BEGIN(LOOK_FOR_BRACE);
}

 /* starea in care am gasit o acolada si incep logica */
 /* pentru continutul unui tag */
<LOOK_FOR_BRACE>\{ {
    BEGIN(INSIDE_TAG);
    brace_counter = 1;
}

<INSIDE_TAG>\{ {
    brace_counter++;
}

<INSIDE_TAG>\} {
    brace_counter--;
    if (brace_counter == 0) {
        BEGIN(INITIAL);
    }
}

 /* stari in care extrag date dintr-un anumit camp */
 /* comportamentul este asemanator in toate cazurile */
 /* cu diferente la author, title, year si pages */
 /* in toate aceste stari adaug in buffer-ul cu rezultatul echivalentul */
 /* in romana al numelui campului si apoi intru in starea in care */
 /* extrag valoarea efectiva a campului */
<INSIDE_TAG>"author"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tAutori: ");
    BEGIN(GET_AUTHORS);
}

<INSIDE_TAG>"title"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tTitlu: ");
    BEGIN(GET_TITLE);
}

<INSIDE_TAG>"journal"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tRevista: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"booktitle"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tConferinta: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"year"([ \t]*)=([ \t]*)\{? {
    append_to_buffer("\tAnul publicarii: ");
    BEGIN(GET_YEAR);
}

<INSIDE_TAG>"publisher"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tEditura: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"volume"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tVolum: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"number"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tNumar: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"pages"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tPagini: ");
    BEGIN(GET_PAGES_BEGIN);
}

<INSIDE_TAG>"doi"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tDigital Object Identifier: ");
    BEGIN(GET_VALUE);
}

<INSIDE_TAG>"organization"([ \t]*)=([ \t]*)\{ {
    append_to_buffer("\tOrganizatie: ");
    BEGIN(GET_VALUE);
}

 /* am pus spatiu in range pentru a permite nume de familie */
 /* formate din mai multe cuvinte */
<GET_AUTHORS>[A-Za-z'` -]+ {
    strncpy(family_name, yytext, 50);
    BEGIN(SEPARATOR);
}

<GET_AUTHORS>. {

}

 /* iau in calcul virgula dintre numele de familie si prenume */
 /* si sar peste ea */
<SEPARATOR>"," {
    BEGIN(BIRTH_NAME);
}

<SEPARATOR>. {
}

 /* semne care marcheaza faptul ca s-a terminat lista de prenume */
<BIRTH_NAME>(" and\n"|"\tand\n"|" and\r\n"|"\tand\r\n"|" and "|" and\t"|"\tand "|"\tand\t")[ \t\r]* {
    append_to_buffer(family_name);
    append_to_buffer(", ");
    BEGIN(GET_AUTHORS);
}

 /* am presupus ca prenumele incep toate cu litera mare */
 /* pentru ca asa are sens */
 /* probabil nu strica nimic nici daca lasam fara litera mare la inceput */
<BIRTH_NAME>[A-Z][a-z'\.`-]* {
    append_to_buffer(yytext);
    append_to_buffer(" ");
}

 /* dupa ce am trecut prin toate prenumele, pun numele de familie */
 /* trec pe randul urmator si ma pregatesc sa citesc un nou tag */
<BIRTH_NAME>"},"|"}" {
    append_to_buffer(family_name);
    append_to_buffer("\n");
    BEGIN(INSIDE_TAG);
}

<BIRTH_NAME>. {

}

 /* singura diferenta intre GET_TITLE si GET_VALUE e ca aici pun */
 /* si ghilimele la inceput si la final */
<GET_TITLE>([^}%]|\n)+ {
    append_to_buffer("\"");
    append_to_buffer(yytext);
    append_to_buffer("\"");
    append_to_buffer("\n");
    BEGIN(MOVE_ON);
}

 /* am facut aceste stari intermediare pentru ca initial eu luam */
 /* continutul cu totul, fara sa imi dau seama ca in output e doar */
 /* o liniuta si nu doua */
<GET_PAGES_BEGIN>[1-9][0-9]* {
    append_to_buffer(yytext);
    BEGIN(GET_PAGES_LINES);
}

 /* transform din doua liniute in una singura */
<GET_PAGES_LINES>"--" {
    append_to_buffer("-");
    BEGIN(GET_PAGES_END);
}

<GET_PAGES_END>[1-9][0-9]* {
    append_to_buffer(yytext);
    append_to_buffer("\n");
    BEGIN(MOVE_ON);
}

 /* copiez tot continutul as is pana la o acolada inchisa sau un comentariu */
 /* sau iau tot numarul daca valoarea campului este un numar */
<GET_VALUE>([^}%]|\n)+|[0-9]+ {
    append_to_buffer(yytext);
    append_to_buffer("\n");
    BEGIN(MOVE_ON);
}

<GET_YEAR>([^},%])+|[0-9]+ {
    append_to_buffer(yytext);
    append_to_buffer("\n");
    BEGIN(MOVE_ON);
}

<GET_VALUE>. {

}

 /* trec la urmatorul field din tag in toate situatiile posibile */
<MOVE_ON>\}?[,]?[\n]? {
    BEGIN(INSIDE_TAG);
}

<MOVE_ON>. {
}

<LOOK_FOR_BRACE>[ \t]* {}

 /* pentru orice alt tag se trece intr-o stare de eroare */
 /* pentru taguri nerecunoscute */
<TAG>. {
    brace_counter = 0;
    BEGIN(INVALID_TAG);
}

 /* se navigheaza prin tag actualizandu-se nivelul de imbricare */
 /* pentru a sti cand se termina tagul */
<INVALID_TAG>\{ {brace_counter++;}

<INVALID_TAG>\} {
    brace_counter--;
    if (brace_counter == 0) {
        BEGIN(INITIAL);
    }
}

<INVALID_TAG>. {}

.|\n {}

%%

int main(int argc, char** argv) {
    if (argc > 2) {
        fprintf(stderr, "too many arguments\n");
        exit(1);
    }
    FILE* f = fopen(argv[1], "r");
    if (f == NULL) {
        fprintf(stderr, "no file found\n");
        exit(1);
    }
    yyin = f;
    buffer = (char*) malloc(buffer_size * sizeof(char));
    if (buffer == NULL) {
        fprintf(stderr, "get malloc'd\n");
        exit(1);
    }

    buffer[0] = 0;
    yylex();
    printf("%s", buffer);
    free(buffer);
}