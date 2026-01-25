;;; early-init.el --- Early init for Emacs 30 (daemon friendly) -*- lexical-binding: t; -*-

;; Speed up startup by raising GC thresholds during init.
(setq gc-cons-threshold (* 128 1024 1024)
      gc-cons-percentage 0.6)

;; Reduce file name handler overhead during startup.
(defvar cr--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist cr--file-name-handler-alist)
            (garbage-collect)))

;; Don’t let Emacs automatically enable packages before init.el runs
(setq package-enable-at-startup nil)

;; UI elements off as early as possible (reduces flicker in non-daemon and applies to frames).
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Prevent expensive frame resizing during startup.
(setq frame-inhibit-implied-resize t)

;; Slightly faster redisplay during startup
(setq inhibit-compacting-font-caches t)

;;; early-init.el ends here

