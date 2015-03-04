/* This file is part of GNU cflow
   Copyright (C) 1997, 2005, 2007, 2010 Sergey Poznyakoff

   GNU cflow is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   GNU cflow is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with GNU cflow; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301 USA */

#include <cflow.h>
#include <parser.h>
#include <sys/stat.h>
#include <ctype.h>
#include <argcv.h>

#ifndef LOCAL_RC
# define LOCAL_RC ".cflowrc"
#endif

static void
expand_argcv(int *argc_ptr, char ***argv_ptr, int argc, char **argv)
{
     int i;
     
     *argv_ptr = xrealloc(*argv_ptr,
			  (*argc_ptr + argc + 1) * sizeof **argv_ptr);
     for (i = 0; i <= argc; i++)
	  (*argv_ptr)[*argc_ptr + i] = argv[i];
     *argc_ptr += argc;
}

/* Parse rc file
 */
void
parse_rc(int *argc_ptr, char ***argv_ptr, char *name)
{
     struct stat st;
     FILE *rcfile;
     int size;
     char *buf, *p;
     
     if (stat(name, &st))
	  return;
     buf = malloc(st.st_size+1);
     if (!buf) {
	  error(0, 0, _("not enough memory to process rc file"));
	  return;
     }
     rcfile = fopen(name, "r");
     if (!rcfile) {
	  error(0, errno, _("cannot open `%s'"), name);
	  return;
     }
     size = fread(buf, 1, st.st_size, rcfile);
     buf[size] = 0;
     fclose(rcfile);

     for (p = strtok(buf, "\n"); p; p = strtok(NULL, "\n")) {
	  int argc;
	  char **argv;
	  
	  argcv_get(p, "", "#", &argc, &argv);
	  expand_argcv(argc_ptr, argv_ptr, argc, argv);
	  free(argv);
     }
     free(buf);
}

/* Process the value of the environment variable CFLOW_OPTIONS
 * and of the rc file.
 * Split the value into words and add them between (*ARGV_PTR)[0] and
 * (*ARGV_PTR[1]) modifying *ARGC_PTR accordingly.
 * NOTE: Since sourcerc() is not meant to take all SH command line processing
 *       burden, only word splitting is performed and no kind of expansion
 *       takes place. 
 */
void
sourcerc(int *argc_ptr, char ***argv_ptr)
{
     char *env;
     int xargc = 1;
     char **xargv; 

     xargv = xmalloc(2*sizeof *xargv);
     xargv[0] = **argv_ptr;
     xargv[1] = NULL;
     
     env = getenv("CFLOW_OPTIONS");
     if (env) {
	  int argc;
	  char **argv;
	  
	  argcv_get(env, "", "#", &argc, &argv);
	  expand_argcv(&xargc, &xargv, argc, argv);
	  free(argv);
     }

     env = getenv("CFLOWRC");
     if (env) 
	  parse_rc(&xargc, &xargv, env);
     else {
	  char *home = getenv("HOME");
	  if (home) {
	       int len = strlen(home);
	       char *buf = malloc(len + sizeof(LOCAL_RC)
				  + (home[len-1] != '/') );
	       if (!buf)
		    return;
	       strcpy(buf, home);
	       if (home[len-1] != '/')
		    buf[len++] = '/';
	       strcpy(buf+len, LOCAL_RC);
	       parse_rc(&xargc, &xargv, buf);
	       free(buf);
	  }
     }
     
     if (xargc > 1) {
	  expand_argcv(&xargc, &xargv, *argc_ptr-1, *argv_ptr+1);
	  *argc_ptr = xargc;
	  *argv_ptr = xargv;
     }
}


	
