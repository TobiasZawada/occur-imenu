;;; occur-imenu.el --- Display imenu as occur buffer  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Tobias Zawada

;; Author: Tobias Zawada <i@tn-home.de>
;; Keywords: tools, matching, matching

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;;; Installation:
;; Put occur-imenu.el into your load path and add
;; (autoload 'occur-imenu "occur-imenu")
;; in your init file.
;;;; Usage
;; Call M-x occur-imenu in any buffer with Imenu support.

;;; Code:

(require 'font-lock)
(require 'imenu)
(require 'replace)

(defun occur-imenu-item-string (item buf)
  "Return occur line representation of imenu ITEM in BUF."
  (with-current-buffer buf
    (let* ((item-name (car item))
	   (fun (and (listp (cdr item)) (functionp (nth 2 item)) (nth 2 item)))
	   (pos (save-excursion
		  (funcall (or fun imenu-default-goto-function)
			   item-name
			   (cdr item))
		  (set-marker (make-marker) (point))))
	   (target-buffer (marker-buffer pos))
	   (target-line-number
	    (with-current-buffer target-buffer
	      (1+ (count-lines 1 pos))))
	   (target-line-str
	    (with-current-buffer target-buffer
	      (save-excursion
		(goto-char pos)
		(let ((b (line-beginning-position))
		      (e (line-end-position)))
		  (when font-lock-mode
		    (font-lock-ensure b e))
		(buffer-substring  b e)))))
	   (match-prefix (apply #'propertize (format "%7d:" target-line-number)
				`(occur-prefix t mouse-face (highlight)
					       front-sticky t
					       rear-nonsticky t
					       occur-target ,pos
					       follow-link t
					       read-only t
					       help-echo "mouse-2: go to this occurrence")))
	   (match-str (propertize
		       target-line-str
		       'mouse-face (list 'highlight)
		       'occur-target pos
		       'follow-link t
		       'help-echo "mouse-2: go to this occurrence")))
      (concat match-prefix match-str))))

(defun occur-imenu-print-index (item buf)
  "Insert imenu ITEM of BUF in current buffer."
  (cond
   ((stringp item)
    (insert (propertize item 'face '(:bold t))
	    "\n"))
   ((imenu--subalist-p item)
    (dolist (li item)
      (occur-imenu-print-index li buf)))
   ((and (consp item) ;; nested sub-alist
	 (stringp (car item))
	 (imenu--subalist-p (cdr item)))
    (insert (propertize (car item) 'face '(:bold t))
	    "\n")
    (occur-imenu-print-index (cdr item) buf))
   (t
    (insert (occur-imenu-item-string item buf) "\n"))))

(defun occur-imenu ()
  "Show imenu in an occur buffer."
  (interactive)
  (let* ((buf (current-buffer))
	 (buf-name (buffer-name buf))
	 (index (funcall imenu-create-index-function))
	 (occur-buf-name (format "*Occur Imenu <%s>*" buf-name))
	 (occur-buf (get-buffer occur-buf-name)))
    (when occur-buf
      (kill-buffer occur-buf))
    (with-current-buffer (get-buffer-create occur-buf-name)
      (insert (format "* Occur Imenu for buffer %s *"
		      (propertize
		       buf-name
		       'face 'link
		       'follow-link t
		       'keymap
		       (let ((m (make-sparse-keymap)))
			 (define-key m [mouse-2]
			   `(lambda ()
			      (interactive)
			      (and (buffer-live-p ,buf)
				   (switch-to-buffer-other-window ,buf))))
			 m))))
      (add-face-text-property (line-beginning-position) (line-end-position) list-matching-lines-buffer-name-face t)
      (insert "\n")
      (occur-imenu-print-index index buf)
      (occur-mode)
      (display-buffer (current-buffer)))))

(provide 'occur-imenu)
;;; occur-imenu.el ends here
