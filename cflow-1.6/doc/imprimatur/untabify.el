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

;;;; Untabify the sources.
;;;; Usage: emacs -batch -l untabify.el [file ...]

(defun global-untabify (buflist)
  (mapcar
   (lambda (bufname)
     (set-buffer (find-file bufname))
     (untabify (point-min) (point-max))
     (save-buffer)
     (kill-buffer (current-buffer)))
   buflist))

(global-untabify command-line-args-left)
