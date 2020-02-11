;; This file is part of Imprimatur.
;; Copyright (C) 2006, 2007, 2010, 2011 Sergey Poznyakoff
;;
;; Imprimatur is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; Imprimatur is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Imprimatur.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file redefines texinfo-master-menu-list so that it takes into
;; account included files.

;; Known bugs: @menu without previous sectioning command will inherit 
;; documentation string from the previous menu. However, since such a
;; menu is illegal in a texinfo file, we can live with it.

(require 'texinfo)  
(require 'texnfo-upd)

(defun texinfo-master-menu-list-recursive (title)
  "Auxiliary function used by `texinfo-master-menu-list'."
  (save-excursion
    (let (master-menu-list)
      (while (re-search-forward "\\(^@menu\\|^@include\\)" nil t)
	(cond
	 ((string= (match-string 0) "@include")
	  (skip-chars-forward " \t")
	  (let ((included-name (let ((start (point)))
				 (end-of-line)
				 (skip-chars-backward " \t")
				 (buffer-substring start (point)))))
	    (end-of-line)
	    (let ((prev-title (texinfo-copy-menu-title)))
	      (save-excursion
		(set-buffer (find-file-noselect included-name))
		(setq master-menu-list
		      (append (texinfo-master-menu-list-recursive prev-title)
			      master-menu-list))))))
	 (t
	  (setq master-menu-list
		(cons (list
		       (texinfo-copy-menu)
		       (let ((menu-title (texinfo-copy-menu-title)))
			 (if (string= menu-title "")
			     title
			   menu-title)))
		      master-menu-list)))))
      master-menu-list)))

(defun texinfo-master-menu-list ()
  "Return a list of menu entries and header lines for the master menu,
recursing into included files.

Start with the menu for chapters and indices and then find each
following menu and the title of the node preceding that menu.

The master menu list has this form:

    \(\(\(... \"entry-1-2\"  \"entry-1\"\) \"title-1\"\)
      \(\(... \"entry-2-2\"  \"entry-2-1\"\) \"title-2\"\)
      ...\)

However, there does not need to be a title field."

  (reverse (texinfo-master-menu-list-recursive "")))

(defun make-master-menu ()
  "Create master menu in the first Emacs argument."
  (find-file (car command-line-args-left))
  (texinfo-master-menu nil)
  (save-buffer))


;;; mastermenu.el ends here
