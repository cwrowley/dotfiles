;;; .emacs -- Clancy's .emacs file

;;; Commentary:
;;; Last modified 22 Oct 2022

;;; Code:

(message "Loading Clancy's .emacs file...")

;;;; ELPA packages
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)

;;;; Automatically change buffers if they are changed on disk
(global-auto-revert-mode t)

;;;; No startup screen
(setq inhibit-startup-screen t)

;;;; No scroll bars
(scroll-bar-mode -1)

;;;; Disable the tool bar
(tool-bar-mode -1)

;;;; Relative line numbers
(setq display-line-numbers-type 'relative)
;; (global-display-line-numbers-mode)
 
;;;; My custom info files are specified in INFOPATH
;; append the default ones here
(setq Info-additional-directory-list Info-default-directory-list)

;;;; Default major mode
(setq-default major-mode 'text-mode)

;;;; Turn on auto-fill for various modes
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;;;; Set path
(add-to-list 'exec-path "/Library/TeX/texbin")
(add-to-list 'exec-path "/usr/local/bin")
(setenv "PATH" (concat "/Library/TeX/texbin:/usr/local/bin:" (getenv "PATH")))

;;;; Set default fill column and window size
(setq-default fill-column 80)
(setq default-frame-alist
       '((top . 20) (left . 20)
         (width . 100) (height . 60)))

;;;; Functions

(defun replace-in-string (string regexp newtext)
  "Replace regular expression REGEXP with NEWTEXT in the given STRING."
  (let ((skip (length newtext))
	(start 0))
    (while (string-match regexp string start)
      (setq string (replace-match newtext t t string)
	    start (+ skip (match-beginning 0)))))
  string)

(defun insert-include-guard ()
  "Insert an #ifdef include guard in a C header file."
  (interactive)
  (goto-char 1)
  (let* ((inc-name (replace-in-string (buffer-name (current-buffer)) "\\." "_" ) )
	 (ftag (concat ""
		       (upcase inc-name )
		       "" ))
	 )
    (insert (concat "#ifndef " ftag))
    (newline)
    (insert (concat "#define " ftag))
    (newline)
    (newline)
    (goto-char (point-max))
    (insert "#endif")
    (newline)
    )
  )

(defun uncomment-line ()
  "Uncomment the current line."
  (interactive)
  (let (a b)
    (beginning-of-line)
    (setq a (point))
    (forward-line)
    (setq b (point))
    (uncomment-region a b)))

;;;; Macros

(fset 'date
   [?\C-u ?\M-! ?d ?a ?t ?e return ?\C-n])

;;;; Packages

(message "Loading packages...")
(eval-when-compile
  (require 'use-package))
(require 'delight)
(require 'bind-key)

(delight '((eldoc-mode nil "eldoc")))

(use-package bind-key
  :config
  (bind-key "<f9>" 'comment-line)
  (bind-key "<f10>" 'uncomment-line)
  (bind-key "<f12>" 'bury-buffer)
  (bind-key "s-d" 'date)
  (bind-key "C-c n" 'display-line-numbers-mode))

;; Download packages automatically if not installed
(require 'use-package-ensure)
(setq use-package-always-ensure t)
;; (setq use-package-verbose t)

(use-package evil
  :init
  (evil-mode 1)
  (setq evil-search-module 'evil-search))

(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;;; Projectile mode
(use-package projectile
  :delight '(:eval (concat " " (projectile-project-name)))
  :init
  (projectile-mode +1)
  :bind-keymap
  ("s-p" . projectile-command-map)
  :config
  (setq projectile-completion-system 'ivy))

(use-package ripgrep
  :defer t)

(use-package treemacs
  :bind ("<f7>" . treemacs))

(use-package treemacs-projectile
  :after (treemacs projectile))

;;;; Use xterm-color for eshell
(use-package xterm-color
  :hook (eshell-mode . (lambda ()
			 (setenv "TERM" "xterm-256color"))))

;;;; Conda configuration
(use-package conda
  ;; :disabled t
  :hook (eshell-mode . conda-env-initialize-eshell)
  :init
  (conda-env-initialize-interactive-shells)
  (conda-env-autoactivate-mode t)
  )

;;;; Ignore generated files
(setq completion-ignored-extensions
      (append completion-ignored-extensions
	     '(".fdb_latexmk" ".fls" ".log" ".out" ".pdf" ".synctex.gz")))

;;;; Git
(use-package magit
  :bind (("<f8>" . magit-status)
	 ("C-x M-g" . magit-dispatch)
	 ("C-c M-g" . magit-file-dispatch)))

;;;; Show Git changed lines in gutter
(use-package diff-hl
  :hook ((vc-dir-mode . turn-on-diff-hl-mode)
	 (magit-pre-refresh . diff-hl-magit-pre-refresh)
	 (magit-post-refresh . diff-hl-magit-post-refresh))
  :init
  (global-diff-hl-mode))

;;;; C stuff

(use-package cc-mode
  :bind (:map c-mode-map
	      ("<f5>" . compile)
	      ("C-c C-i" . insert-include-guard))
  :pin manual)

(use-package google-c-style
  :hook ((c-mode-common . google-set-c-style)
	 (c-mode-common . google-make-newline-indent)))

(use-package make-mode
  :bind (:map makefile-mode-map
	      ("<f5>" . compile)))

(use-package octave
  :mode ("\\.m\\'" . octave-mode))

;;;; Python development
(use-package elpy
  :disabled t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable)
  (setenv "WORKON_HOME" "~/miniconda3/")
  :config
  (bind-key "M-." 'elpy-goto-definition))

(use-package python
  :bind (:map python-mode-map
	      ("<f11>" . numpydoc-generate)))

(use-package numpydoc
  :commands numpydoc-generate)

(use-package py-isort
    :hook (python-mode . py-isort-enable-on-save)
    :config
    (setq py-isort-options '("--line-length=88" "-m=3" "-tc" "-fgw=0" "-ca"))
    (add-hook 'before-save-hook 'py-isort-before-save))

;;; Github-Flavored Markdown
(use-package gfm-mode
  :ensure markdown-mode
  :mode "README\\.md\\'")

(use-package unfill
  :bind ([remap fill-paragraph] . unfill-toggle))

;;;; Package to show rule at fill column
(use-package fill-column-indicator
  :hook ((c-mode-common . fci-mode)
	 (python-mode . fci-mode))
  ;; :config
  ;; (setq fci-rule-color (face-attribute font-lock-comment-face :foreground))
  )

;; whitespace mode
(use-package whitespace
  :hook (c-mode-common LaTeX-mode org-mode python-mode)
  :delight
  :config
  (setq whitespace-style '(face trailing tabs empty tab-mark)))

;; Save backup files to specified directory
(setq make-backup-files t)
(setq version-control t)
(setq delete-old-versions t)
(setq backup-directory-alist (quote ((".*" . "~/.emacs_backups/"))))

;; Flycheck
(use-package flycheck
  :init (global-flycheck-mode)
  :config
  (setq-default flycheck-disabled-checkers '(python-pylint)))

;; Ivy
(use-package ivy
  :delight
  :bind (("C-s" . swiper)
	 ("C-c C-r" . ivy-resume))
  :demand
  :init
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) "))

(use-package counsel
  :delight
  :init
  (counsel-mode 1))

(use-package amx)

(use-package company
  :delight
  :defer t)

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (lisp-mode emacs-lisp-mode LaTeX-mode))

;; Spell checking on the fly
(use-package flyspell
  :hook ((text-mode . flyspell-mode)
	 (c-mode-common . flyspell-prog-mode)))

;;;; LaTeX
(use-package tex
  :ensure auctex
  :defer t
  :defines font-latex-fontify-script
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq TeX-view-program-list '(("open" "open %o")
				("Skim" "/Applications/Skim.app/Contents/SharedSupport/displayline %n %o %b")))
  (setq TeX-view-program-selection '((output-dvi "open")
				     (output-pdf "Skim")
				     (output-html "open")))
  (add-hook 'LaTeX-mode-hook 'visual-line-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
  ;; do not fontify subscripts and superscripts
  (setq font-latex-fontify-script nil))

(use-package latex
  :ensure auctex
  ;; This local keymap binding must be done here, not in 'tex'
  :bind (:map LaTeX-mode-map ("<f5>" . compile)))

;; RefTeX
(use-package reftex
  :hook (LaTeX-mode . turn-on-reftex)
  :config
  (setq reftex-plug-into-AUCTeX t)
  (setq reftex-use-external-file-finders t)
  (setq reftex-external-file-finders
	'(("tex" . "kpsewhich -format=.tex %f")
	  ("bib" . "kpsewhich -format=.bib %f")))
  (setq reftex-ref-macro-prompt nil)  ; do not prompt for ref/pageref
  ;; Define index macros
  (setq reftex-index-macros
	'(;("\\ii{*}" "idx" ?o "" nil t)
	  ("\\indexdefn{*}" "idx" ?d "" nil t)
	  ("\\defined{*}" "idx" ?D "" nil nil)
	  ("\\theoremname{*}" "idx" ?t "" nil nil)
	  index))
  (setq reftex-index-default-macro '(?i ""))
  (setq reftex-index-default-tag nil))

;;;; Org mode
(use-package org
  :defer t
  :bind (("C-c l" . org-store-link)
	 ("C-c d" . org-time-stamp-inactive))
  :config
  (add-to-list 'org-modules 'org-tempo t)
  (setq org-default-notes-file "~/Dropbox/todo.org")
  (setq org-special-ctrl-a/e 'reversed)
  (setq org-src-preserve-indentation t)
  (setq org-todo-keywords
	'((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d)" "CANCELLED(c)")
	  (sequence "PROJECT(p)" "|" "FINISHED(f)")))
  (setq org-todo-keyword-faces
	'(("STARTED" . org-code)
	  ("WAITING" . org-code)
	  ("MAYBE" . org-code)
	  ("CANCELLED" . org-done)
	  ("PROJECT" . org-table)
	  ("REVIEWER" . org-code))))


(use-package lsp-mode
  :delight " LSP"
  :hook (python-mode . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config
  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration))

;; optionally
(use-package lsp-ui :commands lsp-ui-mode)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
;; (use-package lsp-pyright
;;   :ensure t
;;   :hook (python-mode . (lambda ()
;;                           (require 'lsp-pyright)
;;                           (lsp-deferred))))  ; or lsp-deferred
;; optionally if you want to use debugger
;; (use-package dap-mode)
;; (use-package dap-LANGUAGE) to load the dap adapter for your language

;; optional if you want which-key integration
(use-package which-key
  :delight
  :config
  (which-key-mode))


;; (use-package atom-one-dark-theme
;;   :config
;;   (load-theme 'atom-one-dark t))


(use-package zenburn-theme
  :init
  ;; (set-face-attribute 'default nil :font "Menlo-12" :height 140)
  (setq zenburn-use-variable-pitch t)
  (setq zenburn-scale-org-headlines t)
  :config
  (load-theme 'zenburn t))

;;;; Set color-theme
;; (if (fboundp 'load-theme)
;;     (progn
;;       ;; (load-theme 'alect-black t))
;;       ;; (load-theme 'tango-2 t))
;;       ;; (load-theme 'tangotango t))
;;       ;; (load-theme 'monokai t))
;;       ;; (load-theme 'sanityinc-tomorrow-night t))
;;       (load-theme 'zenburn t))
;;       ;; (load-theme 'solarized-dark t))
;;       ;; (load-theme 'gruvbox t))
;;       ;; (load-theme 'doom-one t))
;;   )

;; from custom-face below
 ;; '(default ((t (:inherit nil :stipple nil :background nil :foreground nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 140 :width normal :foundry "nil" :family "Menlo")))))

(use-package calc
  :defer t
  :init
  (setq calc-gnuplot-default-device "qt"))

(use-package ledger-mode
  :mode "\\.ledger\\'")

;; Start server for emacsclient
(server-start)

(message "...done loading Clancy's .emacs file")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#ad7fa8" "#8cc4ff" "#eeeeec"])
 '(custom-safe-themes
   '("171d1ae90e46978eb9c342be6658d937a83aaa45997b1d7af7657546cae5985b" "2dc03dfb67fbcb7d9c487522c29b7582da20766c9998aaad5e5b63b5c27eec3f" "78e6be576f4a526d212d5f9a8798e5706990216e9be10174e3f3b015b8662e27" "251ed7ecd97af314cd77b07359a09da12dcd97be35e3ab761d4a92d8d8cf9a71" "9dae95cdbed1505d45322ef8b5aa90ccb6cb59e0ff26fef0b8f411dfc416c552" "e24180589c0267df991cf54bf1a795c07d00b24169206106624bb844292807b9" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" "4e262566c3d57706c70e403d440146a5440de056dfaeb3062f004da1711d83fc" "c3b79a6eed3dac3e86f48d06f61c3fd1c7d73b647af0ddaf36a673c006f1a8eb" "e9a1226ffed627ec58294d77c62aa9561ec5f42309a1f7a2423c6227e34e3581" "761d44dc06b3c8fff771435fd771b170d1bbdd71348b6aaaa6c0d0270d56cb70" "7153b82e50b6f7452b4519097f880d968a6eaf6f6ef38cc45a144958e553fbc6" "04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "1e7e097ec8cb1f8c3a912d7e1e0331caeed49fef6cff220be63bd2a6ba4cc365" "18689e38e302846fc9e73c5935967528ad46d02a888b3f0a0116b3170f8c2142" "6f3e319164e19b8b692a5281a5c2485439302a527b222335f7bd7393b6943d49" "cc680a1e9f103cbe1efa6a3ba8710522f216d9a5606646451e901630c5984fe0" "b49e817e49812fac2248f358e8c18e94f8f88eabd055e5100930352f0f4bdc65" "50dbbf7a2a6069d6463e797382050fbdabdd47e9169f951543422716ffdce057" "4f170b8e697c0533404028f5279623d34b042523726db87f62ce8000e76b3324" "ff7b6ba2f00a9c0fc65cec9884160f5d4216f94f4db836546d3e5bd783f5e0e6" "4e6314939c32ecb2d856393c921c6be7b9c4e9c7547461b348ba199b84fc3bfd" "fc5fcb6f1f1c1bc01305694c59a1a861b008c534cae8d0e48e4d5e81ad718bc6" "67c2e3da7c9bb6419e631bdc22b718b737368fa45c190226bf5a5fa0d1d09444" "f78a255d73e20d9035554da59fb8bccba52bd7d522c38ba51926ea326661ba52" "d65d132909469ed546955d257dc0342df308857db51ac3f4aa976ff844d537be" "82e6e074742708b2e419c654bd4ddaf17899645808f6cafc3e5efc20d2db9dac" "1c77a0c2ef16184bab3ab173a6c46eec3a988f158abacca8788f18eda3196651" "9ef65957aaad5e655b99d7896fae3a2aaaca3037de5ea884a31238575c3890ad" "3d8f2538ba1814f1b8c3ca042ad80ba7c7e0c13b40c190624abd15f15aeb60a3" "ff778a9b596eba86c62e43bcbc30bcc996c661d94a04558aa2777bb78d6a49bc" "d815ac6bf4aa093f8a3a31fd3ae3255caa2da57d66f9c224b49aac9d057363b8" default))
 '(ledger-reports
   '(("bal inc exp" "ledger ")
     ("bal" "%(binary) -f %(ledger-file) bal")
     ("reg" "%(binary) -f %(ledger-file) reg")
     ("payee" "%(binary) -f %(ledger-file) reg @%(payee)")
     ("account" "%(binary) -f %(ledger-file) reg %(account)")))
 '(org-agenda-files
   '("~/Dropbox/Shared/Financial/Statements/Citibank/fraud-2022-06.org" "/Users/clancy/Dropbox/Jane estate/StoelRives/holdback.org" "/Users/clancy/Work/Teaching/MAE 501/MAE 501 F15/schedule.org" "/Users/clancy/Work/Recommendations/letters.org" "/Users/clancy/.org/todo.org" "/Users/clancy/Work/Reviews/reviews.org"))
 '(package-selected-packages
   '(evil cov neotree treemacs treemacs-projectile ripgrep company counsel-osx-app amx counsel yasnippet numpydoc unfill tangotango-theme flycheck google-c-style magit use-package xterm-color solarized-theme delight diminish gruvbox-theme monokai-theme diff-hl ledger-mode rg ag flx counsel-projectile counsel-world-clock elpy flycheck-pycheckers flycheck-pyflakes conda ivy projectile auctex git-gutter zenburn-theme doom-themes git-gutter-fringe rainbow-mode rainbow-delimiters markdown-mode leuven-theme fill-column-indicator cython-mode color-theme-sanityinc-tomorrow cdlatex))
 '(safe-local-variable-values '((reftex-label-alist (nil 101 nil "~\\ref{%s}" nil nil))))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
