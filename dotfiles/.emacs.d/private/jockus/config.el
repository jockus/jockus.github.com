
(defun insert-diary-entry (day-offset)
  "Insert new org-mode diary entry at top off file, using day-offset as an offset to the current date."
  (interactive)
  (evil-goto-first-line)
  (evil-open-below 1)
  (insert (format-time-string "* %d/%m/%y:" (time-add (current-time) (days-to-time day-offset))))
  (evil-open-below 1)
  (insert "** ")
  (evil-insert 1))
