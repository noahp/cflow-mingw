/* This file is part of GNU cflow
   Copyright (C) 1997-2019 Sergey Poznyakoff

   GNU cflow is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   GNU cflow is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>. */

%top {
#include <cflow.h>
#include <ctype.h>
#include <parser.h>
}

%x comment
%x string
%x stringwait
%x longline
%{
     
struct obstack string_stk;

int line_num;
char *filename;
char *canonical_filename; 
YYSTYPE yylval;
unsigned input_file_count; /* Number of input files, processed by source() */
 
int ident();
void update_loc();
#define lex_error(msg) error_at_line(0, 0, filename, line_num, "%s", msg)

/* Keep the token returned at the previous call to yylex. This is used
   as a lexical tie-in to ensure that the next token after STRUCT is
   IDENTIFIER. See get_token and ident below. */
static int prev_token;

%}
FILENAME [^\n*?]*
ONUMBER (0[0-7]*)
HNUMBER (0[xX][0-9a-fA-F]*)
DNUMBER ([1-9][0-9]*)
DIGITS  [0-9][0-9]*
IDENT [a-zA-Z_][a-zA-Z0-9_]*
WS    [ \t\f\r]* 
%%
     /* comments */
"//".*\n                ++line_num;
"/*"			BEGIN(comment);
<comment>[^*\n]*	;
<comment>[^*\n]*\n	++line_num;
<comment>"*"+[^*/\n]*	;
<comment>"*"+[^*/\n]*\n	++line_num;
<comment>"*"+"/"	BEGIN(INITIAL); 
     /* Line directives */
^{WS}#{WS}line{WS}{DIGITS}.*\n |
^{WS}#{WS}{DIGITS}.*\n   { update_loc(); }
     /* skip any preproc */
^{WS}#.*\\\n             { BEGIN(longline); ++line_num; }
{WS}#.*\n                ++line_num;
<longline>.*\\\n         ++line_num; 
<longline>.*\n           { BEGIN(INITIAL); ++line_num; }
     /* keywords */
auto                 /* ignored */;
extern               return EXTERN; 
static               return STATIC;
typedef              return TYPEDEF;
struct               {yylval.str = "struct"; return STRUCT;}
union                {yylval.str = "union"; return STRUCT;}
enum                 {yylval.str = "enum"; return STRUCT;}
\*                   { yylval.str = "*";
		       return MODIFIER;
		   }
     /* Operators
      *
      */
"->"                 {yylval.str = "->"; return MEMBER_OF;}
"."                  {yylval.str = "."; return MEMBER_OF;}
"*="                 {yylval.str = "*="; return OP;}
"/="                 {yylval.str = "/="; return OP;}
"/"                  {yylval.str = "/"; return OP;}
"%="                 {yylval.str = "%="; return OP;}
"%"                  {yylval.str = "%"; return OP;}
"+="                 {yylval.str = "+="; return OP;}
"+"                  {yylval.str = "+"; return OP;}
"-="                 {yylval.str = "-="; return OP;}
"-"                  {yylval.str = "-"; return OP;}
"<<="                {yylval.str = "<<="; return OP;}
">>="                {yylval.str = ">>="; return OP;}
"&="                 {yylval.str = "&="; return OP;}
"|="                 {yylval.str = "|="; return OP;}
"^="                 {yylval.str = "^="; return OP;}
"^"                  {yylval.str = "^"; return OP;}
"||"                 {yylval.str = "||"; return OP;}
"|"                  {yylval.str = "|"; return OP;}
"&&"                 {yylval.str = "&&"; return OP;}
"&"                  {yylval.str = "&"; return OP;}
"=="                 {yylval.str = "=="; return OP;}
"="                  {yylval.str = "="; return '=';}
"!="                 {yylval.str = "!="; return OP;}
"!"                  {yylval.str = "!"; return OP;}
">="                 {yylval.str = ">="; return OP;}
">"                  {yylval.str = ">"; return OP;}
"<="                 {yylval.str = "<="; return OP;}
"<"                  {yylval.str = "<"; return OP;}    
"<<"                 {yylval.str = "<<"; return OP;}
">>"                 {yylval.str = ">>"; return OP;}
"++"                 {yylval.str = "++"; return OP;}
"--"                 {yylval.str = "--"; return OP;}
'.'  |
'\\.' |
'\\[0-7]{2,3}' |
'\\[xX][0-9a-fA-F]{1,2}'  return STRING;
     /* Identifiers and constants
      *
      */
"..." |
{IDENT}			return ident();
{ONUMBER}               { obstack_grow(&string_stk, yytext, yyleng+1);
			  yylval.str = obstack_finish(&string_stk);
			  return WORD;
		      }
[+\-]?{DNUMBER}[^eE.]   { yyless(yyleng-1);
			  obstack_grow(&string_stk, yytext, yyleng+1);
			  yylval.str = obstack_finish(&string_stk);
			  return WORD;}
{HNUMBER} |               
[+\-]?{DIGITS}?\.{DIGITS}([eE][+\-]?{DIGITS})? |
[+\-]?{DIGITS}\.([eE][+\-]?{DIGITS})? {
    obstack_grow(&string_stk, yytext, yyleng+1);
    yylval.str = obstack_finish(&string_stk);
    return WORD;
}

      /* strings 
      * State map:
      *
      * "<string>blahblahblah"<stringwait>
      * <stringwait>"<string>blahblahblah"<stringwait>
      * <stringwait>.<INITIAL>
      */
\"    BEGIN(string);
<string>[^\\"\n]*       ;
<string>\n              { ++line_num; lex_error(_("unterminated string?")); } 
<string>\\.             ;
<string>\\\n            ++line_num;
<string>\"              BEGIN(stringwait);
<stringwait>{WS}        ;
<stringwait>\n          ++line_num; 
<stringwait>\"          BEGIN(string);
<stringwait>.           {
     BEGIN(INITIAL);
     yyless(0); /* put the symbol back */
     return STRING;
}
\n                      ++line_num;
{WS}                    ;
       /*\f                      ;*/
^\{                     return LBRACE0;
^\}                     return RBRACE0;
.                       return yytext[0];
%%

static char *keywords[] = {
    "break",
    "case",
    "continue",
    "default",
    "do",
    "else",
    "for",
    "goto",
    "if",
    "return",
    "sizeof",
    "switch",
    "while"
};

static char *types[] = {
    "char",
    "double",
    "float",
    "int",
    "void",
};

static char *qualifiers[] = {
    "long",
    "const",
    "register",
    "restrict",
    "short",
    "signed",
    "unsigned",
    "volatile",
    "inline"
};

void
init_tokens()
{
     int i;
     Symbol *sp;
    
     for (i = 0; i < NUMITEMS(keywords); i++) {
	  sp = install(keywords[i], INSTALL_OVERWRITE);
	  sp->type = SymToken;
	  sp->token_type = WORD;
     }
     
     for (i = 0; i < NUMITEMS(types); i++) {
	  sp = install(types[i], INSTALL_OVERWRITE);
	  sp->type = SymToken;
	  sp->token_type = TYPE;
	  sp->source = NULL;
	  sp->def_line = -1;
	  sp->ref_line = NULL;
     }	

     for (i = 0; i < NUMITEMS(qualifiers); i++) {
	  sp = install(qualifiers[i], INSTALL_OVERWRITE);
	  sp->type = SymToken;
	  sp->token_type = QUALIFIER;
	  sp->source = NULL;
	  sp->def_line = -1;
	  sp->ref_line = NULL;
     }	
     sp = install("...", INSTALL_OVERWRITE);
     sp->type = SymToken;
     sp->token_type = IDENTIFIER;
     sp->source = NULL;
     sp->def_line = -1;
     sp->ref_line = NULL;
}	

void
init_lex(int debug_level)
{
     yy_flex_debug = debug_level;
     obstack_init(&string_stk);
     init_tokens();
}

int
ident()
{
     /* Do not attempt any symbol table lookup if the previous token was
	STRUCT.  This helps properly parse constructs like:

	  typedef struct foo foo;
	  struct foo {
	    int dummy;
	  };
     */
     if (prev_token != STRUCT) {
          Symbol *sp = lookup(yytext);
          if (sp && sp->type == SymToken) {
	       yylval.str = sp->name;
	       return sp->token_type;
          }
     }
     obstack_grow(&string_stk, yytext, yyleng);
     obstack_1grow(&string_stk, 0);
     yylval.str = obstack_finish(&string_stk);
     return IDENTIFIER;
}



char *pp_bin;
char *pp_opts;
static struct obstack *opt_stack;

void
set_preprocessor(const char *arg)
{
     pp_bin = arg ? xstrdup(arg) : NULL;
}

void
pp_option(const char *arg)
{
     if (!opt_stack) {
	  if (!pp_bin)
	       pp_bin = CFLOW_PREPROC;
	  opt_stack = xmalloc(sizeof *opt_stack);
	  obstack_init(opt_stack);
     }
     obstack_1grow(opt_stack, ' ');
     obstack_grow(opt_stack, arg, strlen (arg));
}

void
pp_finalize()
{
     char *s = obstack_finish(opt_stack);
     if (!pp_opts)
	  pp_opts = xstrdup(s);
     else {
	  pp_opts = xrealloc(pp_opts, strlen(pp_opts) + strlen(s) + 1);
	  strcat(pp_opts, s);
     }
     obstack_free(opt_stack, s);
     free(opt_stack);
     opt_stack = NULL;
}

FILE *
pp_open(const char *name)
{
     FILE *fp;
     char *s;
     size_t size;
     
     if (opt_stack)
	  pp_finalize();
     size = strlen(pp_bin) + 1 + strlen(name) + 1;
     if (pp_opts)
	  size += strlen(pp_opts);
     s = xmalloc(size);
     strcpy(s, pp_bin);
     if (pp_opts)
	  strcat(s, pp_opts);
     strcat(s, " ");
     strcat(s, name);
     if (debug)
	  fprintf(stderr, _("Command line: %s\n"), s);
     fp = popen(s, "r");
     if (!fp)
	  error(0, errno, _("cannot execute `%s'"), s);
     free(s);
     return fp;
}

void
pp_close(FILE *fp)
{
     pclose(fp);
}



int
yywrap()
{
     if (!yyin)
	  return 1;
     if (preprocess_option)
	  pp_close(yyin);
     else
	  fclose(yyin);
     yyin = NULL;
#ifdef FLEX_SCANNER
     yy_delete_buffer(YY_CURRENT_BUFFER);
#endif
     delete_statics();
     return 1;
}

static int hit_eof;

int
get_token()
{
     int tok;

     if (hit_eof)
          tok = 0;
     else {
          tok = yylex();
          prev_token = tok;
          if (!tok)
               hit_eof = 1;
     }
     return tok;
}

int
source(char *name)
{
     FILE *fp;

     fp = fopen(name, "r");
     if (!fp) {
	  error(0, errno, _("cannot open `%s'"), name);
	  return 1;
     }
     if (preprocess_option) {
	  fclose(fp);
	  fp = pp_open(name);
	  if (!fp)
	       return 1;
     }
     obstack_grow(&string_stk, name, strlen(name)+1);
     filename = obstack_finish(&string_stk);
     canonical_filename = filename;
     line_num = 1;
     input_file_count++;
     hit_eof = 0;

     yyrestart(fp);
     return 0;
}

static int
getnum(unsigned  base, int  count)
{
     int  c, n;
     unsigned i;

     for (n = 0; count; count--) {
	  if (isdigit(c = input()))
	       i = c - '0';
	  else
	       i = toupper(c) - 'A' + 10;
	  if (i > base) {
	       unput(c);
	       break;
	  }
	  n = n * base + i;
     }
     return n;
}

int
backslash()
{                                  
     int c;
     
     switch (c = input()) {                        
     case 'a':   return '\a';                  
     case 'b':   return '\b';                  
     case 'f':   return '\f';                  
     case 'n':   return '\n';                  
     case 'r':   return '\r';                  
     case 't':   return '\t';                  
     case 'x':   return getnum(16,2);          
     case '0':   return getnum(8,3);           
     }                                             
     return c;                                         
}                                                     

void
update_loc()
{
     char *p;
     
     for (p = strchr(yytext, '#')+1; *p && isspace(*p); p++)
	  ;
     if (p[0] == 'l') /* line */
	  p += 4;

     line_num = strtoul(p, &p, 10);
     for ( ; *p && isspace(*p); p++)
	  ;
     if (p[0] == '"') {
	  int n;
	  
	  for (p++, n = 0; p[n] && p[n] != '"'; n++)
	       ;
	  obstack_grow(&string_stk, p, n);
	  obstack_1grow(&string_stk, 0);
	  filename = obstack_finish(&string_stk);
     }
     if (debug > 1)
	  fprintf(stderr, _("New location: %s:%d\n"), filename, line_num);
}
          
